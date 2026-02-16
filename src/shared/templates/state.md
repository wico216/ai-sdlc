# State Template

Template for `.aidlc/STATE.md` — the project's living memory.

> **Naming note:** The AI-SDLC methodology spec references `aidlc-state.md`. This framework uses the shorter `STATE.md` for consistency with other top-level artifacts (`PROJECT.md`, `REQUIREMENTS.md`). The content and purpose are identical.

---

## File Template

```markdown
# Project State

## Project Reference

See: .aidlc/PROJECT.md (updated [date])

**Core value:** [One-liner from PROJECT.md Core Value section]
**Current focus:** [Current unit name]

## Current Position

Unit: [X] of [Y] ([Unit name])
Bolt: [A] of [B] in current unit
Status: [Ready to plan / Planning / Ready to build / In progress / Unit complete]
Last activity: [YYYY-MM-DD] — [What happened]

Progress: [░░░░░░░░░░] 0%

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

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

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

STATE.md is the project's short-term memory spanning all units and sessions.

**Problem it solves:** Information is captured in summaries, issues, and decisions but not systematically consumed. Sessions start without context.

**Solution:** A single, small file that's:
- Read first in every workflow
- Updated after every significant action
- Contains digest of accumulated context
- Enables instant session restoration

</purpose>

<lifecycle>

**Creation:** After execution-plan.md is created (during init)
- Reference PROJECT.md (read it for current context)
- Initialize empty accumulated context sections
- Set position to "Unit 1 ready to plan"

**Reading:** First step of every workflow
- status: Present status to user
- plan: Inform planning decisions
- build: Know current position
- unit-complete: Know what's complete

**Writing:** After every significant action
- build: After bolt-summary.md created
  - Update position (unit, bolt, status)
  - Note new decisions (detail in PROJECT.md)
  - Add blockers/concerns
- unit-complete: After unit marked complete
  - Update progress bar
  - Clear resolved blockers
  - Refresh Project Reference date

</lifecycle>

<sections>

### Project Reference
Points to PROJECT.md for full context. Includes:
- Core value (the ONE thing that matters)
- Current focus (which unit)
- Last update date (triggers re-read if stale)

Claude reads PROJECT.md directly for requirements, constraints, and decisions.

### Current Position
Where we are right now:
- Unit X of Y — which unit
- Bolt A of B — which bolt within unit
- Status — current state
- Last activity — what happened most recently
- Progress bar — visual indicator of overall completion

Progress calculation: (completed bolts) / (total bolts across all units) × 100%

### Performance Metrics
Track velocity to understand execution patterns:
- Total bolts completed
- Average duration per bolt
- Per-unit breakdown
- Recent trend (improving/stable/degrading)

Updated after each bolt completion.

### Accumulated Context

**Decisions:** Reference to PROJECT.md Key Decisions table, plus recent decisions summary for quick access. Full decision log lives in PROJECT.md.

**Blockers/Concerns:** From "Next Unit Readiness" sections
- Issues that affect future work
- Prefix with originating unit
- Cleared when addressed

### Session Continuity
Enables instant resumption:
- When was last session
- What was last completed
- Is there a .continue-here file to resume from

</sections>

<size_constraint>

Keep STATE.md under 100 lines.

It's a DIGEST, not an archive. If accumulated context grows too large:
- Keep only 3-5 recent decisions in summary (full log in PROJECT.md)
- Keep only active blockers, remove resolved ones

The goal is "read once, know where we are" — if it's too long, that fails.

</size_constraint>
