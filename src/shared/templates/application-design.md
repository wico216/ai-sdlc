---
type: application-design
project: "{project-name}"
status: "{draft | reviewed | approved}"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
traces_to:
  intent: "inception/intent.md"
  requirements: "inception/requirements.md"
---

# Application Design: {Project Name}

> System-level architecture created during Inception (when required by execution-plan.md).
> This covers the WHOLE project. Per-unit design lives in `construction/unit-NNN/design.md`.

## Architecture Overview

{High-level description of the system architecture. What are the major components and how do they interact?}

### System Diagram

```
{Text-based architecture diagram — boxes, arrows, labels.
Example:
  [Client] → [API Gateway] → [Service A]
                            → [Service B] → [Database]
                            → [Queue] → [Worker]
}
```

## Components

| Component | Responsibility | Technology | Notes |
|-----------|---------------|------------|-------|
| {Component 1} | {what it does} | {tech choice} | {rationale or constraints} |
| {Component 2} | {what it does} | {tech choice} | |
| {Component 3} | {what it does} | {tech choice} | |

## Data Model

### Core Entities

| Entity | Description | Owned By |
|--------|-------------|----------|
| {Entity} | {what it represents} | {which bounded context/unit} |

### Entity Relationships

{Describe key relationships between entities. Text or simple ER notation.}

### Data Storage

| Store | Technology | Purpose | Sizing |
|-------|-----------|---------|--------|
| {Primary DB} | {e.g., PostgreSQL} | {what data} | {expected volume} |
| {Cache} | {e.g., Redis} | {what data} | {expected volume} |

## API Contracts

### External APIs (exposed)

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| {/api/resource} | {GET/POST/...} | {what it does} | {required/public} |

### Internal APIs (between components)

| From | To | Protocol | Purpose |
|------|----|----------|---------|
| {Component A} | {Component B} | {REST/gRPC/events} | {what data flows} |

### External Dependencies (consumed)

| Service | Purpose | SLA | Fallback |
|---------|---------|-----|----------|
| {third-party service} | {what we use it for} | {availability} | {what if it's down} |

## Technology Decisions

| Decision | Choice | Rationale | Alternatives Considered |
|----------|--------|-----------|------------------------|
| {what was decided} | {chosen approach} | {why} | {what else was considered} |

## Dependency Diagram

```
{Text-based dependency graph showing build/deploy order.
Example:
  shared-types → api-server → deployment
               → web-client → deployment
  database-migrations → api-server
}
```

## Unit Mapping

{How the architecture maps to units for construction.}

| Unit | Components Involved | Primary Concern |
|------|-------------------|-----------------|
| UNIT-001 | {components} | {what this unit builds} |
| UNIT-002 | {components} | {what this unit builds} |

---

*Traces: Intent → Requirements → Application Design → Units → Construction*
*Approved at gate: Inception Exit*
