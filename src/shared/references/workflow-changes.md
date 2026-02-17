# Mid-Workflow Changes

Guidance for handling changes that occur during an active AI-SDLC workflow. Changes are inevitable — requirements evolve, designs prove infeasible, new units emerge. This document defines how to handle them without losing traceability or introducing inconsistencies.

**Cross-cutting rules that always apply:**
- Follow `overconfidence-prevention.md` — when uncertain about change impact, ASK before proceeding
- Follow `error-handling.md` — log all changes and errors to `audit.md`
- Maintain the Golden Thread — every change must preserve bidirectional traceability

---

## 1. Requirement Changes During Inception

### 1a. Changing Requirements After Elaboration

**Scenario:** User wants to add, remove, or modify requirements after `requirements.md` is complete but before Gate 1 (Requirements Approved) is passed.

**Impact:** Low — requirements are still in draft status.

**How to handle:**

1. **Update `requirements.md` directly**
   - Add new requirements with the next available REQ-ID
   - Modify existing requirement descriptions (keep the same REQ-ID)
   - To remove a requirement: move it to the "Out of Scope" section with rationale
   - Update MUST/SHOULD/MAY classification as needed

2. **Check downstream artifacts:**
   - If `user-stories.md` exists: verify stories still align with changed requirements
   - If `application-design.md` exists: verify component inventory still covers changed requirements

3. **No re-generation needed** — requirements.md can be edited in-place

4. **Log the change** in `audit.md`:
   ```markdown
   ## Change — Requirements Update
   **Timestamp:** {ISO 8601}
   **Type:** requirement_change
   **Description:** {What changed and why}
   **Artifacts Updated:** requirements.md
   **Impact:** {downstream artifacts affected}
   ```

### 1b. New Requirements Discovered During User Story Creation

**Scenario:** While creating user stories, the agent or user identifies a requirement that was not captured during requirements analysis.

**Impact:** Low-Medium — may require updating multiple inception artifacts.

**How to handle:**

1. **Add the requirement to `requirements.md`** with a new REQ-ID
2. **Continue story creation** — include the new requirement in the story-to-requirement traceability table
3. **After stories are complete:** verify 100% coverage — every MUST requirement maps to at least one story
4. **Flag to user:** "Discovered new requirement {REQ-ID} during story creation. Added to requirements.md."

### 1c. Scope Change After Execution Plan Is Drafted

**Scenario:** User wants to change scope after the execution plan and unit decomposition are complete but before Gate 2 (Inception Exit).

**Impact:** Medium-High — may require re-decomposition.

**Decision tree:**

```
Is the scope change adding or removing a requirement?
  |
  +-- Adding a requirement:
  |     Does it fit into an existing unit?
  |       +-- Yes: Update the unit's acceptance criteria, update execution-plan.md
  |       +-- No: Create a new unit (see Section 3a)
  |
  +-- Removing a requirement:
  |     Is it the only requirement in its unit?
  |       +-- Yes: Remove the unit entirely (see Section 3b)
  |       +-- No: Remove from unit's acceptance criteria, update execution-plan.md
  |
  +-- Modifying a requirement:
        Does it change the unit boundary?
          +-- Yes: Re-decompose affected units, update unit-dependency-matrix.md
          +-- No: Update requirement description and unit acceptance criteria
```

**Artifacts that need updating:**

| Change Type | requirements.md | execution-plan.md | unit-dependency-matrix.md | user-stories.md | application-design.md |
|------------|:-:|:-:|:-:|:-:|:-:|
| Add requirement (fits existing unit) | Update | Update | - | Update if exists | - |
| Add requirement (new unit needed) | Update | Update | Update | Update if exists | Update if exists |
| Remove requirement | Update | Update | Update if unit removed | Update if exists | - |
| Modify requirement (same boundary) | Update | Update | - | Update if exists | - |
| Modify requirement (new boundary) | Update | Update | Update | Update if exists | Update if exists |

---

## 2. Design Changes During Construction

### 2a. NFR Requirements Change After NFR Design

**Scenario:** After `nfr-design.md` is created for a unit, the NFR requirements change (e.g., performance target increased, new security requirement added).

**Impact:** Medium — NFR design patterns may need revision.

**How to handle:**

1. **Update `nfr-requirements.md`** with the changed requirements
2. **Assess impact on `nfr-design.md`:**
   - If new patterns are needed: regenerate the NFR design stage
   - If existing patterns still apply: update nfr-design.md in-place
3. **Assess impact on existing bolt plans:**
   - If bolts reference old NFR patterns: mark affected bolts for revision
   - If bolts haven't been created yet: no additional action needed
4. **Log change** in `audit.md` with type `design_change`

### 2b. Infrastructure Decisions Change Mid-Construction

**Scenario:** Infrastructure decisions change after `infrastructure-design.md` is created (e.g., switching from RDS to DynamoDB, changing deployment target).

**Impact:** High — may affect multiple bolts and possibly other units.

**How to handle:**

1. **STOP current bolt execution** if in progress (deviation Rule 4 — architectural change)
2. **Present impact analysis to user:**
   - Which bolt plans reference the old infrastructure?
   - Which completed bolts used the old infrastructure?
   - Are other units affected?
3. **Get user approval** before proceeding
4. **Update `infrastructure-design.md`** with new decisions
5. **Determine re-work scope:**
   - **Completed bolts:** Create gap-closure bolts to migrate (use `plan-unit --gaps`)
   - **Planned bolts:** Revise bolt plans to use new infrastructure
   - **Unplanned bolts:** No action needed — they will use new infrastructure

### 2c. Unit Scope Changes After Bolt Planning

**Scenario:** After bolt plans are created for a unit, the unit's scope changes (acceptance criteria added, removed, or modified).

**Impact:** Medium — bolt plans may need revision or new bolts may be needed.

**How to handle:**

1. **Update the unit spec** (`.aidlc/inception/units/UNIT-NNN.md`) with new acceptance criteria
2. **Run impact analysis on existing bolt plans:**

   ```
   For each changed acceptance criterion:
     Find bolt plans that reference it (grep for REQ-IDs in must_haves)
     |
     +-- Criterion added: Does an existing bolt cover it?
     |     +-- Yes: Update bolt's must_haves
     |     +-- No: Create new bolt (next sequential number)
     |
     +-- Criterion removed: Are bolts solely for this criterion?
     |     +-- Yes: Remove bolt plan (or mark as skipped)
     |     +-- No: Remove criterion from bolt's must_haves
     |
     +-- Criterion modified: Does the bolt's action still satisfy it?
           +-- Yes: Update must_haves text
           +-- No: Revise bolt tasks to match new criterion
   ```

3. **Recompute wave assignments** if new bolts were added or dependencies changed
4. **Update execution-plan.md** with new bolt count and objectives
5. **Log change** in `audit.md`

---

## 3. Adding/Removing Units Mid-Project

### 3a. Adding a New Unit

**Scenario:** A new unit is needed that was not in the original execution plan (e.g., new feature request, discovered technical need).

**How to handle:**

1. **Create the unit spec** at `.aidlc/inception/units/UNIT-NNN.md`:
   - Assign the next available unit number
   - Define goal, acceptance criteria, risk level
   - Map to requirement IDs (create new requirements if needed)

2. **Update execution-plan.md:**
   - Add the unit entry with goal, requirements, dependencies, risk level, estimated bolts
   - Update the unit count and bolt estimates

3. **Update unit-dependency-matrix.md:**
   - Add row and column for the new unit
   - Evaluate dependency relationships with ALL existing units
   - Identify dependency type: `BLOCKS`, `INFORMS`, or `-`
   - Re-evaluate the critical path

4. **Assess impact on in-progress units:**
   - If the new unit `BLOCKS` a current unit: warn user, may need to pause current work
   - If the new unit is `INFORMED BY` a current unit: can proceed after current unit completes
   - If independent: no impact on current work

5. **Update requirements.md traceability table** with new unit mappings

6. **Log change** in `audit.md` with type `unit_added`

### 3b. Removing a Unit

**Scenario:** A unit is determined to be unnecessary (e.g., requirement removed, covered by another unit, no longer relevant).

**How to handle:**

1. **Check if the unit has completed work:**
   - If bolt summaries exist: archive to `unit-NNN.archived/`, do not delete
   - If only plans exist: can safely remove
   - If no construction artifacts: remove unit spec

2. **Redistribute requirements:**
   - For each requirement mapped to the removed unit: ensure another unit covers it
   - If any MUST requirement would become unmapped: either add to another unit or create a new unit
   - Flag unmapped requirements as warnings

3. **Update artifacts:**
   - `execution-plan.md`: remove unit entry, update counts
   - `unit-dependency-matrix.md`: remove row and column, re-evaluate critical path
   - `requirements.md`: update traceability table
   - `user-stories.md` (if exists): update coverage table
   - `state.md`: update progress metrics

4. **Check dependency impact:**
   - If other units depended on the removed unit (`BLOCKS`): those units may now be unblocked or may need a replacement dependency
   - If other units were `INFORMED BY` the removed unit: verify they have alternative information sources

5. **Log change** in `audit.md` with type `unit_removed`

### 3c. Unit Dependency Changes

**Scenario:** Dependencies between units change after the execution plan is drafted (e.g., unit B no longer needs unit A, or unit C now needs unit D).

**How to handle:**

1. **Update `unit-dependency-matrix.md`** with new dependency relationships
2. **Re-evaluate critical path** — the longest chain of BLOCKS dependencies may have changed
3. **Re-evaluate recommended build order** based on new dependency graph
4. **Check for circular dependencies** — ensure the dependency graph remains a DAG
5. **Update execution-plan.md** with new dependency information
6. **If construction is in progress:** assess whether current unit ordering is still valid

---

## 4. Change Impact Assessment

### Quick Blast-Radius Checklist

When any change is requested, run through this checklist to determine scope of impact:

```
[ ] 1. REQUIREMENTS: Does this change affect requirements.md?
      If yes: which REQ-IDs are added/removed/modified?

[ ] 2. STORIES: Does this change affect user-stories.md?
      If yes: which stories need updating?

[ ] 3. DESIGN: Does this change affect application-design.md?
      If yes: which components/services are affected?

[ ] 4. EXECUTION PLAN: Does this change affect unit decomposition?
      If yes: which units are added/removed/modified?

[ ] 5. DEPENDENCIES: Does this change affect unit-dependency-matrix.md?
      If yes: does the critical path change?

[ ] 6. NFR: Does this change affect nfr-requirements.md or nfr-design.md?
      If yes: which NFR patterns need updating?

[ ] 7. INFRASTRUCTURE: Does this change affect infrastructure-design.md?
      If yes: which infrastructure components change?

[ ] 8. BOLT PLANS: Does this change affect existing bolt plans?
      If yes: which bolts need revision?

[ ] 9. COMPLETED WORK: Does this change invalidate already-completed bolts?
      If yes: which bolts need gap-closure?

[ ] 10. OTHER UNITS: Does this change affect units beyond the directly changed one?
       If yes: which units and how?
```

### Golden Thread Traceability Map

Changes propagate through the Golden Thread. Use this map to trace impact:

```
Intent (intent.md)
  |
  v
Requirements (requirements.md)
  |                    |
  v                    v
User Stories           Execution Plan (execution-plan.md)
(user-stories.md)        |
  |                      v
  v                    Units (inception/units/UNIT-NNN.md)
Application Design       |
(application-design.md)  v
                       Unit Dependencies (unit-dependency-matrix.md)
                         |
                         v
                       NFR Requirements --> NFR Design --> Infrastructure Design
                         |
                         v
                       Bolt Plans (construction/unit-NNN/bolt-NN-plan.md)
                         |
                         v
                       Bolt Summaries --> Verification Reports --> Test Instructions
```

**Rule of thumb:** Changes at the top of the chain (intent, requirements) have the widest blast radius. Changes at the bottom (bolt plans, summaries) have the narrowest.

### When to Re-Run Stages vs. Patch Artifacts

| Situation | Re-run Stage | Patch Artifact |
|-----------|:--:|:--:|
| Single requirement text change | - | Patch |
| New requirement added (fits existing unit) | - | Patch |
| New requirement added (new unit needed) | Re-run execution planning | - |
| Acceptance criteria modified | - | Patch bolt plans |
| Architecture change | Re-run application design | - |
| NFR target changed (minor) | - | Patch |
| NFR target changed (requires new pattern) | Re-run NFR design | - |
| Infrastructure provider change | Re-run infrastructure design | - |
| Unit boundary change | Re-run execution planning | - |
| Dependency change (no boundary change) | - | Patch dependency matrix |
| Multiple cascading changes | Re-run from earliest affected stage | - |

---

## 5. Change Approval Flow

### Step 1: Present Change Impact

Before executing any change, present the impact analysis to the user:

```markdown
## CHANGE IMPACT ASSESSMENT

**Requested Change:** {description}

### Blast Radius

| Artifact | Impact | Action Needed |
|----------|--------|---------------|
| requirements.md | {Modified/None} | {Update REQ-IDs / No action} |
| execution-plan.md | {Modified/None} | {Update unit list / No action} |
| unit-dependency-matrix.md | {Modified/None} | {Update dependencies / No action} |
| bolt plans | {N bolts affected} | {Revise / Create new / No action} |
| completed work | {N bolts invalidated} | {Gap-closure bolts / No action} |

### Estimated Re-work

- Artifacts to update: {N}
- Bolt plans to revise: {N}
- Gap-closure bolts needed: {N}

### Recommendation

{Proceed with change / Consider alternative / Defer to v2}

Approve this change? (yes / no / modify)
```

### Step 2: Log the Change

After user approval, log the change in `audit.md`:

```markdown
## Change Request — {Stage/Phase Name}
**Timestamp:** {ISO 8601}
**Type:** {requirement_change | design_change | unit_added | unit_removed | scope_change}
**Request:** {What the user wants to change}
**Impact Assessment:** {Summary of blast radius}
**User Approval:** {Approved / Approved with modifications}
**Action Taken:** {What was done}
**Artifacts Updated:** {List of files changed}
```

### Step 3: Update State

After executing the change, update `state.md`:

- Update current position if the change affects sequencing
- Add the change to the decisions table
- If re-work is needed, update the progress bar to reflect new total
- Note any re-opened gates (e.g., if requirements changed after Gate 1, the gate may need re-approval)

### Step 4: Handle Re-opened Gates

Some changes may invalidate previously passed gates:

| Change | Gate Potentially Re-opened |
|--------|---------------------------|
| Requirement added/removed/modified | Gate 1 (Requirements Approved) |
| Unit added/removed/boundaries changed | Gate 2 (Inception Exit) |
| Unit design fundamentally changed | Gate 3 (Design Approved) for that unit |
| Completed bolt invalidated | Gate 4 (Unit Complete) for that unit |

**Rule:** If a gate-relevant artifact changes after the gate was passed, flag to the user that the gate may need re-approval. Do not silently proceed past a potentially invalidated gate.

---

## Change Request Decision Tree

```
User requests a change
    |
    +-- Is the project still in Inception (before Gate 2)?
    |     |
    |     +-- Yes: Changes are expected. Update artifacts in-place.
    |     |         No gate re-approval needed unless Gate 1 was already passed.
    |     |
    |     +-- No: Proceed to next question.
    |
    +-- Is this a requirement change?
    |     |
    |     +-- Yes: Run blast-radius checklist (Section 4).
    |     |         Present impact. Get user approval.
    |     |         Update requirements.md and downstream artifacts.
    |     |         Flag Gate 1 for re-approval if needed.
    |     |
    |     +-- No: Proceed to next question.
    |
    +-- Is this a design/architecture change?
    |     |
    |     +-- Yes: STOP current work (deviation Rule 4).
    |     |         Present impact on existing bolt plans and completed work.
    |     |         Get user approval before re-designing.
    |     |         Re-run affected construction stages.
    |     |
    |     +-- No: Proceed to next question.
    |
    +-- Is this adding/removing a unit?
    |     |
    |     +-- Yes: Follow Section 3 procedures.
    |     |         Update execution plan, dependency matrix, requirements traceability.
    |     |         Flag Gate 2 for re-approval.
    |     |
    |     +-- No: Proceed to next question.
    |
    +-- Is this a bolt-level change (task scope, approach)?
          |
          +-- Yes: Revise the specific bolt plan.
                    No gate re-approval needed.
                    Recompute waves if dependencies changed.
```

---

*Reference this file in agent prompts as:*
```
@__SDLC_REFS__/workflow-changes.md
```
