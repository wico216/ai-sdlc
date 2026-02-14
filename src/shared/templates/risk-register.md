# Risk Register Template

> Risks constrain AI creativity (Principle #6). They're guardrails, not blockers.
> Identify early, mitigate proactively, accept consciously.

## Instructions for agents

- Create during Inception, update throughout project lifecycle
- Each risk gets a unique ID for tracing
- Log risk acceptance decisions in audit.md
- Re-evaluate risks at every gate

## Template

```markdown
---
type: risk-register
project: "{project-name}"
created: "{YYYY-MM-DD}"
last_reviewed: "{YYYY-MM-DD}"
---

# Risk Register: {Project Name}

## Active Risks

### RISK-001: {Risk Title}
- **Category:** {technical | business | security | compliance | integration | operational}
- **Description:** {What could go wrong}
- **Impact:** {high | medium | low} — {What happens if it occurs}
- **Likelihood:** {high | medium | low} — {Why we think this}
- **Severity:** {critical | major | minor} — Impact x Likelihood
- **Mitigation:** {How we're reducing likelihood or impact}
- **Owner:** {Who is responsible for monitoring this risk}
- **Status:** {open | mitigating | accepted | resolved}
- **Traces to:** {UNIT-ID, REQ-ID, or general}

---

## Accepted Risks

{Risks the team has consciously accepted. Each must have an audit.md entry.}

### RISK-{NNN}: {Title}
- **Accepted by:** {name}
- **Accepted on:** {date}
- **Rationale:** {Why this risk is acceptable}

---

## Resolved Risks

{Risks that no longer apply.}

### RISK-{NNN}: {Title}
- **Resolved on:** {date}
- **Resolution:** {How it was resolved}

---

## Risk Matrix

| | Low Impact | Medium Impact | High Impact |
|---|---|---|---|
| **High Likelihood** | Monitor | Mitigate | Block |
| **Medium Likelihood** | Accept | Mitigate | Mitigate |
| **Low Likelihood** | Accept | Monitor | Monitor |

---

*Reviewed at gates: Requirements Approved, INCEPTION EXIT, Design Approved, UNIT COMPLETE, PRODUCTION READY*
```
