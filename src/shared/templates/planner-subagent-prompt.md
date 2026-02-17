# Planner Subagent Prompt Template

Template for spawning sdlc-bolt-planner agent. The agent contains all planning expertise - this template provides planning context only.

---

## Template

```markdown
<planning_context>

**Unit:** {unit_id}

**Project State:**
@.aidlc/STATE.md

**Unit Spec:**
@.aidlc/inception/units/UNIT-{unit_id}.md

**Requirements (if exists):**
@.aidlc/REQUIREMENTS.md

**Unit Context (if exists):**
@.aidlc/construction/unit-{unit_id}/context.md

**Design (if exists):**
@.aidlc/construction/unit-{unit_id}/design.md

**Prior Validation (if exists):**
@.aidlc/construction/unit-{unit_id}/validation-report.md

</planning_context>

<downstream_consumer>
Output consumed by __CMD_PREFIX__build-unit
Plans must be executable prompts with:
- Frontmatter (wave, depends_on, files_modified, autonomous)
- Tasks in XML format
- Verification criteria
- must_haves for acceptance criteria verification
</downstream_consumer>

<quality_gate>
Before returning PLANNING COMPLETE:
- [ ] bolt-NNN-plan.md files created in unit directory
- [ ] Each plan has valid frontmatter
- [ ] Tasks are specific and actionable
- [ ] Dependencies correctly identified
- [ ] Waves assigned for parallel execution
- [ ] must_haves derived from unit acceptance criteria
</quality_gate>
```

---

## Placeholders

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{unit_id}` | From unit spec/arguments | `003` |
| `{unit_dir}` | Unit directory name | `construction/unit-003` |

---

## Usage

**From __CMD_PREFIX__plan-unit:**
```python
Task(
  prompt=filled_template,
  subagent_type="sdlc-bolt-planner",
  description="Plan Unit {unit_id}"
)
```

---

## Continuation

For checkpoints, spawn fresh agent with:

```markdown
<objective>
Continue planning for Unit {unit_id}: {unit_name}
</objective>

<prior_state>
Unit directory: @.aidlc/construction/unit-{unit_id}/
Existing plans: @.aidlc/construction/unit-{unit_id}/bolt-*-plan.md
</prior_state>

<checkpoint_response>
**Type:** {checkpoint_type}
**Response:** {user_response}
</checkpoint_response>
```

---

**Note:** Planning methodology, task breakdown, dependency analysis, wave assignment, TDD detection, and acceptance criteria derivation are baked into the sdlc-bolt-planner agent. This template only passes context.
