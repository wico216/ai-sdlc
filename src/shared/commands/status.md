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
**Verify planning structure exists:**

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

**If execution-plan.md missing but intent.md exists:**

This means a release was completed and archived. Go to **Route F** (between releases).

If missing both execution-plan.md and intent.md: suggest `__CMD_PREFIX__new-project`.
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

- Find the 2-3 most recent SUMMARY.md files
- Extract from each: what was accomplished, key decisions, any issues logged
- This shows "what we've been working on"
  </step>

<step name="position">
**Parse current position:**

- From state.md: current unit, plan number, status
- Calculate: total plans, completed plans, remaining plans
- Note any blockers or concerns
- Check for CONTEXT.md: For units without PLAN.md files, check if `{unit}-CONTEXT.md` exists in unit directory
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

**Step 1: Count plans, summaries, and issues in current unit**

List files in the current unit directory:

```bash
ls -1 .aidlc/construction/unit-NNN/bolt-*-plan.md 2>/dev/null | wc -l
ls -1 .aidlc/construction/unit-NNN/bolt-*-summary.md 2>/dev/null | wc -l
ls -1 .aidlc/construction/unit-NNN/*-UAT.md 2>/dev/null | wc -l
```

State: "This unit has {X} plans, {Y} summaries."

**Step 1.5: Check for unaddressed UAT gaps**

Check for UAT.md files with status "diagnosed" (has gaps needing fixes).

```bash
# Check for diagnosed UAT with gaps
grep -l "status: diagnosed" .aidlc/construction/unit-NNN/*-UAT.md 2>/dev/null
```

Track:
- `uat_with_gaps`: UAT.md files with status "diagnosed" (gaps need fixing)

**Step 2: Route based on counts**

| Condition | Meaning | Action |
|-----------|---------|--------|
| uat_with_gaps > 0 | UAT gaps need fix plans | Go to **Route E** |
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
- `__CMD_PREFIX__list-unit-assumptions {unit}` — see Claude's assumptions

---
```

---

**Route E: UAT gaps need fix plans**

UAT.md exists with gaps (diagnosed issues). User needs to plan fixes.

```
---

## ⚠ UAT Gaps Found

**{unit}-UAT.md** has {N} gaps requiring fixes.

`__CMD_PREFIX__plan-unit {unit} --gaps`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__build-unit {unit}` — execute unit plans
- `__CMD_PREFIX__verify-unit {unit}` — run more UAT testing

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
