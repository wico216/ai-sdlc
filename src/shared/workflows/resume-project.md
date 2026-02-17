<trigger>
Use this workflow when:
- Starting a new session on an existing project
- User says "continue", "what's next", "where were we", "resume"
- Any planning operation when .aidlc/ already exists
- User returns after time away from project
</trigger>

<purpose>
Instantly restore full project context so "Where were we?" has an immediate, complete answer.

Detects phase (inception/construction/operations) and stage within each phase,
loads stage-appropriate artifacts, and presents a clear resumption summary.
</purpose>

<required_reading>
@__SDLC_REFS__/continuation-format.md
@__SDLC_REFS__/error-handling.md
@__SDLC_REFS__/phases.md
</required_reading>

<process>

<step name="detect_existing_project">
Check if this is an existing project:

```bash
test -d .aidlc && echo "AIDLC: exists" || echo "AIDLC: MISSING"
test -f .aidlc/state.md && echo "STATE: exists" || echo "STATE: MISSING"
test -f .aidlc/intent.md && echo "INTENT: exists" || echo "INTENT: MISSING"
test -f .aidlc/config.json && echo "CONFIG: exists" || echo "CONFIG: MISSING"
test -f .aidlc/execution-plan.md && echo "EXEC-PLAN: exists" || echo "EXEC-PLAN: MISSING"
```

**If AIDLC missing:** This is a new project - route to __CMD_PREFIX__new-project
**If state.md exists:** Proceed to detect_phase
**If state.md missing but other artifacts exist:** Offer to reconstruct state.md (see reconstruction step)
</step>

<step name="detect_phase">
Determine the current phase and stage by scanning artifacts on disk.

**Trust artifacts over state.md** (per error-handling.md — artifacts are ground truth).

```bash
# Inception artifact detection
test -f .aidlc/inception/requirements.md && echo "REQUIREMENTS: exists" || echo "REQUIREMENTS: none"
test -d .aidlc/inception/units && echo "UNITS: exist ($(ls .aidlc/inception/units/*.md 2>/dev/null | wc -l) files)" || echo "UNITS: none"
test -f .aidlc/inception/user-stories.md && echo "STORIES: exists" || echo "STORIES: none"
test -f .aidlc/inception/application-design.md && echo "APP-DESIGN: exists" || echo "APP-DESIGN: none"
test -f .aidlc/inception/risk-register.md && echo "RISK-REG: exists" || echo "RISK-REG: none"

# Construction artifact detection
ls .aidlc/construction/unit-*/bolt-*-plan.md 2>/dev/null | head -20
ls .aidlc/construction/unit-*/bolt-*-summary.md 2>/dev/null | head -20

# Construction stage artifacts (NFR, infrastructure)
ls .aidlc/construction/unit-*/nfr-requirements.md 2>/dev/null
ls .aidlc/construction/unit-*/nfr-design.md 2>/dev/null
ls .aidlc/construction/unit-*/infrastructure-design.md 2>/dev/null
ls .aidlc/construction/unit-*/design.md 2>/dev/null
ls .aidlc/construction/unit-*/research.md 2>/dev/null
ls .aidlc/construction/unit-*/CONTEXT.md 2>/dev/null

# Operations artifact detection
test -f .aidlc/operations/deployment-plan.md && echo "DEPLOY-PLAN: exists" || echo "DEPLOY-PLAN: none"
test -d .aidlc/operations/runbooks && echo "RUNBOOKS: exist" || echo "RUNBOOKS: none"
test -f .aidlc/operations/observability.md && echo "OBSERVABILITY: exists" || echo "OBSERVABILITY: none"

# Gate status
grep -i "inception exit" .aidlc/state.md 2>/dev/null
grep -i "production ready" .aidlc/state.md 2>/dev/null

# Checkpoints and incomplete work
ls .aidlc/construction/*/.continue-here*.md 2>/dev/null
ls .aidlc/inception/questions/*.md 2>/dev/null
```

**Phase/Stage determination table:**

| Condition | Phase | Stage |
|-----------|-------|-------|
| No inception artifacts (only intent.md + config) | Inception | Pre-elaboration |
| Questions exist without requirements | Inception | Mid-elaboration (questioning) |
| Requirements exist but no units | Inception | Mid-elaboration (design/planning) |
| Units exist but Inception Exit not passed | Inception | Ready for gate review |
| Inception Exit passed, no construction artifacts | Construction | Pre-planning |
| Bolt plans exist without summaries | Construction | Mid-execution |
| All bolt summaries exist, unit not approved | Construction | Ready for verification |
| All units complete, no operations artifacts | Operations | Pre-operations |
| Operations artifacts exist | Operations | Ready for release |

If state.md phase disagrees with artifact reality, trust artifacts and flag the inconsistency.
</step>

<step name="load_stage_artifacts">
Load artifacts appropriate to the detected phase and stage.

**MANDATORY: Load previous stage artifacts before resuming** — context from earlier stages informs current work.

### Inception Phase

**Always load:**
- `.aidlc/intent.md`
- `.aidlc/config.json`
- `.aidlc/state.md`

**If mid-elaboration (requirements):**
- `.aidlc/inception/questions/*.md` — Pending structured questions
- `.aidlc/inception/requirements.md` — Partial requirements (if exists)
- `.aidlc/audit.md` — Recent decisions

**If mid-elaboration (stories/design/plan):**
- `.aidlc/inception/requirements.md`
- `.aidlc/inception/user-stories.md` (if exists)
- `.aidlc/inception/application-design.md` (if exists)
- `.aidlc/execution-plan.md` (if exists)
- `.aidlc/inception/risk-register.md` (if exists)
- `.aidlc/inception/units/UNIT-*.md` (if any exist)

**If ready for gate review:**
- All inception artifacts above
- `.aidlc/audit.md` — Full decision trail

### Construction Phase

**Always load:**
- `.aidlc/intent.md`
- `.aidlc/state.md`
- `.aidlc/config.json`
- `.aidlc/execution-plan.md`
- `.aidlc/inception/requirements.md`

**Identify current unit** from state.md (Unit field) or most recently modified construction directory.

**For the current unit, load:**
- `.aidlc/inception/units/UNIT-NNN.md` — Unit spec
- `.aidlc/construction/unit-NNN/design.md` (if exists)
- `.aidlc/construction/unit-NNN/research.md` (if exists)
- `.aidlc/construction/unit-NNN/CONTEXT.md` (if exists)
- `.aidlc/construction/unit-NNN/nfr-requirements.md` (if exists)
- `.aidlc/construction/unit-NNN/nfr-design.md` (if exists)
- `.aidlc/construction/unit-NNN/infrastructure-design.md` (if exists)
- `.aidlc/construction/unit-NNN/bolt-*-plan.md` — All bolt plans
- `.aidlc/construction/unit-NNN/bolt-*-summary.md` — Completed summaries
- `.aidlc/construction/unit-NNN/.continue-here.md` (if exists)

### Operations Phase

**Always load:**
- `.aidlc/intent.md`
- `.aidlc/state.md`
- `.aidlc/config.json`
- `.aidlc/execution-plan.md`

**Load operations artifacts:**
- `.aidlc/operations/deployment-plan.md` (if exists)
- `.aidlc/operations/runbooks/*.md` (if any exist)
- `.aidlc/operations/observability.md` (if exists)
- `.aidlc/operations/cost.md` (if exists)

**Context summary:** After loading, provide a brief summary of what was loaded for user awareness (e.g., "Loaded: intent, requirements, 3 unit specs, execution plan, 5 bolt plans, 2 bolt summaries").
</step>

<step name="check_incomplete_work">
Look for incomplete work that needs attention:

```bash
# Check for continue-here files (mid-plan resumption)
ls .aidlc/construction/*/.continue-here*.md 2>/dev/null

# Check for plans without summaries (incomplete execution)
for plan in .aidlc/construction/unit-*/bolt-*-plan.md; do
  summary="${plan/-plan/-summary}"
  [ ! -f "$summary" ] && echo "Incomplete: $plan"
done 2>/dev/null

# Check for unanswered questions (mid-elaboration)
ls .aidlc/inception/questions/*.md 2>/dev/null

# Check for interrupted agents
if [ -f .aidlc/current-agent-id.txt ] && [ -s .aidlc/current-agent-id.txt ]; then
  AGENT_ID=$(cat .aidlc/current-agent-id.txt | tr -d '\n')
  echo "Interrupted agent: $AGENT_ID"
fi

# Check pending todos
ls .aidlc/todos/pending/*.md 2>/dev/null | wc -l

# Check active debug sessions
ls .aidlc/debug/*.md 2>/dev/null | grep -v resolved | wc -l
```

**Checkpoint found (.continue-here):**
- This is a mid-bolt resumption point
- Read the file for specific resumption context
- Flag: "Found mid-bolt checkpoint"

**Plan without summary:**
- Bolt execution was started but not completed
- Flag: "Found incomplete bolt execution"

**Unanswered questions:**
- Elaboration was interrupted mid-questioning
- Flag: "Found unanswered questions from previous session"

**Interrupted agent:**
- Subagent was spawned but session ended before completion
- Flag: "Found interrupted agent"
</step>

<step name="handle_edge_cases">
Before presenting status, detect and handle special situations:

**Project exists but no stages completed:**
- Intent.md and config.json exist, no elaboration started
- Offer: `__CMD_PREFIX__elaborate`

**Mid-question-answer flow:**
- Structured questions in `.aidlc/inception/questions/` without answers
- Present the pending questions so user can continue

**Partial artifact generation:**
- A stage started writing an artifact but session ended
- Detection: Files unusually short or contain template placeholders
- Offer: Re-run the interrupted stage

**Corrupted or inconsistent state:**
- state.md says stage complete but artifacts missing (or vice versa)
- Per error-handling.md: Trust artifacts, update state.md
- Log recovery in audit.md

**Between releases:**
- execution-plan.md missing but intent.md exists
- Suggest: `__CMD_PREFIX__elaborate` for next release cycle
</step>

<step name="present_status">
Present complete project status to user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► RESUMING SESSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**{Project Name}**

| Field              | Value                                    |
|--------------------|------------------------------------------|
| Phase              | {Inception / Construction / Operations}  |
| Current Stage      | {Stage name within phase}                |
| Last Completed     | {Last completed stage or action}         |
| Last Activity      | {Date — what happened}                   |
| Progress           | {[████████░░] XX%}                       |

**Loaded Context:**
- {List of artifacts loaded, grouped by phase}

{If incomplete work detected:}
**Pending Work:**
- {Description of what needs attention}

{If unanswered questions:}
**Pending Questions:**
- {N} unanswered questions in inception/questions/

{If blockers exist:}
**Carried Concerns:**
- {Blocker/concern from state.md}

{If pending todos:}
**Pending Todos:** {N} — __CMD_PREFIX__check-todos to review

{If state was reconstructed:}
**Note:** state.md was reconstructed from artifacts on disk.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
</step>

<step name="determine_next_action">
Based on project state, determine the most logical next action.

**Priority order:**

1. **Checkpoint exists** (.continue-here.md) — Resume from checkpoint
2. **Incomplete bolt execution** (plan without summary) — Continue execution
3. **Unanswered questions** — Present questions for user
4. **Interrupted agent** — Resume or restart
5. **Normal progression** — Next logical command

**Routing table:**

| Phase | Stage | Primary Action | Command |
|-------|-------|----------------|---------|
| Inception | Pre-elaboration | Start elaboration | `__CMD_PREFIX__elaborate` |
| Inception | Mid-elaboration | Continue elaboration | `__CMD_PREFIX__elaborate --resume` |
| Inception | Ready for gate | Approve inception | `__CMD_PREFIX__approve-inception` |
| Construction | Pre-planning | Plan next unit | `__CMD_PREFIX__plan-unit {N}` |
| Construction | Mid-planning | Continue planning | `__CMD_PREFIX__plan-unit {N}` |
| Construction | Design ready | Approve design | `__CMD_PREFIX__approve-unit {N} --design` |
| Construction | Mid-execution | Continue building | `__CMD_PREFIX__build-unit {N}` |
| Construction | Ready for verify | Verify unit | `__CMD_PREFIX__verify-unit {N}` |
| Construction | Unit complete | Approve or next unit | `__CMD_PREFIX__approve-unit {N} --complete` |
| Construction | All units done | Start operations | `__CMD_PREFIX__operations` |
| Operations | Pre-operations | Run operations | `__CMD_PREFIX__operations` |
| Operations | Ready for release | Approve release | `__CMD_PREFIX__approve-release` |
</step>

<step name="offer_options">
Present contextual options based on project state:

```
What would you like to do?

[Primary action — always offered first]
1. {Primary action} ({command})

[Secondary options — context-dependent]
2. Review current status (__CMD_PREFIX__status)
3. Check pending todos ({N} pending)
4. Something else
```

When offering construction actions, check for CONTEXT.md:
- If missing, suggest discuss/elaborate before plan
- If exists, offer plan directly

Wait for user selection.
</step>

<step name="route_to_workflow">
Based on user selection, route to appropriate workflow:

- **Execute plan** → Show command:
  ```
  ---

  ## ▶ Next Up

  **{unit}-bolt-{NN}** — {objective from bolt plan}

  `__CMD_PREFIX__build-unit {unit}`

  <sub>`/clear` first --> fresh context window</sub>

  ---
  ```
- **Plan unit** → Show command:
  ```
  ---

  ## ▶ Next Up

  **Unit {N}: {Name}** — {Goal from execution-plan.md}

  `__CMD_PREFIX__plan-unit {N}`

  <sub>`/clear` first --> fresh context window</sub>

  ---
  ```
- **Check todos** → Read .aidlc/todos/pending/, present summary
- **Something else** → Ask what they need
</step>

<step name="update_session">
Before proceeding to routed workflow, update session continuity:

Update state.md:

```markdown
## Session Continuity

Last session: {current timestamp}
Stopped at: Session resumed, proceeding to {action}
Resume file: {path to .continue-here if exists, otherwise "None"}
```

Log the resumption in audit.md:

```markdown
## Recovery — Session Resumption
**Timestamp:** {ISO 8601}
**Issue:** New session started
**Steps Taken:** Loaded {N} artifacts, detected phase={phase}, stage={stage}
**Outcome:** Routed to {chosen action}
**Artifacts Affected:** state.md updated
```

This ensures if session ends unexpectedly, next resume knows the state.
</step>

</process>

<reconstruction>
If state.md is missing but other artifacts exist:

"state.md missing. Reconstructing from artifacts..."

1. Read intent.md → Extract project name and core value
2. Scan inception/ → Determine inception progress
3. Scan construction/ → Count units, plans, summaries
4. Scan operations/ → Check for deployment artifacts
5. Read execution-plan.md → Determine phases and current position
6. Scan \*-summary.md files → Extract decisions, concerns
7. Count pending todos in .aidlc/todos/pending/
8. Check for .continue-here files → Session continuity

Reconstruct and write state.md, then proceed normally.

This handles cases where:
- Project predates state.md introduction
- File was accidentally deleted
- Cloning repo without full .aidlc/ state
</reconstruction>

<quick_resume>
If user says "continue" or "go":
- Load state silently
- Determine primary action
- Execute immediately without presenting options

"Continuing from [state]... [action]"
</quick_resume>

<success_criteria>
Resume is complete when:

- [ ] state.md loaded (or reconstructed from artifacts)
- [ ] Phase correctly detected from artifacts (not just state.md)
- [ ] Stage within phase correctly identified
- [ ] Stage-appropriate artifacts loaded (inception/construction/operations)
- [ ] Construction stage artifacts loaded (nfr-design, infrastructure-design, etc.)
- [ ] Incomplete work detected and flagged (checkpoints, unfinished bolts, unanswered questions)
- [ ] Edge cases handled (no stages completed, partial artifacts, corrupted state, between releases)
- [ ] Clear resumption summary presented to user
- [ ] Contextual next actions offered with correct commands
- [ ] Session continuity updated in state.md
- [ ] Resumption logged in audit.md
</success_criteria>
</output>
