---
name: sdlc:quick
description: Execute a quick task with AI-SDLC guarantees (atomic commits, state tracking) but skip optional agents
argument-hint: ""
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

<objective>
Execute small, ad-hoc tasks with AI-SDLC guarantees (atomic commits, STATE.md tracking) while skipping optional agents (research, plan-checker, verifier).

Quick mode is the same system with a shorter path:
- Spawns sdlc-bolt-planner (quick mode) + sdlc-bolt-executor(s)
- Skips sdlc-plan-checker, sdlc-unit-verifier
- Quick tasks live in `.aidlc/quick/` separate from planned units
- Updates state.md "Quick Tasks Completed" table (NOT execution-plan.md)

Use when: You know exactly what to do and the task is small enough to not need research or verification.
</objective>

<execution_context>
Orchestration is inline - no separate workflow file. Quick mode is deliberately simpler than full AI-SDLC.
</execution_context>

<context>
@.aidlc/state.md
</context>

<process>
**Step 0: Resolve Model Profile**

Read model profile for agent spawning:

```bash
MODEL_PROFILE=$(cat .aidlc/config.json 2>/dev/null | grep -o '"model_profile"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"' || echo "balanced")
```

Default to "balanced" if not set.

**Model lookup table:**

| Agent | quality | balanced | budget |
|-------|---------|----------|--------|
| sdlc-bolt-planner | opus | opus | sonnet |
| sdlc-bolt-executor | opus | sonnet | sonnet |

Store resolved models for use in Task calls below.

---

**Step 1: Pre-flight validation**

Check that an active AI-SDLC project exists:

```bash
if [ ! -f .aidlc/execution-plan.md ]; then
  echo "Quick mode requires an active project with execution-plan.md."
  echo "Run __CMD_PREFIX__new-project first."
  exit 1
fi
```

If validation fails, stop immediately with the error message.

Quick tasks can run mid-unit - validation only checks execution-plan.md exists, not unit status.

---

**Step 2: Get task description**

Prompt user interactively for the task description:

```
AskUserQuestion(
  header: "Quick Task",
  question: "What do you want to do?",
  followUp: null
)
```

Store response as `$DESCRIPTION`.

If empty, re-prompt: "Please provide a task description."

Generate slug from description:
```bash
slug=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-40)
```

---

**Step 3: Calculate next quick task number**

Ensure `.aidlc/quick/` directory exists and find the next sequential number:

```bash
# Ensure .aidlc/quick/ exists
mkdir -p .aidlc/quick

# Find highest existing number and increment
last=$(ls -1d .aidlc/quick/[0-9][0-9][0-9]-* 2>/dev/null | sort -r | head -1 | xargs -I{} basename {} | grep -oE '^[0-9]+')

if [ -z "$last" ]; then
  next_num="001"
else
  next_num=$(printf "%03d" $((10#$last + 1)))
fi
```

---

**Step 4: Create quick task directory**

Create the directory for this quick task:

```bash
QUICK_DIR=".aidlc/quick/${next_num}-${slug}"
mkdir -p "$QUICK_DIR"
```

Report to user:
```
Creating quick task ${next_num}: ${DESCRIPTION}
Directory: ${QUICK_DIR}
```

Store `$QUICK_DIR` for use in orchestration.

---

**Step 5: Spawn planner (quick mode)**

Spawn sdlc-bolt-planner with quick mode context:

```
Task(
  prompt="
<planning_context>

**Mode:** quick
**Directory:** ${QUICK_DIR}
**Description:** ${DESCRIPTION}

**Project State:**
@.aidlc/state.md

</planning_context>

<constraints>
- Create a SINGLE plan with 1-3 focused tasks
- Quick tasks should be atomic and self-contained
- No research phase, no checker phase
- Target ~30% context usage (simple, focused)
</constraints>

<output>
Write plan to: ${QUICK_DIR}/${next_num}-plan.md
Return: ## PLANNING COMPLETE with plan path
</output>
",
  subagent_type="sdlc-bolt-planner",
  model="{planner_model}",
  description="Quick plan: ${DESCRIPTION}"
)
```

After planner returns:
1. Verify plan exists at `${QUICK_DIR}/${next_num}-plan.md`
2. Extract plan count (typically 1 for quick tasks)
3. Report: "Plan created: ${QUICK_DIR}/${next_num}-plan.md"

If plan not found, error: "Planner failed to create ${next_num}-plan.md"

---

**Step 6: Spawn executor**

Spawn sdlc-bolt-executor with plan reference:

```
Task(
  prompt="
Execute quick task ${next_num}.

Plan: @${QUICK_DIR}/${next_num}-plan.md
Project state: @.aidlc/state.md

<constraints>
- Execute all tasks in the plan
- Commit each task atomically
- Create summary at: ${QUICK_DIR}/${next_num}-summary.md
- Do NOT update execution-plan.md (quick tasks are separate from planned units)
</constraints>
",
  subagent_type="sdlc-bolt-executor",
  model="{executor_model}",
  description="Execute: ${DESCRIPTION}"
)
```

After executor returns:
1. Verify summary exists at `${QUICK_DIR}/${next_num}-summary.md`
2. Extract commit hash from executor output
3. Report completion status

If summary not found, error: "Executor failed to create ${next_num}-summary.md"

Note: For quick tasks producing multiple plans (rare), spawn executors in parallel waves per build-unit patterns.

---

**Step 7: Update STATE.md**

Update state.md with quick task completion record.

**7a. Check if "Quick Tasks Completed" section exists:**

Read state.md and check for `### Quick Tasks Completed` section.

**7b. If section doesn't exist, create it:**

Insert after `### Blockers/Concerns` section:

```markdown
### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
```

**7c. Append new row to table:**

```markdown
| ${next_num} | ${DESCRIPTION} | $(date +%Y-%m-%d) | ${commit_hash} | [${next_num}-${slug}](./quick/${next_num}-${slug}/) |
```

**7d. Update "Last activity" line:**

Find and update the line:
```
Last activity: $(date +%Y-%m-%d) - Completed quick task ${next_num}: ${DESCRIPTION}
```

Use Edit tool to make these changes atomically

---

**Step 8: Final commit and completion**

Stage and commit quick task artifacts:

```bash
# Stage quick task artifacts
git add ${QUICK_DIR}/${next_num}-plan.md
git add ${QUICK_DIR}/${next_num}-summary.md
git add .aidlc/state.md

# Commit with quick task format
git commit -m "$(cat <<'EOF'
docs(quick-${next_num}): ${DESCRIPTION}

Quick task completed.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Get final commit hash:
```bash
commit_hash=$(git rev-parse --short HEAD)
```

Display completion output:
```
---

AI-SDLC > QUICK TASK COMPLETE

Quick Task ${next_num}: ${DESCRIPTION}

Summary: ${QUICK_DIR}/${next_num}-summary.md
Commit: ${commit_hash}

---

Ready for next task: __CMD_PREFIX__quick
```

</process>

<success_criteria>
- [ ] execution-plan.md validation passes
- [ ] User provides task description
- [ ] Slug generated (lowercase, hyphens, max 40 chars)
- [ ] Next number calculated (001, 002, 003...)
- [ ] Directory created at `.aidlc/quick/NNN-slug/`
- [ ] `${next_num}-plan.md` created by planner
- [ ] `${next_num}-summary.md` created by executor
- [ ] state.md updated with quick task row
- [ ] Artifacts committed
</success_criteria>
