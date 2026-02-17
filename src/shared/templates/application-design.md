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

## Component Inventory

| Component | Responsibility | Technology | Bounded Context | Traces To (REQ-IDs) | Notes |
|-----------|---------------|------------|-----------------|---------------------|-------|
| {Component 1} | {what it does} | {tech choice} | {which bounded context} | {REQ-XXX} | {rationale or constraints} |
| {Component 2} | {what it does} | {tech choice} | {which bounded context} | {REQ-XXX} | |
| {Component 3} | {what it does} | {tech choice} | {which bounded context} | {REQ-XXX} | |

## Component Methods

> Method signatures and purpose only. Full business logic is defined in Functional Design (per-unit, construction phase).

### {Component 1}

| Method | Purpose | Inputs | Outputs | Business Rules Touched |
|--------|---------|--------|---------|----------------------|
| {methodName()} | {what it does} | {input types} | {output types} | {which rules — detailed later in Functional Design} |

### {Component 2}

| Method | Purpose | Inputs | Outputs | Business Rules Touched |
|--------|---------|--------|---------|----------------------|
| {methodName()} | {what it does} | {input types} | {output types} | {which rules} |

## Service Layer Design

> Services orchestrate interactions between components. Each service owns a specific coordination concern.

| Service | Responsibility | Components Coordinated | Orchestration Pattern | Notes |
|---------|---------------|----------------------|----------------------|-------|
| {Service 1} | {what it coordinates} | {Component A, Component B} | {saga / choreography / request-response} | |
| {Service 2} | {what it coordinates} | {Component B, Component C} | {pattern} | |

## Component Dependency Diagram

> ASCII diagram per `ascii-diagram-standards.md`. Shows component-to-component dependencies with communication protocols.

```
{Text-based component dependency diagram.
Example:
  [Auth Component] --REST--> [User Component]
  [Order Component] --events--> [Inventory Component]
  [API Gateway] --gRPC--> [Order Component]
                --REST--> [Auth Component]
}
```

## Data Flow Between Components

> Trace major operations through the component chain. Shows how data moves for each key user-facing operation.

### {Operation 1: e.g., "User places an order"}

```
Entry:    [API Gateway] receives POST /orders
Step 1:   [Auth Component] validates token --> passes user context
Step 2:   [Order Component] creates order record --> emits OrderCreated event
Step 3:   [Inventory Component] reserves stock --> confirms availability
Terminal: [Order Component] returns order confirmation to caller
```

**Data shape at each transition:**

| Transition | From | To | Data Shape |
|-----------|------|----|------------|
| {Step 1 -> 2} | {Auth} | {Order} | {UserContext: { id, roles }} |
| {Step 2 -> 3} | {Order} | {Inventory} | {OrderCreated: { orderId, items[] }} |

### {Operation 2: e.g., "..."}

{Same pattern as above}

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
