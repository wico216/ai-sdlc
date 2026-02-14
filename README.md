# AI-SDLC Framework for Claude Code

An AI-native software development lifecycle framework that runs inside Claude Code. Based on the [AI-SDLC methodology](https://ai-sdlc-explainer.vercel.app/), this framework guides you through three phases — Inception, Construction, and Operations — with evidence-based gates and a complete audit trail.

## Why AI-SDLC?

Traditional Agile + copilots is like putting a jet engine on a horse cart. AI-SDLC reimagines the entire workflow:

- **Bolts, not Sprints** — iterations in hours/days, not weeks
- **AI proposes, Human approves** — reverse the conversation direction
- **Proof over Prose** — gates require evidence, not claims
- **Golden Thread** — Intent traces through Requirements → Units → Code → Deployment

## Install

```bash
git clone <this-repo>
cd ai-sdlc
./install.sh
```

This installs commands, agents, and templates into your `~/.claude/` directory. No npm required.

## Quick Start

1. Open your project directory in Claude Code
2. Run `/sdlc:new-project` to initialize
3. Run `/sdlc:inception` to decompose into units
4. Run `/sdlc:bolt 1` to build the first unit
5. Run `/sdlc:deploy` when ready for production

## Three Phases

### Inception (WHAT + WHY)

Convert intent into testable, decomposed work.

```
/sdlc:new-project     → Initialize project (questioning, research, requirements, roadmap)
/sdlc:inception       → Full Inception flow (intent, units, risk register, gates)
```

**Artifacts:** `intent.md`, `requirements.md`, `units/`, `risk-register.md`, `execution-plan.md`
**Gates:** Requirements Approved, INCEPTION EXIT

### Construction (HOW)

Build units with proof via Bolts.

```
/sdlc:bolt <unit>     → Plan + execute a unit's work
/sdlc:plan-phase <N>  → Plan a phase (lower-level)
/sdlc:execute-phase <N> → Execute plans in a phase
/sdlc:verify-work     → Verify phase deliverables
```

**Artifacts:** `design.md`, `bolt-plan.md`, `bolt-summary.md`, `validation-report.md`
**Gates:** Design Approved (per unit), UNIT COMPLETE (per unit)

### Operations (WHERE/WHEN)

Productionize with safety and observability.

```
/sdlc:deploy          → Deployment plan, runbooks, observability, Production Ready gate
```

**Artifacts:** `deployment-plan.md`, `runbooks/`, `observability-config.md`
**Gates:** PRODUCTION READY

## All Commands

| Command | Description |
|---|---|
| `/sdlc:new-project` | Initialize a new project with deep questioning |
| `/sdlc:inception` | Run full Inception phase with gates |
| `/sdlc:bolt <unit>` | Execute a Construction bolt for a unit |
| `/sdlc:deploy` | Run Operations phase |
| `/sdlc:plan-phase <N>` | Create execution plans for a phase |
| `/sdlc:execute-phase <N>` | Execute all plans in a phase |
| `/sdlc:verify-work` | Verify phase deliverables against goals |
| `/sdlc:discuss-phase <N>` | Capture context before planning |
| `/sdlc:research-phase <N>` | Research domain before planning |
| `/sdlc:progress` | Check project progress |
| `/sdlc:quick` | Quick task execution |
| `/sdlc:debug` | Systematic bug investigation |
| `/sdlc:help` | Full command reference |
| `/sdlc:settings` | Configure workflow preferences |

## Project Structure

When you run AI-SDLC on a project, it creates:

```
your-project/
├── .aidlc/                    # All AI-SDLC artifacts
│   ├── PROJECT.md             # Project context
│   ├── REQUIREMENTS.md        # Scoped requirements with IDs
│   ├── ROADMAP.md             # Phase structure
│   ├── STATE.md               # Project memory
│   ├── config.json            # Workflow preferences
│   ├── intent.md              # Golden Thread starting point
│   ├── execution-plan.md      # Adaptive depth settings
│   ├── risk-register.md       # Identified risks
│   ├── audit.md               # Append-only decision log
│   ├── units/                 # Parallel-deliverable work chunks
│   │   ├── UNIT-001.md
│   │   ├── UNIT-001-design.md
│   │   └── ...
│   ├── phases/                # Execution plans and summaries
│   │   ├── 01-phase-name/
│   │   └── ...
│   ├── deployment-plan.md     # Operations artifact
│   ├── runbooks/              # Operational playbooks
│   └── observability-config.md
└── (your source code)
```

## 10 Principles

1. **Reimagine, Don't Retrofit** — AI-native, not Agile + copilots
2. **Reverse Conversation** — AI proposes, Human approves
3. **Design Core** — DDD is mandatory for unit boundaries
4. **Align with AI Capability** — Trust but verify
5. **Cater to Complex Systems** — Designed for real projects
6. **User Stories as Contract** — Familiar handles for humans
7. **Transition via Familiarity** — Learnable in a day
8. **Streamline Responsibilities** — Collapse silos
9. **Minimize Stages, Maximize Flow** — Validation as loss functions
10. **No Hard-Wired Workflows** — Context determines workflow

## 5 Gates

| Gate | Phase | Evidence Required |
|---|---|---|
| Requirements Approved | Inception | Intent + requirements + success criteria |
| INCEPTION EXIT | Inception → Construction | Units + risk register + execution plan |
| Design Approved | Construction (per unit) | Design document + architecture decisions |
| UNIT COMPLETE | Construction (per unit) | Tests passing + validation report |
| PRODUCTION READY | Operations | Deployment plan + runbooks + observability |

## Audit Trail

Every decision, gate approval, and scope change is logged in `.aidlc/audit.md`. This is an append-only log — entries are never deleted or modified. The audit trail provides complete traceability from intent to deployment.

## Forked From

This framework is built on the [Get Shit Done (GSD)](https://github.com/get-shit-done-cc/get-shit-done-cc) framework for Claude Code, enhanced with AI-SDLC methodology.

## License

MIT
