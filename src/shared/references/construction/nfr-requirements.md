# NFR Requirements Stage (Per Unit — CONDITIONAL)

## When to Execute

- Performance requirements exist for this unit
- Security considerations needed
- Scalability concerns present
- Tech stack selection required for this unit
- Compliance or regulatory requirements apply

## When to Skip

- No NFR requirements identified in inception
- Tech stack already determined and locked
- Simple unit with no quality attribute concerns
- Pure refactoring or bug fix unit

---

## Prerequisites

- Unit specification exists in `.aidlc/inception/units/UNIT-NNN.md`
- Requirements exist in `.aidlc/inception/requirements.md`
- Inception NFR document exists at `.aidlc/inception/nfr.md` (if created during inception)

## Output

```
.aidlc/construction/unit-NNN/nfr-requirements.md
```

Contains:
- Performance targets for this unit (response times, throughput, latency)
- Security requirements (authentication, authorization, data protection, threat model)
- Scalability considerations (load patterns, growth, capacity planning)
- Availability targets (uptime SLO, RTO, RPO)
- Reliability requirements (error handling, fault tolerance, monitoring)
- Tech stack decisions with rationale (if any choices needed for this unit)
- Compliance requirements (if applicable)

---

## Execution Steps

### Step 1: Analyze Unit Context

Read the unit specification and identify which NFR categories apply:

```bash
cat .aidlc/inception/units/UNIT-NNN.md
cat .aidlc/inception/nfr.md 2>/dev/null
cat .aidlc/inception/requirements.md | grep -i "performance\|security\|scale\|avail"
```

### Step 2: Determine NFR Scope

Not every unit needs every NFR category. Determine scope based on unit type:

| Unit Type | Typical NFR Focus |
|-----------|-------------------|
| API / Backend | Performance, security, scalability, availability |
| UI / Frontend | Performance (load time, responsiveness), accessibility |
| Data / ETL | Throughput, data integrity, retention |
| Infrastructure | Availability, disaster recovery, monitoring |
| Auth / Security | Security (comprehensive), compliance |

### Step 3: Generate Questions

Write questions to `.aidlc/construction/unit-NNN/questions/nfr-questions.md` using the format from `question-format-guide.md`.

**Question categories to evaluate** (skip categories that clearly don't apply, but err on the side of asking — see `overconfidence-prevention.md`):

- **Performance Requirements** — Response time targets, throughput expectations, performance benchmarks
- **Scalability Requirements** — Expected load, growth patterns, scaling triggers, capacity planning
- **Availability Requirements** — Uptime expectations, disaster recovery, failover, business continuity
- **Security Requirements** — Data protection, compliance, auth/authz, threat models
- **Reliability Requirements** — Error handling approach, fault tolerance, monitoring needs
- **Tech Stack Selection** — Technology preferences, constraints, existing system integration
- **Maintainability Requirements** — Code quality standards, documentation, testing depth
- **Usability Requirements** — User experience targets, accessibility standards

### Step 4: Collect and Analyze Answers

1. Wait for user completion
2. **MANDATORY:** Analyze ALL responses for ambiguity (see `question-format-guide.md`)
3. Look for vague responses: "depends", "standard", "typical", "somewhere between"
4. Create follow-up questions if ANY ambiguities detected
5. Do NOT proceed until all answers are clear

### Step 5: Generate NFR Requirements Document

Write `.aidlc/construction/unit-NNN/nfr-requirements.md`:

```markdown
---
type: nfr-requirements
unit: "UNIT-NNN"
status: draft
traces_to: ["REQ-IDs that have NFR implications"]
---

# NFR Requirements — Unit NNN: {Name}

## Performance
| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| {metric} | {target} | {how to measure} |

## Scalability
| Dimension | Current | Target | Strategy |
|-----------|---------|--------|----------|
| {dimension} | {current} | {target} | {approach} |

## Security
| Requirement | Implementation Approach | Verification |
|-------------|------------------------|--------------|
| {requirement} | {approach} | {how to verify} |

## Availability
| Metric | Target | Notes |
|--------|--------|-------|
| Uptime SLO | {target} | |
| RTO | {target} | |
| RPO | {target} | |

## Tech Stack Decisions
| Decision | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| {decision} | {choice} | {why} | {what else was considered} |

## Compliance
| Standard | Applicability | Requirements |
|----------|--------------|--------------|
| {standard} | {applies to} | {what must be done} |
```

### Step 6: Present for Approval

Present the NFR requirements to the user. This is a checkpoint — wait for explicit approval before proceeding.

### Step 7: Record and Update State

- Log approval in `audit.md` with timestamp
- Update `state.md` to record NFR requirements completion for this unit

---

## Integration with Bolt Planning

The `plan-unit` command checks for `nfr-requirements.md` and feeds it into the bolt planner. NFR requirements influence:

- **Task verification criteria** — Performance thresholds become verify/done criteria
- **Security tasks** — Auth, validation, encryption become explicit bolt tasks
- **Infrastructure bolts** — If infrastructure design follows, NFR requirements inform it
- **Testing depth** — High NFR requirements → more comprehensive test bolts

## Relationship to Inception NFR

The inception-level `nfr.md` captures project-wide NFR requirements. This per-unit stage refines those into unit-specific targets. If no inception NFR exists, this stage derives NFR requirements directly from the unit specification and project requirements.
