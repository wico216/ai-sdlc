# Unit Template

> A Unit is a parallel-deliverable work chunk with clear acceptance criteria.
> Units map to DDD Bounded Contexts where applicable.
> Each unit can be worked on independently by one person + AI.

## Instructions for agents

- Generate units during Inception (`__CMD_PREFIX__inception`)
- Each unit should be completable in 1-5 Bolts (hours to days, not weeks)
- Units should be parallelizable — minimal cross-unit dependencies
- Every unit traces back to requirements and stories
- Acceptance criteria must be testable (Proof over Prose)

## Template

```markdown
---
type: unit
unit_id: "UNIT-{NNN}"
project: "{project-name}"
status: "{defined | in-progress | complete | blocked}"
created: "{YYYY-MM-DD}"
traces_to:
  requirements: ["REQ-{NNN}"]
  stories: ["STORY-{NNN}"]
estimated_bolts: {N}
assigned_to: ""
---

# Unit: {Descriptive Name}

## Purpose

{What this unit delivers. One paragraph max.}

## Bounded Context

{What domain concept(s) does this unit own? What are its boundaries?}

### Owns
- {Entity/concept this unit is responsible for}

### Depends On
- {External inputs from other units or systems — keep minimal}

### Provides
- {What this unit exposes to other units or systems}

## Acceptance Criteria

> Every criterion must be testable. "Proof over Prose."

- [ ] {Criterion 1 — specific, testable}
- [ ] {Criterion 2 — specific, testable}
- [ ] {Criterion 3 — specific, testable}

## Technical Notes

{Any technical considerations, constraints, or decisions relevant to implementation.
Leave empty if TBD — the Construction phase Design gate will fill this.}

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| | | |

## Bolt Plan

{Filled during Construction phase. Rough sequence of bolts to complete this unit.}

1. Bolt 1: {description}
2. Bolt 2: {description}

---

*Traces: Intent → REQ-{NNN} → STORY-{NNN} → UNIT-{NNN}*
*Gate: UNIT COMPLETE requires all acceptance criteria checked with evidence*
```
