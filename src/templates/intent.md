# Intent Document Template

> The Intent document is the foundation of the Golden Thread.
> Everything traces back to this document. Write it clearly.

## Instructions for agents

- Fill this during `/sdlc:inception` or `/sdlc:new-project`
- Use the Reverse Conversation pattern: AI proposes, human refines
- Mark unknowns as `**TBD** — [owner] to clarify`
- Keep language domain-specific (DDD Principle #3)

## Template

```markdown
---
type: intent
project: "{project-name}"
created: "{YYYY-MM-DD}"
status: "{draft | reviewed | approved}"
approved_by: ""
approved_date: ""
---

# Intent: {Project Name}

## The Problem

{What problem are we solving? Be specific about pain points.}

### Who is affected?
{Users, teams, systems — be explicit}

### Why now?
{What's driving urgency? Business pressure, technical debt, opportunity?}

## The Vision

{What does the world look like when this is done? Paint the picture.}

### Success Criteria
{How will we know this worked? Measurable outcomes.}

1. {Criterion 1 — measurable}
2. {Criterion 2 — measurable}
3. {Criterion 3 — measurable}

## Scope

### In Scope (v1)
- {What MUST be built}
- {What MUST be built}

### Out of Scope (future)
- {What explicitly waits}
- {What explicitly waits}

### Non-Negotiables
- {Hard constraints: security, compliance, performance, etc.}

## Constraints

### Technical
- {Existing systems, tech stack requirements, integration points}

### Business
- {Budget, timeline, team capacity, regulatory}

### Dependencies
- {External systems, third parties, other teams}

## Stakeholders

| Role | Person | Responsibility |
|---|---|---|
| Product Owner | | Defines requirements, approves scope |
| Technical Lead | | Architecture decisions, technical feasibility |
| Developer(s) | | Implementation |
| QA | | Validation |
| Stakeholder | | {Specific interest} |

## Risk Summary

{High-level risks identified — detailed risks go in risk-register.md}

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| | | | |

---

*This intent document traces to: all requirements, units, and stories in this project.*
*Approved at gate: Requirements Approved*
```
