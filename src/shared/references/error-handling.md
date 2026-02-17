# Error Handling and Recovery Procedures

## Error Severity Levels

| Level | Impact | Action |
|-------|--------|--------|
| **Critical** | Workflow cannot continue | Stop immediately, inform user, log to audit.md |
| **High** | Current stage cannot complete | Attempt recovery, escalate to user if unresolved |
| **Medium** | Stage can continue with workarounds | Log warning, apply workaround, continue |
| **Low** | Minor issue, no impact on progress | Log for reference, continue normally |

---

## Phase-Specific Error Handling

### Inception Errors

**Requirements conflict:**
- Severity: High
- Cause: User provides contradictory requirements
- Action: Create follow-up questions to resolve contradictions (see `question-format-guide.md`)
- Rule: Do NOT proceed until contradictions are resolved

**Intent.md too vague:**
- Severity: Medium
- Cause: Insufficient detail from `new-project` questioning
- Action: Flag to user, proceed to questioning stage with extra questions targeting gaps
- Workaround: Generate requirements with explicit "ASSUMPTION" markers for user review

**Missing intent.md:**
- Severity: Critical
- Cause: User hasn't run `__CMD_PREFIX__new-project`
- Action: Error message directing user to run `__CMD_PREFIX__new-project` first

**Incomplete answers to verification questions:**
- Severity: High
- Cause: User skipped questions or answered partially
- Action: Highlight unanswered questions, re-request completion
- Rule: Do NOT generate artifacts from incomplete answers

### Construction Errors

**Build failure during bolt execution:**
- Severity: High
- Cause: Code doesn't compile, tests fail, dependencies missing
- Action: Ralph Loop retry (auto-fix and re-run). If 3 retries fail, escalate to user
- Recovery: Capture error output, identify root cause, apply targeted fix

**Circular unit dependencies:**
- Severity: High
- Cause: Poor boundary definition during inception
- Action: Identify circular dependencies, suggest boundary refactoring
- Recovery: Return to inception to revise unit boundaries

**Design conflicts with requirements:**
- Severity: Medium
- Cause: Technical constraints make a requirement infeasible as specified
- Action: Flag conflict, present alternatives, get user decision
- Rule: Log decision in audit.md with rationale

**Bolt context overflow:**
- Severity: Medium
- Cause: Bolt tasks exceed ~50% context budget
- Action: Split bolt into smaller bolts, re-sequence wave assignments
- Prevention: Plan checker should catch oversized bolts

### Operations Errors

**Deployment target unclear:**
- Severity: Medium
- Cause: Missing infrastructure decisions
- Action: Ask user to specify deployment targets
- Workaround: Generate generic deployment instructions, user adapts

**Missing build tool configuration:**
- Severity: Low
- Cause: Non-standard project structure
- Action: Ask user to specify build commands
- Workaround: Provide common alternatives

---

## Recovery Procedures

### Partial Stage Completion

When a stage is interrupted mid-execution:

1. Read the stage plan file (if exists)
2. Identify last completed step (last `[x]` checkbox)
3. Verify all prior steps produced their artifacts
4. Resume from next uncompleted step
5. Log recovery in audit.md

### Corrupted state.md

When `state.md` is corrupted or inconsistent:

1. Create backup: `state.md.backup`
2. Scan existing artifacts to determine actual progress
3. Ask user which stage they're actually on (if ambiguous)
4. Regenerate state.md from existing artifacts
5. Log recovery in audit.md

### Missing Artifacts

When required artifacts from a prior stage are missing:

1. Identify which stage created the missing artifact
2. Check if stage was marked complete in state.md
3. If marked complete but artifact missing: re-run that stage
4. If not marked complete: resume from that stage
5. If cannot regenerate: ask user to provide information manually
6. Log gap in audit.md

### User Wants to Restart Stage

1. Confirm user wants to restart (existing work will be archived)
2. Archive existing artifacts: `{artifact}.backup`
3. Reset stage status in state.md
4. Clear stage checkboxes in plan files
5. Re-execute stage from beginning

### User Wants to Skip Stage

1. Confirm user understands implications (downstream stages may lack input)
2. Document skip reason in audit.md
3. Mark stage as "SKIPPED" in state.md
4. Proceed to next stage
5. Flag potential issues in subsequent stages

---

## Session Resumption Errors

### Missing Artifacts During Resumption

- Cause: Files deleted, moved, or never created
- Action:
  1. Identify which stage created the missing artifact
  2. If stage marked complete → re-run that stage
  3. If stage not complete → resume from that stage
- Recovery: Return to the stage that creates missing artifacts

### Inconsistent State

- Cause: state.md shows stage complete but artifacts don't exist (or vice versa)
- Action:
  1. Trust artifacts over state.md (artifacts are ground truth)
  2. Update state.md to match what actually exists on disk
  3. Log correction in audit.md

### Context Loading Errors

- Cause: Cannot load required context from previous stages
- Action:
  1. List which artifacts are needed for current stage
  2. Identify which ones are missing or corrupted
  3. Complete prerequisite stages before resuming

---

## Escalation Guidelines

### Ask User Immediately When:
- Contradictory or ambiguous requirements
- Missing information needed to proceed
- Technical constraints AI cannot resolve
- Decisions requiring business judgment
- Security-sensitive choices

### Attempt Resolution First, Then Ask When:
- Repeated errors in same step (after 2 attempts)
- Complex technical issues
- Unusual project structures
- Integration with unfamiliar external systems

### Suggest Starting Over When:
- Multiple stages have cascading errors
- state.md is severely corrupted and artifacts are inconsistent
- User requirements have fundamentally changed
- Architectural decisions need reversing

---

## Logging Requirements

### Error Log Format (append to audit.md)

```markdown
## Error — {Stage Name}
**Timestamp:** {ISO 8601}
**Severity:** {Critical|High|Medium|Low}
**Description:** {What went wrong}
**Cause:** {Why it happened}
**Resolution:** {How it was resolved}
**Impact:** {Effect on workflow}
```

### Recovery Log Format (append to audit.md)

```markdown
## Recovery — {Stage Name}
**Timestamp:** {ISO 8601}
**Issue:** {What needed recovery}
**Steps Taken:** {What was done}
**Outcome:** {Result}
**Artifacts Affected:** {List of files}
```

---

## Prevention Best Practices

1. **Validate early:** Check inputs and dependencies before starting work
2. **Checkpoint often:** Update checkboxes immediately after completing steps
3. **Communicate clearly:** Explain what you're doing and why
4. **Ask questions:** Don't assume — clarify ambiguities immediately (see `overconfidence-prevention.md`)
5. **Document everything:** Log decisions and errors in audit.md
