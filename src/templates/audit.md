# Audit Trail Template

> This is an APPEND-ONLY template. Agents must NEVER delete or modify existing entries.
> Each entry records a decision, gate approval, or significant event.

## Instructions for agents

When writing to audit.md:
1. ALWAYS append to the end of the appropriate section
2. NEVER modify or delete existing entries
3. Include timestamp, actor (human/AI), type, and details
4. Reference the Golden Thread: link back to requirements/units/stories
5. Gate records go in **Gate Records** section, all other decisions go in **Decision Log** section

## Template

```markdown
# Audit Trail

## Project: {project-name}
## Created: {YYYY-MM-DD}

---

## Gate Records

> Formal gate approvals and rejections with evidence. These are the primary compliance checkpoints.

### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** {gate-approval | gate-rejection}
- **Gate:** {Requirements Approved | INCEPTION EXIT | Design Approved | UNIT COMPLETE | PRODUCTION READY}
- **Actor:** {Human | Both}
- **Phase:** {Inception | Construction | Operations}
- **Context:** {What gate was being checked}
- **Decision:** {Approved / Rejected — with reason}
- **Evidence:** {Links to artifacts, test results, checklists}
- **Traces to:** {REQ-ID, UNIT-ID, or STORY-ID}

---

## Decision Log

> Architecture choices, scope changes, risk acceptances, design decisions, and deviations.
> These provide context for why things were built the way they were.

### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** {decision | design-choice | scope-change | risk-accepted | deviation}
- **Actor:** {Human | AI-Agent | Both}
- **Phase:** {Inception | Construction | Operations}
- **Context:** {What was being decided}
- **Decision:** {What was decided and why}
- **Evidence:** {Links to artifacts, discussion, or analysis}
- **Traces to:** {REQ-ID, UNIT-ID, or STORY-ID}

---
```

## Entry Type Definitions

### Gate Records (formal checkpoints)

| Type | When to log | Example |
|---|---|---|
| `gate-approval` | Human approves a gate | "INCEPTION EXIT approved — all units defined" |
| `gate-rejection` | Human rejects a gate | "Design review failed — missing error handling" |

### Decision Log (project context)

| Type | When to log | Example |
|---|---|---|
| `decision` | Any non-trivial choice made | "Chose PostgreSQL over MongoDB for relational data" |
| `design-choice` | Architecture or design decision | "Using event sourcing for order processing" |
| `scope-change` | Requirements added/removed/changed | "Removed social login from v1 scope" |
| `risk-accepted` | Known risk acknowledged | "Accepting single-region deployment for v1" |
| `deviation` | Plan deviated from original | "Switched from REST to GraphQL mid-bolt" |

## Agent behavior

- After every gate check, append to **Gate Records** section
- After every significant design decision during a bolt, append to **Decision Log** section
- After any scope change the user approves, append to **Decision Log** section
- The audit trail IS the project's memory — make entries descriptive enough to understand months later
