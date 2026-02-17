---
name: sdlc:retro
description: Run a Guardrail Retro — review what AI did well/poorly and improve for next time
argument-hint: "[unit-id or 'milestone']"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

<objective>

Run a Guardrail Retro after completing a unit or milestone. This is how the team gets better over time.

**Purpose:** Review what the AI did well/poorly, which guardrails helped/were missing, and produce concrete improvement actions for the next unit.

**When to run:**
- After `__CMD_PREFIX__bolt` completes a unit (Unit Complete gate passed)
- After `__CMD_PREFIX__approve-release`
- Anytime the team wants to reflect on completed work

**Principles in play:**
- #2 Reverse Conversation: AI proposes retro findings, human adds perspective
- #4 Align with AI Capability: AI analyzes data, human judges what matters
- #9 Maximize Flow: Learn fast, apply immediately to next unit

</objective>

<execution_context>

@__SDLC_REFS__/principles.md

</execution_context>

<context>
Scope: __ARGUMENTS__

- If "UNIT-001" or "1": retro for that specific unit
- If "milestone" or "v1.0": retro for the entire milestone
- If empty: check state.md for most recently completed unit or milestone

@.aidlc/state.md
</context>

<process>

## 0. Pre-Flight

```bash
ls .aidlc/ 2>/dev/null
```

**If no .aidlc/:** Error — no project to retro. Run `__CMD_PREFIX__new-project` first.

**Resolve scope:**

Parse __ARGUMENTS__ to determine retro scope:

- **Unit retro:** Find the unit file, its design doc, related phase summaries and verifications
- **Milestone retro:** Aggregate across all units and phases

```bash
ls .aidlc/units/UNIT-*.md 2>/dev/null
ls .aidlc/construction/unit-*/  2>/dev/null
```

**Create retro directory if needed:**
```bash
mkdir -p .aidlc/retros
```

## 1. Gather Evidence

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GUARDRAIL RETRO
 Scope: {UNIT-ID or milestone version}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Read all relevant artifacts:

**For unit retro:**
- `.aidlc/units/{UNIT-ID}.md` — acceptance criteria
- `.aidlc/units/{UNIT-ID}-design.md` — design decisions
- `.aidlc/audit.md` — filter entries related to this unit
- `.aidlc/construction/{unit-dir}/*-SUMMARY.md` — what was built
- `.aidlc/construction/{unit-dir}/*-VERIFICATION.md` — what passed/failed
- `.aidlc/risk-register.md` — risks related to this unit

**For milestone retro:**
- All of the above across all units
- `.aidlc/v*-MILESTONE-AUDIT.md` — if exists
- `.aidlc/inception/requirements.md` — original scope vs. delivered

## 2. Analyze Patterns

From the gathered evidence, identify:

**Metrics:**
- Total bolt plans executed
- Gates passed on first attempt vs. rejected and re-attempted
- Rework cycles (how many times was something re-done?)
- Acceptance criteria met vs. missed
- Risks that materialized vs. risks that didn't

**Patterns — What went well:**
- Gates that passed cleanly on first attempt
- Design decisions that held up through implementation
- Guardrails (risks, constraints) that prevented problems
- Bolt plans that executed without deviation

**Patterns — What went wrong:**
- Gates that were rejected (why? what was missing?)
- Scope changes or deviations logged in audit trail
- Acceptance criteria that needed multiple attempts
- Design decisions that had to be revised
- Risks that materialized despite mitigations
- Unexpected issues not covered by risk register

**Guardrail effectiveness:**
For each risk/constraint in the risk register:
- Did it help? (prevented a known problem)
- Was it unnecessary? (never triggered, added overhead)
- Was it missing? (problem occurred that should have been a guardrail)

## 3. Present Findings

Present the retro findings conversationally, not as a wall of text. Go section by section:

**Start with the data:**

```
## Retro Summary

| Metric | Value |
|---|---|
| Bolt plans executed | {N} |
| Gates passed (first attempt) | {N}/{M} |
| Gates rejected then re-passed | {N} |
| Acceptance criteria met | {N}/{M} |
| Risks materialized | {N}/{M} |
| Rework cycles | {N} |
```

**Then present each finding category briefly:**

"Here's what I found from the audit trail and execution history..."

**What went well:** 2-3 bullet points with evidence links
**What went wrong:** 2-3 bullet points with evidence links
**Guardrail review:** Brief table

## 4. Human Input

This is the critical step. The data only tells part of the story.

Ask conversationally (NOT with AskUserQuestion — this should be a natural conversation):

"That's what the data shows. From your side:
- What stood out to you during this work?
- Anything the AI kept getting wrong that you had to correct?
- Any guardrails you wish we'd had from the start?
- What would you do differently next time?"

**Wait for the human's response.** Their input is the most valuable part of the retro.

Incorporate their observations into the final document.

## 5. Write Retro Document

Create `.aidlc/retros/RETRO-{scope}.md`:

```markdown
# Guardrail Retro: {scope}

> Retro date: {timestamp}
> Scope: {UNIT-ID or milestone version}
> Participants: AI + {human}

## Summary

| Metric | Value |
|---|---|
| Bolt plans executed | {N} |
| Gates passed (first attempt) | {N}/{M} |
| Rework cycles | {N} |
| Acceptance criteria met | {N}/{M} |
| Risks materialized | {N}/{M} |

## What Went Well

{2-5 items with evidence from audit trail}

## What Went Wrong

{2-5 items with evidence from audit trail}

## Guardrail Review

| Guardrail | Verdict | Notes |
|---|---|---|
| {risk/constraint from register} | Helped / Unnecessary / Missing | {why} |

## Human Observations

{What the human added during the retro conversation}

## Improvement Actions

| # | Action | Apply To | Priority |
|---|---|---|---|
| 1 | {concrete change} | {next unit / all future work} | {high/medium/low} |
| 2 | {concrete change} | {next unit / all future work} | {high/medium/low} |

## Audit References

{Links to specific audit.md entries that informed this retro}
```

## 6. Update Artifacts

**Append to audit trail:**

```markdown
### Entry #{N} — {timestamp}
- **Type:** decision
- **Actor:** Both
- **Phase:** {Construction or Operations}
- **Context:** Guardrail Retro for {scope}
- **Decision:** Retro completed. {N} improvement actions identified.
- **Evidence:** .aidlc/retros/RETRO-{scope}.md
- **Traces to:** {UNIT-IDs or milestone version}
```

**If new risks were identified during retro:**

Ask: "Should I add these new risks to the risk register for the next unit?"

If yes, append new RISK-IDs to `.aidlc/risk-register.md`.

## 7. Completion

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RETRO COMPLETE
 Scope: {scope}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Retro saved:** .aidlc/retros/RETRO-{scope}.md
**Improvement actions:** {N} identified
**Audit updated:** Entry #{N}

## ▶ Next

{If unit retro + more units:}
__CMD_PREFIX__build-unit {next-UNIT-ID} — start next unit (with retro learnings applied)

{If milestone retro:}
__CMD_PREFIX__elaborate — start next milestone cycle

{Always:}
Review improvement actions before starting next work.
The best retros change how the next unit is built.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<anti_patterns>
- Don't skip the human input step — the data alone is insufficient
- Don't make the retro a blame session — focus on improvement, not fault
- Don't produce generic advice ("write better tests") — be specific ("add input validation tests for the payment form, which broke twice")
- Don't ignore gate rejections — they're the richest source of learning
- Don't create improvement actions without evidence — every action should trace to a specific problem
</anti_patterns>

<success_criteria>
- [ ] Scope resolved (unit or milestone)
- [ ] All relevant artifacts read (audit, summaries, verifications, risks)
- [ ] Metrics extracted (gates, rework, criteria coverage)
- [ ] What went well/wrong identified with evidence
- [ ] Guardrail effectiveness reviewed
- [ ] Human input solicited and incorporated
- [ ] RETRO-{scope}.md written to .aidlc/retros/
- [ ] Audit trail updated
- [ ] Risk register updated if new risks found
- [ ] Concrete improvement actions listed (not vague advice)
</success_criteria>
