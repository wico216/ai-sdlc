---
name: sdlc:approve-unit
description: Approve unit gates — Design Approved (Gate 3) before building, Unit Complete (Gate 4) after building
argument-hint: "<unit> [--design | --complete]"
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

Approve per-unit Construction gates. Each unit passes through two gates:

**Gate 3 — Design Approved:** Architecture reviewed, interfaces defined, acceptance criteria mapped. Must pass before building.
**Gate 4 — UNIT COMPLETE:** Tests pass, all acceptance criteria met, no regressions. Must pass after building.

**When to use:**
- `--design`: After `__CMD_PREFIX__plan-unit` creates the design document, before `__CMD_PREFIX__build-unit`
- `--complete`: After `__CMD_PREFIX__build-unit` finishes all bolts
- No flag: Auto-detect based on unit state

**Principles in play:**
- #6 Proof over Prose: Gate evidence from artifacts, not claims
- #2 Reverse Conversation: AI collects evidence, human approves
- #3 Design Core: Design gate enforces thinking before building

</objective>

<execution_context>

@__SDLC_REFS__/gates.md
@__SDLC_REFS__/ui-brand.md

</execution_context>

<context>
Unit: __ARGUMENTS__ (e.g., "001", "UNIT-001", "001 --design", "3 --complete")

@.aidlc/state.md
@.aidlc/audit.md
@.aidlc/execution-plan.md
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

**Parse __ARGUMENTS__:**

Extract unit identifier and optional flag:
- Unit: normalize to zero-padded 3-digit (e.g., "1" -> "001", "UNIT-003" -> "003")
- Flag: `--design` or `--complete` (optional)

```bash
# Verify unit construction directory exists
ls .aidlc/construction/unit-{NNN}/ 2>/dev/null
```

**If unit directory missing:**
```
╔══════════════════════════════════════════════════════════════╗
║  ERROR                                                       ║
╚══════════════════════════════════════════════════════════════╝

Unit {NNN} construction directory not found at .aidlc/construction/unit-{NNN}/.
Run `__CMD_PREFIX__plan-unit {NNN}` first to create the unit's design and bolt plans.
```
Exit command.

**Resolve commit_docs config:**
```bash
COMMIT_DOCS=$(cat .aidlc/config.json 2>/dev/null | grep -o '"commit_docs"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")
git check-ignore -q .aidlc 2>/dev/null && COMMIT_DOCS=false
```

**Read state.md** to determine current gate status for this unit.

**Resolve model profile:**
```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-gate-checker | sonnet | sonnet | haiku |

## 1. Determine Which Gate to Check

**If `--design` flag:** Check Gate 3 (Design Approved).
**If `--complete` flag:** Check Gate 4 (UNIT COMPLETE).
**If no flag — auto-detect:**

```bash
# Check if design exists
[ -f .aidlc/construction/unit-{NNN}/design.md ] && echo "DESIGN: exists" || echo "DESIGN: MISSING"

# Check if bolts have been executed (summaries exist)
ls .aidlc/construction/unit-{NNN}/bolt-*-summary.md 2>/dev/null | wc -l
```

- Design exists but no bolt summaries -> Gate 3 (Design Approved)
- Bolt summaries exist -> Gate 4 (UNIT COMPLETE)
- No design exists -> Error: run `__CMD_PREFIX__plan-unit {NNN}` first
- Both gates already passed -> inform user, suggest next step

**If both gates already passed for this unit:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN}: Gates Already Passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Both construction gates for UNIT-{NNN} have been approved:
- Design Approved: passed ({date})
- Unit Complete: passed ({date})
```

Suggest `__CMD_PREFIX__retro {NNN}` or `__CMD_PREFIX__plan-unit {next-unit}`.
Exit command.

## 2. Gate 3 — Design Approved

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Design Approved
 Unit: UNIT-{NNN} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Spawn gate checker:**

```
Task(prompt="
First, read __AGENTS_DIR__/sdlc-gate-checker.md for your role and instructions.

Check Gate 3: Design Approved for UNIT-{NNN}.

Project state: @.aidlc/state.md
Unit design: @.aidlc/construction/unit-{NNN}/design.md
Requirements: @.aidlc/inception/requirements.md
Execution plan: @.aidlc/execution-plan.md

Run all prerequisite checks for Gate 3 and return the structured checklist result.
", subagent_type="sdlc-gate-checker", model="{gate_checker_model}", description="Gate 3 check: Design Approved for UNIT-{NNN}")
```

**Present gate checklist result to user.**

### If PASSED or PASSED WITH WARNINGS:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Verification Required                           ║
╚══════════════════════════════════════════════════════════════╝

{Gate checker result table}

──────────────────────────────────────────────────────────────
→ Approve or reject Gate 3: Design Approved for UNIT-{NNN}
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Gate 3: Design Approved — UNIT-{NNN}"
- question: "Do you approve this unit's design? This allows building to begin. (Expected approver: Tech Lead)"
- options:
  - "Approve design" — Proceed to building
  - "Revise design" — Needs changes before building
  - "Reject" — Design fundamentally wrong, rethink approach

**If approved:**

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-approval
- **Gate:** Design Approved
- **Actor:** Human
- **Phase:** Construction
- **Context:** Gate 3 — Design Approved for UNIT-{NNN}
- **Decision:** Design approved. Architecture, interfaces, and acceptance criteria mapping reviewed.
- **Evidence:** .aidlc/construction/unit-{NNN}/design.md
- **Traces to:** UNIT-{NNN}, {REQ-IDs from design}
```

Update state.md:
- Set `Design Approved` for UNIT-{NNN} to `passed` with date
- Update current focus to UNIT-{NNN}

Update design.md frontmatter: set `status: approved`.

Conditional commit:
```bash
if [ "$COMMIT_DOCS" = "true" ]; then
  git add .aidlc/audit.md .aidlc/state.md .aidlc/construction/unit-{NNN}/design.md
  git commit -m "$(cat <<'EOF'
docs(gate): Design Approved — UNIT-{NNN} Gate 3 passed

Design reviewed and approved for UNIT-{NNN}: {Unit Name}.
EOF
)"
fi
```

Present next step:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► DESIGN APPROVED ✓
 Unit: UNIT-{NNN} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Build unit** — execute bolt plans

`__CMD_PREFIX__build-unit {NNN}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────
```

**If revise:** Ask what to change. User updates design, then re-run this command.
**If rejected:** Audit entry with `gate-rejection`. Route back to `__CMD_PREFIX__plan-unit {NNN}`.

### If BLOCKED:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Gate 3: Design Approved — BLOCKED for UNIT-{NNN}

{Gate checker result table with failures}

### How to Fix

{Fix guidance from gate checker}

──────────────────────────────────────────────────────────────
→ Resolve the above, then re-run `__CMD_PREFIX__approve-unit {NNN} --design`
──────────────────────────────────────────────────────────────
```

## 3. Gate 4 — UNIT COMPLETE

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Unit Complete
 Unit: UNIT-{NNN} — {Unit Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Verify Gate 3 passed first:**
Check state.md — if Design Approved is not `passed` for this unit:
```
Gate 3 (Design Approved) must pass before Gate 4 can be checked.
Run `__CMD_PREFIX__approve-unit {NNN} --design` first.
```
Exit command.

**Spawn gate checker:**

```
Task(prompt="
First, read __AGENTS_DIR__/sdlc-gate-checker.md for your role and instructions.

Check Gate 4: Unit Complete for UNIT-{NNN}.

Project state: @.aidlc/state.md
Unit construction dir: .aidlc/construction/unit-{NNN}/
Bolt summaries: .aidlc/construction/unit-{NNN}/bolt-*-summary.md
Bolt plans: .aidlc/construction/unit-{NNN}/bolt-*-plan.md
Verification: .aidlc/construction/unit-{NNN}/validation-report.md
Requirements: @.aidlc/inception/requirements.md

Run all prerequisite checks for Gate 4 and return the structured checklist result.
", subagent_type="sdlc-gate-checker", model="{gate_checker_model}", description="Gate 4 check: Unit Complete for UNIT-{NNN}")
```

**Present gate checklist result to user.**

### If PASSED or PASSED WITH WARNINGS:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Verification Required                           ║
╚══════════════════════════════════════════════════════════════╝

{Gate checker result table}

──────────────────────────────────────────────────────────────
→ Approve or reject Gate 4: UNIT COMPLETE for UNIT-{NNN}
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Gate 4: UNIT COMPLETE — UNIT-{NNN}"
- question: "Do you approve this unit as complete? All acceptance criteria met, tests passing. (Expected approver: QA / Tech Lead)"
- options:
  - "Approve — unit done" — Mark unit complete
  - "Not yet — more work needed" — Plan another bolt
  - "Reject" — Significant issues, needs rework

**If approved:**

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-approval
- **Gate:** UNIT COMPLETE
- **Actor:** Human
- **Phase:** Construction
- **Context:** Gate 4 — UNIT COMPLETE for UNIT-{NNN}
- **Decision:** Unit complete. All acceptance criteria met, tests passing, no regressions.
- **Evidence:** .aidlc/construction/unit-{NNN}/validation-report.md, bolt summaries
- **Traces to:** UNIT-{NNN}, {REQ-IDs satisfied}
```

Update state.md:
- Set `Unit Complete` for UNIT-{NNN} to `passed` with date
- Update progress bar based on units completed vs total
- Update status

Conditional commit:
```bash
if [ "$COMMIT_DOCS" = "true" ]; then
  git add .aidlc/audit.md .aidlc/state.md
  git commit -m "$(cat <<'EOF'
docs(gate): UNIT COMPLETE — UNIT-{NNN} Gate 4 passed

UNIT-{NNN} ({Unit Name}) complete. All acceptance criteria met.
EOF
)"
fi
```

**Check if all units are now complete:**

```bash
# Count total units and completed units from state.md
```

**If more units remain:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**UNIT-{NNN}: {Unit Name}** — Complete

Progress: {progress bar} {X}/{Y} units

| Unit | Design | Complete |
|------|--------|----------|
{status table for all units}

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Retro** — review what went well/poorly (recommended)

`__CMD_PREFIX__retro {NNN}`

**Or plan next unit:**

`__CMD_PREFIX__plan-unit {next-unit}`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────
```

**If ALL units now complete:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► UNIT {NNN} COMPLETE ✓
 ALL UNITS COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All {Y} units have passed the Unit Complete gate.

| Unit | Design | Complete |
|------|--------|----------|
{all units showing ✓ passed}

Construction phase complete. Ready for Operations.

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Deploy** — prepare for production (deployment plan, runbooks, observability)

`__CMD_PREFIX__operations`

**Or approve release directly:**

`__CMD_PREFIX__approve-release`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__retro {NNN}` — retro on this unit first (recommended)
- `__CMD_PREFIX__retro release` — retro on the full project

───────────────────────────────────────────────────────────────
```

**If not yet:** Identify remaining work. Suggest `__CMD_PREFIX__build-unit {NNN}` for another bolt.
**If rejected:** Audit entry with `gate-rejection`. Route back to `__CMD_PREFIX__build-unit {NNN}`.

### If BLOCKED:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Gate 4: UNIT COMPLETE — BLOCKED for UNIT-{NNN}

{Gate checker result table with failures}

### How to Fix

{Fix guidance from gate checker}

──────────────────────────────────────────────────────────────
→ Resolve the above, then re-run `__CMD_PREFIX__approve-unit {NNN} --complete`
──────────────────────────────────────────────────────────────
```

</process>

<success_criteria>

- [ ] Unit resolved from __ARGUMENTS__ with correct zero-padded ID
- [ ] Correct gate identified (Gate 3 or Gate 4, from flag or auto-detect)
- [ ] Gate checker spawned with correct gate number and unit context
- [ ] Gate checklist presented to user with evidence
- [ ] Formal approval obtained via AskUserQuestion
- [ ] Audit trail updated in Gate Records section (gate-approval or gate-rejection)
- [ ] State.md gate status table updated for this unit
- [ ] Design.md status updated (Gate 3 only)
- [ ] Committed (if commit_docs = true)
- [ ] User knows next step (build-unit after Gate 3, retro/next-unit/deploy after Gate 4)
- [ ] All-units-complete check performed after Gate 4
- [ ] Security review completed (SAST/DAST if applicable, or manual review)

**Proof over Prose:** Every gate shows evidence from the gate checker, not self-reported claims.

</success_criteria>

<adaptive_depth>
## Adaptive Depth
Read `.aidlc/execution-plan.md` for the rigor level set during inception.
Adjust your behavior per the Rigor Levels table:

| Aspect | Low Risk | Medium Risk | High Risk |
|--------|----------|-------------|-----------|
| Gate formality | Quick review | Evidence checklist | Formal sign-off |
| Evidence depth | Tests pass | Tests + coverage | Tests + coverage + load test |
| Approval ceremony | Single approver | Named approver | Multi-stakeholder sign-off |
| Audit detail | Summary | Standard entries | Detailed with rationale |

If no execution-plan.md exists, default to **Medium Risk**.
</adaptive_depth>
