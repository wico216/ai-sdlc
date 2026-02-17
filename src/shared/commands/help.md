---
name: sdlc:help
description: Show available AI-SDLC commands and usage guide
---

<objective>
Display the complete AI-SDLC command reference.

Output ONLY the reference content below. Do NOT add:

- Project-specific analysis
- Git status or file context
- Next-step suggestions
- Any commentary beyond the reference
  </objective>

<reference>
# AI-SDLC Command Reference

**AI-SDLC** is an AI-native software development lifecycle framework for Claude Code. Three phases — Inception, Construction, Operations — with evidence-based gates, a unit/bolt execution model, and a complete audit trail.

## Quick Start

1. `__CMD_PREFIX__new-project` - Initialize project (questioning + config + brownfield detection)
2. `__CMD_PREFIX__elaborate` - Adaptive inception (requirements, user stories, application design, execution plan)
3. `__CMD_PREFIX__approve-inception` - Gate 1+2 approval
4. `__CMD_PREFIX__plan-unit 1` - Plan bolts for Unit 1
5. `__CMD_PREFIX__approve-unit 1 --design` - Gate 3 approval
6. `__CMD_PREFIX__build-unit 1` - Execute bolts for Unit 1
7. `__CMD_PREFIX__verify-unit 1` - UAT for Unit 1
8. `__CMD_PREFIX__approve-unit 1 --complete` - Gate 4 approval
9. `__CMD_PREFIX__deploy` - Run Operations phase
10. `__CMD_PREFIX__approve-release` - Gate 5 approval

## Core Workflow (3 Phases)

```
INCEPTION:     __CMD_PREFIX__new-project → __CMD_PREFIX__elaborate → __CMD_PREFIX__approve-inception
CONSTRUCTION:  __CMD_PREFIX__plan-unit → __CMD_PREFIX__approve-unit --design → __CMD_PREFIX__build-unit → __CMD_PREFIX__verify-unit → __CMD_PREFIX__approve-unit --complete (repeat per unit)
OPERATIONS:    __CMD_PREFIX__deploy → __CMD_PREFIX__approve-release
```

### 5 Gates (Proof over Prose)

| Gate | Command | What it checks |
|---|---|---|
| Requirements Approved | `__CMD_PREFIX__approve-inception` | Intent + requirements clear |
| INCEPTION EXIT | `__CMD_PREFIX__approve-inception` | Application design complete, execution plan ready |
| Design Approved | `__CMD_PREFIX__approve-unit <unit> --design` | Architecture reviewed per unit |
| UNIT COMPLETE | `__CMD_PREFIX__approve-unit <unit> --complete` | Tests pass, criteria met per unit |
| PRODUCTION READY | `__CMD_PREFIX__approve-release` | Deployable, observable, rollbackable |

### Project Initialization

**`__CMD_PREFIX__new-project`**
Initialize new project through unified flow.

One command takes you from idea to ready-for-elaboration:
- Deep questioning to understand what you're building
- Brownfield detection and optional codebase mapping
- Writes intent.md capturing vision, scope, and constraints
- Configures workflow preferences (mode, depth, agents)

Creates `.aidlc/` artifacts:
- `intent.md` — project intent (Golden Thread foundation)
- `config.json` — workflow mode (interactive/yolo)
- `state.md` — project memory

Usage: `__CMD_PREFIX__new-project`

**`__CMD_PREFIX__map-codebase`**
Map an existing codebase for brownfield projects.

- Analyzes codebase with parallel Explore agents
- Creates `.aidlc/codebase/` with 7 focused documents
- Covers stack, architecture, structure, conventions, testing, integrations, concerns
- Use before `__CMD_PREFIX__new-project` on existing codebases

Usage: `__CMD_PREFIX__map-codebase`

### Inception Phase

**`__CMD_PREFIX__elaborate`**
Adaptive inception — build out all inception artifacts from intent.

Replaces the old inception, discuss-phase, and research-phase commands. Drives the project from intent through to a complete, gate-ready inception:
- Requirements definition (with research if configured)
- User stories
- Application design
- Execution plan with unit decomposition
- Risk register

Creates `.aidlc/inception/` artifacts:
- `requirements.md` — scoped requirements with REQ-IDs
- `user-stories.md` — user stories derived from requirements
- `application-design.md` — architecture and design decisions
- `execution-plan.md` — units, dependencies, and build order
- `research/` — domain research (if selected)

Usage: `__CMD_PREFIX__elaborate`

**`__CMD_PREFIX__approve-inception`**
Gate 1+2 approval — Requirements Approved and INCEPTION EXIT.

- Reviews intent.md and inception artifacts for completeness
- Validates requirements are specific, testable, and traced
- Confirms application design is sound
- Checks execution plan covers all requirements
- Records gate evidence in audit.md

Usage: `__CMD_PREFIX__approve-inception`

### Construction Phase

**`__CMD_PREFIX__plan-unit <unit>`**
Plan bolts for a specific unit.

Creates bolt plans (the smallest iteration in AI-SDLC):
- Loads unit definition from execution plan
- Checks dependencies on other units
- Decomposes unit into bolt plans (2-3 tasks max per bolt)
- Creates design document for the unit

Creates `.aidlc/construction/unit-NNN/` artifacts:
- `design.md` — unit architecture and design
- `bolt-NN-plan.md` — individual bolt plans

Usage: `__CMD_PREFIX__plan-unit UNIT-001`
Usage: `__CMD_PREFIX__plan-unit 1`

**`__CMD_PREFIX__approve-unit <unit> --design`**
Gate 3 approval — Design Approved for a specific unit.

- Reviews unit design document
- Validates architecture decisions
- Checks alignment with application design
- Records gate evidence in audit.md

Usage: `__CMD_PREFIX__approve-unit UNIT-001 --design`
Usage: `__CMD_PREFIX__approve-unit 1 --design`

**`__CMD_PREFIX__build-unit <unit>`**
Execute bolts for a specific unit.

Runs bolt execution — the build phase:
- Loads bolt plans for the unit
- Executes plans with wave-based parallelization
- Creates bolt summaries after each bolt completes
- Appends to audit trail

Creates `.aidlc/construction/unit-NNN/` artifacts:
- `bolt-NN-summary.md` — execution results per bolt

Usage: `__CMD_PREFIX__build-unit UNIT-001`
Usage: `__CMD_PREFIX__build-unit 1`

**`__CMD_PREFIX__verify-unit <unit>`**
Validate built features through conversational UAT for a specific unit.

- Extracts testable deliverables from bolt summaries
- Presents tests one at a time (yes/no responses)
- Automatically diagnoses failures and creates fix plans
- Ready for re-execution if issues found

Creates `.aidlc/construction/unit-NNN/` artifacts:
- `VERIFICATION.md` — verification results
- `UAT.md` — user acceptance test results

Usage: `__CMD_PREFIX__verify-unit UNIT-001`
Usage: `__CMD_PREFIX__verify-unit 1`

**`__CMD_PREFIX__approve-unit <unit> --complete`**
Gate 4 approval — UNIT COMPLETE for a specific unit.

- Reviews verification and UAT results
- Validates all acceptance criteria are met
- Checks tests pass and criteria satisfied
- Records gate evidence in audit.md

Usage: `__CMD_PREFIX__approve-unit UNIT-001 --complete`
Usage: `__CMD_PREFIX__approve-unit 1 --complete`

### Operations Phase

**`__CMD_PREFIX__deploy`**
Run the Operations phase — deployment plan, runbooks, and readiness checks.

- Verifies all units are complete
- Generates deployment plan with rollback procedures
- Creates operational runbooks
- Sets up observability configuration
- Completes the Golden Thread: Intent → Code → Deployment

Usage: `__CMD_PREFIX__deploy`

**`__CMD_PREFIX__approve-release [version]`**
Gate 5 approval — PRODUCTION READY.

- Reviews deployment plan and runbooks
- Validates all units passed Gate 4
- Checks rollback procedures exist
- Confirms observability is configured
- Records final gate evidence in audit.md

Usage: `__CMD_PREFIX__approve-release`
Usage: `__CMD_PREFIX__approve-release 1.0.0`

### Progress Tracking

**`__CMD_PREFIX__progress`**
Check project status and intelligently route to next action.

- Shows visual progress bar and completion percentage
- Summarizes recent work from summary files
- Displays current position and what's next
- Lists key decisions and open issues
- Offers to execute next action or create it if missing
- Detects unit/project completion

Usage: `__CMD_PREFIX__progress`

### Quick Mode

**`__CMD_PREFIX__quick`**
Execute small, ad-hoc tasks with AI-SDLC guarantees but skip optional agents.

Quick mode uses the same system with a shorter path:
- Spawns planner + executor (skips researcher, checker, verifier)
- Quick tasks live in `.aidlc/quick/` separate from planned units
- Updates state.md tracking

Use when you know exactly what to do and the task is small enough to not need research or verification.

Usage: `__CMD_PREFIX__quick`
Result: Creates `.aidlc/quick/NNN-slug/PLAN.md`, `.aidlc/quick/NNN-slug/SUMMARY.md`

### Session Management

**`__CMD_PREFIX__resume-work`**
Resume work from previous session with full context restoration.

- Reads state.md for project context
- Shows current position and recent progress
- Offers next actions based on project state

Usage: `__CMD_PREFIX__resume-work`

**`__CMD_PREFIX__pause-work`**
Create context handoff when pausing work mid-unit.

- Creates .continue-here file with current state
- Updates state.md session continuity section
- Captures in-progress work context

Usage: `__CMD_PREFIX__pause-work`

### Debugging

**`__CMD_PREFIX__debug [issue description]`**
Systematic debugging with persistent state across context resets.

- Gathers symptoms through adaptive questioning
- Creates `.aidlc/debug/[slug].md` to track investigation
- Investigates using scientific method (evidence → hypothesis → test)
- Survives `/clear` — run `__CMD_PREFIX__debug` with no args to resume
- Archives resolved issues to `.aidlc/debug/resolved/`

Usage: `__CMD_PREFIX__debug "login button doesn't work"`
Usage: `__CMD_PREFIX__debug` (resume active session)

### Todo Management

**`__CMD_PREFIX__add-todo [description]`**
Capture idea or task as todo from current conversation.

- Extracts context from conversation (or uses provided description)
- Creates structured todo file in `.aidlc/todos/pending/`
- Infers area from file paths for grouping
- Checks for duplicates before creating
- Updates state.md todo count

Usage: `__CMD_PREFIX__add-todo` (infers from conversation)
Usage: `__CMD_PREFIX__add-todo Add auth token refresh`

**`__CMD_PREFIX__check-todos [area]`**
List pending todos and select one to work on.

- Lists all pending todos with title, area, age
- Optional area filter (e.g., `__CMD_PREFIX__check-todos api`)
- Loads full context for selected todo
- Routes to appropriate action (work now, add to unit, brainstorm)
- Moves todo to done/ when work begins

Usage: `__CMD_PREFIX__check-todos`
Usage: `__CMD_PREFIX__check-todos api`

### Guardrail Retro

**`__CMD_PREFIX__retro [unit-id]`**
Review what AI did well/poorly and improve for next time.

- Analyzes audit trail, gate results, rework cycles, risk register
- Identifies effective vs. missing guardrails
- Asks for human observations (data alone isn't enough)
- Produces concrete improvement actions for next unit
- Optionally updates risk register with new risks

Usage: `__CMD_PREFIX__retro UNIT-001`
Usage: `__CMD_PREFIX__retro` (retro on most recently completed unit)

### Compliance

**`__CMD_PREFIX__audit-compliance`**
Verify AI-SDLC compliance — gates passed, Golden Thread intact, audit trail complete.

- Checks all 5 gates have evidence in audit trail
- Verifies Golden Thread traceability (intent → requirements → units → code → deployment)
- Validates audit trail completeness
- Checks risk register exists and is structured
- Produces `.aidlc/COMPLIANCE.md` with pass/fail checklist

Usage: `__CMD_PREFIX__audit-compliance`

### Configuration

**`__CMD_PREFIX__settings`**
Configure workflow toggles and model profile interactively.

- Toggle researcher, plan checker, verifier agents
- Select model profile (quality/balanced/budget)
- Updates `.aidlc/config.json`

Usage: `__CMD_PREFIX__settings`

**`__CMD_PREFIX__set-profile <profile>`**
Quick switch model profile for AI-SDLC agents.

- `quality` — Opus everywhere except verification
- `balanced` — Opus for planning, Sonnet for execution (default)
- `budget` — Sonnet for writing, Haiku for research/verification

Usage: `__CMD_PREFIX__set-profile budget`

### Utility Commands

**`__CMD_PREFIX__ask`**
Ask questions about the project, codebase, or AI-SDLC methodology.

Usage: `__CMD_PREFIX__ask`

**`__CMD_PREFIX__help`**
Show this command reference.

**`__CMD_PREFIX__update`**
Update AI-SDLC to latest version with changelog preview.

- Shows installed vs latest version comparison
- Displays changelog entries for versions you've missed
- Highlights breaking changes
- Confirms before running install
- Uses GitHub API to check for new releases

Usage: `__CMD_PREFIX__update`

**`__CMD_PREFIX__community`**
Open the AI-SDLC community on GitHub.

- Report issues, request features, share feedback
- Browse discussions and solutions

Usage: `__CMD_PREFIX__community`

## Files & Structure

```
.aidlc/
├── intent.md              # Project intent (Golden Thread foundation)
├── state.md               # Project memory & context
├── config.json            # Workflow mode & gates
├── audit.md               # Append-only decision log
├── risk-register.md       # Identified risks with mitigations
├── inception/             # Inception artifacts
│   ├── requirements.md    # Scoped requirements with REQ-IDs
│   ├── user-stories.md    # User stories from requirements
│   ├── application-design.md  # Architecture and design
│   ├── execution-plan.md  # Units, dependencies, build order
│   └── research/          # Domain research (optional)
├── construction/          # Construction artifacts
│   └── unit-NNN/          # Per-unit directory
│       ├── design.md      # Unit architecture
│       ├── bolt-NN-plan.md    # Bolt execution plans
│       ├── bolt-NN-summary.md # Bolt execution results
│       ├── VERIFICATION.md    # Verification results
│       └── UAT.md             # User acceptance tests
├── todos/                 # Captured ideas and tasks
│   ├── pending/           # Todos waiting to be worked on
│   └── done/              # Completed todos
├── debug/                 # Active debug sessions
│   └── resolved/          # Archived resolved issues
├── codebase/              # Codebase map (brownfield projects)
│   ├── STACK.md           # Languages, frameworks, dependencies
│   ├── ARCHITECTURE.md    # Patterns, layers, data flow
│   ├── STRUCTURE.md       # Directory layout, key files
│   ├── CONVENTIONS.md     # Coding standards, naming
│   ├── TESTING.md         # Test setup, patterns
│   ├── INTEGRATIONS.md    # External services, APIs
│   └── CONCERNS.md        # Tech debt, known issues
└── quick/                 # Quick tasks (ad-hoc)
    └── NNN-slug/
        ├── PLAN.md
        └── SUMMARY.md
```

## Workflow Modes

Set during `__CMD_PREFIX__new-project`:

**Interactive Mode**

- Confirms each major decision
- Pauses at checkpoints for approval
- More guidance throughout

**YOLO Mode**

- Auto-approves most decisions
- Executes plans without confirmation
- Only stops for critical checkpoints

Change anytime by editing `.aidlc/config.json`

## Planning Configuration

Configure how planning artifacts are managed in `.aidlc/config.json`:

**`planning.commit_docs`** (default: `true`)
- `true`: Planning artifacts committed to git (standard workflow)
- `false`: Planning artifacts kept local-only, not committed

When `commit_docs: false`:
- Add `.aidlc/` to your `.gitignore`
- Useful for OSS contributions, client projects, or keeping planning private
- All planning files still work normally, just not tracked in git

**`planning.search_gitignored`** (default: `false`)
- `true`: Add `--no-ignore` to broad ripgrep searches
- Only needed when `.aidlc/` is gitignored and you want project-wide searches to include it

Example config:
```json
{
  "planning": {
    "commit_docs": false,
    "search_gitignored": true
  }
}
```

## Common Workflows

**Starting a new project (full AI-SDLC flow):**

```
__CMD_PREFIX__new-project             # INCEPTION: questioning → intent → config
/clear
__CMD_PREFIX__elaborate               # INCEPTION: requirements → user stories → design → execution plan
/clear
__CMD_PREFIX__approve-inception       # GATE 1+2: Requirements Approved + INCEPTION EXIT
/clear
__CMD_PREFIX__plan-unit 1             # CONSTRUCTION: plan bolts for Unit 1
__CMD_PREFIX__approve-unit 1 --design # GATE 3: Design Approved
/clear
__CMD_PREFIX__build-unit 1            # CONSTRUCTION: execute bolts for Unit 1
/clear
__CMD_PREFIX__verify-unit 1           # CONSTRUCTION: UAT for Unit 1
__CMD_PREFIX__approve-unit 1 --complete # GATE 4: UNIT COMPLETE
/clear
__CMD_PREFIX__plan-unit 2             # CONSTRUCTION: next unit...
# ... repeat for all units ...
/clear
__CMD_PREFIX__deploy                  # OPERATIONS: deployment plan → runbooks
__CMD_PREFIX__approve-release 1.0.0   # GATE 5: PRODUCTION READY
```

**Resuming work after a break:**

```
__CMD_PREFIX__progress  # See where you left off and continue
```

**Capturing ideas during work:**

```
__CMD_PREFIX__add-todo                    # Capture from conversation context
__CMD_PREFIX__add-todo Fix modal z-index  # Capture with explicit description
__CMD_PREFIX__check-todos                 # Review and work on todos
__CMD_PREFIX__check-todos api             # Filter by area
```

**Debugging an issue:**

```
__CMD_PREFIX__debug "form submission fails silently"  # Start debug session
# ... investigation happens, context fills up ...
/clear
__CMD_PREFIX__debug                                    # Resume from where you left off
```

**Running a retro after completing a unit:**

```
__CMD_PREFIX__retro UNIT-001  # Review guardrails, identify improvements
```

## Getting Help

- Read `.aidlc/intent.md` for project vision
- Read `.aidlc/state.md` for current context
- Check `.aidlc/inception/execution-plan.md` for unit status
- Run `__CMD_PREFIX__progress` to check where you're up to
  </reference>
