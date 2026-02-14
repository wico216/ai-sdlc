---
name: sdlc:bolt
description: Run a Construction bolt — plan and execute a unit's work with gates
argument-hint: "<unit-id-or-number> [--skip-design-gate] [--plan-only] [--execute-only]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - TodoWrite
---

<objective>

Execute a Construction bolt for a specific unit. A Bolt is the smallest iteration in AI-SDLC — hours to days, not weeks.

**Flow:** Load unit → Design gate → Plan bolt → Execute bolt → Unit Complete gate (if all bolts done)

**Bolt = Plan + Execute for one unit.** This command orchestrates the full cycle:
1. Read the unit definition
2. Present/approve the design (Design Approved gate)
3. Create execution plans (spawn sdlc-planner)
4. Execute plans (spawn sdlc-executor)
5. Check if unit is complete (Unit Complete gate)
6. Append to audit trail

**Principles in play:**
- #1 Reimagine: Bolts are hours/days, not sprints
- #2 Reverse Conversation: AI proposes design, human approves
- #6 Proof over Prose: Unit Complete gate requires test evidence
- #7 Transition via Familiarity: Bolts feel like focused work sessions
- #9 Maximize Flow: Minimize ceremony, maximize building

</objective>

<execution_context>

@__SDLC_HOME__/references/principles.md
@__SDLC_HOME__/references/gates.md
@__SDLC_HOME__/references/ui-brand.md

</execution_context>

<context>
Unit: $ARGUMENTS (unit ID like "UNIT-001" or just number like "1")

**Flags:**
- `--skip-design-gate` — Skip the Design Approved gate (for subsequent bolts on same unit)
- `--plan-only` — Only create bolt plans, don't execute
- `--execute-only` — Execute existing plans (skip design gate and planning)

@.aidlc/STATE.md
</context>

<process>

## 0. Pre-Flight

```bash
ls .aidlc/units/ 2>/dev/null
```

**If no units directory:** Error — run `/sdlc:inception` first.

**Resolve unit:**

Parse $ARGUMENTS to find the target unit:
- If "UNIT-001" or "1": find `.aidlc/units/UNIT-001.md`
- If no argument: check STATE.md for current unit, or list available units

```bash
ls .aidlc/units/UNIT-*.md 2>/dev/null
```

**Load unit definition:**
Read the unit file. Extract: purpose, bounded context, acceptance criteria, dependencies, estimated bolts.

**Check dependencies:**
If the unit depends on other units, check if those are complete (check their status field). Warn if dependencies are incomplete.

**Resolve model profile:**
```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-planner | opus | opus | sonnet |
| sdlc-executor | opus | sonnet | sonnet |
| sdlc-plan-checker | sonnet | sonnet | haiku |

## 1. Design Gate (unless --skip-design-gate or --execute-only)

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► CONSTRUCTION: Design Review
 Unit: {UNIT-ID} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Check if design already exists:**
```bash
[ -f .aidlc/units/{UNIT-ID}-design.md ] && echo "DESIGN: exists" || echo "DESIGN: none"
```

**If no design exists, create one:**

Based on the unit definition, research (if exists), and codebase map (if exists), propose a design:

```
## Design: {Unit Name}

### Architecture
{How this unit fits into the overall system}

### Data Model
{Key entities and relationships}

### Interfaces
{What this unit exposes and consumes}

### Key Technical Decisions
{Decisions made for this unit}

### Implementation Approach
{How we'll build this in bolts}
```

Save to `.aidlc/units/{UNIT-ID}-design.md`.

**Present GATE: Design Approved:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Design Approved
 Unit: {UNIT-ID}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Evidence:
- [x] Design document exists → .aidlc/units/{UNIT-ID}-design.md
- [x] Architecture decisions documented
- [x] Interface contracts defined
- [x] No conflicts with other units
```

Use AskUserQuestion:
- header: "Design Gate"
- question: "Approve this design for {UNIT-ID}?"
- options:
  - "Approve design" — Proceed to planning
  - "Revise design" — Needs changes
  - "Skip gate" — I'll review later, proceed now

**If approved:** Audit entry `gate-approval`. Continue.
**If revise:** Ask what to change, iterate. Re-present gate.
**If skip:** Note in audit as `risk-accepted`. Continue.

## 2. Plan Bolt (unless --execute-only)

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► CONSTRUCTION: Planning Bolt
 Unit: {UNIT-ID} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Map unit to roadmap phase:**
Find which ROADMAP phase contains this unit's requirements. Use that phase for the plan-phase flow.

**Spawn sdlc-planner with unit context:**

The planner gets:
- Unit definition (acceptance criteria as success criteria)
- Unit design document
- Overall project context (PROJECT.md, REQUIREMENTS.md)
- Risk register entries relevant to this unit

```
Task(prompt="
First, read __CLAUDE_HOME__/agents/sdlc-planner.md for your role and instructions.

<planning_context>

**Project:** @.aidlc/PROJECT.md
**Requirements:** @.aidlc/REQUIREMENTS.md
**Unit:** @.aidlc/units/{UNIT-ID}.md
**Design:** @.aidlc/units/{UNIT-ID}-design.md (if exists)
**Risk Register:** @.aidlc/risk-register.md
**Config:** @.aidlc/config.json

</planning_context>

<instructions>
Create bolt plans for unit {UNIT-ID}.

Key constraints:
- Each plan should be 2-3 tasks MAX (small batches, Principle #1)
- Plans map to the unit's acceptance criteria
- Every plan must trace back to a REQ-ID
- Plans go in .aidlc/phases/{phase-dir}/

Success criteria = unit acceptance criteria.
</instructions>
", subagent_type="sdlc-planner", model="{planner_model}", description="Plan bolt for {UNIT-ID}")
```

**If --plan-only:** Stop here, show plans created.

## 3. Execute Bolt

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► CONSTRUCTION: Executing Bolt
 Unit: {UNIT-ID} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Use the same wave-based execution as /sdlc:execute-phase:**

Spawn sdlc-executor for each plan. Collect results.

After execution, update the audit trail:

```
### Entry #{N} — {timestamp}
- **Type:** decision
- **Actor:** AI-Agent
- **Phase:** Construction
- **Context:** Bolt execution for {UNIT-ID}
- **Decision:** {N} plans executed. {summary of what was built}
- **Evidence:** {SUMMARY.md paths}
- **Traces to:** {UNIT-ID}, {REQ-IDs}
```

## 4. Unit Complete Gate (automatic check)

After bolt execution, check if all acceptance criteria for the unit are met:

**Read unit acceptance criteria and check against execution summaries.**

If all criteria appear satisfied:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Unit Complete
 Unit: {UNIT-ID}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Evidence:
- [x] Acceptance criterion 1: {description} → {evidence}
- [x] Acceptance criterion 2: {description} → {evidence}
- [x] Tests passing → {test output or summary}
- [x] Code reviewed → {via bolt execution}
- [x] No regressions → {test output}
```

Use AskUserQuestion:
- header: "Unit Gate"
- question: "Unit {UNIT-ID} appears complete. Approve the Unit Complete gate?"
- options:
  - "Approve — unit done" — Mark unit complete
  - "Not yet" — More work needed, plan another bolt
  - "Verify first" — Run /sdlc:verify-work on this unit

**If approved:**
- Update unit status to `complete` in unit file
- Audit entry: `gate-approval` for UNIT COMPLETE
- Update STATE.md

**If not yet:**
- Identify remaining work
- Suggest: "Run `/sdlc:bolt {UNIT-ID} --skip-design-gate` for another bolt"

**If verify first:**
- Suggest: "Run `/sdlc:verify-work` then return to check gate"

If NOT all criteria met:
- Show which criteria are still pending
- Suggest another bolt

## 5. Completion Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► BOLT COMPLETE ✓
 Unit: {UNIT-ID} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Status:** {Complete / In Progress (N/M criteria met)}
**Plans executed:** {N}
**Audit entries added:** {N}

## ▶ Next

{If unit complete:}
/sdlc:bolt {next-UNIT-ID} — start next unit

{If more bolts needed:}
/sdlc:bolt {UNIT-ID} --skip-design-gate — continue this unit

{If all units complete:}
/sdlc:deploy — begin Operations phase

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<output>

- Bolt plans in `.aidlc/phases/{phase-dir}/`
- Execution summaries in `.aidlc/phases/{phase-dir}/`
- Design document at `.aidlc/units/{UNIT-ID}-design.md`
- Updated `.aidlc/audit.md`
- Updated `.aidlc/STATE.md`
- Updated unit status in `.aidlc/units/{UNIT-ID}.md`

</output>

<success_criteria>

- [ ] Unit loaded and dependencies checked
- [ ] Design Approved gate passed (or skipped with flag)
- [ ] Bolt plans created by sdlc-planner
- [ ] Plans executed by sdlc-executor
- [ ] Audit trail updated with bolt execution + gate results
- [ ] Unit Complete gate checked (auto or manual)
- [ ] STATE.md reflects current position
- [ ] User knows what to do next

**Proof over Prose:** Unit Complete gate requires evidence for EACH acceptance criterion.

</success_criteria>
