---
name: sdlc:new-project
description: Initialize a new project with deep context gathering and intent.md
allowed-tools:
  - Read
  - Bash
  - Write
  - Task
  - AskUserQuestion
---

<objective>

Initialize a new project through unified flow: questioning → intent → config.

This is the most leveraged moment in any project. Deep questioning here means better plans, better execution, better outcomes. One command takes you from idea to ready-for-elaboration.

**Creates:**
- `.aidlc/intent.md` — project intent (Golden Thread foundation)
- `.aidlc/config.json` — workflow preferences
- `.aidlc/state.md` — project memory

**After this command:** Run `__CMD_PREFIX__elaborate` to build out inception artifacts (requirements, user stories, application design, execution plan).

</objective>

<execution_context>

@__SDLC_REFS__/questioning.md
@__SDLC_REFS__/ui-brand.md
@__SDLC_REFS__/overconfidence-prevention.md
@__SDLC_REFS__/error-handling.md
@__SDLC_REFS__/content-validation.md
@__SDLC_TEMPLATES__/intent.md
@__SDLC_TEMPLATES__/welcome-message.md

</execution_context>

<process>

## Phase 0: Welcome Message (First-Time Only)

**Display the welcome message on first use.** If the user has never interacted with AI-SDLC before (no `.aidlc/` directory exists anywhere in the current project), display the welcome message from `welcome-message.md` template before proceeding to Phase 1.

**Skip if:** User has previously run `__CMD_PREFIX__new-project` (even in a different directory), or explicitly says they know the framework. The welcome message is informational — do not block on it.

After displaying (or skipping), proceed directly to Phase 1.

## Phase 1: Setup

**MANDATORY FIRST STEP — Execute these checks before ANY user interaction:**

1. **Abort if project exists:**
   ```bash
   [ -f .aidlc/intent.md ] && echo "ERROR: Project already initialized. Use __CMD_PREFIX__status" && exit 1
   ```

2. **Initialize git repo in THIS directory** (required even if inside a parent repo):
   ```bash
   if [ -d .git ] || [ -f .git ]; then
       echo "Git repo exists in current directory"
   else
       git init
       echo "Initialized new git repo"
   fi
   ```

3. **Detect existing code (brownfield detection):**
   ```bash
   CODE_FILES=$(find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" -o -name "*.java" 2>/dev/null | grep -v node_modules | grep -v .git | head -20)
   HAS_PACKAGE=$([ -f package.json ] || [ -f requirements.txt ] || [ -f Cargo.toml ] || [ -f go.mod ] || [ -f Package.swift ] && echo "yes")
   HAS_CODEBASE_MAP=$([ -d .aidlc/codebase ] && echo "yes")
   ```

   **You MUST run all bash commands above using the Bash tool before proceeding.**

## Phase 2: Brownfield Offer

**If existing code detected and .aidlc/codebase/ doesn't exist:**

Check the results from setup step:
- If `CODE_FILES` is non-empty OR `HAS_PACKAGE` is "yes"
- AND `HAS_CODEBASE_MAP` is NOT "yes"

Use AskUserQuestion:
- header: "Existing Code"
- question: "I detected existing code in this directory. Would you like to map the codebase first?"
- options:
  - "Map codebase first" — Run __CMD_PREFIX__map-codebase to understand existing architecture (Recommended)
  - "Skip mapping" — Proceed with project initialization

**If "Map codebase first":**
```
Run `__CMD_PREFIX__map-codebase` first, then return to `__CMD_PREFIX__new-project`
```
Exit command.

**If "Skip mapping":** Continue to Phase 3.

**If no existing code detected OR codebase already mapped:** Continue to Phase 3.

## Phase 3: Deep Questioning

**Display stage banner:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► QUESTIONING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Open the conversation:**

Ask inline (freeform, NOT AskUserQuestion):

"What do you want to build?"

Wait for their response. This gives you the context needed to ask intelligent follow-up questions.

**Follow the thread:**

Based on what they said, ask follow-up questions that dig into their response. Use AskUserQuestion with options that probe what they mentioned — interpretations, clarifications, concrete examples.

Keep following threads. Each answer opens new threads to explore. Ask about:
- What excited them
- What problem sparked this
- What they mean by vague terms
- What it would actually look like
- What's already decided

Consult `questioning.md` for techniques:
- Challenge vagueness
- Make abstract concrete
- Surface assumptions
- Find edges
- Reveal motivation

**Check context (background, not out loud):**

As you go, mentally check the context checklist from `questioning.md`. If gaps remain, weave questions naturally. Don't suddenly switch to checklist mode.

**Decision gate:**

When you could write a clear intent.md, use AskUserQuestion:

- header: "Ready?"
- question: "I think I understand what you're after. Ready to create intent.md?"
- options:
  - "Create intent.md" — Let's move forward
  - "Keep exploring" — I want to share more / ask me more

If "Keep exploring" — ask what they want to add, or identify gaps and probe naturally.

Loop until "Create intent.md" selected.

## Phase 4: Write intent.md

Synthesize all context into `.aidlc/intent.md` using the template from `__SDLC_TEMPLATES__/intent.md`.

Fill in every section from the questioning conversation:
- **The Problem** — what they're solving, who's affected, why now
- **The Vision** — what success looks like, measurable criteria
- **Scope** — in scope (v1), out of scope, non-negotiables
- **Constraints** — technical, business, dependencies
- **Stakeholders** — roles and responsibilities
- **Risk Summary** — high-level risks (detailed risks come later in elaborate)

**For brownfield projects (codebase map exists):**

Read `.aidlc/codebase/ARCHITECTURE.md` and `STACK.md` to inform constraints and technical context. Reference existing capabilities in the scope section.

**Key Decisions:**

Initialize with any decisions made during questioning:

```markdown
## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| [Choice from questioning] | [Why] | — Pending |
```

Do not compress. Capture everything gathered.

**Commit intent.md:**

```bash
mkdir -p .aidlc
git add .aidlc/intent.md
git commit -m "$(cat <<'EOF'
docs: initialize project intent

[One-liner from intent.md Vision section]
EOF
)"
```

**Initialize GUARDRAILS.md:**

Create `.aidlc/GUARDRAILS.md` using the template from `__SDLC_TEMPLATES__/guardrails.md`:
- Populate **Code Style** from detected tech stack (if brownfield) or leave as defaults
- Set **Review Depth** based on project complexity from questioning
- Leave **Known Pitfalls**, **Team Conventions**, and **Evolution Log** empty (filled during retros)

```bash
git add .aidlc/GUARDRAILS.md
git commit -m "$(cat <<'EOF'
docs: initialize project guardrails

Starting guardrails for AI collaboration preferences.
EOF
)"
```

## Phase 5: Workflow Preferences

**Round 1 — Core workflow settings (4 questions):**

```
questions: [
  {
    header: "Mode",
    question: "How do you want to work?",
    multiSelect: false,
    options: [
      { label: "YOLO (Recommended)", description: "Auto-approve, just execute" },
      { label: "Interactive", description: "Confirm at each step" }
    ]
  },
  {
    header: "Depth",
    question: "How thorough should planning be?",
    multiSelect: false,
    options: [
      { label: "Quick", description: "Ship fast (fewer units, smaller bolts)" },
      { label: "Standard", description: "Balanced scope and speed (default)" },
      { label: "Comprehensive", description: "Thorough coverage (more units, larger bolts)" }
    ]
  },
  {
    header: "Execution",
    question: "Run bolt plans in parallel?",
    multiSelect: false,
    options: [
      { label: "Parallel (Recommended)", description: "Independent bolt plans run simultaneously" },
      { label: "Sequential", description: "One bolt plan at a time" }
    ]
  },
  {
    header: "Git Tracking",
    question: "Commit planning docs to git?",
    multiSelect: false,
    options: [
      { label: "Yes (Recommended)", description: "Planning docs tracked in version control" },
      { label: "No", description: "Keep .aidlc/ local-only (add to .gitignore)" }
    ]
  }
]
```

**Round 2 — Workflow agents:**

These spawn additional agents during planning/execution. They add tokens and time but improve quality.

| Agent | When it runs | What it does |
|-------|--------------|--------------|
| **Researcher** | Before planning each unit | Investigates domain, finds patterns, surfaces gotchas |
| **Plan Checker** | After bolt plan is created | Verifies plan actually achieves the bolt goal |
| **Verifier** | After unit execution | Confirms must-haves were delivered |

All recommended for important projects. Skip for quick experiments.

```
questions: [
  {
    header: "Research",
    question: "Research before planning each unit? (adds tokens/time)",
    multiSelect: false,
    options: [
      { label: "Yes (Recommended)", description: "Investigate domain, find patterns, surface gotchas" },
      { label: "No", description: "Plan directly from requirements" }
    ]
  },
  {
    header: "Plan Check",
    question: "Verify bolt plans will achieve their goals? (adds tokens/time)",
    multiSelect: false,
    options: [
      { label: "Yes (Recommended)", description: "Catch gaps before execution starts" },
      { label: "No", description: "Execute plans without verification" }
    ]
  },
  {
    header: "Verifier",
    question: "Verify work satisfies requirements after each unit? (adds tokens/time)",
    multiSelect: false,
    options: [
      { label: "Yes (Recommended)", description: "Confirm deliverables match unit goals" },
      { label: "No", description: "Trust execution, skip verification" }
    ]
  },
  {
    header: "Model Profile",
    question: "Which AI models for planning agents?",
    multiSelect: false,
    options: [
      { label: "Balanced (Recommended)", description: "Sonnet for most agents — good quality/cost ratio" },
      { label: "Quality", description: "Opus for research/planning — higher cost, deeper analysis" },
      { label: "Budget", description: "Haiku where possible — fastest, lowest cost" }
    ]
  }
]
```

Create `.aidlc/config.json` with all settings:

```json
{
  "mode": "yolo|interactive",
  "depth": "quick|standard|comprehensive",
  "parallelization": true|false,
  "commit_docs": true|false,
  "model_profile": "quality|balanced|budget",
  "workflow": {
    "research": true|false,
    "plan_check": true|false,
    "verifier": true|false
  }
}
```

**If commit_docs = No:**
- Set `commit_docs: false` in config.json
- Add `.aidlc/` to `.gitignore` (create if needed)

**If commit_docs = Yes:**
- No additional gitignore entries needed

**Commit config.json:**

```bash
git add .aidlc/config.json
git commit -m "$(cat <<'EOF'
chore: add project config

Mode: [chosen mode]
Depth: [chosen depth]
Parallelization: [enabled/disabled]
Workflow agents: research=[on/off], plan_check=[on/off], verifier=[on/off]
EOF
)"
```

**Note:** Run `__CMD_PREFIX__settings` anytime to update these preferences.

## Phase 6: Done

Present completion with next steps:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► PROJECT INITIALIZED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**[Project Name]**

| Artifact       | Location                    |
|----------------|-----------------------------|
| Intent         | `.aidlc/intent.md`       |
| Guardrails     | `.aidlc/GUARDRAILS.md`   |
| Config         | `.aidlc/config.json`     |

Ready for elaboration ✓

───────────────────────────────────────────────────────────────

## ▶ Next: Elaborate

Build out inception artifacts — requirements, user stories, design, execution plan:

__CMD_PREFIX__elaborate — adaptive inception from intent

<sub>/clear first → fresh context window</sub>

───────────────────────────────────────────────────────────────
```

</process>

<output>

- `.aidlc/intent.md`
- `.aidlc/GUARDRAILS.md`
- `.aidlc/config.json`

</output>

<success_criteria>

- [ ] .aidlc/ directory created
- [ ] Git repo initialized
- [ ] Brownfield detection completed
- [ ] Deep questioning completed (threads followed, not rushed)
- [ ] intent.md captures full context (problem, vision, scope, constraints) → **committed**
- [ ] GUARDRAILS.md initialized with project defaults → **committed**
- [ ] config.json has workflow mode, depth, parallelization → **committed**
- [ ] User knows next step is `__CMD_PREFIX__elaborate`

**Atomic commits:** Each phase commits its artifacts immediately. If context is lost, artifacts persist.

</success_criteria>
