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

**AI-SDLC** is an AI-native software development lifecycle framework for Claude Code. Three phases — Inception, Construction, Operations — with evidence-based gates and a complete audit trail.

## Quick Start

1. `__CMD_PREFIX__new-project` - Initialize project (questioning, research, requirements, roadmap)
2. `__CMD_PREFIX__inception` - Run full Inception phase (intent, units, risk register, gates)
3. `__CMD_PREFIX__bolt 1` - Execute a Construction bolt for the first unit
4. `__CMD_PREFIX__deploy` - Run Operations phase when ready

## Core Workflow (3 Phases)

```
INCEPTION:     __CMD_PREFIX__new-project → __CMD_PREFIX__inception
CONSTRUCTION:  __CMD_PREFIX__bolt <unit> (repeat per unit)
OPERATIONS:    __CMD_PREFIX__deploy
```

### 5 Gates (Proof over Prose)

| Gate | Phase | What it checks |
|---|---|---|
| Requirements Approved | Inception | Intent + requirements clear |
| INCEPTION EXIT | Inception → Construction | Units decomposed, risks identified |
| Design Approved | Construction | Architecture reviewed per unit |
| UNIT COMPLETE | Construction | Tests pass, criteria met per unit |
| PRODUCTION READY | Operations | Deployable, observable, rollbackable |

### Project Initialization

**`__CMD_PREFIX__new-project`**
Initialize new project through unified flow.

One command takes you from idea to ready-for-planning:
- Deep questioning to understand what you're building
- Optional domain research (spawns 4 parallel researcher agents)
- Requirements definition with v1/v2/out-of-scope scoping
- Roadmap creation with phase breakdown and success criteria

Creates all `.aidlc/` artifacts:
- `PROJECT.md` — vision and requirements
- `config.json` — workflow mode (interactive/yolo)
- `research/` — domain research (if selected)
- `REQUIREMENTS.md` — scoped requirements with REQ-IDs
- `ROADMAP.md` — phases mapped to requirements
- `STATE.md` — project memory

Usage: `__CMD_PREFIX__new-project`

**`__CMD_PREFIX__map-codebase`**
Map an existing codebase for brownfield projects.

- Analyzes codebase with parallel Explore agents
- Creates `.aidlc/codebase/` with 7 focused documents
- Covers stack, architecture, structure, conventions, testing, integrations, concerns
- Use before `__CMD_PREFIX__new-project` on existing codebases

Usage: `__CMD_PREFIX__map-codebase`

### Inception Phase

**`__CMD_PREFIX__inception`**
Run the full AI-SDLC Inception phase after `__CMD_PREFIX__new-project`.

Converts intent into testable, decomposed work:
- Creates intent document (Golden Thread starting point)
- Generates execution plan (adaptive depth)
- Decomposes into Units (parallel-deliverable work chunks using DDD)
- Creates risk register
- Runs 2 gates: Requirements Approved, INCEPTION EXIT

Creates additional `.aidlc/` artifacts:
- `intent.md` — project intent and success criteria
- `execution-plan.md` — which stages to run
- `units/UNIT-NNN.md` — parallel work chunks with acceptance criteria
- `risk-register.md` — identified risks with mitigations
- `audit.md` — append-only decision log

Usage: `__CMD_PREFIX__inception`

### Construction Phase

**`__CMD_PREFIX__bolt <unit>`**
Execute a Construction bolt for a specific unit.

A Bolt is the smallest iteration in AI-SDLC (hours to days):
- Loads unit definition and checks dependencies
- Runs Design Approved gate (architecture review)
- Creates bolt plans (2-3 tasks max per plan)
- Executes plans with wave-based parallelization
- Checks Unit Complete gate when all criteria met
- Appends to audit trail

Flags:
- `--skip-design-gate` — Skip design review (for subsequent bolts)
- `--plan-only` — Only create plans, don't execute
- `--execute-only` — Execute existing plans

Usage: `__CMD_PREFIX__bolt UNIT-001`
Usage: `__CMD_PREFIX__bolt 1`
Usage: `__CMD_PREFIX__bolt UNIT-002 --skip-design-gate`

### Operations Phase

**`__CMD_PREFIX__deploy`**
Run the Operations phase — deployment plan, runbooks, and Production Ready gate.

- Verifies all units are complete
- Generates deployment plan with rollback procedures
- Creates operational runbooks
- Sets up observability configuration
- Runs Production Ready gate (final gate)
- Completes the Golden Thread: Intent → Code → Deployment

Usage: `__CMD_PREFIX__deploy`

### Unit Research & Planning

These commands help prepare for bolt execution. They are called internally by `__CMD_PREFIX__bolt` but can also be used standalone for deeper control.

**`__CMD_PREFIX__discuss-phase <number>`**
Help articulate your vision for a phase before planning.

- Captures how you imagine this phase working
- Creates CONTEXT.md with your vision, essentials, and boundaries
- Use when you have ideas about how something should look/feel

Usage: `__CMD_PREFIX__discuss-phase 2`

**`__CMD_PREFIX__research-phase <number>`**
Comprehensive ecosystem research for niche/complex domains.

- Discovers standard stack, architecture patterns, pitfalls
- Creates RESEARCH.md with "how experts build this" knowledge
- Use for 3D, games, audio, shaders, ML, and other specialized domains
- Goes beyond "which library" to ecosystem knowledge

Usage: `__CMD_PREFIX__research-phase 3`

**`__CMD_PREFIX__list-phase-assumptions <number>`**
See what Claude is planning to do before it starts.

- Shows Claude's intended approach for a phase
- Lets you course-correct if Claude misunderstood your vision
- No files created - conversational output only

Usage: `__CMD_PREFIX__list-phase-assumptions 3`

### Advanced: Direct Phase Execution

> **Note:** These commands bypass AI-SDLC gates (Design Approved, Unit Complete). They are the internal execution engine used by `__CMD_PREFIX__bolt`. Use them directly only when you need fine-grained control over planning and execution, and understand that gate enforcement and Golden Thread traceability are your responsibility.

**`__CMD_PREFIX__plan-phase <number>`**
Create detailed execution plan for a specific phase.

- Generates `.aidlc/phases/XX-phase-name/XX-YY-PLAN.md`
- Breaks phase into concrete, actionable tasks
- Includes verification criteria and success measures
- Multiple plans per phase supported (XX-01, XX-02, etc.)
- **Does not enforce Design Approved gate** — use `__CMD_PREFIX__bolt` for gate-enforced flow

Usage: `__CMD_PREFIX__plan-phase 1`
Result: Creates `.aidlc/phases/01-foundation/01-01-PLAN.md`

**`__CMD_PREFIX__execute-phase <phase-number>`**
Execute all plans in a phase.

- Groups plans by wave (from frontmatter), executes waves sequentially
- Plans within each wave run in parallel via Task tool
- Verifies phase goal after all plans complete
- Updates REQUIREMENTS.md, ROADMAP.md, STATE.md
- **Does not enforce Unit Complete gate** — use `__CMD_PREFIX__bolt` for gate-enforced flow

Usage: `__CMD_PREFIX__execute-phase 5`

### Quick Mode

**`__CMD_PREFIX__quick`**
Execute small, ad-hoc tasks with AI-SDLC guarantees but skip optional agents.

Quick mode uses the same system with a shorter path:
- Spawns planner + executor (skips researcher, checker, verifier)
- Quick tasks live in `.aidlc/quick/` separate from planned phases
- Updates STATE.md tracking (not ROADMAP.md)

Use when you know exactly what to do and the task is small enough to not need research or verification.

Usage: `__CMD_PREFIX__quick`
Result: Creates `.aidlc/quick/NNN-slug/PLAN.md`, `.aidlc/quick/NNN-slug/SUMMARY.md`

### Extended Workflow: Roadmap & Milestone Management

> These commands extend AI-SDLC for multi-release projects. They manage the ROADMAP.md phases and milestone lifecycle. They are not part of the core 3-phase model (Inception → Construction → Operations) but are useful for iterative development across multiple releases.

**`__CMD_PREFIX__add-phase <description>`**
Add new phase to end of current milestone.

- Appends to ROADMAP.md
- Uses next sequential number
- Updates phase directory structure

Usage: `__CMD_PREFIX__add-phase "Add admin dashboard"`

**`__CMD_PREFIX__insert-phase <after> <description>`**
Insert urgent work as decimal phase between existing phases.

- Creates intermediate phase (e.g., 7.1 between 7 and 8)
- Useful for discovered work that must happen mid-milestone
- Maintains phase ordering

Usage: `__CMD_PREFIX__insert-phase 7 "Fix critical auth bug"`
Result: Creates Phase 7.1

**`__CMD_PREFIX__remove-phase <number>`**
Remove a future phase and renumber subsequent phases.

- Deletes phase directory and all references
- Renumbers all subsequent phases to close the gap
- Only works on future (unstarted) phases
- Git commit preserves historical record

Usage: `__CMD_PREFIX__remove-phase 17`
Result: Phase 17 deleted, phases 18-20 become 17-19

**`__CMD_PREFIX__new-milestone <name>`**
Start a new milestone through unified flow.

- Deep questioning to understand what you're building next
- Optional domain research (spawns 4 parallel researcher agents)
- Requirements definition with scoping
- Roadmap creation with phase breakdown

Mirrors `__CMD_PREFIX__new-project` flow for brownfield projects (existing PROJECT.md).

Usage: `__CMD_PREFIX__new-milestone "v2.0 Features"`

**`__CMD_PREFIX__complete-milestone <version>`**
Archive completed milestone and prepare for next version.

- Creates MILESTONES.md entry with stats
- Archives full details to milestones/ directory
- Creates git tag for the release
- Prepares workspace for next version

Usage: `__CMD_PREFIX__complete-milestone 1.0.0`

**`__CMD_PREFIX__audit-milestone [version]`**
Audit milestone completion against original intent.

- Reads all phase VERIFICATION.md files
- Checks requirements coverage
- Spawns integration checker for cross-phase wiring
- Creates MILESTONE-AUDIT.md with gaps and tech debt

Usage: `__CMD_PREFIX__audit-milestone`

**`__CMD_PREFIX__plan-milestone-gaps`**
Create phases to close gaps identified by audit.

- Reads MILESTONE-AUDIT.md and groups gaps into phases
- Prioritizes by requirement priority (must/should/nice)
- Adds gap closure phases to ROADMAP.md
- Ready for `__CMD_PREFIX__plan-phase` on new phases

Usage: `__CMD_PREFIX__plan-milestone-gaps`

### Progress Tracking

**`__CMD_PREFIX__progress`**
Check project status and intelligently route to next action.

- Shows visual progress bar and completion percentage
- Summarizes recent work from SUMMARY files
- Displays current position and what's next
- Lists key decisions and open issues
- Offers to execute next plan or create it if missing
- Detects 100% milestone completion

Usage: `__CMD_PREFIX__progress`

### Session Management

**`__CMD_PREFIX__resume-work`**
Resume work from previous session with full context restoration.

- Reads STATE.md for project context
- Shows current position and recent progress
- Offers next actions based on project state

Usage: `__CMD_PREFIX__resume-work`

**`__CMD_PREFIX__pause-work`**
Create context handoff when pausing work mid-phase.

- Creates .continue-here file with current state
- Updates STATE.md session continuity section
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
- Updates STATE.md todo count

Usage: `__CMD_PREFIX__add-todo` (infers from conversation)
Usage: `__CMD_PREFIX__add-todo Add auth token refresh`

**`__CMD_PREFIX__check-todos [area]`**
List pending todos and select one to work on.

- Lists all pending todos with title, area, age
- Optional area filter (e.g., `__CMD_PREFIX__check-todos api`)
- Loads full context for selected todo
- Routes to appropriate action (work now, add to phase, brainstorm)
- Moves todo to done/ when work begins

Usage: `__CMD_PREFIX__check-todos`
Usage: `__CMD_PREFIX__check-todos api`

### User Acceptance Testing

**`__CMD_PREFIX__verify-work [phase]`**
Validate built features through conversational UAT.

- Extracts testable deliverables from SUMMARY.md files
- Presents tests one at a time (yes/no responses)
- Automatically diagnoses failures and creates fix plans
- Ready for re-execution if issues found

Usage: `__CMD_PREFIX__verify-work 3`

### Guardrail Retro

**`__CMD_PREFIX__retro [unit-id or 'milestone']`**
Review what AI did well/poorly and improve for next time.

- Analyzes audit trail, gate results, rework cycles, risk register
- Identifies effective vs. missing guardrails
- Asks for human observations (data alone isn't enough)
- Produces concrete improvement actions for next unit
- Optionally updates risk register with new risks

Usage: `__CMD_PREFIX__retro UNIT-001`
Usage: `__CMD_PREFIX__retro milestone`
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
├── PROJECT.md            # Project vision
├── ROADMAP.md            # Current phase breakdown
├── STATE.md              # Project memory & context
├── config.json           # Workflow mode & gates
├── todos/                # Captured ideas and tasks
│   ├── pending/          # Todos waiting to be worked on
│   └── done/             # Completed todos
├── debug/                # Active debug sessions
│   └── resolved/         # Archived resolved issues
├── codebase/             # Codebase map (brownfield projects)
│   ├── STACK.md          # Languages, frameworks, dependencies
│   ├── ARCHITECTURE.md   # Patterns, layers, data flow
│   ├── STRUCTURE.md      # Directory layout, key files
│   ├── CONVENTIONS.md    # Coding standards, naming
│   ├── TESTING.md        # Test setup, patterns
│   ├── INTEGRATIONS.md   # External services, APIs
│   └── CONCERNS.md       # Tech debt, known issues
└── phases/
    ├── 01-foundation/
    │   ├── 01-01-PLAN.md
    │   └── 01-01-SUMMARY.md
    └── 02-core-features/
        ├── 02-01-PLAN.md
        └── 02-01-SUMMARY.md
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
__CMD_PREFIX__new-project        # INCEPTION: questioning → research → requirements → roadmap
/clear
__CMD_PREFIX__inception          # INCEPTION: intent → units → risk register → gates
/clear
__CMD_PREFIX__bolt UNIT-001      # CONSTRUCTION: design gate → plan → execute → unit gate
/clear
__CMD_PREFIX__bolt UNIT-002      # CONSTRUCTION: next unit
/clear
__CMD_PREFIX__deploy             # OPERATIONS: deployment plan → runbooks → production ready gate
```

**Resuming work after a break:**

```
__CMD_PREFIX__progress  # See where you left off and continue
```

**Adding urgent mid-milestone work:**

```
__CMD_PREFIX__insert-phase 5 "Critical security fix"
__CMD_PREFIX__plan-phase 5.1
__CMD_PREFIX__execute-phase 5.1
```

**Completing a milestone:**

```
__CMD_PREFIX__complete-milestone 1.0.0
/clear
__CMD_PREFIX__new-milestone  # Start next milestone (questioning → research → requirements → roadmap)
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

## Getting Help

- Read `.aidlc/PROJECT.md` for project vision
- Read `.aidlc/STATE.md` for current context
- Check `.aidlc/ROADMAP.md` for phase status
- Run `__CMD_PREFIX__progress` to check where you're up to
  </reference>
