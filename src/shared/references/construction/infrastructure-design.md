# Infrastructure Design Stage (Per Unit — CONDITIONAL)

## When to Execute

- Infrastructure services need mapping (logical component → cloud service)
- Deployment architecture required for this unit
- Cloud resources need specification
- Database or storage services need provisioning
- Networking or messaging infrastructure needed

## When to Skip

- No infrastructure changes for this unit
- Infrastructure already defined (from a prior unit or existing codebase)
- Purely local/CLI project with no infrastructure
- Simple frontend-only unit deploying to static hosting

---

## Prerequisites

- Unit specification exists in `.aidlc/inception/units/UNIT-NNN.md`
- Functional design or requirements clarify what needs deploying
- NFR design exists (recommended — provides logical components to map)

## Output

```
.aidlc/construction/unit-NNN/infrastructure-design.md
```

Contains:
- Infrastructure service mapping (logical component → actual cloud/infrastructure service)
- Deployment architecture for this unit
- Resource specifications (instance sizes, storage, quotas)
- Environment configuration (dev, staging, production)
- Cost considerations

---

## Execution Steps

### Step 1: Analyze Design Artifacts

Read available design artifacts to identify infrastructure needs:

```bash
cat .aidlc/construction/unit-NNN/nfr-design.md 2>/dev/null
cat .aidlc/construction/unit-NNN/nfr-requirements.md 2>/dev/null
cat .aidlc/inception/units/UNIT-NNN.md
```

Identify logical components that need infrastructure mapping:
- Application servers / compute
- Databases / storage
- Message queues / event buses
- Caches
- CDN / static hosting
- Load balancers / API gateways
- Monitoring / logging services
- CI/CD pipeline requirements

### Step 2: Generate Questions (if needed)

If infrastructure decisions require user input, write questions to `.aidlc/construction/unit-NNN/questions/infrastructure-questions.md` using `question-format-guide.md`.

**Question categories** (only ask if not already determined):

- **Deployment Environment** — Cloud provider, region, account structure
- **Compute Infrastructure** — Container vs serverless vs VM, orchestration approach
- **Storage Infrastructure** — Database type, managed vs self-hosted, backup strategy
- **Messaging Infrastructure** — Queue service, event bus, pub/sub needs
- **Networking Infrastructure** — Load balancing, API gateway, CDN, DNS
- **Monitoring Infrastructure** — Observability stack, alerting, log aggregation
- **Shared Infrastructure** — Shared services across units, resource reuse

Apply overconfidence prevention: present cloud service options with trade-offs rather than assuming a provider or service.

### Step 3: Generate Infrastructure Design Document

Write `.aidlc/construction/unit-NNN/infrastructure-design.md`:

```markdown
---
type: infrastructure-design
unit: "UNIT-NNN"
status: draft
traces_to: ["nfr-design.md", "nfr-requirements.md"]
---

# Infrastructure Design — Unit NNN: {Name}

## Service Mapping

| Logical Component | Infrastructure Service | Justification |
|-------------------|----------------------|---------------|
| Application server | {e.g., AWS ECS Fargate} | {why this choice} |
| Database | {e.g., AWS RDS PostgreSQL} | {why this choice} |
| Cache | {e.g., AWS ElastiCache Redis} | {why this choice} |
| Message queue | {e.g., AWS SQS} | {why this choice} |

## Deployment Architecture

### Environment Strategy
| Environment | Purpose | Infrastructure Differences |
|-------------|---------|---------------------------|
| Development | Local development | {e.g., Docker Compose, local DB} |
| Staging | Pre-production testing | {e.g., Scaled-down production mirror} |
| Production | Live system | {e.g., Full HA, multi-AZ} |

### Architecture Diagram

[ASCII diagram per `ascii-diagram-standards.md` or Mermaid per `content-validation.md`]

## Resource Specifications

| Resource | Specification | Scaling Policy | Estimated Cost |
|----------|--------------|----------------|---------------|
| {resource} | {size/config} | {auto-scale rules} | {monthly est.} |

## Configuration

### Environment Variables
| Variable | Purpose | Source |
|----------|---------|--------|
| {var} | {what it does} | {where to get it} |

### Secrets Management
| Secret | Storage | Rotation Policy |
|--------|---------|----------------|
| {secret} | {e.g., AWS Secrets Manager} | {rotation schedule} |

## IaC Approach

| Tool | Scope | Notes |
|------|-------|-------|
| {e.g., Terraform, CDK, Pulumi} | {what it manages} | {relevant details} |
```

### Step 4: Present for Approval

Present the infrastructure design to the user. Wait for explicit approval.

### Step 5: Record and Update State

- Log approval in `audit.md`
- Update `state.md`

---

## Integration with Bolt Planning

Infrastructure design output affects bolt planning:

- **IaC setup** may become a dedicated bolt (e.g., "provision infrastructure" bolt in Wave 1)
- **Environment configuration** feeds into user_setup frontmatter (secrets, dashboard configs)
- **Service mapping** informs deployment bolt tasks
- **Resource specifications** become verification criteria (e.g., "ECS service running with 2 tasks")

The bolt planner reads `infrastructure-design.md` alongside unit specification and NFR documents when creating bolt plans.

## Shared Infrastructure

If infrastructure is shared across units, create a shared document:

```
.aidlc/construction/shared-infrastructure.md
```

Individual units reference shared infrastructure rather than duplicating it. The first unit that needs shared infrastructure creates this document; subsequent units append to it.
