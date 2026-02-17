---
name: sdlc:resume-work
description: Resume work from previous session with full context restoration and stage-appropriate artifact loading
allowed-tools:
  - Read
  - Bash
  - Write
  - Glob
  - Grep
  - AskUserQuestion
  - SlashCommand
---

<objective>
Restore complete project context and resume work seamlessly from a previous session.

Detects the current phase and stage, loads all stage-appropriate artifacts, presents a clear resumption summary, and routes to the correct next action.

Handles:
- Phase detection (inception / construction / operations)
- Stage-specific artifact loading (mid-elaboration, mid-planning, mid-construction)
- Checkpoint detection (.continue-here files)
- Incomplete work detection (PLAN without SUMMARY)
- Corrupted or partial state recovery (per error-handling.md)
- Edge cases: no stages completed, mid-question-answer flow, partial artifact generation
</objective>

<execution_context>
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/error-handling.md
@__SDLC_REFS__/phases.md
@__SDLC_REFS__/content-validation.md
</execution_context>

<process>

## 1. Verify Project Exists

**MANDATORY FIRST STEP — Execute before any user interaction:**

```bash
test -d .aidlc && echo "AIDLC: exists" || echo "AIDLC: MISSING"
test -f .aidlc/state.md && echo "STATE: exists" || echo "STATE: MISSING"
test -f .aidlc/intent.md && echo "INTENT: exists" || echo "INTENT: MISSING"
test -f .aidlc/config.json && echo "CONFIG: exists" || echo "CONFIG: MISSING"
test -f .aidlc/execution-plan.md && echo "EXEC-PLAN: exists" || echo "EXEC-PLAN: MISSING"
```

**If .aidlc/ missing entirely:**
```
No AI-SDLC project found in this directory.

Run __CMD_PREFIX__new-project to start a new project.
```
Exit command.

**If .aidlc/ exists but intent.md missing:**
```
Project directory found but intent.md is missing.
This indicates a corrupted or incomplete project initialization.

Run __CMD_PREFIX__new-project to reinitialize.
```
Exit command.

## 2. Detect Phase and Stage

Load state.md and determine exactly where the project was when last paused.

```bash
# Read state for phase/stage detection
cat .aidlc/state.md 2>/dev/null

# Read config for workflow settings
cat .aidlc/config.json 2>/dev/null

# Detect inception artifacts
test -f .aidlc/inception/requirements.md && echo "REQUIREMENTS: exists" || echo "REQUIREMENTS: none"
test -d .aidlc/inception/units && echo "UNITS: exist ($(ls .aidlc/inception/units/*.md 2>/dev/null | wc -l) files)" || echo "UNITS: none"
test -f .aidlc/inception/user-stories.md && echo "STORIES: exists" || echo "STORIES: none"
test -f .aidlc/inception/application-design.md && echo "DESIGN: exists" || echo "DESIGN: none"
test -f .aidlc/inception/risk-register.md && echo "RISK-REG: exists" || echo "RISK-REG: none"

# Detect construction artifacts
ls .aidlc/construction/unit-*/bolt-*-plan.md 2>/dev/null | head -20
ls .aidlc/construction/unit-*/bolt-*-summary.md 2>/dev/null | head -20

# Detect construction stage artifacts (NFR, infrastructure)
ls .aidlc/construction/unit-*/nfr-requirements.md 2>/dev/null
ls .aidlc/construction/unit-*/nfr-design.md 2>/dev/null
ls .aidlc/construction/unit-*/infrastructure-design.md 2>/dev/null

# Detect operations artifacts
test -f .aidlc/operations/deployment-plan.md && echo "DEPLOY-PLAN: exists" || echo "DEPLOY-PLAN: none"
test -d .aidlc/operations/runbooks && echo "RUNBOOKS: exist" || echo "RUNBOOKS: none"
test -f .aidlc/operations/observability.md && echo "OBSERVABILITY: exists" || echo "OBSERVABILITY: none"

# Detect checkpoints and incomplete work
ls .aidlc/construction/*/.continue-here*.md 2>/dev/null
ls .aidlc/inception/questions/*.md 2>/dev/null

# Detect gate status
grep -i "inception exit" .aidlc/state.md 2>/dev/null
grep -i "production ready" .aidlc/state.md 2>/dev/null
```

**Determine phase from artifacts (trust artifacts over state.md per error-handling.md):**

| Condition | Phase | Stage |
|-----------|-------|-------|
| No inception artifacts (only intent.md + config) | Inception | Pre-elaboration |
| Inception questions exist without requirements | Inception | Mid-elaboration (questioning) |
| Requirements exist but no units | Inception | Mid-elaboration (design/planning) |
| Units exist but Inception Exit not passed | Inception | Ready for gate review |
| Inception Exit passed, no construction artifacts | Construction | Pre-planning |
| Bolt plans exist without summaries | Construction | Mid-execution |
| All bolt summaries exist, unit not approved | Construction | Ready for verification |
| All units complete, no operations artifacts | Operations | Pre-operations |
| Operations artifacts exist | Operations | Ready for release |

## 3. Load Stage-Appropriate Artifacts

Based on the detected phase and stage, load the relevant context. This follows the principle from AWS's session-continuity: **load previous stage artifacts before resuming**.

### Inception Phase — Loading

**Always load:**
- `.aidlc/intent.md` — The Golden Thread starting point
- `.aidlc/config.json` — Workflow preferences
- `.aidlc/state.md` — Living memory

**If mid-elaboration (requirements stage):**
- `.aidlc/inception/questions/*.md` — Any unanswered structured questions
- `.aidlc/inception/requirements.md` — Partial requirements (if exists)
- `.aidlc/audit.md` — Recent decisions

**If mid-elaboration (stories/design/plan stages):**
- `.aidlc/inception/requirements.md` — Completed requirements
- `.aidlc/inception/user-stories.md` — If exists
- `.aidlc/inception/application-design.md` — If exists
- `.aidlc/execution-plan.md` — If exists
- `.aidlc/inception/risk-register.md` — If exists
- `.aidlc/inception/units/UNIT-*.md` — If any exist

**If ready for gate review:**
- All inception artifacts above
- `.aidlc/audit.md` — Full decision trail for review

### Construction Phase — Loading

**Always load:**
- `.aidlc/intent.md`
- `.aidlc/state.md`
- `.aidlc/config.json`
- `.aidlc/execution-plan.md`
- `.aidlc/inception/requirements.md`

**Identify current unit** from state.md (Unit field) or most recently modified construction directory.

**For the current unit, load:**
- `.aidlc/inception/units/UNIT-NNN.md` — Unit specification
- `.aidlc/construction/unit-NNN/design.md` — Unit design (if exists)
- `.aidlc/construction/unit-NNN/research.md` — Research findings (if exists)
- `.aidlc/construction/unit-NNN/CONTEXT.md` — User decisions (if exists)
- `.aidlc/construction/unit-NNN/nfr-requirements.md` — NFR assessment (if exists)
- `.aidlc/construction/unit-NNN/nfr-design.md` — NFR design (if exists)
- `.aidlc/construction/unit-NNN/infrastructure-design.md` — Infrastructure design (if exists)
- `.aidlc/construction/unit-NNN/bolt-*-plan.md` — All bolt plans
- `.aidlc/construction/unit-NNN/bolt-*-summary.md` — Completed bolt summaries
- `.aidlc/construction/unit-NNN/.continue-here.md` — Checkpoint (if exists)

### Operations Phase — Loading

**Always load:**
- `.aidlc/intent.md`
- `.aidlc/state.md`
- `.aidlc/config.json`
- `.aidlc/execution-plan.md`

**Load operations artifacts:**
- `.aidlc/operations/deployment-plan.md` — If exists
- `.aidlc/operations/runbooks/*.md` — If any exist
- `.aidlc/operations/observability.md` — If exists
- `.aidlc/operations/cost.md` — If exists

## 4. Detect Edge Cases

Handle special situations before presenting status:

**Edge case: Project exists but no stages completed**
- Intent.md and config.json exist, but no elaboration has started
- Route: Suggest `__CMD_PREFIX__elaborate`

**Edge case: Mid-question-answer flow**
- Structured questions exist in `.aidlc/inception/questions/` without corresponding answers
- Flag: "Unanswered questions from previous session"
- Present the pending questions so user can continue

**Edge case: Partial artifact generation**
- A stage started writing an artifact but session ended before completion
- Detection: Check if artifact files are unusually short or contain template placeholders
- Route: Suggest re-running the stage that was interrupted

**Edge case: Corrupted or inconsistent state**
- state.md shows a stage complete but artifacts don't exist (or vice versa)
- Per error-handling.md: Trust artifacts over state.md
- Reconstruct state.md from actual artifacts on disk
- Log recovery in audit.md

**Edge case: Between releases**
- execution-plan.md missing but intent.md exists
- Previous release was completed and archived
- Route: Suggest `__CMD_PREFIX__elaborate` for next release

## 5. Present Resumption Summary

Display a clear, structured summary of where the project stands.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RESUMING SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Project Name}**

| Field              | Value                                    |
|--------------------|------------------------------------------|
| Phase              | {Inception / Construction / Operations}  |
| Current Stage      | {Stage name within phase}                |
| Last Completed     | {Last completed stage or action}         |
| Last Activity      | {Date — what happened}                   |
| Progress           | {[████████░░] XX%}                       |

**Loaded Context:**
- {List of artifacts loaded, grouped by phase}
- {e.g., "Intent, requirements, 3 unit specs, execution plan"}

{If incomplete work detected:}
**Pending Work:**
- {.continue-here checkpoint: unit-NNN, task X of Y}
- {OR: Incomplete bolt execution: bolt-03 in unit-001}
- {OR: Unanswered questions: N questions in inception/questions/}

{If blockers or concerns exist:}
**Carried Concerns:**
- {Blocker/concern from state.md}

{If state was reconstructed:}
**Note:** state.md was reconstructed from artifacts on disk.
See audit.md for recovery details.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 6. Route to Next Action

Based on the detected phase, stage, and any pending work, offer the appropriate next action.

**Routing priority (highest first):**

1. **Checkpoint exists** (.continue-here.md) — Resume from checkpoint
2. **Incomplete bolt execution** (plan without summary) — Continue execution
3. **Unanswered questions** — Present questions for user to answer
4. **Normal progression** — Offer the next logical command

**Routing table:**

| Phase | Stage | Primary Action | Command |
|-------|-------|----------------|---------|
| Inception | Pre-elaboration | Start elaboration | `__CMD_PREFIX__elaborate` |
| Inception | Mid-elaboration | Continue elaboration | `__CMD_PREFIX__elaborate --resume` |
| Inception | Ready for gate | Approve inception | `__CMD_PREFIX__approve-inception` |
| Construction | Pre-planning | Plan next unit | `__CMD_PREFIX__plan-unit {N}` |
| Construction | Mid-planning | Continue planning | `__CMD_PREFIX__plan-unit {N}` |
| Construction | Design ready | Approve design | `__CMD_PREFIX__approve-unit {N} --design` |
| Construction | Mid-execution | Continue building | `__CMD_PREFIX__build-unit {N}` |
| Construction | Ready for verify | Verify unit | `__CMD_PREFIX__verify-unit {N}` |
| Construction | Unit complete | Approve or next unit | `__CMD_PREFIX__approve-unit {N} --complete` |
| Construction | All units done | Start operations | `__CMD_PREFIX__operations` |
| Operations | Pre-operations | Run operations | `__CMD_PREFIX__operations` |
| Operations | Ready for release | Approve release | `__CMD_PREFIX__approve-release` |

Use AskUserQuestion to present options:
- header: "Resume"
- question: Based on the routing, present the primary recommended action and relevant alternatives
- options: Include 2-4 contextual options (primary action, review status, review artifacts, something else)

## 7. Update Session Continuity

Before routing to the chosen action, update state.md session continuity:

```markdown
## Session Continuity

Last session: {current timestamp}
Stopped at: Session resumed, proceeding to {chosen action}
Resume file: {path to .continue-here if exists, otherwise "None"}
```

Log the resumption in audit.md:

```markdown
## Recovery — Session Resumption
**Timestamp:** {ISO 8601}
**Issue:** New session started
**Steps Taken:** Loaded {N} artifacts, detected phase={phase}, stage={stage}
**Outcome:** Routed to {chosen action}
**Artifacts Affected:** state.md updated
```

</process>

<output>

- Updated `.aidlc/state.md` — Session continuity refreshed
- Appended `.aidlc/audit.md` — Session resumption logged
- User presented with resumption summary and next action

</output>

<success_criteria>

- [ ] Project existence verified (.aidlc/ and intent.md exist)
- [ ] Phase correctly detected from artifacts (not just state.md)
- [ ] Stage within phase correctly identified
- [ ] Stage-appropriate artifacts loaded (inception/construction/operations context)
- [ ] Construction stage artifacts loaded when mid-construction (nfr-design, infrastructure-design, etc.)
- [ ] Checkpoints detected (.continue-here files)
- [ ] Incomplete work detected (plans without summaries)
- [ ] Unanswered questions detected and flagged
- [ ] Edge cases handled (no stages completed, partial artifacts, corrupted state)
- [ ] State reconstructed from artifacts if state.md is inconsistent (per error-handling.md)
- [ ] Clear resumption summary presented showing: last completed, current stage, pending artifacts
- [ ] Context-appropriate next action offered
- [ ] Session continuity updated in state.md
- [ ] Resumption logged in audit.md

</success_criteria>
</output>
