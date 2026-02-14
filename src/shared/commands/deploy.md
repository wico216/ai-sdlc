---
name: sdlc:deploy
description: Run the Operations phase — deployment plan, runbooks, and Production Ready gate
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

<objective>

Run the AI-SDLC Operations phase: productionize with safety and observability.

**When to use:**
- After all Construction units are complete
- When preparing a release for production deployment

**Creates:**
- `.aidlc/deployment-plan.md` — How this reaches production
- `.aidlc/runbooks/` — Operational playbooks
- `.aidlc/observability-config.md` — Monitoring and alerting setup
- Updates `.aidlc/audit.md` — Gate entries

**After this command:** The Production Ready gate must pass, then deploy.

**Principles in play:**
- #4 Align with AI Capability: AI generates plans, human validates safety
- #6 Proof over Prose: Production Ready gate requires evidence
- #9 Maximize Flow: Automated what can be automated

</objective>

<execution_context>

@__SDLC_REFS__/principles.md
@__SDLC_REFS__/gates.md
@__SDLC_TEMPLATES__/deployment-plan.md
@__SDLC_TEMPLATES__/runbook.md
@__SDLC_TEMPLATES__/observability-config.md

</execution_context>

<context>
@.aidlc/STATE.md
@.aidlc/PROJECT.md
@.aidlc/execution-plan.md
</context>

<process>

## 0. Pre-Flight

**Check all units are complete:**
```bash
ls .aidlc/units/UNIT-*.md 2>/dev/null
```

Read each unit file and check status. If any unit is not `complete`:

```
Not all units are complete:
- UNIT-001: complete ✓
- UNIT-002: in-progress ✗
- UNIT-003: defined ✗

Complete all units before Operations. Run __CMD_PREFIX__bolt {UNIT-ID} to continue.
```

Use AskUserQuestion:
- header: "Proceed?"
- question: "Not all units are complete. Continue to Operations anyway?"
- options:
  - "Wait" — I'll complete units first (exit)
  - "Proceed anyway" — Deploy what's ready (accepted risk)

If "Proceed anyway": log in audit as `risk-accepted`.

## 1. Deployment Plan

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► OPERATIONS: Deployment Planning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Read execution-plan.md for deployment approach (set during Inception).
Read PROJECT.md for infrastructure constraints.

**Generate deployment plan:**

```markdown
# Deployment Plan

## Strategy
{Deployment strategy: manual, CI/CD, container, serverless}

## Pre-Deployment Checklist
- [ ] All tests passing
- [ ] Code reviewed and merged
- [ ] Database migrations prepared (if applicable)
- [ ] Environment variables configured
- [ ] Secrets rotated (if applicable)

## Deployment Steps
1. {Step 1}
2. {Step 2}
3. {Step 3}

## Rollback Procedure
1. {How to roll back if something goes wrong}
2. {Data rollback if applicable}

## Post-Deployment Verification
- [ ] {Health check 1}
- [ ] {Health check 2}
- [ ] {Smoke test 1}
```

Present to user and iterate until approved.
Save to `.aidlc/deployment-plan.md`.

## 2. Runbook Generation

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► OPERATIONS: Runbook Generation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Based on the project, generate operational runbooks:

```bash
mkdir -p .aidlc/runbooks
```

**Common runbooks (generate what's applicable):**

- `incident-response.md` — What to do when things break
- `scaling.md` — How to handle increased load
- `maintenance.md` — Routine maintenance procedures
- `backup-restore.md` — Data backup and recovery
- `monitoring-alerts.md` — What alerts mean and how to respond

Each runbook follows a standard structure:
```markdown
# Runbook: {Title}

## When to Use
{Trigger conditions}

## Steps
1. {Step with commands/actions}
2. {Step with verification}

## Escalation
{When and who to escalate to}

## Related
{Links to other runbooks, docs}
```

Use AskUserQuestion:
- header: "Runbooks"
- question: "Which runbooks should we generate?"
- multiSelect: true
- options:
  - "Incident Response" — What to do when things break
  - "Scaling" — Handle increased load
  - "Maintenance" — Routine procedures
  - "Backup/Restore" — Data recovery

Generate selected runbooks and save to `.aidlc/runbooks/`.

## 3. Observability Config

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► OPERATIONS: Observability Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Based on execution-plan.md observability level:

**Basic:** Logging configuration
**Standard:** Logging + metrics endpoints
**Full APM:** Logging + metrics + tracing + alerting rules

Generate observability config document:

```markdown
# Observability Configuration

## Logging
- Log level: {info/debug/warn}
- Log format: {structured JSON / plaintext}
- Log destination: {stdout / file / service}

## Metrics (if applicable)
- Health endpoint: {path}
- Key metrics: {list}
- Dashboard: {TBD / link}

## Alerting (if applicable)
| Alert | Condition | Severity | Action |
|---|---|---|---|
| {name} | {condition} | {critical/warning} | {runbook link} |

## Tracing (if applicable)
- Trace provider: {service}
- Sample rate: {percentage}
```

Save to `.aidlc/observability-config.md`.

## 4. GATE: Production Ready

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► GATE: Production Ready
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 Final gate before production.
```

**Evidence checklist:**

```
Evidence:
- [{status}] All units complete and integrated
- [{status}] Deployment plan exists and reviewed → .aidlc/deployment-plan.md
- [{status}] Runbooks generated → .aidlc/runbooks/
- [{status}] Observability configured → .aidlc/observability-config.md
- [{status}] Rollback procedure documented
- [{status}] Performance requirements validated (from intent.md success criteria)
- [{status}] Security review passed (if applicable)
```

Use AskUserQuestion:
- header: "Production Gate"
- question: "Do you approve the Production Ready gate?"
- options:
  - "Approve — ready to deploy" — All clear
  - "Reject — not ready" — More work needed
  - "Approve with conditions" — Deploy but track follow-ups

**If approved:**
Audit entry: `gate-approval` for PRODUCTION READY.
Update STATE.md: phase = Operations Complete.

**If rejected:**
Audit entry: `gate-rejection`.
Surface what needs to change.

**If approved with conditions:**
Audit entry: `gate-approval` with conditions noted.
Create follow-up items.

**Commit:**
```bash
git add .aidlc/deployment-plan.md .aidlc/runbooks/ .aidlc/observability-config.md .aidlc/audit.md .aidlc/STATE.md
git commit -m "$(cat <<'EOF'
docs(operations): Production Ready gate {approved/rejected}

Deployment plan, runbooks, and observability configured.
EOF
)"
```

## 5. Completion

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► OPERATIONS COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Project Name}** — Production Ready

| Artifact | Location |
|---|---|
| Deployment Plan | `.aidlc/deployment-plan.md` |
| Runbooks | `.aidlc/runbooks/` |
| Observability | `.aidlc/observability-config.md` |
| Full Audit Trail | `.aidlc/audit.md` |

**Gates passed:** Requirements Approved ✓ → Inception Exit ✓ → Design Approved ✓ → Unit Complete ✓ → Production Ready ✓

**The Golden Thread is complete:**
Intent → Requirements → Units → Design → Code → Tests → Deployment

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Deploy

Follow the deployment plan at `.aidlc/deployment-plan.md`.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<output>

- `.aidlc/deployment-plan.md`
- `.aidlc/runbooks/` (selected runbooks)
- `.aidlc/observability-config.md`
- Updated `.aidlc/audit.md`
- Updated `.aidlc/STATE.md`

</output>

<success_criteria>

- [ ] All units checked for completion
- [ ] Deployment plan generated and approved
- [ ] Runbooks generated for selected scenarios
- [ ] Observability configuration created
- [ ] Gate: Production Ready — passed with evidence
- [ ] Audit trail has Production Ready gate entry
- [ ] STATE.md reflects Operations Complete
- [ ] Golden Thread intact: Intent → Requirements → Units → Code → Deployment

</success_criteria>
