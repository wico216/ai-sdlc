# Audit Trail Template

> This is an APPEND-ONLY template. Agents must NEVER delete or modify existing entries.
> Each entry records a decision, gate approval, or significant event.

## Instructions for agents

When writing to audit.md:
1. ALWAYS append to the end of the file
2. NEVER modify or delete existing entries
3. Include timestamp, actor (human/AI), type, and details
4. Reference the Golden Thread: link back to requirements/units/stories

## Template

```markdown
# Audit Trail

## Project: {project-name}
## Created: {YYYY-MM-DD}

---

### Entry #{N} — {YYYY-MM-DD HH:MM}
- **Type:** {decision | gate-approval | gate-rejection | design-choice | scope-change | risk-accepted | deviation}
- **Actor:** {Human | AI-Agent | Both}
- **Phase:** {Inception | Construction | Operations}
- **Context:** {What was being decided}
- **Decision:** {What was decided and why}
- **Evidence:** {Links to artifacts, test results, or discussion}
- **Traces to:** {REQ-ID, UNIT-ID, or STORY-ID}

---
```

## Entry Type Definitions

| Type | When to log | Example |
|---|---|---|
| `decision` | Any non-trivial choice made | "Chose PostgreSQL over MongoDB for relational data" |
| `gate-approval` | Human approves a gate | "INCEPTION EXIT approved — all units defined" |
| `gate-rejection` | Human rejects a gate | "Design review failed — missing error handling" |
| `design-choice` | Architecture or design decision | "Using event sourcing for order processing" |
| `scope-change` | Requirements added/removed/changed | "Removed social login from v1 scope" |
| `risk-accepted` | Known risk acknowledged | "Accepting single-region deployment for v1" |
| `deviation` | Plan deviated from original | "Switched from REST to GraphQL mid-bolt" |

## Agent behavior

- After every gate check, append an entry
- After every significant design decision during a bolt, append an entry
- After any scope change the user approves, append an entry
- The audit trail IS the project's memory — make entries descriptive enough to understand months later
