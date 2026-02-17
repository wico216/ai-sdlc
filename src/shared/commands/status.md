---
name: sdlc:status
description: Check project status — current phase, stage, active unit, gate statuses, progress, next action
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - SlashCommand
---

<objective>
Check project progress, summarize recent work and what's ahead, then intelligently route to the next action - either executing an existing plan or creating the next one.

Provides situational awareness before continuing work.
</objective>


<process>

<step name="verify">
**Verify planning structure exists and determine project phase:**

Use Bash (not Glob) to check—Glob respects .gitignore but .aidlc/ is often gitignored:

```bash
test -d .aidlc && echo "exists" || echo "missing"
```

If no `.aidlc/` directory:

```
No planning structure found.

Run __CMD_PREFIX__new-project to start a new project.
```

Exit.

If missing state.md: suggest `__CMD_PREFIX__new-project`.

**Decision tree for routing to next action:**

```bash
# Phase detection checks
test -f .aidlc/intent.md && echo "intent:yes" || echo "intent:no"
test -f .aidlc/inception/requirements.md && echo "requirements:yes" || echo "requirements:no"
test -d .aidlc/inception/units && echo "units:yes" || echo "units:no"
grep -q "INCEPTION EXIT" .aidlc/state.md 2>/dev/null && echo "inception_exit:yes" || echo "inception_exit:no"
test -f .aidlc/execution-plan.md && echo "exec_plan:yes" || echo "exec_plan:no"
ls .aidlc/construction/unit-*/bolt-*-plan.md 2>/dev/null | head -1 && echo "bolt_plans:yes" || echo "bolt_plans:no"
ls .aidlc/construction/unit-*/validation-report.md 2>/dev/null | head -1 && echo "validation:yes" || echo "validation:no"
ls .aidlc/operations/ 2>/dev/null | head -1 && echo "operations:yes" || echo "operations:no"
```

| Condition | Meaning | Action |
|-----------|---------|--------|
| No `.aidlc/` | No project | Suggest `__CMD_PREFIX__new-project` |
| Has `intent.md` but no `inception/requirements.md` | Inception incomplete | Suggest `__CMD_PREFIX__elaborate` |
| Has `inception/requirements.md` but no `inception/units/` | Units not decomposed | Suggest `__CMD_PREFIX__elaborate` |
| Has `inception/units/` but no INCEPTION EXIT gate | Inception not approved | Suggest `__CMD_PREFIX__approve-inception` |
| Has INCEPTION EXIT gate | Construction phase | Suggest `__CMD_PREFIX__plan-unit` for first unbuilt unit |
| Has bolt plans but no `validation-report.md` | Building/verifying | Suggest `__CMD_PREFIX__build-unit` or `__CMD_PREFIX__verify-unit` |
| Has UNIT COMPLETE for all units | All units done | Suggest `__CMD_PREFIX__operations` |
| Has operations artifacts | Release prep | Suggest `__CMD_PREFIX__approve-release` |
| Has `intent.md` but no `execution-plan.md` | Between releases (archived) | Go to **Route F** |

If missing both execution-plan.md and intent.md: suggest `__CMD_PREFIX__new-project`.

After determining the phase, continue to the **load** step to gather full context before presenting the status report and the routing suggestion.
</step>

<step name="load">
**Load full project context:**

- Read `.aidlc/state.md` for living memory (position, decisions, issues)
- Read `.aidlc/execution-plan.md` for unit structure and objectives
- Read `.aidlc/intent.md` for current state (What This Is, Core Value, Requirements)
- Read `.aidlc/config.json` for settings (model_profile, workflow toggles)
  </step>

<step name="recent">
**Gather recent work context:**

- Find the 2-3 most recent `bolt-*-summary.md` files in `.aidlc/construction/unit-*/`
- Extract from each: what was accomplished, key decisions, any issues logged
- This shows "what we've been working on"
  </step>

<step name="position">
**Parse current position:**

- From state.md: current unit, plan number, status
- Calculate: total plans, completed plans, remaining plans
- Note any blockers or concerns
- Check for CONTEXT.md: For units without `bolt-*-plan.md` files, check if `{unit}-CONTEXT.md` exists in unit directory
- Count pending todos: `ls .aidlc/todos/pending/*.md 2>/dev/null | wc -l`
- Check for active debug sessions: `ls .aidlc/debug/*.md 2>/dev/null | grep -v resolved | wc -l`
  </step>

<step name="report">
**Present rich status report:**

```
# [Project Name]

**Progress:** [████████░░] 8/10 plans complete
**Profile:** [quality/balanced/budget]

## Recent Work
- [Unit X, Plan Y]: [what was accomplished - 1 line]
- [Unit X, Plan Z]: [what was accomplished - 1 line]

## Current Position
Unit [N] of [total]: [unit-name]
Plan [M] of [unit-total]: [status]
CONTEXT: [✓ if CONTEXT.md exists | - if not]

## Key Decisions Made
- [decision 1 from STATE.md]
- [decision 2]

## Blockers/Concerns
- [any blockers or concerns from STATE.md]

## Pending Todos
- [count] pending — __CMD_PREFIX__check-todos to review

## Active Debug Sessions
- [count] active — __CMD_PREFIX__debug to continue
(Only show this section if count > 0)

## What's Next
[Next unit/plan objective from execution-plan]
```

</step>

<step name="route">
**Determine next action based on verified counts.**

If the decision tree from the verify step already identified a pre-construction phase (no inception exit, missing requirements, etc.), use that routing directly. Otherwise, for projects in the construction phase, continue with unit-level routing:

**Step 1: Count plans, summaries, and validation in current unit**

List files in the current unit directory:

```bash
ls -1 .aidlc/construction/unit-NNN/bolt-*-plan.md 2>/dev/null | wc -l
ls -1 .aidlc/construction/unit-NNN/bolt-*-summary.md 2>/dev/null | wc -l
[ -f .aidlc/construction/unit-NNN/validation-report.md ] && echo "1" || echo "0"
```

State: "This unit has {X} plans, {Y} summaries."

**Step 1.5: Check for unaddressed validation gaps**

Check for validation-report.md with status "diagnosed" (has gaps needing fixes).

```bash
# Check for diagnosed validation with gaps
grep -l "status: diagnosed" .aidlc/construction/unit-NNN/validation-report.md 2>/dev/null
```

Track:
- `validation_with_gaps`: validation-report.md with status "diagnosed" (gaps need fixing)

**Step 2: Route based on counts**

| Condition | Meaning | Action |
|-----------|---------|--------|
| validation_with_gaps > 0 | Validation gaps need fix plans | Go to **Route E** |
| summaries < plans | Unexecuted plans exist | Go to **Route A** |
| summaries = plans AND plans > 0 | Unit complete | Go to Step 3 |
| plans = 0 | Unit not yet planned | Go to **Route B** |

---

**Route A: Unexecuted plan exists**

Find the first bolt-plan.md without matching bolt-summary.md.
Read its `<objective>` section.

```
---

## ▶ Next Up

**{unit}-{plan}: [Plan Name]** — [objective summary from bolt-plan.md]

`__CMD_PREFIX__build-unit {unit}`

<sub>`/clear` first → fresh context window</sub>

---
```

---

**Route B: Unit needs planning**

Check if `{unit}-CONTEXT.md` exists in unit directory.

**If CONTEXT.md exists:**

```
---

## ▶ Next Up

**Unit {N}: {Name}** — {Goal from execution-plan.md}
<sub>✓ Context gathered, ready to plan</sub>

`__CMD_PREFIX__plan-unit {unit-number}`

<sub>`/clear` first → fresh context window</sub>

---
```

**If CONTEXT.md does NOT exist:**

```
---

## ▶ Next Up

**Unit {N}: {Name}** — {Goal from execution-plan.md}

`__CMD_PREFIX__elaborate {unit}` — gather context and clarify approach

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__plan-unit {unit}` — skip discussion, plan directly

---
```

---

**Route E: Validation gaps need fix plans**

validation-report.md exists with gaps (diagnosed issues). User needs to plan fixes.

```
---

## ⚠ Validation Gaps Found

**validation-report.md** has {N} gaps requiring fixes.

`__CMD_PREFIX__plan-unit {unit} --gaps`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__build-unit {unit}` — execute unit plans
- `__CMD_PREFIX__verify-unit {unit}` — run validation testing

---
```

---

**Step 3: Check release status (only when unit complete)**

Read execution-plan.md and identify:
1. Current unit number
2. All unit numbers in the current release section

Count total units and identify the highest unit number.

State: "Current unit is {X}. Release has {N} units (highest: {Y})."

**Route based on release status:**

| Condition | Meaning | Action |
|-----------|---------|--------|
| current unit < highest unit | More units remain | Go to **Route C** |
| current unit = highest unit | Release complete | Go to **Route D** |

---

**Route C: Unit complete, more units remain**

Read execution-plan.md to get the next unit's name and goal.

```
---

## ✓ Unit {Z} Complete

## ▶ Next Up

**Unit {Z+1}: {Name}** — {Goal from execution-plan.md}

`__CMD_PREFIX__elaborate {Z+1}` — gather context and clarify approach

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__plan-unit {Z+1}` — skip discussion, plan directly
- `__CMD_PREFIX__verify-unit {Z}` — user acceptance test before continuing

---
```

---

**Route D: Release complete**

```
---

## 🎉 Release Complete

All {N} units finished!

## ▶ Next Up

**Approve Release** — review and approve for release

`__CMD_PREFIX__approve-release`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__verify-unit` — user acceptance test before approving release

---
```

---

**Route F: Between releases (execution-plan.md missing, intent.md exists)**

A release was completed and archived. Ready to start the next release cycle.

Read state.md to find the last completed release version.

```
---

## ✓ Release v{X.Y} Complete

Ready to plan the next release.

## ▶ Next Up

**Start Next Release** — elaborate → requirements → execution-plan

`__CMD_PREFIX__elaborate`

<sub>`/clear` first → fresh context window</sub>

---
```

</step>

<step name="edge_cases">
**Handle edge cases:**

- Unit complete but next unit not planned → offer `__CMD_PREFIX__plan-unit [next]`
- All work complete → offer release approval
- Blockers present → highlight before offering to continue
- Handoff file exists → mention it, offer `__CMD_PREFIX__resume-work`
  </step>

</process>

<success_criteria>

- [ ] Rich context provided (recent work, decisions, issues)
- [ ] Current position clear with visual progress
- [ ] What's next clearly explained
- [ ] Smart routing: __CMD_PREFIX__build-unit if plans exist, __CMD_PREFIX__plan-unit if not
- [ ] User confirms before any action
- [ ] Seamless handoff to appropriate sdlc command
      </success_criteria>
