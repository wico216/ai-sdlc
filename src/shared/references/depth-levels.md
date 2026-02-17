# Adaptive Depth Levels

## Core Principle

**When a stage executes, ALL its defined artifacts are created. Depth controls the DETAIL within those artifacts, not which artifacts exist.**

---

## Stage Selection vs Detail Level

### Stage Selection (Binary)
- During inception workflow planning: EXECUTE or SKIP for each stage
- If EXECUTE: Stage runs and creates ALL its defined artifacts
- If SKIP: Stage doesn't run at all

### Detail Level (Adaptive)
- When a stage executes, detail adapts to complexity
- Simple problems get concise artifacts with essential detail
- Complex problems get comprehensive artifacts with extensive detail

---

## Three Depth Levels

| Level | When | Effect on Artifacts |
|-------|------|---------------------|
| **Minimal** | Simple, clear request; low risk; well-known domain | Brief artifacts, fewer questions, essential sections only |
| **Standard** | Normal complexity; moderate risk; some unknowns | Full artifacts, standard question coverage, all sections populated |
| **Comprehensive** | Complex system; high risk; regulated; novel domain | Detailed artifacts, deep question coverage, extra validation sections |

---

## Factors That Determine Depth

The agent considers these when choosing depth:

1. **Request clarity:** How clear and complete is the user's request?
2. **Problem complexity:** How intricate is the solution space?
3. **Scope:** Single file → component → multiple components → system-wide?
4. **Risk level:** What's the impact of errors or omissions?
5. **Available context:** Greenfield vs brownfield, existing documentation
6. **User preferences:** Has user expressed preference for brevity or detail?
7. **Project config:** `depth` setting in `.aidlc/config.json` (quick/standard/comprehensive)

---

## Depth by Stage

### Requirements Analysis

| Depth | Questions | Requirements Document |
|-------|-----------|----------------------|
| Minimal | 2-3 targeted questions | Concise functional requirements, essential sections |
| Standard | 5-8 questions across categories | Full functional + non-functional requirements |
| Comprehensive | 10+ questions, multiple rounds | Detailed requirements with traceability, acceptance criteria, edge cases |

### User Stories

| Depth | Stories | Acceptance Criteria |
|-------|---------|---------------------|
| Minimal | 3-5 core stories | 1-2 criteria per story |
| Standard | 5-10 stories with personas | Given/When/Then per story |
| Comprehensive | 10+ stories, detailed personas | Comprehensive Given/When/Then with edge cases |

### Application Design

| Depth | Design Document |
|-------|----------------|
| Minimal | Component list with responsibilities, basic data model |
| Standard | Component breakdown, data model, API contracts, technology rationale |
| Comprehensive | Full component design, detailed data model, all API contracts, alternatives considered, dependency diagram |

### Bolt Planning

| Depth | Plan Detail |
|-------|------------|
| Minimal | Larger bolts (fewer), broad tasks, spot-check verification |
| Standard | 3-5 tasks per bolt, specific actions, full verification |
| Comprehensive | 2-3 fine-grained tasks per bolt, detailed actions, comprehensive verification + integration checks |

---

## How Depth Interacts with Risk

The project's rigor level (from `execution-plan.md`) sets a baseline:

| Project Risk | Default Depth | Can Override? |
|-------------|--------------|---------------|
| Low | Minimal | User can request Standard or Comprehensive |
| Medium | Standard | User can request Minimal or Comprehensive |
| High | Comprehensive | User can request Standard but NOT Minimal |

**High-risk projects cannot use Minimal depth.** This is a guardrail, not a suggestion.

---

## Examples

### Simple Bug Fix (Minimal)
- Requirements: 2 targeted questions, concise requirements doc
- No user stories (skip stage)
- No application design (skip stage)
- 1-2 bolts with broad tasks

### Standard Feature (Standard)
- Requirements: 5-8 questions, full requirements with REQ-IDs
- User stories if UI-facing
- Application design if new components
- 3-5 bolts with standard detail

### Complex System Migration (Comprehensive)
- Requirements: 10+ questions across all categories, multiple clarification rounds
- User stories with detailed personas and journeys
- Full application design with alternatives analysis
- 5-10 fine-grained bolts with comprehensive verification

---

## Agent Integration

Agents should determine depth automatically based on the factors above. When uncertain, default to **Standard**.

**Reference this file in agent prompts as:**
```
@__SDLC_REFS__/depth-levels.md
```

**Do not ask the user to choose depth directly** — infer it from context. The `depth` setting in config.json provides a general preference, but agents should adjust based on specific stage complexity.
