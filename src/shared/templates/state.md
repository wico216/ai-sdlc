# State Template

Template for `.aidlc/state.md` — the project's living memory.

---

## File Template

```markdown
---
type: state
project: "{project-name}"
phase: "{inception | construction | operations}"
updated: "{YYYY-MM-DD}"
---

# Project State

## Project Reference

See: .aidlc/inception/intent.md (updated [date])

**Core value:** [One-liner from intent.md]
**Current focus:** [Current unit name or "Inception"]

## Current Position

Phase: [Inception | Construction | Operations]
Stage: [Current stage within phase]
Unit: [X] of [Y] ([Unit name]) — or "N/A" during inception
Bolt: [A] of [B] in current unit — or "N/A"
Status: [Elaborating | Ready to plan | Planning | Ready to build | In progress | Verifying | Unit complete]
Last activity: [YYYY-MM-DD] — [What happened]

Progress: [░░░░░░░░░░] 0%

## Gate Status

### Inception Gates

| Gate | Status | Date | Approver | Evidence |
|------|--------|------|----------|----------|
| Requirements Approved | {not_started \| pending \| passed \| failed} | | | |
| Inception Exit | {not_started \| pending \| passed \| failed} | | | |

### Construction Gates (per unit)

| Unit | Design Approved | Unit Complete |
|------|-----------------|---------------|
| UNIT-001 | {not_started \| passed} ({date}) | {not_started \| passed} ({date}) |
| UNIT-002 | {not_started} | {not_started} |

### Operations Gate

| Gate | Status | Date | Approver | Evidence |
|------|--------|------|----------|----------|
| Production Ready | {not_started \| pending \| passed \| failed} | | | |

## Performance Metrics

**Velocity:**
- Total bolts completed: [N]
- Average duration: [X] min
- Total execution time: [X.X] hours

**By Unit:**

| Unit | Bolts | Total | Avg/Bolt |
|------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**
- Last 5 bolts: [durations]
- Trend: [Improving / Stable / Degrading]

*Updated after each bolt completion*

## Accumulated Context

### Decisions

Recent decisions affecting current work (full log in audit.md):

- [Unit X]: [Decision summary]
- [Unit Y]: [Decision summary]

### Blockers/Concerns

[Issues that affect future work]

None yet.

## Session Continuity

Last session: [YYYY-MM-DD HH:MM]
Stopped at: [Description of last completed action]
Resume file: [Path to .continue-here*.md if exists, otherwise "None"]
```

<purpose>

state.md is the project's short-term memory spanning all units and sessions.

**Problem it solves:** Information is captured in summaries, issues, and decisions but not systematically consumed. Sessions start without context.

**Solution:** A single, small file that's:
- Read first in every workflow
- Updated after every significant action
- Contains digest of accumulated context
- Enables instant session restoration
- Tracks gate status for enforcement

</purpose>

<lifecycle>

**Creation:** After execution-plan.md is created (during new-project)
- Reference intent.md (read it for current context)
- Initialize empty accumulated context sections
- Initialize all gates as "not_started"
- Set position to "Inception — Elaborating"

**Reading:** First step of every workflow
- status: Present status to user
- plan-unit: Inform planning decisions, check gates
- build-unit: Know current position
- approve-*: Update gate status
- All commands: Check gate prerequisites

**Writing:** After every significant action
- build-unit: After bolt-summary.md created
  - Update position (unit, bolt, status)
  - Note new decisions (detail in audit.md)
  - Add blockers/concerns
- approve-*: After gate approval
  - Update gate status table
  - Record approver and date
- Unit complete: After unit marked complete
  - Update progress bar
  - Clear resolved blockers
  - Refresh Project Reference date

</lifecycle>

<gate_enforcement>

Gate status in state.md drives workflow enforcement:

- `__CMD_PREFIX__plan-unit` requires Inception Exit = passed
- `__CMD_PREFIX__build-unit` requires Design Approved = passed for that unit
- `__CMD_PREFIX__operations` requires all units complete
- `__CMD_PREFIX__approve-release` requires Production Ready checklist

Agents MUST check gate status before proceeding. If a gate is not passed, the agent should refuse and explain what's needed.

</gate_enforcement>

<size_constraint>

Keep state.md under 120 lines.

It's a DIGEST, not an archive. If accumulated context grows too large:
- Keep only 3-5 recent decisions in summary (full log in audit.md)
- Keep only active blockers, remove resolved ones
- Gate status tables grow with units but stay compact

The goal is "read once, know where we are" — if it's too long, that fails.

</size_constraint>
