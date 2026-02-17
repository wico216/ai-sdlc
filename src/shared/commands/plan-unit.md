---
name: sdlc:plan-unit
description: Create bolt plans for a unit with research and verification loop
argument-hint: "<unit> [--research] [--skip-research] [--gaps] [--skip-verify]"
agent: sdlc-bolt-planner
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Task
  - WebFetch
  - mcp__context7__*
---

<execution_context>
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/principles.md
@__SDLC_REFS__/gates.md
@__SDLC_REFS__/planning-config.md
@__SDLC_REFS__/question-format-guide.md
@__SDLC_REFS__/overconfidence-prevention.md
@__SDLC_REFS__/error-handling.md
@__SDLC_REFS__/content-validation.md
@__SDLC_REFS__/depth-levels.md
@__SDLC_TEMPLATES__/bolt-plan.md
@__SDLC_TEMPLATES__/research.md
@__SDLC_TEMPLATES__/design.md
</execution_context>

<objective>
Create executable bolt plans for a unit with integrated research and verification.

**Default flow:** Research (if needed) --> Design (if needed) --> Plan bolts --> Verify --> Done

**Orchestrator role:** Parse arguments, validate unit, ensure construction directory exists, research domain (unless skipped or exists), spawn sdlc-bolt-planner agent, verify plans with sdlc-plan-checker, iterate until plans pass or max iterations reached, present results.

**Why subagents:** Research and planning burn context fast. Verification uses fresh context. User sees the flow between agents in main context.

**Cross-cutting rules:** All agents spawned by this command must follow:
- `question-format-guide.md` — Write planning questions to `unit-NNN/questions/` as structured files
- `overconfidence-prevention.md` — Present options when multiple approaches exist, never pick silently
- `error-handling.md` — Log errors to audit.md, escalate to user when blocked
- `content-validation.md` — Validate diagrams and complex content before writing
- `depth-levels.md` — Calibrate bolt detail based on risk level

**Key difference from old plan-phase.md:**
- Plans target UNITS (not phases)
- Bolt plans live at `.aidlc/construction/unit-NNN/bolt-NN-plan.md` (not `.aidlc/phases/`)
- Uses `sdlc-bolt-planner` agent (not `sdlc-planner`)
- Design document at `.aidlc/construction/unit-NNN/design.md`
- Produces bolt-plan.md files (not XX-YY-PLAN.md)

> **Note:** This command is the internal planning engine for units. It does NOT enforce AI-SDLC gates (Design Approved, Unit Complete). For the full gate-enforced workflow, use `__CMD_PREFIX__build-unit <unit>` which calls this internally. Use this command directly only when you need fine-grained control over planning.
</objective>

<context>
Unit: __ARGUMENTS__ (required — e.g., "1", "001", "UNIT-001")

**Flags:**
- `--research` — Force re-research even if research.md exists
- `--skip-research` — Skip research entirely, go straight to planning
- `--gaps` — Gap closure mode (reads verification reports, skips research)
- `--skip-verify` — Skip bolt-planner --> plan-checker verification loop

Normalize unit input in step 2 before any directory lookups.
</context>

<process>

## 1. Validate Environment and Check Gates

```bash
ls .aidlc/ 2>/dev/null
[ -f .aidlc/state.md ] && echo "STATE: exists" || echo "STATE: MISSING"
[ -f .aidlc/execution-plan.md ] && echo "EXEC-PLAN: exists" || echo "EXEC-PLAN: MISSING"
[ -d .aidlc/inception/units ] && echo "UNITS: exist" || echo "UNITS: MISSING"
```

**If not found:** Error — user should run `__CMD_PREFIX__new-project` first.

**Check inception gate:**
```bash
grep -i "inception exit" .aidlc/state.md 2>/dev/null | grep -i "passed"
```

**If inception gate not passed:**
```
╔══════════════════════════════════════════════════════════════╗
║  ERROR                                                       ║
╚══════════════════════════════════════════════════════════════╝

Inception Exit gate has not been approved.
Construction cannot begin until inception is complete.

Run `__CMD_PREFIX__approve-inception` to pass gates 1 and 2.
```
Exit command.

**Resolve model profile:**

```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

Default to "balanced" if not set.

**Model lookup table:**

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-research-synthesizer | sonnet | sonnet | haiku |
| sdlc-bolt-planner | opus | opus | sonnet |
| sdlc-plan-checker | sonnet | sonnet | haiku |

Store resolved models for use in Task calls below.

## 2. Parse and Normalize Arguments

Extract from __ARGUMENTS__:

- Unit identifier (integer, zero-padded, or full ID like UNIT-001)
- `--research` flag to force re-research
- `--skip-research` flag to skip research
- `--gaps` flag for gap closure mode
- `--skip-verify` flag to bypass verification loop

**Normalize unit to zero-padded format:**

```bash
# Parse unit from arguments
RAW_UNIT=$(echo "__ARGUMENTS__" | grep -oE '(UNIT-)?[0-9]+' | head -1 | grep -oE '[0-9]+')

if [ -n "$RAW_UNIT" ]; then
  UNIT_NUM=$(printf "%03d" "$RAW_UNIT")
  UNIT_ID="UNIT-${UNIT_NUM}"
else
  echo "ERROR: No unit number found in arguments"
  exit 1
fi

echo "Resolved: ${UNIT_ID}"
```

## 3. Validate Unit

```bash
# Check unit exists in inception
ls .aidlc/inception/units/${UNIT_ID}.md 2>/dev/null

# Check unit referenced in execution-plan.md
grep -i "${UNIT_ID}\|unit.*${UNIT_NUM}" .aidlc/execution-plan.md 2>/dev/null
```

**If unit file not found:**
```
╔══════════════════════════════════════════════════════════════╗
║  ERROR                                                       ║
╚══════════════════════════════════════════════════════════════╝

Unit ${UNIT_ID} not found in .aidlc/inception/units/.

Available units:
$(ls .aidlc/inception/units/UNIT-*.md 2>/dev/null | sed 's/.*\//  /')
```
Exit command.

**If found:** Extract unit name, bounded context, acceptance criteria, dependencies, estimated bolts.

## 4. Ensure Construction Directory Exists and Load Context

```bash
UNIT_DIR=".aidlc/construction/unit-${UNIT_NUM}"
mkdir -p "${UNIT_DIR}"
echo "Construction directory: ${UNIT_DIR}"

# Check for existing bolt plans
ls "${UNIT_DIR}"/bolt-*-plan.md 2>/dev/null
# Check for existing research
ls "${UNIT_DIR}"/research.md 2>/dev/null
# Check for existing design
ls "${UNIT_DIR}"/design.md 2>/dev/null
# Check for CONTEXT.md (from discuss-phase equivalent or prior work)
ls "${UNIT_DIR}"/CONTEXT.md 2>/dev/null
```

**CRITICAL:** Load CONTEXT.md immediately if it exists. It must be passed to:
- **Researcher** — constrains what to research (locked decisions vs discretion areas)
- **Bolt Planner** — locked decisions must be honored, not revisited
- **Plan Checker** — verifies plans respect user's stated vision
- **Revision** — context for targeted fixes

```bash
CONTEXT_CONTENT=$(cat "${UNIT_DIR}"/CONTEXT.md 2>/dev/null)
```

If CONTEXT.md exists, display: `Using unit context from: ${UNIT_DIR}/CONTEXT.md`

## 5. Check Unit Dependencies

Read the unit file and check if dependencies are met:

```bash
# Get dependency list from unit spec
DEPS=$(grep -A5 "dependencies\|depends_on" .aidlc/inception/units/${UNIT_ID}.md 2>/dev/null)
```

**If dependencies exist:** Check each dependency unit's status (from state.md or unit files). Warn if any dependency unit is not complete:

```
⚠  Warning: ${UNIT_ID} depends on ${DEP_UNIT_ID} which is not yet complete.
   Proceed with caution — integration issues may arise.
```

Do NOT block — just warn. The user may be planning ahead.

## 6. Handle Research

**If `--gaps` flag:** Skip research (gap closure uses verification reports instead).

**If `--skip-research` flag:** Skip to step 7.

**Check config for research setting:**

```bash
WORKFLOW_RESEARCH=$(cat .aidlc/config.json 2>/dev/null | grep -o '"research"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")
```

**If `workflow.research` is `false` AND `--research` flag NOT set:** Skip to step 7.

**Otherwise:**

Check for existing research:

```bash
ls "${UNIT_DIR}"/research.md 2>/dev/null
```

**If research.md exists AND `--research` flag NOT set:**
- Display: `Using existing research: ${UNIT_DIR}/research.md`
- Skip to step 7

**If research.md missing OR `--research` flag set:**

Display stage banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RESEARCHING UNIT {NNN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning researcher...
```

Proceed to spawn researcher.

### Spawn sdlc-research-synthesizer

Gather context for research prompt:

```bash
# Read unit spec
UNIT_SPEC=$(cat .aidlc/inception/units/${UNIT_ID}.md 2>/dev/null)

# Read execution plan for construction approach
EXEC_PLAN=$(cat .aidlc/execution-plan.md 2>/dev/null)

# Read requirements for traceability
REQUIREMENTS=$(cat .aidlc/inception/requirements.md 2>/dev/null | head -100)

# Read intent for project context
INTENT=$(cat .aidlc/intent.md 2>/dev/null | head -50)

# Read prior unit summaries for established patterns
PRIOR_SUMMARIES=$(cat .aidlc/construction/unit-*/bolt-*-summary.md 2>/dev/null | head -80)

# CONTEXT_CONTENT already loaded in step 4
```

Fill research prompt and spawn:

```markdown
<objective>
Research how to implement Unit {UNIT_ID}: {unit_name}

Answer: "What do I need to know to PLAN this unit's bolts well?"
</objective>

<unit_context>
**IMPORTANT:** If CONTEXT.md exists below, it contains user decisions.

- **Decisions section** = Locked choices — research THESE deeply, don't explore alternatives
- **Claude's Discretion section** = Your freedom areas — research options, make recommendations
- **Deferred Ideas section** = Out of scope — ignore completely

{context_content}
</unit_context>

<additional_context>
**Unit specification:**
{unit_spec}

**Project intent (summary):**
{intent}

**Execution plan:**
{exec_plan}

**Requirements:**
{requirements}

**Prior unit work (patterns established):**
{prior_summaries}
</additional_context>

<output>
Write research findings to: {unit_dir}/research.md
Use the research.md template structure (standard_stack, architecture_patterns, dont_hand_roll, common_pitfalls, code_examples, sources).
</output>
```

```
Task(
  prompt="First, read __AGENTS_DIR__/sdlc-research-synthesizer.md for your role and instructions.\n\n" + research_prompt,
  subagent_type="general-purpose",
  model="{researcher_model}",
  description="Research Unit {UNIT_ID}"
)
```

### Handle Researcher Return

**`## RESEARCH COMPLETE`:**
- Display: `✓ Research complete. Proceeding to planning...`
- Continue to step 7

**`## RESEARCH BLOCKED`:**
- Display blocker information
- Offer: 1) Provide more context, 2) Skip research and plan anyway, 3) Abort
- Wait for user response

## 7. Check Existing Plans

```bash
ls "${UNIT_DIR}"/bolt-*-plan.md 2>/dev/null
```

**If plans exist:**

Use AskUserQuestion:
- header: "Existing Plans"
- question: "Bolt plans already exist for ${UNIT_ID}. What would you like to do?"
- options:
  - "Add more bolts" -- Continue planning from where we left off
  - "View existing" -- Show current bolt plans
  - "Replan from scratch" -- Overwrite existing plans
  - "Skip to verify" -- Verify existing plans

Wait for response.

## 8. Read Context Files for Planner

Read and store context file contents. The `@` syntax does not work across Task() boundaries — content must be inlined.

```bash
# Read required files
STATE_CONTENT=$(cat .aidlc/state.md)
UNIT_SPEC_CONTENT=$(cat .aidlc/inception/units/${UNIT_ID}.md)
EXEC_PLAN_CONTENT=$(cat .aidlc/execution-plan.md)
INTENT_CONTENT=$(cat .aidlc/intent.md)

# Read optional files (empty string if missing)
REQUIREMENTS_CONTENT=$(cat .aidlc/inception/requirements.md 2>/dev/null)
NFR_CONTENT=$(cat .aidlc/inception/nfr.md 2>/dev/null)
DESIGN_CONTENT=$(cat "${UNIT_DIR}"/design.md 2>/dev/null)
RESEARCH_CONTENT=$(cat "${UNIT_DIR}"/research.md 2>/dev/null)
# CONTEXT_CONTENT already loaded in step 4

# Read prior bolt summaries for this unit (for continuation)
PRIOR_BOLT_SUMMARIES=$(cat "${UNIT_DIR}"/bolt-*-summary.md 2>/dev/null)

# Read prior unit summaries for patterns and dependencies
PRIOR_UNIT_SUMMARIES=""
for dep_dir in .aidlc/construction/unit-*/; do
  if [ "$dep_dir" != "${UNIT_DIR}/" ] && [ -d "$dep_dir" ]; then
    PRIOR_UNIT_SUMMARIES="${PRIOR_UNIT_SUMMARIES}$(cat "${dep_dir}"bolt-*-summary.md 2>/dev/null | head -40)
"
  fi
done

# Gap closure files (only if --gaps mode)
VERIFICATION_CONTENT=$(cat "${UNIT_DIR}"/verification-report.md 2>/dev/null)
```

## 9. Spawn sdlc-bolt-planner Agent

Display stage banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► PLANNING UNIT {NNN}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning bolt planner...
```

Fill prompt with inlined content and spawn:

```markdown
<planning_context>

**Unit:** {UNIT_ID}
**Mode:** {standard | gap_closure | continuation}

**Unit Specification:**
{unit_spec_content}

**Project Intent:**
{intent_content}

**Project State:**
{state_content}

**Execution Plan:**
{exec_plan_content}

**Requirements:**
{requirements_content}

**NFR Requirements (if exists):**
{nfr_content}

**Unit Design (if exists):**
{design_content}

**Unit Context (if exists):**

IMPORTANT: If unit context exists below, it contains USER DECISIONS.
- **Decisions** = LOCKED — honor these exactly, do not revisit or suggest alternatives
- **Claude's Discretion** = Your freedom — make implementation choices here
- **Deferred Ideas** = Out of scope — do NOT include in bolt plans

{context_content}

**Research (if exists):**
{research_content}

**Prior Bolt Summaries for this unit (if continuation):**
{prior_bolt_summaries}

**Prior Unit Summaries (patterns and dependencies):**
{prior_unit_summaries}

**Gap Closure (if --gaps mode):**
{verification_content}

</planning_context>

<downstream_consumer>
Output consumed by `__CMD_PREFIX__build-unit`
Bolt plans must be executable prompts with:

- Frontmatter (unit, bolt, wave, depends_on, files_modified, autonomous, must_haves)
- Tasks in XML format (<task>, <verify>, <done>)
- Verification criteria per task
- must_haves for goal-backward verification
- Traces to unit acceptance criteria and REQ-IDs
</downstream_consumer>

<output_location>
Write bolt plans to: {unit_dir}/bolt-NN-plan.md
Use the bolt-plan.md template structure.

**Naming convention:** `bolt-01-plan.md`, `bolt-02-plan.md`, etc.
If continuing from existing bolts, number sequentially from the last existing bolt.
</output_location>

<quality_gate>
Before returning PLANNING COMPLETE:

- [ ] bolt-NN-plan.md files created in unit construction directory
- [ ] Each plan has valid frontmatter (unit, bolt, wave, depends_on, files_modified, autonomous, must_haves)
- [ ] Tasks are specific and actionable with <task>, <verify>, <done> XML
- [ ] Dependencies correctly identified (between bolts and between tasks)
- [ ] Waves assigned for parallel execution
- [ ] must_haves derived from unit acceptance criteria
- [ ] Every acceptance criterion covered by at least one bolt
- [ ] Traces to REQ-IDs maintained (Golden Thread)
- [ ] 3-7 tasks per bolt (typical range)
- [ ] Each task completable in fresh context (atomic)
</quality_gate>
```

```
Task(
  prompt="First, read __AGENTS_DIR__/sdlc-bolt-planner.md for your role and instructions.\n\n" + filled_prompt,
  subagent_type="general-purpose",
  model="{planner_model}",
  description="Plan bolts for {UNIT_ID}"
)
```

## 10. Handle Planner Return

Parse planner output:

**`## PLANNING COMPLETE`:**
- Display: `✓ Planner created {N} bolt plan(s). Files on disk.`
- List bolt plan files created
- If `--skip-verify`: Skip to step 14
- Check config: `WORKFLOW_PLAN_CHECK=$(cat .aidlc/config.json 2>/dev/null | grep -o '"plan_check"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")`
- If `workflow.plan_check` is `false`: Skip to step 14
- Otherwise: Proceed to step 11

**`## CHECKPOINT REACHED`:**
- Present to user, get response, spawn continuation (see step 13)

**`## PLANNING INCONCLUSIVE`:**
- Show what was attempted
- Offer: Add context, Retry, Manual
- Wait for user response

## 11. Spawn sdlc-plan-checker Agent

Display:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► VERIFYING PLANS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning plan checker...
```

Read plans for the checker:

```bash
# Read all bolt plans in unit directory
PLANS_CONTENT=$(cat "${UNIT_DIR}"/bolt-*-plan.md 2>/dev/null)

# CONTEXT_CONTENT already loaded in step 4
# REQUIREMENTS_CONTENT already loaded in step 8
# UNIT_SPEC_CONTENT already loaded in step 8
```

Fill checker prompt with inlined content and spawn:

```markdown
<verification_context>

**Unit:** {UNIT_ID}
**Unit Goal:** {goal from unit spec}

**Unit Specification:**
{unit_spec_content}

**Bolt plans to verify:**
{plans_content}

**Requirements:**
{requirements_content}

**NFR Requirements (if exists):**
{nfr_content}

**Unit Context (if exists):**

IMPORTANT: If unit context exists below, it contains USER DECISIONS.
Plans MUST honor these decisions. Flag as issue if plans contradict user's stated vision.

- **Decisions** = LOCKED — plans must implement these exactly
- **Claude's Discretion** = Freedom areas — plans can choose approach
- **Deferred Ideas** = Out of scope — plans must NOT include these

{context_content}

</verification_context>

<checks>
Verify:
1. Every unit acceptance criterion is covered by at least one bolt must_have
2. Bolt frontmatter is valid (unit, bolt, wave, depends_on, files_modified, autonomous, must_haves)
3. Tasks have <task>, <verify>, and <done> XML structure
4. File ownership — no two bolt plans modify the same file in the same wave
5. Dependencies form a valid DAG (no cycles)
6. Must_haves are observable and testable (not vague)
7. Golden Thread intact — traces from must_haves to acceptance criteria to REQ-IDs
8. Tasks are atomic — completable without referencing other tasks
9. Context decisions honored — locked decisions not contradicted
10. NFR compliance addressed where applicable
</checks>

<expected_output>
Return one of:
- ## VERIFICATION PASSED — all checks pass
- ## ISSUES FOUND — structured issue list with severity and fix guidance
</expected_output>
```

```
Task(
  prompt=checker_prompt,
  subagent_type="sdlc-plan-checker",
  model="{checker_model}",
  description="Verify bolt plans for {UNIT_ID}"
)
```

## 12. Handle Checker Return

**If `## VERIFICATION PASSED`:**
- Display: `✓ Plans verified. Ready for execution.`
- Proceed to step 14

**If `## ISSUES FOUND`:**
- Display: `Checker found issues:`
- List issues from checker output
- Check iteration count
- Proceed to step 13

## 13. Revision Loop (Max 3 Iterations)

Track: `iteration_count` (starts at 1 after initial plan + check)

**If iteration_count < 3:**

Display: `Sending back to planner for revision... (iteration {N}/3)`

Read current plans for revision context:

```bash
PLANS_CONTENT=$(cat "${UNIT_DIR}"/bolt-*-plan.md 2>/dev/null)
# CONTEXT_CONTENT already loaded in step 4
```

Spawn sdlc-bolt-planner with revision prompt:

```markdown
<revision_context>

**Unit:** {UNIT_ID}
**Mode:** revision

**Existing bolt plans:**
{plans_content}

**Checker issues:**
{structured_issues_from_checker}

**Unit Specification:**
{unit_spec_content}

**Unit Context (if exists):**

IMPORTANT: If unit context exists, revisions MUST still honor user decisions.

{context_content}

</revision_context>

<instructions>
Make targeted updates to address checker issues.
Do NOT replan from scratch unless issues are fundamental.
Revisions must still honor all locked decisions from Unit Context.
Return ## PLANNING COMPLETE when done, listing what changed.
</instructions>
```

```
Task(
  prompt="First, read __AGENTS_DIR__/sdlc-bolt-planner.md for your role and instructions.\n\n" + revision_prompt,
  subagent_type="general-purpose",
  model="{planner_model}",
  description="Revise bolt plans for {UNIT_ID}"
)
```

- After planner returns --> spawn checker again (step 11)
- Increment iteration_count

**If iteration_count >= 3:**

Display:
```
⚠  Max iterations reached. {N} issues remain:
```
- List remaining issues

Use AskUserQuestion:
- header: "Verification"
- question: "3 plan/check iterations completed with issues remaining. How to proceed?"
- options:
  - "Force proceed" -- Execute despite remaining issues
  - "Provide guidance" -- I'll give direction for a final revision
  - "Abandon" -- Exit planning for now

Wait for user response.

- **Force proceed:** Note in audit as `risk-accepted`, proceed to step 14
- **Provide guidance:** Get user guidance, spawn one more revision, proceed to step 14
- **Abandon:** Exit command

## 14. Present Final Status

Route to `<offer_next>`.

</process>

<offer_next>
Output this markdown directly (not as a code block):

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} PLANNED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{UNIT_ID}: {Unit Name}** — {N} bolt plan(s) in {M} wave(s)

| Wave | Bolts | What it builds |
|------|-------|----------------|
| 1    | 01, 02 | [objectives] |
| 2    | 03     | [objective]  |

**Acceptance Criteria Coverage:**

| Criterion | Covered By | Status |
|-----------|------------|--------|
| {AC-01} | bolt-01, bolt-02 | ✓ |
| {AC-02} | bolt-02 | ✓ |
| {AC-03} | bolt-03 | ✓ |

Research: {Completed | Used existing | Skipped}
Verification: {Passed | Passed with override | Skipped}

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Build Unit {NNN}** — execute all {N} bolt plans

`__CMD_PREFIX__build-unit {unit}`

<sub>`/clear` first --> fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `cat .aidlc/construction/unit-{NNN}/bolt-*-plan.md` -- review bolt plans
- `__CMD_PREFIX__plan-unit {unit} --research` -- re-research first
- `__CMD_PREFIX__plan-unit {unit} --gaps` -- close verification gaps

───────────────────────────────────────────────────────────────
</offer_next>

<output>

- `.aidlc/construction/unit-NNN/bolt-NN-plan.md` — Bolt plans (one per bolt)
- `.aidlc/construction/unit-NNN/research.md` — Research findings (if research ran)
- `.aidlc/construction/unit-NNN/design.md` — Unit design (if created)
- Updated `.aidlc/state.md` — Reflects unit planning status

</output>

<success_criteria>
- [ ] .aidlc/ directory validated
- [ ] Inception Exit gate verified as passed
- [ ] Unit validated against inception/units/
- [ ] Unit argument normalized (1 --> 001 --> UNIT-001)
- [ ] Construction directory created (.aidlc/construction/unit-NNN/)
- [ ] CONTEXT.md loaded early (step 4) and passed to ALL agents
- [ ] Unit dependencies checked (warn if incomplete)
- [ ] Research completed (unless --skip-research or --gaps or exists)
- [ ] sdlc-research-synthesizer spawned with CONTEXT.md (constrains research scope)
- [ ] Existing bolt plans checked (continue, replan, or skip)
- [ ] sdlc-bolt-planner spawned with full inlined context
- [ ] Bolt plans created in .aidlc/construction/unit-NNN/bolt-NN-plan.md
- [ ] Plans use correct naming: bolt-01-plan.md, bolt-02-plan.md, etc.
- [ ] sdlc-plan-checker spawned with CONTEXT.md (verifies context compliance)
- [ ] Verification passed OR user override OR max iterations with user decision
- [ ] All unit acceptance criteria covered by at least one bolt
- [ ] Golden Thread intact (must_haves --> acceptance criteria --> REQ-IDs)
- [ ] User sees status between agent spawns
- [ ] User knows next step is `__CMD_PREFIX__build-unit {unit}`
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
| Bolt granularity | Larger bolts (fewer) | Standard (3-5 tasks) | Fine-grained (2-3 tasks) |
| Audit detail | Summary | Standard entries | Detailed with rationale |

If no execution-plan.md exists, default to **Medium Risk**.
</adaptive_depth>
