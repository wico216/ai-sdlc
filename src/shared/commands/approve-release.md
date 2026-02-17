---
name: sdlc:approve-release
description: Approve release gate — Production Ready (Gate 5) for deployment
argument-hint: "[version, e.g., '1.0.0']"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Write
  - Task
  - AskUserQuestion
---

<objective>

Approve the final gate in the AI-SDLC pipeline. Gate 5 — Production Ready — confirms the project is deployable, observable, and rollbackable.

**When to use:**
- After `__CMD_PREFIX__deploy` creates deployment plan, runbooks, and observability config
- After all units complete (all Gate 4s passed)
- When ready to tag a release and/or merge branches

**What this replaces:** `complete-milestone` and `audit-milestone` for the gate-based workflow.

**Principles in play:**
- #6 Proof over Prose: Final gate — all evidence from full pipeline
- #9 Maximize Flow: Clean cutover from Construction to Operations/Complete

</objective>

<execution_context>

@__SDLC_REFS__/gates.md
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/planning-config.md

</execution_context>

<context>
Version: __ARGUMENTS__ (optional — e.g., "1.0.0")

@.aidlc/state.md
@.aidlc/audit.md
@.aidlc/execution-plan.md
@.aidlc/intent.md
</context>

<process>

## 0. Pre-Flight

```bash
[ -d .aidlc ] && echo "AIDLC: exists" || echo "AIDLC: MISSING"
[ -f .aidlc/state.md ] && echo "STATE: exists" || echo "STATE: MISSING"
```

**If .aidlc/ missing:**
```
╔══════════════════════════════════════════════════════════════╗
║  ERROR                                                       ║
╚══════════════════════════════════════════════════════════════╝

No .aidlc/ directory found. Run `__CMD_PREFIX__new-project` first.
```
Exit command.

**Read state.md.** Check all unit gate statuses.

**Check all Gate 4s (UNIT COMPLETE) are passed:**

```bash
# Read state.md Construction Gates table
```

**If any unit has not passed Gate 4:**

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Not all units have passed the UNIT COMPLETE gate:

| Unit | Design Approved | Unit Complete |
|------|-----------------|---------------|
{table from state.md showing status per unit}

──────────────────────────────────────────────────────────────
→ Complete all units before release approval
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Incomplete Units"
- question: "Not all units are complete. How would you like to proceed?"
- options:
  - "Wait" — I'll complete units first (exit)
  - "Proceed anyway" — Release with incomplete units (accepted risk)

If "Wait": Exit command.
If "Proceed anyway": Log in audit as `risk-accepted` with list of incomplete units.

**Parse version from __ARGUMENTS__:**
If no version provided, attempt to derive from config.json, intent.md, or ask:

Use AskUserQuestion:
- header: "Version"
- question: "What version tag should this release use? (e.g., 1.0.0)"

**Resolve commit_docs config:**
```bash
COMMIT_DOCS=$(cat .aidlc/config.json 2>/dev/null | grep -o '"commit_docs"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")
git check-ignore -q .aidlc 2>/dev/null && COMMIT_DOCS=false
```

**Resolve model profile:**
```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-gate-checker | sonnet | sonnet | haiku |

## 1. Gate 5 — PRODUCTION READY

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Production Ready
 Version: {version}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Final gate before production.
```

**Spawn gate checker:**

```
Task(prompt="
First, read __AGENTS_DIR__/sdlc-gate-checker.md for your role and instructions.

Check Gate 5: Production Ready.

Project state: @.aidlc/state.md
Requirements: @.aidlc/requirements.md
Execution plan: @.aidlc/execution-plan.md
Deployment plan: @.aidlc/deployment-plan.md (if exists)
Observability: @.aidlc/observability-config.md (if exists)
Runbooks: .aidlc/runbooks/ (if exists)
All unit verifications: .aidlc/construction/unit-*/VERIFICATION.md

Run all prerequisite checks for Gate 5 and return the structured checklist result.
", subagent_type="sdlc-gate-checker", model="{gate_checker_model}", description="Gate 5 check: Production Ready")
```

**Present gate checklist result to user.**

### If PASSED or PASSED WITH WARNINGS:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Verification Required                           ║
╚══════════════════════════════════════════════════════════════╝

{Gate checker result table}

──────────────────────────────────────────────────────────────
→ Approve or reject Gate 5: PRODUCTION READY
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Gate 5: PRODUCTION READY — v{version}"
- question: "Do you approve this release as production ready? This is the final gate. (Expected approvers: Product Owner + Tech Lead)"
- options:
  - "Approve — ship it" — All clear, create release
  - "Approve with conditions" — Ship but track follow-ups
  - "Reject — not ready" — More work needed

**If approved (or approved with conditions):**

If "Approve with conditions":
- Ask what conditions/follow-ups to track
- Record conditions in audit entry

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-approval
- **Gate:** PRODUCTION READY
- **Actor:** Human
- **Phase:** Operations
- **Context:** Gate 5 — PRODUCTION READY for v{version}
- **Decision:** Release approved.{" Conditions: " + conditions if applicable}
- **Evidence:** .aidlc/deployment-plan.md, .aidlc/runbooks/, .aidlc/observability-config.md, all VERIFICATION.md files
- **Traces to:** All UNIT-IDs, all MUST requirements
```

## 2. Branch Handling

**Read branching strategy:**
```bash
BRANCHING_STRATEGY=$(cat .aidlc/config.json 2>/dev/null | grep -o '"branching_strategy"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:.*"\([^"]*\)"/\1/' || echo "none")
```

**If branching_strategy = "unit":**

List all unit branches:
```bash
git branch --list "sdlc/unit-*" 2>/dev/null
```

If unit branches exist, offer merge options:

Use AskUserQuestion:
- header: "Branch Merge"
- question: "Unit branches exist. How should they be merged?"
- options:
  - "Squash merge (recommended)" — Single clean commit per branch
  - "Merge with history" — Preserves all individual commits
  - "Keep branches" — Handle manually later
  - "Delete without merging" — Discard branch work

Execute chosen merge strategy:
```bash
# For each unit branch, per chosen strategy:
# Squash merge:
git merge --squash {branch} && git commit -m "feat: merge UNIT-{NNN} ({name})"

# Merge with history:
git merge --no-ff {branch}

# Delete:
git branch -D {branch}
```

**If branching_strategy = "project":**

```bash
PROJECT_BRANCH=$(git branch --list "sdlc/*" 2>/dev/null | head -1 | xargs)
```

If project branch exists:

Use AskUserQuestion:
- header: "Branch Merge"
- question: "Project branch '{branch}' exists. How should it be merged to the current branch?"
- options:
  - "Squash merge (recommended)" — Single commit for entire project
  - "Merge with history" — Preserves all commits
  - "Keep branch" — Handle manually

Execute chosen merge strategy.

**If branching_strategy = "none":** Skip branch handling entirely.

## 3. Finalize Release

**Update state.md:**
- Set `Production Ready` gate to `passed` with date
- Update phase to `Operations` or `Complete`
- Update status to `Released — v{version}`
- Set progress to 100%

**Create git tag (if version provided and commit_docs = true):**

```bash
if [ "$COMMIT_DOCS" = "true" ]; then
  git add .aidlc/audit.md .aidlc/state.md
  git commit -m "$(cat <<'EOF'
docs(gate): PRODUCTION READY — Gate 5 passed

Release v{version} approved. All gates passed.
EOF
)"

  git tag -a "v{version}" -m "$(cat <<'EOF'
Release v{version}

Gates passed:
- Requirements Approved ✓
- Inception Exit ✓
- Design Approved ✓ (all units)
- Unit Complete ✓ (all units)
- Production Ready ✓

{Conditions if any}
EOF
)"
fi
```

Use AskUserQuestion:
- header: "Push"
- question: "Tag v{version} created. Push tag to remote?"
- options:
  - "Yes" — Push tag now
  - "No" — I'll push manually later

If "Yes":
```bash
git push origin "v{version}"
```

## 4. Completion

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RELEASE COMPLETE 🎉
 Version: v{version}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**The Golden Thread is complete:**
Intent → Requirements → Units → Design → Code → Tests → Deployment

## All Gates Passed

| Gate | Status | Date |
|------|--------|------|
| 1. Requirements Approved | ✓ | {date} |
| 2. Inception Exit | ✓ | {date} |
| 3. Design Approved | ✓ (all units) | {dates} |
| 4. Unit Complete | ✓ (all units) | {dates} |
| 5. Production Ready | ✓ | {date} |

## Artifacts

| Artifact | Location |
|----------|----------|
| Intent | `.aidlc/intent.md` |
| Requirements | `.aidlc/requirements.md` |
| Execution Plan | `.aidlc/execution-plan.md` |
| Unit Designs | `.aidlc/construction/unit-*/design.md` |
| Verifications | `.aidlc/construction/unit-*/VERIFICATION.md` |
| Deployment Plan | `.aidlc/deployment-plan.md` |
| Runbooks | `.aidlc/runbooks/` |
| Observability | `.aidlc/observability-config.md` |
| Full Audit Trail | `.aidlc/audit.md` |

**Tag:** v{version}
{**Conditions:** {list} — if approved with conditions}

───────────────────────────────────────────────────────────────

## ▶ Next

`__CMD_PREFIX__retro milestone` — Guardrail Retro on the full project (recommended)

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__new-project` — start a new project
- `__CMD_PREFIX__progress` — view final project summary

───────────────────────────────────────────────────────────────
```

**If rejected:**

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-rejection
- **Gate:** PRODUCTION READY
- **Actor:** Human
- **Phase:** Operations
- **Context:** Gate 5 — PRODUCTION READY for v{version}
- **Decision:** Rejected. {reason}
- **Evidence:** Gate checker results
- **Traces to:** {what needs to be fixed}
```

```
Gate 5 rejected. What needs to change before the release can be approved?
```

Wait for user input. Route to appropriate fix action:
- Missing deployment plan -> `__CMD_PREFIX__deploy`
- Failing verifications -> `__CMD_PREFIX__build-unit {unit}` or `__CMD_PREFIX__verify-unit`
- Other issues -> address specifically

### If BLOCKED:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Gate 5: PRODUCTION READY — BLOCKED

{Gate checker result table with failures}

### How to Fix

{Fix guidance from gate checker}

──────────────────────────────────────────────────────────────
→ Resolve the above, then re-run `__CMD_PREFIX__approve-release {version}`
──────────────────────────────────────────────────────────────
```

</process>

<success_criteria>

- [ ] Pre-flight checks passed (.aidlc/ exists, state.md readable)
- [ ] All Gate 4s verified (all units complete, or risk accepted)
- [ ] Version resolved from arguments or user input
- [ ] Gate checker spawned for Gate 5 with all relevant artifacts
- [ ] Gate checklist presented to user with evidence
- [ ] Formal approval obtained via AskUserQuestion
- [ ] Audit trail updated in Gate Records section (gate-approval or gate-rejection)
- [ ] Branch handling executed per branching_strategy config
- [ ] State.md updated to Complete/Released with all gates shown as passed
- [ ] Git tag created with version (if commit_docs = true)
- [ ] User offered to push tag
- [ ] Final completion banner with all artifacts listed
- [ ] User knows next step (retro milestone recommended)

**Proof over Prose:** Final gate aggregates evidence from the entire pipeline.

</success_criteria>

<adaptive_depth>
## Adaptive Depth
Read `.aidlc/execution-plan.md` for the rigor level set during inception.
Adjust your behavior per the Rigor Levels table:

| Aspect | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| Gate formality | Quick review | Evidence checklist | Formal sign-off with all stakeholders |
| Deployment evidence | Plan exists | Plan + runbooks | Plan + runbooks + observability + rollback tested |
| Branch handling | Skip | Offer merge | Require merge before release |
| Tag ceremony | Lightweight tag | Annotated tag | Annotated tag + changelog |
| Audit detail | Summary | Standard entries | Detailed with full evidence chain |

If no execution-plan.md exists, default to **Medium Risk**.
</adaptive_depth>
