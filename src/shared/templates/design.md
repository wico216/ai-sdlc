# Unit Design Template

> Per-unit design document created during Construction.
> Covers domain model, logical design, interface contracts, and NFR compliance.
> Lives at: `.aidlc/construction/unit-NNN/design.md`

## Instructions for agents

- Create during `__CMD_PREFIX__plan-unit` before generating bolt plans
- Must trace back to unit spec acceptance criteria
- Must address NFR compliance (from `inception/nfr.md` if exists)
- AI proposes design, human reviews at Design Approved gate
- Keep focused — this is for ONE unit, not the whole system

## Template

```markdown
---
type: unit-design
unit_id: "UNIT-{NNN}"
project: "{project-name}"
status: "{draft | reviewed | approved}"
created: "{YYYY-MM-DD}"
traces_to:
  unit_spec: "inception/units/UNIT-{NNN}.md"
  requirements: ["REQ-{IDs}"]
  nfr: "inception/nfr.md"
---

# Design: {Unit Name}

## Overview

{What this unit implements and why. One paragraph.}

## Domain Model

### Entities

| Entity | Description | Owned By |
|--------|-------------|----------|
| {Entity} | {what it represents} | {this unit | shared | external} |

### Relationships

{How entities relate to each other. Text description or simple diagram.}

### Invariants

- {Business rule that must always hold}
- {Constraint that the design must enforce}

## Logical Design

### Component Structure

{How the implementation is organized — modules, files, layers.}

### Data Structures

{Key data types, schemas, models. Include field names and types.}

### Algorithms / Logic

{Non-trivial logic that needs to be designed up front. Skip for simple CRUD.}

## Interface Contracts

### Public API

{What this unit exposes to other units or external consumers.}

| Endpoint / Method | Input | Output | Notes |
|-------------------|-------|--------|-------|
| {interface} | {params/body} | {response} | {constraints} |

### Dependencies

{What this unit consumes from other units or external systems.}

| Dependency | Interface | Used For |
|------------|-----------|----------|
| {unit/service} | {API/event/import} | {purpose} |

## NFR Compliance

{How this unit addresses applicable non-functional requirements.
Skip sections that don't apply to this unit.}

### Performance
- {How performance targets are met}

### Security
- {How security requirements are addressed}

### Scalability
- {How the design scales if needed}

## Test Strategy

| Test Type | What's Tested | Approach |
|-----------|---------------|----------|
| Unit tests | {core logic} | {approach} |
| Integration tests | {API/DB interactions} | {approach} |
| E2E tests | {user flows, if applicable} | {approach} |

## Acceptance Criteria Mapping

| Criterion (from unit spec) | Design Element | How Verified |
|---------------------------|----------------|--------------|
| {AC-01 text} | {which component/code handles it} | {test type + assertion} |
| {AC-02 text} | {which component/code handles it} | {test type + assertion} |

## Technical Decisions

| Decision | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| {what was decided} | {chosen approach} | {why} | {what else was considered} |

---

*Traces: Intent → REQ-{IDs} → UNIT-{NNN} → Design → Bolt Plans*
*Gate: Design Approved required before bolt execution*
```

<guidelines>

**Depth scales with complexity:**
- Simple CRUD unit: Skip Algorithms section, minimal Domain Model
- Complex business logic: Full Domain Model with invariants, detailed Algorithms
- Integration-heavy unit: Focus on Interface Contracts and Dependencies

**Acceptance Criteria Mapping is mandatory.**
Every acceptance criterion from the unit spec must map to a design element. If a criterion can't be mapped, the design is incomplete.

**NFR Compliance is mandatory when nfr.md exists.**
Even if brief — document how each relevant NFR is addressed or why it doesn't apply to this unit.

**After creation:**
- Human reviews design before bolt planning proceeds
- Design decisions feed into bolt plans (bolt-planner reads this file)
- Changes to design after approval require audit.md entry

</guidelines>
