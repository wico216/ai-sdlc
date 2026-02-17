---
name: sdlc:elaborate
description: Adaptive inception — AI determines and executes needed elaboration stages
argument-hint: "[--resume] [--stage=requirements|stories|design|plan]"
agent: sdlc-inception
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - WebFetch
  - mcp__context7__*
---

<execution_context>
@__SDLC_REFS__/principles.md
@__SDLC_REFS__/phases.md
@__SDLC_REFS__/gates.md
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/questioning.md
@__SDLC_REFS__/ddd-decomposition.md
@__SDLC_REFS__/question-format-guide.md
@__SDLC_REFS__/overconfidence-prevention.md
@__SDLC_REFS__/error-handling.md
@__SDLC_REFS__/content-validation.md
@__SDLC_REFS__/depth-levels.md
@__SDLC_TEMPLATES__/intent.md
@__SDLC_TEMPLATES__/requirements.md
@__SDLC_TEMPLATES__/user-stories.md
@__SDLC_TEMPLATES__/execution-plan.md
@__SDLC_TEMPLATES__/application-design.md
@__SDLC_TEMPLATES__/unit.md
@__SDLC_TEMPLATES__/risk-register.md
@__SDLC_TEMPLATES__/state.md
</execution_context>

<objective>

Run adaptive Inception elaboration: determine what work is needed, then execute it.

**Replaces:** `inception.md`, `discuss-phase.md`, `research-phase.md` (GSD-era commands)

**When to use:**
- After `__CMD_PREFIX__new-project` — elaborate intent into decomposed work
- After scope changes — re-elaborate specific stages
- When inception artifacts are incomplete or stale

**What it does:**
Spawns the `sdlc-inception` agent which adaptively detects what elaboration is needed based on existing artifacts, then executes those stages. Not a fixed sequence — the agent reads project state and determines the minimum path to inception exit readiness.

**Creates/updates (in `.aidlc/inception/`):**
- `intent.md` — The Golden Thread starting point
- `requirements.md` — Scoped requirements with REQ-IDs
- `user-stories.md` — User journeys (if applicable)
- `application-design.md` — High-level architecture (if applicable)
- `units/UNIT-NNN.md` — Parallel-deliverable work chunks

**Creates/updates (in `.aidlc/`):**
- `execution-plan.md` — Which stages to run, adaptive depth, construction approach
- `risk-register.md` — Identified risks with mitigations
- `state.md` — Phase tracking
- `audit.md` — Append-only decision log

**After this command:** Run `__CMD_PREFIX__approve-inception` to pass gates 1 and 2.

**Principles in play:**
- #2 Reverse Conversation: AI proposes, human approves
- #3 Design Core: DDD for unit boundaries
- #5 Complex Systems: Adaptive depth based on risk
- #6 User Stories as Contract: Stories trace to requirements
- #8 Streamline: Minimize handoffs, each unit is self-contained
- #10 No Hard-Wired Workflows: Context determines which stages run

</objective>

<context>
Arguments: __ARGUMENTS__

**Flags:**
- `--resume` — Continue interrupted inception from last checkpoint
- `--stage=X` — Force a specific stage to run (requirements, stories, design, plan)

Normalize arguments in step 1 before any operations.
</context>

<process>

## 0. Pre-Flight Checks

**MANDATORY — Execute before any user interaction:**

1. **Verify .aidlc/ exists:**
   ```bash
   [ -d .aidlc ] && echo "AIDLC: exists" || echo "AIDLC: MISSING"
   [ -f .aidlc/intent.md ] && echo "INTENT: exists" || echo "INTENT: MISSING"
   [ -f .aidlc/config.json ] && echo "CONFIG: exists" || echo "CONFIG: MISSING"
   ```

   **If .aidlc/ missing:**
   ```
   ╔══════════════════════════════════════════════════════════════╗
   ║  ERROR                                                       ║
   ╚══════════════════════════════════════════════════════════════╝

   Elaboration requires an initialized project.
   Run `__CMD_PREFIX__new-project` first to create .aidlc/ with intent.md.
   ```
   Exit command.

2. **Load project context:**
   Read `.aidlc/intent.md`, `.aidlc/config.json`, and `.aidlc/state.md` (if exists).
   Extract: project name, core value, current phase, last activity.

3. **Detect existing inception artifacts:**
   ```bash
   [ -f .aidlc/inception/requirements.md ] && echo "REQUIREMENTS: exists" || echo "REQUIREMENTS: none"
   [ -d .aidlc/inception/units ] && echo "UNITS: exist ($(ls .aidlc/inception/units/*.md 2>/dev/null | wc -l) files)" || echo "UNITS: none"
   [ -f .aidlc/inception/user-stories.md ] && echo "STORIES: exists" || echo "STORIES: none"
   [ -f .aidlc/inception/application-design.md ] && echo "DESIGN: exists" || echo "DESIGN: none"
   [ -f .aidlc/execution-plan.md ] && echo "EXEC-PLAN: exists" || echo "EXEC-PLAN: none"
   [ -f .aidlc/risk-register.md ] && echo "RISK-REG: exists" || echo "RISK-REG: none"
   ```

4. **Handle --resume flag:**
   If `--resume` in __ARGUMENTS__:
   - Read `.aidlc/state.md` for last checkpoint
   - Skip to the stage recorded as in-progress
   - Display: `Resuming inception from: {stage}`

5. **Handle --stage flag:**
   If `--stage=X` in __ARGUMENTS__:
   - Validate X is one of: requirements, stories, design, plan
   - Skip adaptive detection, run only that stage
   - Display: `Running stage: {X} (forced)`

6. **Handle existing artifacts (no flags):**
   If inception artifacts already exist and no flags provided:

   Use AskUserQuestion:
   - header: "Inception Artifacts Found"
   - question: "Existing inception work detected. What would you like to do?"
   - options:
     - "Continue elaboration" -- Fill gaps in existing artifacts
     - "Re-elaborate from scratch" -- Overwrite existing inception work
     - "Review existing" -- Show current artifacts and status
     - "Skip to gate" -- Check inception gates with existing artifacts

7. **Resolve model profile:**
   ```bash
   MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
   ```

## 1. Parse Arguments

Extract from __ARGUMENTS__:
- `--resume` flag
- `--stage=X` flag (requirements, stories, design, plan)

If both flags present, `--stage` takes precedence.

## 2. Spawn sdlc-inception Agent

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Adaptive Elaboration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ Spawning inception agent...
```

**Read all context files for inlining** (@ references do not work across Task boundaries):

```bash
INTENT_CONTENT=$(cat .aidlc/intent.md 2>/dev/null)
STATE_CONTENT=$(cat .aidlc/state.md 2>/dev/null)
CONFIG_CONTENT=$(cat .aidlc/config.json 2>/dev/null)
REQUIREMENTS_CONTENT=$(cat .aidlc/inception/requirements.md 2>/dev/null)
STORIES_CONTENT=$(cat .aidlc/inception/user-stories.md 2>/dev/null)
DESIGN_CONTENT=$(cat .aidlc/inception/application-design.md 2>/dev/null)
EXEC_PLAN_CONTENT=$(cat .aidlc/execution-plan.md 2>/dev/null)
RISK_REG_CONTENT=$(cat .aidlc/risk-register.md 2>/dev/null)
```

**Also detect workspace type:**
```bash
CODE_FILES=$(find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" -o -name "*.java" 2>/dev/null | grep -v node_modules | grep -v .git | head -5)
HAS_PACKAGE=$([ -f package.json ] || [ -f requirements.txt ] || [ -f Cargo.toml ] || [ -f go.mod ] || [ -f pyproject.toml ] && echo "yes")
HAS_CODEBASE_MAP=$([ -d .aidlc/codebase ] && echo "yes")
```

Fill prompt and spawn:

```markdown
<inception_context>

**Project Intent:**
{intent_content}

**Project State:**
{state_content}

**Config:**
{config_content}

**Workspace:**
- Code files found: {yes/no}
- Package manager: {yes/no}
- Codebase map: {yes/no}
- Type: {greenfield | brownfield | enhancement}

**Existing Artifacts:**
- Requirements: {exists/missing} {requirements_content if exists}
- User Stories: {exists/missing} {stories_content if exists}
- Application Design: {exists/missing} {design_content if exists}
- Execution Plan: {exists/missing} {exec_plan_content if exists}
- Risk Register: {exists/missing} {risk_reg_content if exists}
- Units: {count or "none"}

</inception_context>

<mode>
{
  "resume": {true/false},
  "forced_stage": "{stage or null}",
  "action": "{continue | fresh | forced_stage}"
}
</mode>

<instructions>

You are the sdlc-inception agent. Your job is to take a project from intent to decomposed, plannable work.

**Adaptive detection:** Based on the existing artifacts above, determine which stages need to run:

1. **Requirements Analysis** — If requirements.md missing or incomplete
2. **User Stories** — If the project has UI/multiple users AND stories missing
3. **Application Design** — If new components needed AND design missing
4. **Execution Planning** — If execution-plan.md missing
5. **Unit Decomposition** — If units missing or incomplete
6. **Risk Assessment** — If risk-register.md missing

Skip stages where artifacts already exist and are complete. Present your assessment before executing.

**For each stage you run:**
- Use the Reverse Conversation pattern (Principle #2): propose, present, get approval
- Write clarifying questions to `.aidlc/inception/questions/` using structured format from `question-format-guide.md`
- Run contradiction detection on answers before proceeding (see `question-format-guide.md`)
- Apply overconfidence prevention: default to asking, never assume (see `overconfidence-prevention.md`)
- Validate content before writing (see `content-validation.md`); use `depth-levels.md` for detail calibration
- Handle errors per `error-handling.md` — log to audit.md
- Use AskUserQuestion only for binary decisions (proceed/revise, gate approval)
- Write artifacts to `.aidlc/inception/` (requirements, stories, design, units)
- Write cross-cutting artifacts to `.aidlc/` (execution-plan, risk-register, state, audit)
- Commit after each stage (if commit_docs is true)

**Unit decomposition MUST follow DDD protocol:**
1. Identify bounded contexts from requirements
2. Map domain events per context
3. Define aggregates within each context
4. Derive units from aggregates (each unit = one or more aggregates)
5. Validate 100% requirement coverage

**Key constraints:**
- Every v1 requirement must map to exactly one unit
- Every unit must have measurable acceptance criteria
- Units must trace back to REQ-IDs (Golden Thread)
- Bolt plans live at `.aidlc/construction/unit-NNN/bolt-NN-plan.md`
- Summaries at `.aidlc/construction/unit-NNN/bolt-NN-summary.md`

</instructions>

<quality_gate>
Before declaring inception complete:
- [ ] All required stages executed (per adaptive detection)
- [ ] Requirements documented with REQ-IDs
- [ ] Units defined with acceptance criteria and DDD boundaries
- [ ] Every v1 requirement mapped to exactly one unit
- [ ] Execution plan created with adaptive depth settings
- [ ] Risk register populated
- [ ] State.md updated
- [ ] Audit trail has entries for all decisions
</quality_gate>
```

**Model lookup table:**

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-inception | opus | opus | sonnet |

```
Task(
  prompt="First, read __AGENTS_DIR__/sdlc-inception.md for your role and instructions.\n\n" + filled_prompt,
  subagent_type="general-purpose",
  model="{inception_model}",
  description="Inception elaboration"
)
```

## 3. Handle Agent Return

**If inception agent completes successfully:**
- Display stage summary (which stages ran, artifacts created)
- Proceed to step 4

**If checkpoint reached:**
- Present checkpoint to user
- Get response
- Spawn continuation with checkpoint context

**If blocked:**
- Display blocker information
- Offer: 1) Provide context, 2) Skip stage, 3) Abort
- Wait for user response

## 4. Present Completion Status

Display artifact summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION ELABORATION COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Project Name}** — Ready for gate review

| Artifact | Location | Status |
|----------|----------|--------|
| Intent | `.aidlc/intent.md` | ✓ |
| Requirements | `.aidlc/inception/requirements.md` | {✓ / ○} |
| User Stories | `.aidlc/inception/user-stories.md` | {✓ / ○ / N/A} |
| Application Design | `.aidlc/inception/application-design.md` | {✓ / ○ / N/A} |
| Units | `.aidlc/inception/units/` ({N} units) | {✓ / ○} |
| Execution Plan | `.aidlc/execution-plan.md` | {✓ / ○} |
| Risk Register | `.aidlc/risk-register.md` | {✓ / ○} |

**Units:** {N} | **Estimated Bolts:** {N} | **Risks:** {N}
**Requirements Coverage:** {X}/{Y} v1 requirements mapped (100%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Route to `<offer_next>`.

</process>

<offer_next>
Output this markdown directly (not as a code block):

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Approve Inception** — pass gates 1 (Requirements Approved) and 2 (Inception Exit)

`__CMD_PREFIX__approve-inception`

<sub>`/clear` first --> fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__elaborate --stage=requirements` -- re-run requirements stage only
- `__CMD_PREFIX__elaborate --stage=plan` -- re-run execution planning only
- `cat .aidlc/inception/units/UNIT-*.md` -- review unit definitions
- `cat .aidlc/execution-plan.md` -- review execution plan

───────────────────────────────────────────────────────────────
</offer_next>

<output>

- `.aidlc/intent.md` — The Golden Thread starting point (may be updated)
- `.aidlc/inception/requirements.md` — Scoped requirements with REQ-IDs
- `.aidlc/inception/user-stories.md` — User journeys (if applicable)
- `.aidlc/inception/application-design.md` — High-level architecture (if applicable)
- `.aidlc/inception/units/UNIT-NNN.md` — Parallel-deliverable work chunks
- `.aidlc/execution-plan.md` — Which stages run, adaptive depth, construction approach
- `.aidlc/risk-register.md` — Identified risks with mitigations
- `.aidlc/audit.md` — Append-only decision log (initialized or appended)
- Updated `.aidlc/state.md` — Reflects inception completion status

</output>

<success_criteria>

- [ ] Pre-flight checks passed (.aidlc/ and intent.md exist)
- [ ] Arguments parsed correctly (--resume, --stage flags)
- [ ] Existing artifacts detected and handled (continue, fresh, or forced stage)
- [ ] sdlc-inception agent spawned with full inlined context
- [ ] Adaptive stage detection correct (only missing/incomplete stages run)
- [ ] Requirements documented with REQ-IDs (if stage ran)
- [ ] User stories generated if applicable (if stage ran)
- [ ] Application design created if applicable (if stage ran)
- [ ] Units decomposed with DDD boundaries (if stage ran)
- [ ] All v1 requirements mapped to exactly one unit (100% coverage)
- [ ] Execution plan created with adaptive depth (if stage ran)
- [ ] Risk register populated (if stage ran)
- [ ] State.md updated to reflect inception status
- [ ] Audit trail has entries for decisions and stage completions
- [ ] User sees artifact summary with status indicators
- [ ] User knows next step is `__CMD_PREFIX__approve-inception`

**Proof over Prose:** Every artifact must exist on disk, not just claimed as complete.

</success_criteria>

<adaptive_depth>
## Adaptive Depth
Read `.aidlc/execution-plan.md` for the rigor level set during inception.
Adjust your behavior per the Rigor Levels table:

| Aspect | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| Gate formality | Quick review | Evidence checklist | Formal sign-off |
| Questioning depth | Brief clarification | Standard exploration | Deep investigation |
| Requirements detail | Bullet points | Full REQ-IDs with priorities | REQ-IDs + acceptance tests |
| Unit decomposition | Simple split | DDD bounded contexts | Full DDD with event mapping |
| Risk assessment | Top 3 risks | Comprehensive register | Register + mitigation plans |
| Audit detail | Summary | Standard entries | Detailed with rationale |

If no execution-plan.md exists yet, default to **Medium Risk** and create the plan as part of elaboration.
</adaptive_depth>
