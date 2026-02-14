---
name: sdlc:inception
description: Run the full Inception phase — from intent to units with gates and evidence
allowed-tools:
  - Read
  - Bash
  - Write
  - Edit
  - Task
  - AskUserQuestion
  - Glob
  - Grep
---

<objective>

Run the AI-SDLC Inception phase: convert intent into testable, decomposed work.

**When to use:**
- After `__CMD_PREFIX__new-project` (greenfield — PROJECT.md and REQUIREMENTS.md already exist)
- After `__CMD_PREFIX__new-milestone` (brownfield — adding to existing project)
- Standalone, when you have a PROJECT.md + REQUIREMENTS.md and need to decompose into units

**Creates:**
- `.aidlc/intent.md` — The Golden Thread starting point
- `.aidlc/units/UNIT-NNN.md` — Parallel-deliverable work chunks
- `.aidlc/risk-register.md` — Identified risks with mitigations
- `.aidlc/execution-plan.md` — Which stages to run and how
- `.aidlc/audit.md` — Append-only decision log (initialized or appended to)
- Updates `.aidlc/STATE.md` — Phase tracking

**After this command:** The Inception Exit gate must be passed, then run `__CMD_PREFIX__plan-phase 1` to begin Construction.

**Principles in play:**
- #2 Reverse Conversation: AI proposes, human approves
- #3 Design Core: DDD for unit boundaries
- #5 Complex Systems: Adaptive depth based on risk
- #6 User Stories as Contract: Stories trace to requirements
- #8 Streamline: Minimize handoffs, each unit is self-contained
- #10 No Hard-Wired Workflows: Context determines which stages run

</objective>

<execution_context>

@__SDLC_REFS__/principles.md
@__SDLC_REFS__/phases.md
@__SDLC_REFS__/gates.md
@__SDLC_TEMPLATES__/intent.md
@__SDLC_TEMPLATES__/unit.md
@__SDLC_TEMPLATES__/risk-register.md
@__SDLC_TEMPLATES__/execution-plan.md
@__SDLC_TEMPLATES__/audit.md

</execution_context>

<process>

## Stage 0: Pre-Flight Checks

**MANDATORY — Execute before any user interaction:**

1. **Verify prerequisites exist:**
   ```bash
   [ -f .aidlc/PROJECT.md ] && echo "PROJECT: exists" || echo "PROJECT: MISSING"
   [ -f .aidlc/REQUIREMENTS.md ] && echo "REQUIREMENTS: exists" || echo "REQUIREMENTS: MISSING"
   [ -f .aidlc/ROADMAP.md ] && echo "ROADMAP: exists" || echo "ROADMAP: MISSING"
   [ -f .aidlc/config.json ] && echo "CONFIG: exists" || echo "CONFIG: MISSING"
   ```

   **If PROJECT.md or REQUIREMENTS.md missing:**
   ```
   Inception requires PROJECT.md and REQUIREMENTS.md.
   Run `__CMD_PREFIX__new-project` first to initialize the project.
   ```
   Exit command.

2. **Check if Inception already completed:**
   ```bash
   [ -d .aidlc/units ] && echo "UNITS: exist ($(ls .aidlc/units/*.md 2>/dev/null | wc -l) files)" || echo "UNITS: none"
   [ -f .aidlc/intent.md ] && echo "INTENT: exists" || echo "INTENT: none"
   [ -f .aidlc/audit.md ] && echo "AUDIT: exists" || echo "AUDIT: none"
   ```

   **If units already exist:**
   Use AskUserQuestion:
   - header: "Re-run?"
   - question: "Inception artifacts already exist. What would you like to do?"
   - options:
     - "Re-run Inception" — Start fresh (existing artifacts will be overwritten)
     - "Review existing" — Show current units and risk register
     - "Skip to gate" — Check Inception Exit gate with existing artifacts

3. **Load project context:**
   Read `.aidlc/PROJECT.md`, `.aidlc/REQUIREMENTS.md`, `.aidlc/config.json`, and `.aidlc/ROADMAP.md`.
   Extract: project name, core value, requirements list, phase structure.

4. **Resolve model profile:**
   ```bash
   MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
   ```

## Stage 1: Workspace Detection

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Workspace Detection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Detect project type:
```bash
CODE_FILES=$(find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" -o -name "*.java" 2>/dev/null | grep -v node_modules | grep -v .git | head -5)
HAS_PACKAGE=$([ -f package.json ] || [ -f requirements.txt ] || [ -f Cargo.toml ] || [ -f go.mod ] || [ -f pyproject.toml ] && echo "yes")
HAS_CODEBASE_MAP=$([ -d .aidlc/codebase ] && echo "yes")
```

Determine type:
- **Greenfield:** No code files, no package files
- **Brownfield:** Code exists
- **Enhancement:** Code exists + codebase map exists

Record classification. This informs which stages are required (Stage 2 is brownfield-only).

## Stage 2: Reverse Engineering (brownfield only)

**Skip if greenfield.**

If brownfield and `.aidlc/codebase/` doesn't exist:
```
Existing code detected. Running codebase analysis...
```
Suggest running `__CMD_PREFIX__map-codebase` and returning. Or if codebase map exists, read key findings.

## Stage 3: Create Intent Document

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Intent Capture
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Synthesize intent from existing artifacts.**

Read PROJECT.md and REQUIREMENTS.md. Draft the intent document using the `intent.md` template:
- Problem statement (from PROJECT.md pain points)
- Vision (from PROJECT.md core value)
- Success criteria (from REQUIREMENTS.md + PROJECT.md)
- Scope (from REQUIREMENTS.md v1/v2/out-of-scope)
- Constraints (from PROJECT.md)
- Stakeholders (from PROJECT.md or infer)

Present the draft to the user:

```
## Intent Document (Draft)

**Problem:** {synthesized problem}
**Vision:** {synthesized vision}
**Success Criteria:**
1. {criterion}
2. {criterion}

**In Scope (v1):** {count} requirements across {N} categories
**Out of Scope:** {list}

Does this capture your intent accurately?
```

Use AskUserQuestion:
- header: "Intent"
- question: "Does this intent document capture what you're building?"
- options:
  - "Looks good" — Save and continue
  - "Needs changes" — Let me refine

If "Needs changes": ask what to change, iterate until approved.

**Save intent.md:**
Write to `.aidlc/intent.md` using the template.

**Initialize audit trail:**
If `.aidlc/audit.md` doesn't exist, create it with header.
Append first entry:
```
### Entry #1 — {timestamp}
- **Type:** decision
- **Actor:** Both
- **Phase:** Inception
- **Context:** Intent document creation
- **Decision:** Intent approved — captures problem, vision, and success criteria
- **Evidence:** .aidlc/intent.md
- **Traces to:** All REQ-IDs
```

**Commit:**
```bash
mkdir -p .aidlc
git add .aidlc/intent.md .aidlc/audit.md
git commit -m "$(cat <<'EOF'
docs(inception): capture project intent

Intent document synthesized from project context and requirements.
Audit trail initialized.
EOF
)"
```

## Stage 4: Create Execution Plan

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Execution Planning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Adaptive Depth assessment.**

Based on project classification and requirements count, propose:
- Which Inception stages apply
- Bolt sizing for Construction
- Gate rigor level
- Operations approach

Use `execution-plan.md` template. Present to user:

```
## Execution Plan

| Stage | Required? | Status |
|---|---|---|
| Workspace Detection | Yes | Done |
| Reverse Engineering | {Yes/No} | {Done/N/A} |
| Requirements Analysis | Yes | Done (via __CMD_PREFIX__new-project) |
| User Stories | {Yes/No} | Pending |
| Workflow Planning | Yes | This step |
| Application Design | {Yes/No} | Pending |
| Units Generation | Yes | Pending |

**Construction:** {bolt sizing} bolts, {parallel/sequential}
**Gate rigor:** {Light/Standard/Formal}
```

Use AskUserQuestion:
- header: "Plan"
- question: "Does this execution plan work?"
- options:
  - "Approve plan" — Continue with these settings
  - "Adjust" — Change what's needed

Save to `.aidlc/execution-plan.md`.

## Stage 5: User Stories (conditional)

**Skip if execution plan marks this as N/A (e.g., pure backend, CLI tool, library).**

If applicable:

Present AI-proposed user stories derived from requirements:

```
## User Stories

### STORY-001: Account Creation
As a {persona}, I want to {action} so that {benefit}.
Acceptance: {criteria}
Traces to: AUTH-01, AUTH-02

### STORY-002: {title}
...
```

Use AskUserQuestion:
- header: "Stories"
- question: "Do these user stories capture the user journeys?"
- options:
  - "Looks good" — Continue
  - "Add stories" — I have more scenarios
  - "Revise" — These need changes

Iterate until approved. Stories go into `.aidlc/requirements.md` (append a User Stories section) or a separate `.aidlc/stories/` directory.

## Stage 6: Units Generation

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Unit Decomposition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**This is the core Inception deliverable.**

Apply DDD principles (Principle #3) to decompose requirements into parallel-deliverable units:

1. **Identify bounded contexts** from requirements and domain analysis
2. **Group requirements** into units by bounded context
3. **Define interfaces** between units (what each provides/depends on)
4. **Size each unit** in estimated bolts (1-5 bolts each, Principle #7)
5. **Map acceptance criteria** from requirements to unit-level checks

**AI proposes, human refines (Principle #2):**

Present proposed units:

```
## Proposed Units

### UNIT-001: {Name} ({N} bolts)
Bounded context: {domain area}
Requirements: {REQ-IDs}
Acceptance criteria:
- [ ] {criterion from requirements}
- [ ] {criterion from requirements}
Dependencies: None / {UNIT-IDs}

### UNIT-002: {Name} ({N} bolts)
...

---

**Summary:** {N} units, {total bolts} estimated bolts
**Parallelizable:** {which units can run simultaneously}
**Critical path:** UNIT-{X} → UNIT-{Y} → UNIT-{Z}
```

Use AskUserQuestion:
- header: "Units"
- question: "Does this decomposition make sense? Every requirement should be covered."
- options:
  - "Approve units" — Save and continue
  - "Merge units" — Some should be combined
  - "Split units" — Some are too large
  - "Adjust" — Other changes needed

Iterate until approved.

**Save units:**
```bash
mkdir -p .aidlc/units
```

Write each unit to `.aidlc/units/UNIT-NNN.md` using the `unit.md` template.

**Verify requirement coverage:**
Every REQ-ID in REQUIREMENTS.md v1 must appear in exactly one unit. If gaps found, surface them.

**Audit entry:**
```
### Entry #{N} — {timestamp}
- **Type:** decision
- **Actor:** Both
- **Phase:** Inception
- **Context:** Unit decomposition
- **Decision:** {N} units created covering {X} requirements. Critical path: {path}
- **Evidence:** .aidlc/units/
- **Traces to:** All v1 REQ-IDs
```

**Commit:**
```bash
git add .aidlc/units/
git commit -m "$(cat <<'EOF'
docs(inception): decompose into {N} units

Units: {list unit names}
Total estimated bolts: {N}
All v1 requirements mapped.
EOF
)"
```

## Stage 7: Risk Register

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION: Risk Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**AI identifies risks from all artifacts gathered so far:**

Sources of risk:
- Technical complexity (from requirements + research)
- Dependencies between units
- External integrations
- Knowledge gaps (TBDs in intent/requirements)
- Timeline pressure (from PROJECT.md)
- Team capacity constraints

Present risk register:

```
## Risks Identified

| ID | Risk | Impact | Likelihood | Severity | Mitigation |
|---|---|---|---|---|---|
| RISK-001 | {risk} | {H/M/L} | {H/M/L} | {critical/major/minor} | {mitigation} |
| RISK-002 | {risk} | {H/M/L} | {H/M/L} | {severity} | {mitigation} |
```

Use AskUserQuestion:
- header: "Risks"
- question: "Any risks I'm missing? Any of these should be accepted rather than mitigated?"
- options:
  - "Looks complete" — Save risk register
  - "Add risks" — I know of more
  - "Accept some" — Mark certain risks as accepted

Save to `.aidlc/risk-register.md` using template.

**Commit:**
```bash
git add .aidlc/risk-register.md
git commit -m "$(cat <<'EOF'
docs(inception): create risk register

{N} risks identified. {critical count} critical, {major count} major, {minor count} minor.
EOF
)"
```

## Stage 8: GATE — Requirements Approved

Display gate banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Requirements Approved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Present evidence checklist:**

```
## Gate: Requirements Approved

Evidence:
- [x] Intent document exists and is complete → .aidlc/intent.md
- [x] Requirements documented with IDs → .aidlc/REQUIREMENTS.md ({N} requirements)
- [x] Success criteria are measurable → .aidlc/intent.md (criteria section)
- [x] Scope boundaries defined → .aidlc/REQUIREMENTS.md (v1/v2/out-of-scope)
- [x] Stakeholders identified → .aidlc/intent.md (stakeholders section)

All evidence items satisfied.
```

Use AskUserQuestion:
- header: "Gate"
- question: "Do you approve the Requirements Approved gate? This confirms the WHAT and WHY."
- options:
  - "Approve gate" — Requirements are clear, proceed to decomposition review
  - "Reject gate" — Something needs to change before proceeding

**If approved:** Audit entry with type `gate-approval`.
**If rejected:** Audit entry with type `gate-rejection`. Ask what needs to change, loop back to relevant stage.

## Stage 9: GATE — INCEPTION EXIT

Display gate banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: INCEPTION EXIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 This is the most important gate in AI-SDLC.
 Construction should NOT begin until intent is crystal clear.
```

**Present evidence checklist:**

```
## Gate: INCEPTION EXIT

Evidence:
- [x] All applicable Inception stages completed
- [x] {N} units defined with acceptance criteria → .aidlc/units/
- [x] Risk register populated ({N} risks) → .aidlc/risk-register.md
- [x] Execution plan approved → .aidlc/execution-plan.md
- [x] User stories trace to requirements (if applicable)
- [ ] No critical unresolved risks → {status}

Requirements coverage: {X}/{Y} v1 requirements mapped to units (100%)
Estimated total bolts: {N}
Critical path: {UNIT-X} → {UNIT-Y} → {UNIT-Z}
```

Use AskUserQuestion:
- header: "Exit Gate"
- question: "Do you approve the Inception Exit gate? This allows Construction to begin."
- options:
  - "Approve — begin Construction" — All clear, let's build
  - "Reject — more Inception work needed" — Not ready yet

**If approved:**

Audit entry:
```
### Entry #{N} — {timestamp}
- **Type:** gate-approval
- **Actor:** Human
- **Phase:** Inception
- **Context:** INCEPTION EXIT gate
- **Decision:** Inception complete. {N} units approved for Construction. {N} risks identified.
- **Evidence:** .aidlc/units/, .aidlc/risk-register.md, .aidlc/execution-plan.md
- **Traces to:** All v1 REQ-IDs
```

Update STATE.md: phase = Construction, status = "Ready to plan first unit"

**Commit:**
```bash
git add .aidlc/audit.md .aidlc/STATE.md .aidlc/execution-plan.md
git commit -m "$(cat <<'EOF'
docs(inception): INCEPTION EXIT gate approved

Inception complete. Ready for Construction.
{N} units, {N} bolts estimated, {N} risks tracked.
EOF
)"
```

**If rejected:**

Audit entry with `gate-rejection`. Ask what's missing. Route back to the relevant stage.

## Stage 10: Completion

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Project Name}** — Ready for Construction

| Artifact | Location |
|---|---|
| Intent | `.aidlc/intent.md` |
| Requirements | `.aidlc/REQUIREMENTS.md` |
| Units | `.aidlc/units/` ({N} units) |
| Risk Register | `.aidlc/risk-register.md` |
| Execution Plan | `.aidlc/execution-plan.md` |
| Audit Trail | `.aidlc/audit.md` |

**Units:** {N} | **Bolts:** {estimated} | **Risks:** {N}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ▶ Next: Construction

Start building the first unit:

__CMD_PREFIX__plan-phase 1 — plan the first unit's bolts

<sub>/clear first → fresh context window</sub>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<output>

- `.aidlc/intent.md` — The Golden Thread starting point
- `.aidlc/execution-plan.md` — Which stages run, adaptive depth settings
- `.aidlc/units/UNIT-NNN.md` — Parallel-deliverable work chunks (1 file per unit)
- `.aidlc/risk-register.md` — Identified risks with mitigations
- `.aidlc/audit.md` — Append-only decision log (initialized or appended)
- Updated `.aidlc/STATE.md` — Reflects Construction readiness

</output>

<success_criteria>

- [ ] Pre-flight checks passed (PROJECT.md + REQUIREMENTS.md exist)
- [ ] Workspace detection completed (greenfield/brownfield classified)
- [ ] Intent document created and approved → **committed**
- [ ] Execution plan created with adaptive depth → **committed**
- [ ] User stories generated (if applicable)
- [ ] Units decomposed with DDD boundaries → **committed**
- [ ] All v1 requirements mapped to exactly one unit (100% coverage)
- [ ] Risk register populated → **committed**
- [ ] Gate: Requirements Approved — passed with evidence
- [ ] Gate: INCEPTION EXIT — passed with evidence
- [ ] Audit trail has entries for both gates
- [ ] STATE.md updated to reflect Construction readiness
- [ ] User knows next step is `__CMD_PREFIX__plan-phase 1`

**Proof over Prose:** Every gate must show evidence, not just claim completion.

</success_criteria>
