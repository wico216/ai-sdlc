# Execution Plan Template

> The execution plan determines WHICH Inception stages to run based on project context.
> Adaptive Depth (Principle #10): context determines workflow.

## Instructions for agents

- Generate this early in Inception (after Workspace Detection)
- Use Adaptive Depth to determine required stages
- This plan IS the workflow — there's no separate process layer
- Update as understanding deepens during Inception

## Template

```markdown
---
type: execution-plan
project: "{project-name}"
created: "{YYYY-MM-DD}"
project_type: "{greenfield | brownfield | bugfix | migration | enhancement}"
complexity: "{low | medium | high}"
---

# Execution Plan: {Project Name}

## Project Classification

- **Type:** {greenfield | brownfield | bugfix | migration | enhancement}
- **Complexity:** {low | medium | high}
- **Estimated Bolts:** {rough total}
- **Team Size:** {N people}

## Inception Stages

| # | Stage | Required? | Reason | Status |
|---|---|---|---|---|
| 1 | Workspace Detection | Always | Classify project type | {done | pending | skipped} |
| 2 | Reverse Engineering | Brownfield only | Map existing system | {done | pending | skipped | n/a} |
| 3 | Requirements Analysis | Always | Define what to build | {done | pending | skipped} |
| 4 | User Stories | If UI/users | Define user journeys | {done | pending | skipped | n/a} |
| 5 | Workflow Planning | Always | This document | {done | pending | skipped} |
| 6 | Application Design | If new components | High-level architecture | {done | pending | skipped | n/a} |
| 7 | Units Generation | If decomposable | Parallel work chunks | {done | pending | skipped | n/a} |

## Construction Approach

- **Bolt sizing:** {Small (hours) | Medium (1-2 days) | Large (3-5 days)}
- **Parallelization:** {Sequential | 2 parallel | 3+ parallel}
- **Gate rigor:** {Light (tests pass) | Standard (tests + review) | Formal (tests + review + sign-off)}

## Operations Approach

- **Deployment:** {Manual | CI/CD | Container | Serverless}
- **Observability:** {Basic logging | Metrics + logging | Full APM}
- **Rollback:** {Git revert | Blue-green | Canary}

## Unit Dependency Matrix

See `.aidlc/inception/unit-dependency-matrix.md` for the full dependency matrix.

**Summary:**

| Unit \ Depends On | UNIT-001 | UNIT-002 | UNIT-003 |
|--------------------|----------|----------|----------|
| UNIT-001           | -        | -        | -        |
| UNIT-002           | {BLOCKS/INFORMS/-} | -        | -        |
| UNIT-003           | {BLOCKS/INFORMS/-} | {BLOCKS/INFORMS/-} | -        |

**Dependency types:**
- `BLOCKS` — Hard dependency: must complete before dependent unit can start
- `INFORMS` — Soft dependency: output feeds into dependent unit but does not block start
- `-` — No dependency

**Critical path:** {UNIT-X -> UNIT-Y -> UNIT-Z} ({N} units, {E} estimated bolts)

**Recommended build order:**
1. {UNIT-NNN} — {reason: no dependencies / foundation unit}
2. {UNIT-NNN} — {reason: depends on unit above}
3. {UNIT-NNN} — {reason: can parallelize with unit above}

## Story-to-Unit Mapping

{Include only if user-stories.md exists}

| Unit | Stories Implemented | Story Count |
|------|-------------------|-------------|
| UNIT-001 | STORY-001, STORY-003 | {N} |
| UNIT-002 | STORY-002, STORY-004 | {N} |

**Coverage:** {N} of {M} stories mapped to units ({percentage}%)
**Unmapped stories:** {list STORY-IDs or "None"}

## Adaptive Depth Rationale

{Why this level of rigor was chosen. Reference Principle #5 (Complex Systems) and #10 (No Hard-Wired Workflows).}

---

*This plan adapts as understanding deepens. Update during Inception.*
```
