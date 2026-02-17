# NFR Design Stage (Per Unit — CONDITIONAL)

## When to Execute

- NFR Requirements stage was executed for this unit (`.aidlc/construction/unit-NNN/nfr-requirements.md` exists)
- Design patterns are needed to meet NFR targets

## When to Skip

- NFR Requirements stage was skipped for this unit
- No `nfr-requirements.md` exists
- NFR requirements are trivially met by standard implementation

---

## Prerequisites

- `nfr-requirements.md` exists for this unit
- Unit specification exists in `.aidlc/inception/units/UNIT-NNN.md`

## Output

```
.aidlc/construction/unit-NNN/nfr-design.md
```

Contains:
- Design patterns to apply (caching, rate limiting, circuit breaker, retry, etc.)
- How NFR requirements map to implementation patterns
- Performance optimization strategies
- Security implementation approach
- Logical components needed (queues, caches, load balancers, etc.)

---

## Execution Steps

### Step 1: Analyze NFR Requirements

Read the unit's NFR requirements and identify which design patterns are needed:

```bash
cat .aidlc/construction/unit-NNN/nfr-requirements.md
```

Map each NFR requirement to candidate design patterns:

| NFR Category | Common Patterns |
|-------------|-----------------|
| Performance | Caching, connection pooling, lazy loading, pagination, indexing |
| Scalability | Horizontal scaling, sharding, event-driven, CQRS |
| Availability | Circuit breaker, retry with backoff, health checks, graceful degradation |
| Security | Input validation, parameterized queries, rate limiting, encryption at rest/transit |
| Reliability | Idempotency, dead letter queues, saga pattern, compensating transactions |

### Step 2: Generate Questions (if needed)

If pattern selection requires user input, write questions to `.aidlc/construction/unit-NNN/questions/nfr-design-questions.md` using `question-format-guide.md`.

**Question categories** (only ask if the choice isn't obvious from NFR requirements):

- **Resilience Patterns** — If fault tolerance approach needs clarification (circuit breaker vs retry vs bulkhead)
- **Scalability Patterns** — If scaling mechanism is unclear (horizontal vs vertical, stateless vs stateful)
- **Performance Patterns** — If optimization strategy is ambiguous (cache-aside vs write-through, sync vs async)
- **Security Patterns** — If security implementation approach needs input (token vs session, encryption approach)
- **Logical Components** — If infrastructure components (message queues, caches, CDN) need clarification

Apply overconfidence prevention: when multiple valid patterns exist, present options rather than picking silently.

### Step 3: Generate NFR Design Document

Write `.aidlc/construction/unit-NNN/nfr-design.md`:

```markdown
---
type: nfr-design
unit: "UNIT-NNN"
status: draft
traces_to: ["nfr-requirements.md"]
---

# NFR Design — Unit NNN: {Name}

## Design Patterns Applied

### {Pattern Name}
- **Addresses:** {Which NFR requirement}
- **Implementation:** {How to implement in this unit's context}
- **Trade-offs:** {What we gain vs what we pay}

### {Pattern Name}
...

## Performance Optimization Strategy

| Optimization | Target NFR | Approach | Verification |
|-------------|-----------|----------|--------------|
| {optimization} | {which metric} | {how} | {how to test} |

## Security Implementation

| Security Requirement | Pattern | Implementation Notes |
|---------------------|---------|---------------------|
| {requirement} | {pattern} | {specifics} |

## Logical Components

| Component | Purpose | Service/Technology | Justification |
|-----------|---------|-------------------|---------------|
| {component} | {why needed} | {what to use} | {why this choice} |

## Impact on Bolt Plans

These NFR design decisions affect bolt planning:
- {decision} → affects {which bolts/tasks}
- {decision} → requires {additional task or verification}
```

### Step 4: Present for Approval

Present the NFR design to the user. Wait for explicit approval before proceeding.

### Step 5: Record and Update State

- Log approval in `audit.md`
- Update `state.md`

---

## Integration with Bolt Planning

NFR design output feeds directly into bolt planning:

- **Design patterns** become implementation tasks within bolts
- **Logical components** may require their own setup bolts (e.g., cache configuration, queue setup)
- **Performance optimizations** become verification criteria (e.g., "response time < 200ms")
- **Security implementations** become explicit tasks with security-specific verification

The bolt planner reads `nfr-design.md` alongside the unit specification when creating bolt plans.
