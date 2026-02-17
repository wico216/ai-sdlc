---
name: sdlc:verify-unit
description: Validate built features through conversational UAT for a unit
argument-hint: "[unit number or ID, e.g., '1' or 'UNIT-001']"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Edit
  - Write
  - Task
---

<objective>
Validate built features through conversational testing with persistent state for a specific unit.

Purpose: Confirm what was built actually works from the user's perspective. One test at a time, plain text responses, no interrogation. When issues are found, automatically diagnose, plan fixes, and prepare for execution.

Output:
- `.aidlc/construction/unit-NNN/UAT.md` tracking all test results
- `.aidlc/construction/unit-NNN/test-instructions.md` with build, unit test, integration test, performance test instructions, and test summary (produced by sdlc-unit-verifier alongside validation-report.md)

If issues found: diagnosed gaps, verified fix plans ready for `__CMD_PREFIX__build-unit --gaps-only`.
</objective>

<execution_context>
@__SDLC_TEMPLATES__/UAT.md
@__SDLC_REFS__/ui-brand.md
</execution_context>

<context>
Unit: __ARGUMENTS__
- If provided: Test specific unit (e.g., "1", "001", "UNIT-001")
- If not provided: Check state.md for current unit, or check for active UAT sessions

@.aidlc/state.md
@.aidlc/execution-plan.md
</context>

<process>

## 0. Parse Unit Argument

Parse unit from __ARGUMENTS__. Accept flexible formats:
- `"1"`, `"01"`, `"001"` → unit `001`
- `"UNIT-001"` → unit `001`
- No argument → check state.md for current unit

Normalize to three-digit format (`NNN`).

Set `UNIT_DIR=.aidlc/construction/unit-{NNN}`.

## 1. Check for Active UAT Session

```bash
cat .aidlc/construction/unit-{NNN}/UAT.md 2>/dev/null
```

**If UAT.md exists and status is "testing":**
- Resume session: read Current Test section, find first `[pending]` result
- Report: "Resuming UAT session for Unit {NNN} — {N}/{M} tests completed"
- Skip to step 4 (present next test)

**If UAT.md exists and status is "complete" or "diagnosed":**
- Session already finished. Present summary and offer next steps.
- Skip to step 6.

**If no UAT.md:** Continue to step 2.

## 2. Discover Bolt Summaries

Find bolt-summary.md files for this unit:

```bash
ls .aidlc/construction/unit-{NNN}/bolt-*-summary.md 2>/dev/null | sort
```

**If no summaries found:** Error — run `__CMD_PREFIX__build-unit {NNN}` first.

Read each summary and extract testable deliverables (user-observable outcomes from the Accomplishments and Files Created sections).

## 3. Create UAT.md

Display banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► VERIFYING
 Unit {NNN}: {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Create `.aidlc/construction/unit-{NNN}/UAT.md` using the UAT template:
- Set status to "testing"
- Set unit to NNN
- List source bolt-summary files
- Set started timestamp
- Generate test list from extracted deliverables
- Set all results to `[pending]`
- Initialize Summary counts (total: N, passed: 0, issues: 0, pending: N, skipped: 0)

Report:

```
Created {N} tests from {M} bolt summaries.

Starting UAT — respond with "yes"/"y"/"next" to pass, or describe any issue.
```

## 4. Present Tests One at a Time

For each pending test in order:

**Present the test as plain text (NOT AskUserQuestion):**

```
**Test {N}/{total}: {Test Name}**

Expected: {observable behavior — what user should see or be able to do}
```

**Wait for user's plain text response.**

**Parse response:**
- `"yes"`, `"y"`, `"next"`, `"pass"`, `"ok"`, `"looks good"` → **pass**
- `"skip"`, `"n/a"` → **skipped** (add reason if provided)
- Anything else → **issue** (infer severity from description)

**Severity inference (never ask for severity):**

| User describes | Infer |
|----------------|-------|
| Crash, error, exception, fails completely, unusable | blocker |
| Doesn't work, nothing happens, wrong behavior, missing | major |
| Works but..., slow, weird, minor, small issue | minor |
| Color, font, spacing, alignment, visual, looks off | cosmetic |

Default: **major** (safe default).

## 5. Update UAT.md After Each Response

After each user response:

- Update the test result (pass / issue / skipped)
- If issue: add `reported` (verbatim user response) and `severity` (inferred)
- If skipped: add `reason` if provided
- Update Summary counts
- Update Current Test section to point to next pending test
- Update `updated` timestamp in frontmatter

**Batch writes:** Update UAT.md on issue, every 5 passes, or on completion.

Continue presenting tests until all are resolved.

## 6. On Completion

Update UAT.md:
- Set status to "complete"
- Set Current Test to "[testing complete]"
- Final Summary counts

Commit UAT.md and test-instructions.md:

```bash
git add .aidlc/construction/unit-{NNN}/UAT.md
git add .aidlc/construction/unit-{NNN}/test-instructions.md
git commit -m "docs({NNN}): complete UAT session ({passed}/{total} passed)"
```

Present summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} UAT COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total: {N}  Passed: {N}  Issues: {N}  Skipped: {N}
```

**Route based on results:**

### If all tests pass → Route to approve-unit

No issues found. Proceed to gate approval.

See `<offer_next>` Route A.

### If issues found → Diagnose and plan fixes

**a. Spawn parallel debug agents:**

For each gap in UAT.md, spawn a debug agent to investigate root cause:

```
Task(prompt="Investigate UAT gap for Unit {NNN}.

Symptom: {truth from test}
User reported: {verbatim user response}
Severity: {inferred severity}

Find the root cause. Read relevant source files, trace the logic, identify what's broken.

Return:
- Root cause (specific file + line/logic)
- Evidence (what you found)
- Suggested fix direction (brief)
", subagent_type="general-purpose", description="Debug: {test_name}")
```

All debug agents spawn in parallel.

**b. Collect diagnoses and update UAT.md:**

For each gap, fill in:
- `root_cause`: from debug agent
- `artifacts`: files involved
- `missing`: what needs to change
- `debug_session`: path to debug file (if created)

Update UAT.md status to "diagnosed".

**c. Spawn `sdlc-bolt-planner` in --gaps mode:**

```
Task(prompt="Create gap closure bolt plans for Unit {NNN}.

Read .aidlc/construction/unit-{NNN}/UAT.md for diagnosed gaps.
Create bolt plans that fix each gap.
Mark plans with gap_closure: true in frontmatter.
", subagent_type="sdlc-bolt-planner", model="{planner_model}")
```

**d. Spawn `sdlc-plan-checker` to verify fix plans:**

```
Task(prompt="Verify gap closure bolt plans for Unit {NNN}.

Check that each gap from UAT.md has a corresponding fix plan.
Verify plans are complete, have correct traceability, and address root causes.
", subagent_type="sdlc-plan-checker", model="{checker_model}")
```

Iterate planner and checker until plans pass (max 3 iterations).

**e. Commit diagnosed UAT and fix plans:**

```bash
git add .aidlc/construction/unit-{NNN}/UAT.md
git add .aidlc/construction/unit-{NNN}/bolt-*-plan.md
git commit -m "docs({NNN}): diagnose UAT gaps and create fix plans"
```

See `<offer_next>` Route C or D.

</process>

<offer_next>
Output this markdown directly (not as a code block). Route based on UAT results:

| Status | Route |
|--------|-------|
| All tests pass + more units | Route A (approve unit) |
| All tests pass + last unit | Route B (approve final unit) |
| Issues found + fix plans ready | Route C (execute fixes) |
| Issues found + planning blocked | Route D (manual intervention) |

---

**Route A: All tests pass, more units remain**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} VERIFIED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

{N}/{N} tests passed
UAT complete ✓

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Approve Unit {NNN}** — pass the Unit Complete gate

`__CMD_PREFIX__approve-unit {NNN}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__plan-unit {next-NNN}` — plan next unit ahead of time

───────────────────────────────────────────────────────────────

---

**Route B: All tests pass, all units complete**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} VERIFIED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

{N}/{N} tests passed
Final unit verified ✓

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Approve Unit {NNN}** — pass the final Unit Complete gate, then operations

`__CMD_PREFIX__approve-unit {NNN}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__retro` — retrospective before operations

───────────────────────────────────────────────────────────────

---

**Route C: Issues found, fix plans ready**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} ISSUES FOUND ⚠
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

{N}/{M} tests passed
{X} issues diagnosed
Fix plans verified ✓

### Issues Found

{List issues with severity from UAT.md}

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Execute fix plans** — run diagnosed fixes

`__CMD_PREFIX__build-unit {NNN} --gaps-only`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- Review fix plans: `.aidlc/construction/unit-{NNN}/bolt-*-plan.md`
- `__CMD_PREFIX__plan-unit {NNN} --gaps` — regenerate fix plans

───────────────────────────────────────────────────────────────

---

**Route D: Issues found, planning blocked**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} BLOCKED ✗
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

{N}/{M} tests passed
Fix planning blocked after {X} iterations

### Unresolved Issues

{List blocking issues from planner/checker output}

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Manual intervention required**

Review the issues above and either:
1. Provide guidance for fix planning
2. Manually address blockers
3. Accept current state and continue

───────────────────────────────────────────────────────────────

**Options:**
- `__CMD_PREFIX__plan-unit {NNN} --gaps` — retry fix planning with guidance
- `__CMD_PREFIX__approve-unit {NNN}` — accept current state with known issues

───────────────────────────────────────────────────────────────

</offer_next>

<anti_patterns>
- Do NOT use AskUserQuestion for test responses — plain text conversation only
- Do NOT ask severity — always infer from the user's description
- Do NOT present full checklist upfront — one test at a time
- Do NOT run automated tests — this is manual user validation
- Do NOT fix issues during testing — log as gaps, diagnose after all tests complete
- Do NOT reference `.aidlc/phases/` paths — all artifacts live in `.aidlc/construction/unit-NNN/`
- Do NOT reference old naming like `XX-YY-SUMMARY.md` — use `bolt-NN-summary.md`
</anti_patterns>

<success_criteria>
- [ ] UAT.md created at `.aidlc/construction/unit-{NNN}/UAT.md` with tests from bolt summaries
- [ ] test-instructions.md created at `.aidlc/construction/unit-{NNN}/test-instructions.md` with build and test instructions
- [ ] Tests presented one at a time with expected behavior
- [ ] Plain text responses (no structured forms or AskUserQuestion)
- [ ] Severity inferred from description, never asked
- [ ] Batched writes: on issue, every 5 passes, or completion
- [ ] Committed on completion
- [ ] If issues: parallel debug agents diagnose root causes
- [ ] If issues: `sdlc-bolt-planner` creates gap closure bolt plans
- [ ] If issues: `sdlc-plan-checker` verifies fix plans (max 3 iterations)
- [ ] Ready for `__CMD_PREFIX__build-unit {NNN} --gaps-only` when complete
</success_criteria>

<adaptive_depth>
## Adaptive Depth
Read `.aidlc/execution-plan.md` for the rigor level set during inception.
Adjust your behavior per the Rigor Levels table:

| Aspect | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| Gate formality | Quick review | Evidence checklist | Formal sign-off |
| Evidence depth | Tests pass | Tests + coverage | Tests + coverage + load test |
| Research depth | Skip | Standard | Comprehensive |
| Verification | Spot check | Full verification | Full + integration check |
| Audit detail | Summary | Standard entries | Detailed with rationale |

If no execution-plan.md exists, default to **Medium Risk**.
</adaptive_depth>
