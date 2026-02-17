# AI-SDLC: Three Phases

The AI-SDLC lifecycle consists of three macro-phases, each with specific goals, rituals, artifacts, and gates.

---

## Phase 1: INCEPTION (WHAT + WHY)

**Goal:** Convert intent into testable, decomposed work.

**Key Ritual:** Mob Elaboration
- Conducted with shared screen and facilitator
- AI proposes breakdown into stories and units
- Team (PO, Devs, QA, stakeholders) reviews and refines
- Compresses weeks of sequential work into hours

**Stages (adaptive based on complexity):**

1. **Workspace Detection** — Greenfield or brownfield? What's the tech stack?
2. **Reverse Engineering** (brownfield only) — Analyze existing architecture, map dependencies
3. **Requirements Analysis** (mandatory) — Elaborate intent, document functional requirements
4. **User Stories** (if UI/multiple users) — Define personas, document user journeys
5. **Workflow Planning** (mandatory) — Determine which stages to run, create execution plan
6. **Application Design** (if new components) — High-level architecture, component responsibilities
7. **Units Generation** (if decomposable) — Break into parallel units, define acceptance criteria

**Artifacts:**
- `intent.md` — The project's purpose and success criteria
- `requirements.md` — Scoped requirements with IDs
- `inception/units/` — Parallel-deliverable work chunks
- `risk-register.md` — Identified risks with mitigations
- `execution-plan.md` — Which stages to run and in what order

**Gates:**
- **Requirements Approved** — Intent + requirements reviewed by human
- **INCEPTION EXIT** — All units defined with acceptance criteria, human approval to proceed

---

## Phase 2: CONSTRUCTION (HOW)

**Goal:** Build units with proof via Bolts (rapid iterations).

**Key Ritual:** Mob Construction
- Teams collocated, delivering Bolts
- AI generates, humans validate
- Each Bolt = smallest iteration (hours to days, not weeks)

**Flow per Unit:**
1. **Domain Design** — Bounded contexts, data models
2. **Logical Design** — Component architecture, interfaces
3. **Implementation** — Code generation + human review
4. **Validation** — Automated tests + manual verification

**Artifacts:**
- `design.md` — Architecture and design decisions per unit
- `bolt-plan.md` — Task breakdown for each bolt
- `bolt-summary.md` — What was built, what was learned
- `validation-report.md` — Test results and evidence
- `audit.md` — Append-only decision log

**Gates:**
- **Design Approved** — Design document reviewed before implementation
- **UNIT COMPLETE** — Tests passing + validation report accepted

### Brownfield & Frontend
- For brownfield projects: regression baseline must exist before construction begins
- For frontend changes: behaviour preservation evidence required at Gate 4 (Unit Complete)
- See: verification-patterns.md § Frontend Behaviour Preservation

---

## Phase 3: OPERATIONS (WHERE/WHEN)

**Goal:** Productionize with safety and observability.

**Key Ritual:** AI-driven operational efficiency with human oversight for SLA/compliance.

**Flow:**
1. **Deployment Planning** — How will this reach production?
2. **Runbook Generation** — AI generates operational playbooks
3. **Observability Setup** — Monitoring, alerting, logging
4. **Release** — Deploy with rollback capability

**Artifacts:**
- `operations/deployment-plan.md` — Deployment strategy, rollback procedures
- `operations/runbooks/` — Operational playbooks
- `operations/observability.md` — Monitoring and alerting setup
- `operations/cost.md` — Cost estimates (if applicable)

**Gates:**
- **PRODUCTION READY** — Deployable + observable + rollbackable

---

## Phase Flow

```
INCEPTION
  ├── Capture Intent
  ├── Mob Elaboration
  └── Define Units
        │
        ▼ [Gate: INCEPTION EXIT]
CONSTRUCTION
  ├── Domain Design
  ├── Logical Design
  └── Code + Tests (Bolts)
        │
        ▼ [Gate: UNIT COMPLETE]
OPERATIONS
  ├── Deploy
  ├── Monitor
  └── Adapt
        │
        ▼ [Gate: PRODUCTION READY]
```

Feedback loops flow backward: Operations insights inform Construction improvements, Construction learnings refine Inception processes.

---

## Agents note

When determining which phase the project is in, check `.aidlc/state.md`. The current phase determines which commands and workflows are available. Don't allow skipping gates — evidence must be provided before transitioning.
