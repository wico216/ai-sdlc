---
name: sdlc:approve-inception
description: Approve inception gates — Requirements Approved (Gate 1) and Inception Exit (Gate 2)
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

Approve the two Inception-phase gates. This command checks prerequisites, spawns the gate checker, presents evidence, and records formal approval.

**Gate 1 — Requirements Approved:** Intent + requirements are clear, measurable, and scoped.
**Gate 2 — INCEPTION EXIT:** Units decomposed, risks identified, execution plan approved.

**When to use:**
- After `__CMD_PREFIX__inception` completes its stages
- Standalone, when inception artifacts exist and you want to formally gate-check

**Principles in play:**
- #6 Proof over Prose: Gates require evidence, not claims
- #2 Reverse Conversation: AI collects evidence, human approves

</objective>

<execution_context>

@__SDLC_REFS__/gates.md
@__SDLC_REFS__/ui-brand.md

</execution_context>

<context>
@.aidlc/state.md
@.aidlc/intent.md
@.aidlc/requirements.md
@.aidlc/execution-plan.md
@.aidlc/audit.md
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

**Read state.md** to determine current gate status.

**Resolve commit_docs config:**
```bash
COMMIT_DOCS=$(cat .aidlc/config.json 2>/dev/null | grep -o '"commit_docs"[[:space:]]*:[[:space:]]*[^,}]*' | grep -o 'true\|false' || echo "true")
git check-ignore -q .aidlc 2>/dev/null && COMMIT_DOCS=false
```

## 1. Determine Which Gate to Check

Read the Gate Status section from state.md.

**If Gate 1 (Requirements Approved) not yet passed** -> proceed to Gate 1 check.
**If Gate 1 passed but Gate 2 (Inception Exit) not yet passed** -> proceed to Gate 2 check.
**If both gates already passed:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION GATES: Already Passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Both inception gates have already been approved:
- Requirements Approved: passed ({date})
- Inception Exit: passed ({date})

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Plan first unit** — begin Construction

`__CMD_PREFIX__plan-unit 001`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────
```

Exit command.

## 2. Gate 1 — Requirements Approved

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Requirements Approved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Resolve model profile:**
```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-gate-checker | sonnet | sonnet | haiku |

**Spawn gate checker:**

```
Task(prompt="
First, read __AGENTS_DIR__/sdlc-gate-checker.md for your role and instructions.

Check Gate 1: Requirements Approved.

Project state: @.aidlc/state.md
Intent: @.aidlc/intent.md
Requirements: @.aidlc/requirements.md
Execution plan: @.aidlc/execution-plan.md

Run all prerequisite checks for Gate 1 and return the structured checklist result.
", subagent_type="sdlc-gate-checker", model="{gate_checker_model}", description="Gate 1 check: Requirements Approved")
```

**Present gate checklist result to user.**

### If PASSED or PASSED WITH WARNINGS:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Verification Required                           ║
╚══════════════════════════════════════════════════════════════╝

{Gate checker result table}

──────────────────────────────────────────────────────────────
→ Approve or reject Gate 1: Requirements Approved
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Gate 1: Requirements Approved"
- question: "Do you approve this gate? This confirms the WHAT and WHY are clear. (Expected approver: Product Owner)"
- options:
  - "Approve" — Requirements are clear, proceed
  - "Reject" — Something needs to change

**If approved:**

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-approval
- **Gate:** Requirements Approved
- **Actor:** Human
- **Phase:** Inception
- **Context:** Gate 1 — Requirements Approved
- **Decision:** Approved — intent, requirements, and success criteria confirmed
- **Evidence:** .aidlc/intent.md, .aidlc/requirements.md, .aidlc/execution-plan.md
- **Traces to:** All MUST requirements
```

Update state.md: Set `Requirements Approved` row to `passed` with date and approver.

Conditional commit:
```bash
if [ "$COMMIT_DOCS" = "true" ]; then
  git add .aidlc/audit.md .aidlc/state.md
  git commit -m "$(cat <<'EOF'
docs(gate): Requirements Approved — Gate 1 passed

Intent and requirements confirmed by Product Owner.
EOF
)"
fi
```

**If Gate 2 also needs checking:** Continue to step 3.
**Otherwise:** Present next step.

**If rejected:**

Append to audit.md **Gate Records** section with type `gate-rejection` and the rejection reason.

```
Gate 1 rejected. What needs to change before requirements can be approved?
```

Wait for user input. Route back to `__CMD_PREFIX__inception` or address specific gaps.
Exit command.

### If BLOCKED:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Gate 1: Requirements Approved — BLOCKED

{Gate checker result table with failures}

### How to Fix

{Fix guidance from gate checker}

──────────────────────────────────────────────────────────────
→ Resolve the above issues, then re-run `__CMD_PREFIX__approve-inception`
──────────────────────────────────────────────────────────────
```

Exit command.

## 3. Gate 2 — INCEPTION EXIT

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: INCEPTION EXIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 This is the most important gate in AI-SDLC.
 Construction should NOT begin until intent is crystal clear.
```

**Spawn gate checker:**

```
Task(prompt="
First, read __AGENTS_DIR__/sdlc-gate-checker.md for your role and instructions.

Check Gate 2: Inception Exit.

Project state: @.aidlc/state.md
Intent: @.aidlc/intent.md
Requirements: @.aidlc/requirements.md
Execution plan: @.aidlc/execution-plan.md
Application design: @.aidlc/application-design.md (if exists)

Run all prerequisite checks for Gate 2 and return the structured checklist result.
", subagent_type="sdlc-gate-checker", model="{gate_checker_model}", description="Gate 2 check: Inception Exit")
```

**Present gate checklist result to user.**

### If PASSED or PASSED WITH WARNINGS:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Verification Required                           ║
╚══════════════════════════════════════════════════════════════╝

{Gate checker result table}

──────────────────────────────────────────────────────────────
→ Approve or reject Gate 2: INCEPTION EXIT
──────────────────────────────────────────────────────────────
```

Use AskUserQuestion:
- header: "Gate 2: INCEPTION EXIT"
- question: "Do you approve the Inception Exit gate? This allows Construction to begin. (Expected approvers: Product Owner + Tech Lead)"
- options:
  - "Approve — begin Construction" — All clear, let's build
  - "Reject — more Inception work needed" — Not ready yet

**If approved:**

Append to audit.md **Gate Records** section:
```markdown
### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** gate-approval
- **Gate:** INCEPTION EXIT
- **Actor:** Human
- **Phase:** Inception
- **Context:** Gate 2 — INCEPTION EXIT
- **Decision:** Inception complete. Units decomposed, risks identified, execution plan approved.
- **Evidence:** .aidlc/execution-plan.md, .aidlc/application-design.md, .aidlc/state.md
- **Traces to:** All v1 requirements, all UNIT-IDs
```

Update state.md:
- Set `Inception Exit` row to `passed` with date and approver
- Update phase to `Construction`
- Update status to `Ready to plan first unit`

Conditional commit:
```bash
if [ "$COMMIT_DOCS" = "true" ]; then
  git add .aidlc/audit.md .aidlc/state.md
  git commit -m "$(cat <<'EOF'
docs(gate): INCEPTION EXIT — Gate 2 passed

Inception complete. Ready for Construction.
EOF
)"
fi
```

Present completion:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► INCEPTION EXIT APPROVED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Both inception gates passed. Construction can begin.

| Gate | Status | Date |
|------|--------|------|
| Requirements Approved | ✓ passed | {date} |
| Inception Exit | ✓ passed | {date} |

───────────────────────────────────────────────────────────────

## ▶ Next Up

**Plan first unit** — begin Construction

`__CMD_PREFIX__plan-unit 001`

<sub>`/clear` first → fresh context window</sub>

───────────────────────────────────────────────────────────────

**Also available:**
- `__CMD_PREFIX__progress` — view project status
- `__CMD_PREFIX__settings` — adjust project configuration

───────────────────────────────────────────────────────────────
```

**If rejected:**

Append to audit.md **Gate Records** section with type `gate-rejection` and reason.

```
Inception Exit rejected. What needs more work before Construction can begin?
```

Wait for user input. Route to appropriate inception stage.

### If BLOCKED:

```
╔══════════════════════════════════════════════════════════════╗
║  CHECKPOINT: Action Required                                 ║
╚══════════════════════════════════════════════════════════════╝

Gate 2: INCEPTION EXIT — BLOCKED

{Gate checker result table with failures}

### How to Fix

{Fix guidance from gate checker}

──────────────────────────────────────────────────────────────
→ Resolve the above issues, then re-run `__CMD_PREFIX__approve-inception`
──────────────────────────────────────────────────────────────
```

</process>

<success_criteria>

- [ ] Pre-flight checks passed (.aidlc/ exists, state.md readable)
- [ ] Correct gate identified (Gate 1 if not passed, Gate 2 if Gate 1 passed)
- [ ] Gate checker spawned with correct gate number and context
- [ ] Gate checklist presented to user with evidence
- [ ] Formal approval obtained via AskUserQuestion
- [ ] Audit trail updated in Gate Records section (gate-approval or gate-rejection)
- [ ] State.md gate status table updated
- [ ] Committed (if commit_docs = true)
- [ ] User knows next step (`__CMD_PREFIX__plan-unit 001` after Gate 2)

**Proof over Prose:** Every gate shows evidence from the gate checker, not self-reported claims.

</success_criteria>
