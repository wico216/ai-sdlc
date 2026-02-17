---
name: sdlc:build-unit
description: Execute bolt plans for a unit with wave-based parallelization and Ralph Loop
argument-hint: "<unit> [--gaps-only]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

<objective>
Execute all bolt plans in a unit using wave-based parallel execution, then verify the unit goal via the Ralph Loop (Build -> Verify -> Loop until acceptance criteria met).

Orchestrator stays lean: discover bolt plans, analyze dependencies, group into waves, spawn subagents, collect results. Each subagent loads the full context and handles its own bolt plan.

Context budget: ~15% orchestrator, 100% fresh per subagent.
</objective>

<execution_context>
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/git-integration.md
</execution_context>

<context>
Unit: __ARGUMENTS__

**Flags:**
- `--gaps-only` — Execute only gap closure bolt plans (plans with `gap_closure: true` in frontmatter). Use after verify-unit creates fix plans.

@.aidlc/state.md
@.aidlc/execution-plan.md
</context>

<process>

## 0. Parse Unit Argument

Parse unit from __ARGUMENTS__. Accept flexible formats:
- `"1"`, `"01"`, `"001"` → unit `001`
- `"UNIT-001"` → unit `001`
- No argument → check state.md for current unit, or list available units

Normalize to three-digit format (`NNN`).

```bash
ls .aidlc/construction/ 2>/dev/null
```

**If no construction directory:** Error — run `__CMD_PREFIX__inception` first.

Set `UNIT_DIR=.aidlc/construction/unit-{NNN}`.

```bash
ls .aidlc/construction/unit-{NNN}/ 2>/dev/null
```

**If unit directory missing:** Error — run `__CMD_PREFIX__plan-unit {NNN}` first.

## 1. Resolve Model Profile

Read model profile for agent spawning:

```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

Default to "balanced" if not set.

**Model lookup table:**

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-bolt-executor | opus | sonnet | sonnet |
| sdlc-unit-verifier | sonnet | sonnet | haiku |

Store resolved models for use in Task calls below.

## 2. Check Gate Prerequisites

Read state.md and verify:
- **Inception Exit gate** must be `passed`
- **Design Approved gate** for this unit must be `passed`

If either gate is not passed:

```
╔══════════════════════════════════════════════════════════════╗
║  ERROR                                                       ║
╚══════════════════════════════════════════════════════════════╝

Gate prerequisite not met for Unit {NNN}.

{gate_name}: {status}

**To fix:** Run `__CMD_PREFIX__approve-unit {NNN}` to pass required gates.
```

## 3. Discover Bolt Plans

List all bolt-plan files in the unit directory:

```bash
ls .aidlc/construction/unit-{NNN}/bolt-*-plan.md 2>/dev/null | sort
ls .aidlc/construction/unit-{NNN}/bolt-*-summary.md 2>/dev/null | sort
```

- Check which bolt plans have a corresponding bolt-summary.md (already complete)
- If `--gaps-only`: filter to only plans with `gap_closure: true` in frontmatter
- Build list of incomplete bolt plans

**If no incomplete plans found:** Unit already fully built. Skip to step 7 (verification).

Display banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► EXECUTING WAVE {N}
 Unit {NNN}: {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plans: {incomplete}/{total}
{If --gaps-only: "Gap closure mode: executing fix plans only"}
```

## 4. Group by Wave

Read `wave` from each incomplete bolt plan's frontmatter. Group bolt plans by wave number.

Report wave structure to user:

```
Wave 1: bolt-01, bolt-02 (parallel)
Wave 2: bolt-03 (sequential — depends on wave 1)
Wave 3: bolt-04, bolt-05 (parallel)
```

## 5. Execute Waves

For each wave in order:

**a. Read plan contents before spawning.**

The `@` syntax does NOT work across Task() boundaries. Read each plan and state inline:

```bash
BOLT_01_CONTENT=$(cat ".aidlc/construction/unit-{NNN}/bolt-01-plan.md")
BOLT_02_CONTENT=$(cat ".aidlc/construction/unit-{NNN}/bolt-02-plan.md")
STATE_CONTENT=$(cat .aidlc/state.md)
```

**b. Spawn `sdlc-bolt-executor` for each plan in wave (parallel Task calls).**

Spawn all plans in a wave with a single message containing multiple Task calls, with inlined content:

```
Task(prompt="Execute bolt plan at .aidlc/construction/unit-{NNN}/bolt-01-plan.md

Bolt plan:
{bolt_01_content}

Project state:
{state_content}

Commit format: {type}({NNN}-01): description
", subagent_type="sdlc-bolt-executor", model="{executor_model}")

Task(prompt="Execute bolt plan at .aidlc/construction/unit-{NNN}/bolt-02-plan.md

Bolt plan:
{bolt_02_content}

Project state:
{state_content}

Commit format: {type}({NNN}-02): description
", subagent_type="sdlc-bolt-executor", model="{executor_model}")
```

All plans in a wave run in parallel. Task tool blocks until all complete.

**No polling.** No background agents. No TaskOutput loops.

**c. After wave completes:**
- Verify bolt-summary.md files were created for each bolt in the wave
- Report wave completion:

```
✓ Wave {N} complete: bolt-01, bolt-02
  Files modified: {count}
  Deviations: {count}
```

- Proceed to next wave

**d. Repeat for all waves.**

## 6. Commit Orchestrator Corrections

Check for uncommitted changes after all bolts complete:

```bash
git status --porcelain
```

**If changes exist:** Orchestrator made corrections between executor completions. Commit them:

```bash
git add -u && git commit -m "fix({NNN}): orchestrator corrections"
```

**If clean:** Continue to verification.

## 7. Verify Unit Goal (Ralph Loop)

Check config:

```bash
WORKFLOW_VERIFIER=$(cat .aidlc/config.json 2>/dev/null | grep -o '"verifier"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")
```

**If `workflow.verifier` is `false`:** Skip verification (treat as passed).

**Otherwise:** Spawn `sdlc-unit-verifier` with unit context:

Read the unit definition and all bolt summaries:

```bash
UNIT_DEF=$(cat ".aidlc/construction/unit-{NNN}/unit.md" 2>/dev/null || cat ".aidlc/inception/units/unit-{NNN}.md" 2>/dev/null)
SUMMARIES=$(cat .aidlc/construction/unit-{NNN}/bolt-*-summary.md 2>/dev/null)
```

```
Task(prompt="Verify unit {NNN} goal against codebase.

Unit definition:
{unit_def}

Bolt summaries:
{summaries}

Check must_haves against actual codebase (not summary claims).
Create .aidlc/construction/unit-{NNN}/VERIFICATION.md with detailed report.
", subagent_type="sdlc-unit-verifier", model="{verifier_model}")
```

**Route by verification status:**
- `passed` → continue to step 8
- `gaps_found` → present gaps, offer `__CMD_PREFIX__plan-unit {NNN} --gaps`
- `human_needed` → present items, get approval or feedback

## 8. Update State and Execution Plan

Update state.md:
- Current Position: unit, bolt count, status
- Last activity: today's date and what happened
- Progress bar: recalculate from total bolts completed

Update execution-plan.md:
- Mark unit bolts as complete (if applicable)

## 9. Update Requirements Traceability

Read the unit definition to find which REQ-IDs this unit covers. If requirements.md exists:
- For each REQ-ID in this unit: update status from "Pending" to "Complete"
- Write updated requirements.md
- Skip if requirements.md doesn't exist or unit has no REQ-IDs

## 10. Commit Unit Completion Metadata

Check `COMMIT_PLANNING_DOCS` from config.json (default: true).

If false: Skip git operations for .aidlc/ files.

If true: Bundle all unit metadata updates in one commit:

```bash
git add .aidlc/state.md
git add .aidlc/execution-plan.md
git add .aidlc/construction/unit-{NNN}/VERIFICATION.md
# Add requirements.md if updated
git add .aidlc/inception/requirements.md 2>/dev/null
git commit -m "docs({NNN}): complete unit {NNN} construction"
```

## 11. Offer Next Steps

Route based on status (see `<offer_next>`).

</process>

<offer_next>
Output this markdown directly (not as a code block). Route based on status:

| Status | Route |
|--------|-------|
| `gaps_found` | Route C (gap closure) |
| `human_needed` | Present checklist, then re-route based on approval |
| `passed` + more units | Route A (approve and continue) |
| `passed` + last unit | Route B (release) |

---

**Route A: Unit verified, more units remain**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

{Y} bolts executed
Goal verified ✓

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Approve Unit {NNN}** — pass the Unit Complete gate, then continue

`__CMD_PREFIX__approve-unit {NNN}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__verify-unit {NNN}` — manual acceptance testing before approving
- `__CMD_PREFIX__plan-unit {next-NNN}` — plan next unit ahead of time

───────────────────────────────────────────────────────────────

---

**Route B: Unit verified, all units complete**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RELEASE COMPLETE 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**All {N} units complete**

All unit goals verified ✓

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Approve final unit** — then proceed to operations

`__CMD_PREFIX__approve-unit {NNN}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__verify-unit {NNN}` — manual acceptance testing
- `__CMD_PREFIX__retro` — retrospective before operations

───────────────────────────────────────────────────────────────

---

**Route C: Gaps found — need additional planning**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} GAPS FOUND ⚠
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Unit {NNN}: {Name}**

Score: {N}/{M} must-haves verified
Report: .aidlc/construction/unit-{NNN}/VERIFICATION.md

### What's Missing

{Extract gap summaries from VERIFICATION.md}

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Plan gap closure** — create additional bolt plans to complete the unit

`__CMD_PREFIX__plan-unit {NNN} --gaps`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- Review full report: `.aidlc/construction/unit-{NNN}/VERIFICATION.md`
- `__CMD_PREFIX__verify-unit {NNN}` — manual testing before planning

───────────────────────────────────────────────────────────────

---

After user runs `__CMD_PREFIX__plan-unit {NNN} --gaps`:
1. Planner reads VERIFICATION.md gaps
2. Creates additional bolt plans (bolt-04, bolt-05, etc.) to close gaps
3. User runs `__CMD_PREFIX__build-unit {NNN} --gaps-only`
4. build-unit executes only gap closure plans
5. Verifier runs again → loop until passed (Ralph Loop)
</offer_next>

<deviation_rules>
During execution, handle discoveries automatically:

1. **Auto-fix bugs** — Fix immediately, document in bolt summary
2. **Auto-add critical** — Security/correctness gaps, add and document
3. **Auto-fix blockers** — Can't proceed without fix, do it and document
4. **Ask about architectural** — Major structural changes, stop and ask user

Only rule 4 requires user intervention.
</deviation_rules>

<commit_rules>
**Per-Task Commits:**

After each task completes:
1. Stage only files modified by that task
2. Commit with format: `{type}({unit}-{bolt}): {task-name}`
3. Types: feat, fix, test, refactor, perf, chore
4. Record commit hash for bolt-summary.md

**Examples:**
```bash
git add src/api/auth.ts src/types/user.ts
git commit -m "feat(001-02): create user registration endpoint"
```

**Bolt Metadata Commit:**

After all tasks in a bolt complete:
1. Stage bolt artifacts only: bolt-plan.md, bolt-summary.md
2. Commit with format: `docs({unit}-{bolt}): complete [bolt-name]`
3. NO code files (already committed per-task)

**Unit Completion Commit:**

After all bolts in unit complete (step 10):
1. Stage: state.md, execution-plan.md, VERIFICATION.md, requirements.md (if updated)
2. Commit with format: `docs({unit}): complete unit {NNN} construction`
3. Bundles all unit-level state updates in one commit

**NEVER use:**
- `git add .`
- `git add -A`
- `git add src/` or any broad directory

**Always stage files individually.**
</commit_rules>

<checkpoint_handling>
Bolt plans with `autonomous: false` have checkpoints. Handle the full checkpoint flow:
- Subagent pauses at checkpoint, returns structured state
- Orchestrator presents to user, collects response
- Spawns fresh continuation agent (not resume)

See `@__SDLC_REFS__/checkpoints.md` for complete checkpoint protocol.
</checkpoint_handling>

<success_criteria>
- [ ] All incomplete bolt plans in unit executed
- [ ] Each bolt plan has bolt-summary.md
- [ ] Unit goal verified (must_haves checked against codebase)
- [ ] VERIFICATION.md created in unit directory
- [ ] state.md reflects unit completion
- [ ] execution-plan.md updated
- [ ] requirements.md updated (unit requirements marked Complete)
- [ ] User informed of next steps via continuation format
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
