# AI-SDLC Framework for Claude Code

An AI-native software development lifecycle framework that runs inside Claude Code. Based on the [AI-SDLC methodology](https://ai-sdlc-explainer.vercel.app/), this framework guides you through three phases — Inception, Construction, and Operations — with evidence-based gates and a complete audit trail.

## Why AI-SDLC?

Traditional Agile + copilots is like putting a jet engine on a horse cart. You're still doing 2-week sprints, daily standups, and Jira tickets — but now with AI autocomplete. That's retrofitting AI onto processes designed for a world without it.

AI-SDLC reimagines the entire workflow:

- **Bolts, not Sprints** — iterations in hours/days, not weeks
- **AI proposes, Human approves** — reverse the conversation direction
- **Proof over Prose** — gates require evidence, not claims
- **Golden Thread** — Intent traces through Requirements → Units → Code → Deployment

## The Methodology

AI-SDLC is built on three phases, each answering a different question:

```
INCEPTION (WHAT + WHY)          CONSTRUCTION (HOW)           OPERATIONS (WHERE/WHEN)
┌─────────────────────┐        ┌──────────────────────┐     ┌──────────────────────┐
│ Capture Intent      │        │ Design per Unit      │     │ Deployment Plan      │
│ Elaborate Reqs      │──gate──│ Build in Bolts       │─gate│ Runbooks             │
│ Decompose into Units│        │ Validate with Tests  │     │ Observability        │
│ Identify Risks      │        │ Audit Decisions      │     │ Release              │
└─────────────────────┘        └──────────────────────┘     └──────────────────────┘
     INCEPTION EXIT                 UNIT COMPLETE              PRODUCTION READY
```

### Key Concepts

| Concept | What it means |
|---|---|
| **Golden Thread** | Every artifact traces back: Intent → Requirements → Units → Code → Deployment. If a link breaks, you've lost traceability. |
| **Gates** | Human approval checkpoints with evidence requirements. No gate passes without proof — "it works" is not evidence, passing tests are. |
| **Bolts** | The smallest iteration. Hours to days, not weeks. Replaces Sprints. Each bolt plans, executes, and validates a piece of a unit. |
| **Units** | Parallel-deliverable work chunks aligned to DDD bounded contexts. Each unit has acceptance criteria and can be built independently. |
| **Audit Trail** | Append-only decision log. Every gate approval, every design choice, every scope change is recorded. Never deleted, never modified. |
| **Adaptive Depth** | Rigor scales to risk. A simple bug fix gets a brief spec. A regulated system gets formal verification. Context determines workflow. |

### Who Does What

AI-SDLC has a clear responsibility split:

| AI Owns (Execution) | Human Owns (Decisions) |
|---|---|
| Code generation | Requirements scope |
| Test execution | Architecture choices |
| Documentation writing | Security controls |
| Plan proposals | Go/No-Go approvals |
| Research & analysis | Risk acceptance |
| Artifact creation | Gate approvals |

The human is always accountable. AI does the heavy lifting, humans make the judgment calls.

## Install

```bash
git clone https://github.com/wico216/ai-sdlc.git
cd ai-sdlc
./install.sh
```

This installs commands, agents, and templates into your `~/.claude/` directory. No npm required.

### What gets installed

| Location | What | Count |
|---|---|---|
| `~/.claude/ai-sdlc/` | References, templates, workflows | ~50 files |
| `~/.claude/commands/sdlc/` | User-facing commands | 23 commands |
| `~/.claude/agents/` | Specialized AI agents | 11 agents |
| `~/.claude/hooks/` | Status line integration | 2 hooks |

## Quick Start

1. Open your project directory in Claude Code
2. Run `/sdlc:new-project` to initialize
3. Run `/sdlc:elaborate` to decompose into units
4. Run `/sdlc:approve-inception` to approve gates
5. Run `/sdlc:build-unit 1` to build the first unit
6. Run `/sdlc:operations` when ready for production

## Three Phases — Step by Step

### Phase 1: Inception (WHAT + WHY)

Convert intent into testable, decomposed work. This is the most important phase — Construction should not begin until intent is crystal clear.

**Methodology steps and how the framework implements them:**

| Step | What AI-SDLC requires | Framework command | Artifact produced |
|---|---|---|---|
| Capture Intent | Document the problem, vision, success criteria, and constraints | `/sdlc:new-project` | `intent.md` |
| Research Domain | Investigate ecosystem, standard stacks, common pitfalls | `/sdlc:new-project` (optional) | `inception/research/STACK.md`, `FEATURES.md`, `ARCHITECTURE.md`, `PITFALLS.md` |
| Requirements Analysis | Scope what's in v1 vs v2 vs out, assign REQ-IDs | `/sdlc:elaborate` | `inception/requirements.md` |
| Workflow Planning | Determine which stages to run based on complexity (Adaptive Depth) | `/sdlc:elaborate` | `execution-plan.md` |
| User Stories | Define personas and user journeys (if UI/users involved) | `/sdlc:elaborate` | Stories in `inception/requirements.md` |
| Unit Decomposition | Break into parallel-deliverable chunks using DDD bounded contexts | `/sdlc:elaborate` | `inception/units/UNIT-001.md`, `UNIT-002.md`, ... |
| Risk Assessment | Identify risks, assign mitigations and owners | `/sdlc:elaborate` | `inception/risk-register.md` |
| **Gate: Requirements Approved** | Evidence: intent + requirements + success criteria reviewed | `/sdlc:approve-inception` | `audit.md` entry |
| **Gate: INCEPTION EXIT** | Evidence: all units defined, risks identified, human approves | `/sdlc:approve-inception` | `audit.md` entry |

### Phase 2: Construction (HOW)

Build units with proof via Bolts — rapid iterations of AI generation + human validation.

| Step | What AI-SDLC requires | Framework command | Artifact produced |
|---|---|---|---|
| Design Review | Architecture and data model for each unit | `/sdlc:plan-unit <unit>` | `inception/units/UNIT-NNN-design.md` |
| **Gate: Design Approved** | Evidence: design document reviewed, no conflicts with other units | `/sdlc:approve-unit <unit>` | `audit.md` entry |
| Plan Bolt | Break unit work into small plans (2-3 tasks each) | `/sdlc:plan-unit <unit>` | `construction/unit-NNN/bolt-NN-plan.md` |
| Execute Bolt | AI generates code, human reviews, tests run | `/sdlc:build-unit <unit>` | `construction/unit-NNN/bolt-NN-summary.md` |
| Validate | Automated tests + manual verification | `/sdlc:verify-unit <unit>` | Verification report |
| **Gate: UNIT COMPLETE** | Evidence: all acceptance criteria met, tests passing | `/sdlc:approve-unit <unit>` | `audit.md` entry |
| Repeat | Run another bolt if unit needs more work | `/sdlc:build-unit <unit>` | — |

### Phase 3: Operations (WHERE/WHEN)

Productionize with safety and observability.

| Step | What AI-SDLC requires | Framework command | Artifact produced |
|---|---|---|---|
| Deployment Planning | Strategy, pre-deployment checklist, rollback procedure | `/sdlc:operations` (Stage 1) | `operations/deployment-plan.md` |
| Runbook Generation | Operational playbooks for incidents, scaling, maintenance | `/sdlc:operations` (Stage 2) | `operations/runbooks/` |
| Observability Setup | Logging, metrics, alerting, tracing configuration | `/sdlc:operations` (Stage 3) | `operations/observability.md` |
| **Gate: PRODUCTION READY** | Evidence: deployable + observable + rollbackable | `/sdlc:approve-release` | `audit.md` entry |

## The Golden Thread

Every artifact in the framework traces back through a continuous chain. This is the core traceability mechanism of AI-SDLC:

```
Intent (intent.md)
  └── "What problem are we solving and why?"
       │
       ▼
Requirements (inception/requirements.md)
  └── REQ-001, REQ-002... — scoped, testable, with IDs
       │
       ▼
Units (inception/units/UNIT-001.md)
  └── Parallel work chunks aligned to domain boundaries
       │
       ▼
Design (inception/units/UNIT-001-design.md)
  └── Architecture, data models, interfaces per unit
       │
       ▼
Code (via /sdlc:build-unit)
  └── Implementation with atomic commits per task
       │
       ▼
Tests (validation-report.md)
  └── Evidence that acceptance criteria are met
       │
       ▼
Deployment (operations/deployment-plan.md)
  └── How it reaches production safely
```

The `audit.md` file records every transition between these stages. If someone asks "why was this built this way?" — the answer is in the thread.

## 10 Principles — How This Framework Implements Them

| # | Principle | What it means | How the framework implements it |
|---|---|---|---|
| 1 | **Reimagine, Don't Retrofit** | AI enables Bolts (hours/days), not Sprints (weeks). Build AI-native. | `/sdlc:build-unit` runs rapid iterations. Parallel unit execution via wave-based agents. No sprint ceremonies. |
| 2 | **Reverse Conversation** | AI proposes, Human approves. Human states intent, AI proposes plans. | Every command presents proposals at gates. AI drafts intent, requirements, units — human reviews and approves. |
| 3 | **Design Core (DDD)** | Domain-Driven Design produces bounded contexts for parallel delivery. | `/sdlc:elaborate` decomposes requirements into DDD-aligned units. Each unit owns a bounded context. |
| 4 | **Align with AI Capability** | AI does heavy lifting, Humans make judgment calls. Trust but verify. | 5 gates require human approval with evidence. AI never auto-approves. Confidence levels on proposals. |
| 5 | **Cater to Complex Systems** | Designed for real projects — regulated, distributed, brownfield. | Adaptive Depth scales rigor to complexity. Brownfield detection + codebase mapping. Risk register for constraints. |
| 6 | **User Stories as Contract** | Stories bridge human intent and AI execution. Risk registers constrain AI. | `/sdlc:elaborate` generates stories tracing to requirements. Risk register limits what AI can do without approval. |
| 7 | **Transition via Familiarity** | Learnable in a day. Bolts feel like focused work sessions, not alien processes. | Commands use familiar patterns (plan → execute → verify). Terminology maps to known concepts. |
| 8 | **Streamline Responsibilities** | Collapse silos. One person + AI per unit. Minimize handoffs. | Each unit is self-contained and completable by one developer + AI. No cross-unit dependencies in artifacts. |
| 9 | **Minimize Stages, Maximize Flow** | Every gate must catch errors. If a step doesn't add value, skip it. | Adaptive Depth skips unnecessary stages. Gates have explicit evidence criteria — no rubber-stamping. |
| 10 | **No Hard-Wired Workflows** | Context determines workflow. Greenfield ≠ Brownfield ≠ Bug fix. | `execution-plan.md` adapts stages based on project type. `/sdlc:quick` for simple tasks that don't need full ceremony. |

## Adaptive Depth

The framework doesn't treat every task the same. Rigor scales to risk:

| Risk Level | Inception | Construction | Operations |
|---|---|---|---|
| **Low** (bug fix, small feature) | Brief intent + requirements | Quick bolts, light gates | Basic deploy plan |
| **Medium** (new feature, integration) | Full inception + units | Standard bolts + design review | Deploy + runbooks |
| **High** (regulated, distributed, critical) | Full inception + stories + risk register | Formal gates + verification | Full ops readiness + observability |

The execution plan created during Inception determines the depth. You can also use `/sdlc:quick` to skip the full ceremony for truly simple tasks.

## 5 Gates

Gates are the "Proof over Prose" mechanism. Each gate requires evidence before passing:

| Gate | Phase | Evidence Required |
|---|---|---|
| Requirements Approved | Inception | Intent document + requirements with IDs + measurable success criteria |
| INCEPTION EXIT | Inception → Construction | Units defined with acceptance criteria + risk register + execution plan |
| Design Approved | Construction (per unit) | Design document + architecture decisions + no conflicts with other units |
| UNIT COMPLETE | Construction (per unit) | All acceptance criteria checked + tests passing + validation report |
| PRODUCTION READY | Operations | Deployment plan + runbooks + observability config + rollback procedure tested |

**How gates work in the framework:**
1. AI collects evidence and presents it as a checklist
2. Human reviews the evidence
3. Human approves or rejects the gate
4. Decision is logged in `audit.md` (approve or reject with reason)
5. If rejected: AI surfaces gaps, routes back to the right stage

## All Commands

| Command | Phase | Description |
|---|---|---|
| `/sdlc:new-project` | Inception | Initialize project with questioning and intent capture |
| `/sdlc:elaborate` | Inception | Full inception: requirements, units, risk register, gates |
| `/sdlc:approve-inception` | Inception | Approve Requirements (Gate 1) and Inception Exit (Gate 2) |
| `/sdlc:plan-unit <unit>` | Construction | Create bolt plans for a unit with research and verification |
| `/sdlc:build-unit <unit>` | Construction | Execute bolts with wave-based parallel agents |
| `/sdlc:verify-unit <unit>` | Construction | Verify deliverables through conversational UAT |
| `/sdlc:approve-unit <unit>` | Construction | Approve Design (Gate 3) and Unit Complete (Gate 4) |
| `/sdlc:operations` | Operations | Operations phase — deployment plan, runbooks, observability |
| `/sdlc:approve-release` | Operations | Approve Production Ready (Gate 5) |
| `/sdlc:status` | Any | Check project status, gate statuses, and next action |
| `/sdlc:quick` | Any | Quick task execution (skip full ceremony) |
| `/sdlc:debug` | Any | Systematic bug investigation with persistent state |
| `/sdlc:map-codebase` | Any | Analyze codebase with parallel mapper agents |
| `/sdlc:settings` | Any | Configure workflow preferences |
| `/sdlc:set-profile` | Any | Switch model profile (quality/balanced/budget) |
| `/sdlc:pause-work` | Any | Save context for later resumption |
| `/sdlc:resume-work` | Any | Restore project context from previous session |
| `/sdlc:retro` | Any | Guardrail retrospective on completed work |
| `/sdlc:add-todo` | Any | Capture idea as pending todo |
| `/sdlc:check-todos` | Any | Review pending todos |
| `/sdlc:audit-compliance` | Any | Verify audit trail compliance |
| `/sdlc:help` | Any | Full command reference |

## Project Structure

When you run AI-SDLC on a project, it creates a `.aidlc/` directory with all artifacts:

```
your-project/
├── .aidlc/                        # All AI-SDLC artifacts
│   ├── intent.md                  # Golden Thread starting point
│   ├── config.json                # Workflow preferences
│   ├── state.md                   # Project memory (current position)
│   ├── execution-plan.md          # Unit structure and execution order
│   ├── audit.md                   # Append-only decision log
│   ├── guardrails.md              # Project-specific guardrails
│   │
│   ├── inception/                 # Inception phase artifacts
│   │   ├── requirements.md        # Scoped requirements with REQ-IDs
│   │   ├── risk-register.md       # Identified risks with mitigations
│   │   ├── units/                 # Unit definitions (DDD-aligned)
│   │   │   ├── UNIT-001.md        # Unit definition + acceptance criteria
│   │   │   ├── UNIT-001-design.md # Architecture for this unit
│   │   │   └── ...
│   │   └── research/              # Domain research (optional)
│   │       ├── STACK.md
│   │       ├── FEATURES.md
│   │       ├── ARCHITECTURE.md
│   │       └── PITFALLS.md
│   │
│   ├── construction/              # Bolt plans and summaries
│   │   ├── unit-001/
│   │   │   ├── bolt-01-plan.md    # Bolt plan (2-3 tasks)
│   │   │   ├── bolt-01-summary.md # What was built
│   │   │   └── ...
│   │   └── unit-002/
│   │       └── ...
│   │
│   ├── operations/                # Operations phase artifacts
│   │   ├── deployment-plan.md     # How to deploy
│   │   ├── runbooks/              # Operational playbooks
│   │   ├── observability.md       # Monitoring setup
│   │   └── cost.md                # Cost analysis
│   │
│   └── retros/                    # Retrospective reports
│       └── RETRO-{scope}.md
│
└── (your source code)
```

## Audit Trail

Every decision, gate approval, and scope change is logged in `.aidlc/audit.md`. This is an append-only log — entries are never deleted or modified.

Each entry records:
- **Type**: decision, gate-approval, gate-rejection, design-choice, scope-change, risk-accepted, deviation
- **Actor**: Human, AI-Agent, or Both
- **Phase**: Which phase this happened in
- **Evidence**: Links to artifacts that support the decision
- **Traces to**: Which REQ-ID, UNIT-ID, or STORY-ID this relates to

The audit trail answers: "Why was this built this way?" months after the fact.

## Forked From

This framework is built on the [Get Shit Done (GSD)](https://github.com/get-shit-done-cc/get-shit-done-cc) framework for Claude Code, enhanced with AI-SDLC methodology.

**What changed from GSD:**

| GSD | AI-SDLC |
|---|---|
| `/gsd:*` commands | `/sdlc:*` commands |
| `.planning/` directory | `.aidlc/` directory |
| Phases → Plans → Execute | Inception → Construction (Bolts) → Operations |
| Informal checkpoints | 5 formal gates with evidence requirements |
| No audit trail | Append-only `audit.md` |
| No unit decomposition | DDD-based units with acceptance criteria |
| No operations phase | Full deployment + runbooks + observability |
| No risk tracking | Risk register with mitigations |

## Learn More

- [AI-SDLC Methodology Explainer](https://ai-sdlc-explainer.vercel.app/) — Interactive lessons on the methodology
- [GSD Framework](https://github.com/get-shit-done-cc/get-shit-done-cc) — The foundation this framework builds on

## License

MIT
