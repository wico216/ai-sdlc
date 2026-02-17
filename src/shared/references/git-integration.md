<overview>
Git integration for AI-SDLC framework.
</overview>

<core_principle>

**Commit outcomes, not process.**

The git log should read like a changelog of what shipped, not a diary of planning activity.
</core_principle>

<commit_points>

| Event                   | Commit? | Why                                              |
| ----------------------- | ------- | ------------------------------------------------ |
| Intent + execution plan created | YES     | Project initialization                           |
| bolt-plan.md created            | NO      | Intermediate - commit with bolt completion       |
| research.md created             | NO      | Intermediate                                     |
| **Task completed**              | YES     | Atomic unit of work (1 commit per task)         |
| **Bolt completed**              | YES     | Metadata commit (summary + state)               |
| Handoff created                 | YES     | WIP state preserved                              |

</commit_points>

<git_check>

```bash
[ -d .git ] && echo "GIT_EXISTS" || echo "NO_GIT"
```

If NO_GIT: Run `git init` silently. AI-SDLC projects always get their own repo.
</git_check>

<commit_formats>

<format name="initialization">
## Project Initialization (brief + roadmap together)

```
docs: initialize [project-name] ([N] units)

[One-liner from PROJECT.md]

Units:
1. [unit-name]: [goal]
2. [unit-name]: [goal]
3. [unit-name]: [goal]
```

What to commit:

```bash
git add .aidlc/
git commit
```

</format>

<format name="task-completion">
## Task Completion (During Plan Execution)

Each task gets its own commit immediately after completion.

```
{type}({unit}-{bolt}): {task-name}

- [Key change 1]
- [Key change 2]
- [Key change 3]
```

**Commit types:**
- `feat` - New feature/functionality
- `fix` - Bug fix
- `test` - Test-only (TDD RED phase)
- `refactor` - Code cleanup (TDD REFACTOR phase)
- `perf` - Performance improvement
- `chore` - Dependencies, config, tooling

**Examples:**

```bash
# Standard task
git add src/api/auth.ts src/types/user.ts
git commit -m "feat(002-01): create user registration endpoint

- POST /auth/register validates email and password
- Checks for duplicate users
- Returns JWT token on success
"

# TDD task - RED
git add src/__tests__/jwt.test.ts
git commit -m "test(001-02): add failing test for JWT generation

- Tests token contains user ID claim
- Tests token expires in 1 hour
- Tests signature verification
"

# TDD task - GREEN
git add src/utils/jwt.ts
git commit -m "feat(001-02): implement JWT generation

- Uses jose library for signing
- Includes user ID and expiry claims
- Signs with HS256 algorithm
"
```

</format>

<format name="plan-completion">
## Plan Completion (After All Tasks Done)

After all tasks committed, one final metadata commit captures plan completion.

```
docs({unit}-{bolt}): complete [bolt-name]

Tasks completed: [N]/[N]
- [Task 1 name]
- [Task 2 name]
- [Task 3 name]

SUMMARY: .aidlc/construction/unit-{NNN}/bolt-{NN}-summary.md
```

What to commit:

```bash
git add .aidlc/construction/unit-{NNN}/bolt-{NN}-plan.md
git add .aidlc/construction/unit-{NNN}/bolt-{NN}-summary.md
git add .aidlc/state.md
git commit
```

**Note:** Code files NOT included - already committed per-task.

</format>

<format name="handoff">
## Handoff (WIP)

```
wip: unit [NNN] paused at task [X]/[Y]

Current: [task name]
[If blocked:] Blocked: [reason]
```

What to commit:

```bash
git add .aidlc/
git commit
```

</format>
</commit_formats>

<example_log>

**Old approach (per-plan commits):**
```
a7f2d1 feat(checkout): Stripe payments with webhook verification
3e9c4b feat(products): catalog with search, filters, and pagination
8a1b2c feat(auth): JWT with refresh rotation using jose
5c3d7e feat(foundation): Next.js 15 + Prisma + Tailwind scaffold
2f4a8d docs: initialize ecommerce-app (5 phases)
```

**New approach (per-task commits):**
```
# Unit 004 - Checkout
1a2b3c docs(004-01): complete checkout flow bolt
4d5e6f feat(004-01): add webhook signature verification
7g8h9i feat(004-01): implement payment session creation
0j1k2l feat(004-01): create checkout page component

# Unit 003 - Products
3m4n5o docs(003-02): complete product listing bolt
6p7q8r feat(003-02): add pagination controls
9s0t1u feat(003-02): implement search and filters
2v3w4x feat(003-01): create product catalog schema

# Unit 002 - Auth
5y6z7a docs(002-02): complete token refresh bolt
8b9c0d feat(002-02): implement refresh token rotation
1e2f3g test(002-02): add failing test for token refresh
4h5i6j docs(002-01): complete JWT setup bolt
7k8l9m feat(002-01): add JWT generation and validation
0n1o2p chore(002-01): install jose library

# Unit 001 - Foundation
3q4r5s docs(001-01): complete scaffold bolt
6t7u8v feat(001-01): configure Tailwind and globals
9w0x1y feat(001-01): set up Prisma with database
2z3a4b feat(001-01): create Next.js 15 project

# Initialization
5c6d7e docs: initialize ecommerce-app (5 units)
```

Each bolt produces 2-4 commits (tasks + metadata). Clear, granular, bisectable.

</example_log>

<anti_patterns>

**Still don't commit (intermediate artifacts):**
- bolt-plan.md creation (commit with bolt completion)
- research.md (intermediate)
- Minor planning tweaks

**Do commit (outcomes):**
- Each task completion (feat/fix/test/refactor)
- Plan completion metadata (docs)
- Project initialization (docs)

**Key principle:** Commit working code and shipped outcomes, not planning process.

</anti_patterns>

<commit_strategy_rationale>

## Why Per-Task Commits?

**Context engineering for AI:**
- Git history becomes primary context source for future Claude sessions
- `git log --grep="{unit}-{bolt}"` shows all work for a bolt
- `git diff <hash>^..<hash>` shows exact changes per task
- Less reliance on parsing SUMMARY.md = more context for actual work

**Failure recovery:**
- Task 1 committed ✅, Task 2 failed ❌
- Claude in next session: sees task 1 complete, can retry task 2
- Can `git reset --hard` to last successful task

**Debugging:**
- `git bisect` finds exact failing task, not just failing plan
- `git blame` traces line to specific task context
- Each commit is independently revertable

**Observability:**
- Solo developer + Claude workflow benefits from granular attribution
- Atomic commits are git best practice
- "Commit noise" irrelevant when consumer is Claude, not humans

</commit_strategy_rationale>

<pr_discipline>

## PR Discipline

### Size Limits
- **Target:** ≤ 400 lines changed per PR (excluding generated files, lock files, tests)
- **Hard ceiling:** 600 lines. If a bolt produces more, split into sub-PRs before review
- **Why:** Large PRs get rubber-stamped. Small PRs get real review

### One Bolt = One PR
- Each bolt produces exactly one PR
- Never bundle multiple bolts into a single PR
- If a bolt is too large for one PR, split the bolt first (`/sdlc:plan-unit` adjustment), not the PR after the fact

### Batch Rules
- Maximum 2 PRs open per unit at any time
- A bolt's PR must be merged before its dependent bolt starts construction
- Exception: independent bolts in the same wave MAY have concurrent open PRs

### Merge Discipline
- Squash merge by default (clean history)
- PR title format: `[UNIT-NNN/bolt-NN] <description>`
- PR body must reference: unit ID, bolt ID, and acceptance criteria addressed
- All CI checks green before merge — no "merge and fix later"

### AI-Generated PR Review Checklist
Before approving any AI-generated PR, the reviewer MUST check:
1. No hallucinated imports or dependencies
2. No dead code or unused variables introduced
3. No "defensive complexity" — code that handles impossible states
4. Tests actually test behaviour, not just exist for coverage
5. No hardcoded values that should be configuration
6. Diff matches what the bolt plan said would change — nothing more, nothing less

</pr_discipline>
