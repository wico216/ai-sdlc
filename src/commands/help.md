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

1. `/sdlc:new-project` - Initialize project (questioning, research, requirements, roadmap)
2. `/sdlc:inception` - Run full Inception phase (intent, units, risk register, gates)
3. `/sdlc:bolt 1` - Execute a Construction bolt for the first unit
4. `/sdlc:deploy` - Run Operations phase when ready

## Core Workflow (3 Phases)

```
INCEPTION:     /sdlc:new-project → /sdlc:inception
CONSTRUCTION:  /sdlc:bolt <unit> (repeat per unit)
OPERATIONS:    /sdlc:deploy
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

**`/sdlc:new-project`**
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

Usage: `/sdlc:new-project`

**`/sdlc:map-codebase`**
Map an existing codebase for brownfield projects.

- Analyzes codebase with parallel Explore agents
- Creates `.aidlc/codebase/` with 7 focused documents
- Covers stack, architecture, structure, conventions, testing, integrations, concerns
- Use before `/sdlc:new-project` on existing codebases

Usage: `/sdlc:map-codebase`

### Inception Phase

**`/sdlc:inception`**
Run the full AI-SDLC Inception phase after `/sdlc:new-project`.

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

Usage: `/sdlc:inception`

### Construction Phase

**`/sdlc:bolt <unit>`**
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

Usage: `/sdlc:bolt UNIT-001`
Usage: `/sdlc:bolt 1`
Usage: `/sdlc:bolt UNIT-002 --skip-design-gate`

### Operations Phase

**`/sdlc:deploy`**
Run the Operations phase — deployment plan, runbooks, and Production Ready gate.

- Verifies all units are complete
- Generates deployment plan with rollback procedures
- Creates operational runbooks
- Sets up observability configuration
- Runs Production Ready gate (final gate)
- Completes the Golden Thread: Intent → Code → Deployment

Usage: `/sdlc:deploy`

### Phase Planning

**`/sdlc:discuss-phase <number>`**
Help articulate your vision for a phase before planning.

- Captures how you imagine this phase working
- Creates CONTEXT.md with your vision, essentials, and boundaries
- Use when you have ideas about how something should look/feel

Usage: `/sdlc:discuss-phase 2`

**`/sdlc:research-phase <number>`**
Comprehensive ecosystem research for niche/complex domains.

- Discovers standard stack, architecture patterns, pitfalls
- Creates RESEARCH.md with "how experts build this" knowledge
- Use for 3D, games, audio, shaders, ML, and other specialized domains
- Goes beyond "which library" to ecosystem knowledge

Usage: `/sdlc:research-phase 3`

**`/sdlc:list-phase-assumptions <number>`**
See what Claude is planning to do before it starts.

- Shows Claude's intended approach for a phase
- Lets you course-correct if Claude misunderstood your vision
- No files created - conversational output only

Usage: `/sdlc:list-phase-assumptions 3`

**`/sdlc:plan-phase <number>`**
Create detailed execution plan for a specific phase.

- Generates `.aidlc/phases/XX-phase-name/XX-YY-PLAN.md`
- Breaks phase into concrete, actionable tasks
- Includes verification criteria and success measures
- Multiple plans per phase supported (XX-01, XX-02, etc.)

Usage: `/sdlc:plan-phase 1`
Result: Creates `.aidlc/phases/01-foundation/01-01-PLAN.md`

### Execution

**`/sdlc:execute-phase <phase-number>`**
Execute all plans in a phase.

- Groups plans by wave (from frontmatter), executes waves sequentially
- Plans within each wave run in parallel via Task tool
- Verifies phase goal after all plans complete
- Updates REQUIREMENTS.md, ROADMAP.md, STATE.md

Usage: `/sdlc:execute-phase 5`

### Quick Mode

**`/sdlc:quick`**
Execute small, ad-hoc tasks with AI-SDLC guarantees but skip optional agents.

Quick mode uses the same system with a shorter path:
- Spawns planner + executor (skips researcher, checker, verifier)
- Quick tasks live in `.aidlc/quick/` separate from planned phases
- Updates STATE.md tracking (not ROADMAP.md)

Use when you know exactly what to do and the task is small enough to not need research or verification.

Usage: `/sdlc:quick`
Result: Creates `.aidlc/quick/NNN-slug/PLAN.md`, `.aidlc/quick/NNN-slug/SUMMARY.md`

### Roadmap Management

**`/sdlc:add-phase <description>`**
Add new phase to end of current milestone.

- Appends to ROADMAP.md
- Uses next sequential number
- Updates phase directory structure

Usage: `/sdlc:add-phase "Add admin dashboard"`

**`/sdlc:insert-phase <after> <description>`**
Insert urgent work as decimal phase between existing phases.

- Creates intermediate phase (e.g., 7.1 between 7 and 8)
- Useful for discovered work that must happen mid-milestone
- Maintains phase ordering

Usage: `/sdlc:insert-phase 7 "Fix critical auth bug"`
Result: Creates Phase 7.1

**`/sdlc:remove-phase <number>`**
Remove a future phase and renumber subsequent phases.

- Deletes phase directory and all references
- Renumbers all subsequent phases to close the gap
- Only works on future (unstarted) phases
- Git commit preserves historical record

Usage: `/sdlc:remove-phase 17`
Result: Phase 17 deleted, phases 18-20 become 17-19

### Milestone Management

**`/sdlc:new-milestone <name>`**
Start a new milestone through unified flow.

- Deep questioning to understand what you're building next
- Optional domain research (spawns 4 parallel researcher agents)
- Requirements definition with scoping
- Roadmap creation with phase breakdown

Mirrors `/sdlc:new-project` flow for brownfield projects (existing PROJECT.md).

Usage: `/sdlc:new-milestone "v2.0 Features"`

**`/sdlc:complete-milestone <version>`**
Archive completed milestone and prepare for next version.

- Creates MILESTONES.md entry with stats
- Archives full details to milestones/ directory
- Creates git tag for the release
- Prepares workspace for next version

Usage: `/sdlc:complete-milestone 1.0.0`

### Progress Tracking

**`/sdlc:progress`**
Check project status and intelligently route to next action.

- Shows visual progress bar and completion percentage
- Summarizes recent work from SUMMARY files
- Displays current position and what's next
- Lists key decisions and open issues
- Offers to execute next plan or create it if missing
- Detects 100% milestone completion

Usage: `/sdlc:progress`

### Session Management

**`/sdlc:resume-work`**
Resume work from previous session with full context restoration.

- Reads STATE.md for project context
- Shows current position and recent progress
- Offers next actions based on project state

Usage: `/sdlc:resume-work`

**`/sdlc:pause-work`**
Create context handoff when pausing work mid-phase.

- Creates .continue-here file with current state
- Updates STATE.md session continuity section
- Captures in-progress work context

Usage: `/sdlc:pause-work`

### Debugging

**`/sdlc:debug [issue description]`**
Systematic debugging with persistent state across context resets.

- Gathers symptoms through adaptive questioning
- Creates `.aidlc/debug/[slug].md` to track investigation
- Investigates using scientific method (evidence → hypothesis → test)
- Survives `/clear` — run `/sdlc:debug` with no args to resume
- Archives resolved issues to `.aidlc/debug/resolved/`

Usage: `/sdlc:debug "login button doesn't work"`
Usage: `/sdlc:debug` (resume active session)

### Todo Management

**`/sdlc:add-todo [description]`**
Capture idea or task as todo from current conversation.

- Extracts context from conversation (or uses provided description)
- Creates structured todo file in `.aidlc/todos/pending/`
- Infers area from file paths for grouping
- Checks for duplicates before creating
- Updates STATE.md todo count

Usage: `/sdlc:add-todo` (infers from conversation)
Usage: `/sdlc:add-todo Add auth token refresh`

**`/sdlc:check-todos [area]`**
List pending todos and select one to work on.

- Lists all pending todos with title, area, age
- Optional area filter (e.g., `/sdlc:check-todos api`)
- Loads full context for selected todo
- Routes to appropriate action (work now, add to phase, brainstorm)
- Moves todo to done/ when work begins

Usage: `/sdlc:check-todos`
Usage: `/sdlc:check-todos api`

### User Acceptance Testing

**`/sdlc:verify-work [phase]`**
Validate built features through conversational UAT.

- Extracts testable deliverables from SUMMARY.md files
- Presents tests one at a time (yes/no responses)
- Automatically diagnoses failures and creates fix plans
- Ready for re-execution if issues found

Usage: `/sdlc:verify-work 3`

### Milestone Auditing

**`/sdlc:audit-milestone [version]`**
Audit milestone completion against original intent.

- Reads all phase VERIFICATION.md files
- Checks requirements coverage
- Spawns integration checker for cross-phase wiring
- Creates MILESTONE-AUDIT.md with gaps and tech debt

Usage: `/sdlc:audit-milestone`

**`/sdlc:plan-milestone-gaps`**
Create phases to close gaps identified by audit.

- Reads MILESTONE-AUDIT.md and groups gaps into phases
- Prioritizes by requirement priority (must/should/nice)
- Adds gap closure phases to ROADMAP.md
- Ready for `/sdlc:plan-phase` on new phases

Usage: `/sdlc:plan-milestone-gaps`

### Configuration

**`/sdlc:settings`**
Configure workflow toggles and model profile interactively.

- Toggle researcher, plan checker, verifier agents
- Select model profile (quality/balanced/budget)
- Updates `.aidlc/config.json`

Usage: `/sdlc:settings`

**`/sdlc:set-profile <profile>`**
Quick switch model profile for AI-SDLC agents.

- `quality` — Opus everywhere except verification
- `balanced` — Opus for planning, Sonnet for execution (default)
- `budget` — Sonnet for writing, Haiku for research/verification

Usage: `/sdlc:set-profile budget`

### Utility Commands

**`/sdlc:help`**
Show this command reference.

**`/sdlc:update`**
Update AI-SDLC to latest version with changelog preview.

- Shows installed vs latest version comparison
- Displays changelog entries for versions you've missed
- Highlights breaking changes
- Confirms before running install
- Better than raw `npx ai-sdlc-cc`

Usage: `/sdlc:update`

**`/sdlc:join-discord`**
Join the AI-SDLC Discord community.

- Get help, share what you're building, stay updated
- Connect with other AI-SDLC users

Usage: `/sdlc:join-discord`

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

Set during `/sdlc:new-project`:

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
/sdlc:new-project        # INCEPTION: questioning → research → requirements → roadmap
/clear
/sdlc:inception          # INCEPTION: intent → units → risk register → gates
/clear
/sdlc:bolt UNIT-001      # CONSTRUCTION: design gate → plan → execute → unit gate
/clear
/sdlc:bolt UNIT-002      # CONSTRUCTION: next unit
/clear
/sdlc:deploy             # OPERATIONS: deployment plan → runbooks → production ready gate
```

**Quick start (skip Inception decomposition):**

```
/sdlc:new-project        # Initialize project
/clear
/sdlc:plan-phase 1       # Plan first phase directly
/clear
/sdlc:execute-phase 1    # Execute
```

**Resuming work after a break:**

```
/sdlc:progress  # See where you left off and continue
```

**Adding urgent mid-milestone work:**

```
/sdlc:insert-phase 5 "Critical security fix"
/sdlc:plan-phase 5.1
/sdlc:execute-phase 5.1
```

**Completing a milestone:**

```
/sdlc:complete-milestone 1.0.0
/clear
/sdlc:new-milestone  # Start next milestone (questioning → research → requirements → roadmap)
```

**Capturing ideas during work:**

```
/sdlc:add-todo                    # Capture from conversation context
/sdlc:add-todo Fix modal z-index  # Capture with explicit description
/sdlc:check-todos                 # Review and work on todos
/sdlc:check-todos api             # Filter by area
```

**Debugging an issue:**

```
/sdlc:debug "form submission fails silently"  # Start debug session
# ... investigation happens, context fills up ...
/clear
/sdlc:debug                                    # Resume from where you left off
```

## Getting Help

- Read `.aidlc/PROJECT.md` for project vision
- Read `.aidlc/STATE.md` for current context
- Check `.aidlc/ROADMAP.md` for phase status
- Run `/sdlc:progress` to check where you're up to
  </reference>
