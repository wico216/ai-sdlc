# AI-SDLC Gates

Gates are human approval checkpoints with evidence requirements. No gate can be passed without explicit human approval AND supporting evidence. This is the "Proof over Prose" principle in action.

---

## Gate Definitions

### Gate 1: Requirements Approved (Inception)

**When:** After Requirements Analysis stage
**Who approves:** Product Owner / Stakeholder
**Evidence required:**
- [ ] Intent document exists and is complete
- [ ] Requirements documented with IDs (REQ-NNN)
- [ ] Success criteria are measurable
- [ ] Scope boundaries defined (in/out)
- [ ] Stakeholders identified

**Checkpoint type:** `checkpoint:human-verify`
**Audit entry:** `gate-approval` or `gate-rejection`

---

### Gate 2: INCEPTION EXIT (Inception → Construction)

**When:** After all Inception stages complete
**Who approves:** Product Owner + Technical Lead
**Evidence required:**
- [ ] All applicable Inception stages completed (per execution plan)
- [ ] Units defined with acceptance criteria
- [ ] Risk register populated
- [ ] Execution plan approved
- [ ] User stories trace to requirements
- [ ] No critical unresolved risks

**Checkpoint type:** `checkpoint:human-verify`
**Audit entry:** `gate-approval` or `gate-rejection`

**This is the most important gate.** Construction should not begin until Inception produces clear, decomposed work.

---

### Gate 3: Design Approved (Construction, per Unit)

**When:** Before implementation of each unit
**Who approves:** Technical Lead
**Evidence required:**
- [ ] Design document exists for the unit
- [ ] Architecture decisions documented
- [ ] Interface contracts defined
- [ ] Data models specified
- [ ] No conflicts with other units

**Checkpoint type:** `checkpoint:human-verify`
**Audit entry:** `gate-approval` or `gate-rejection`

---

### Gate 4: UNIT COMPLETE (Construction, per Unit)

**When:** After all bolts for a unit are executed
**Who approves:** Technical Lead + QA
**Evidence required:**
- [ ] All acceptance criteria checked (from unit definition)
- [ ] Tests passing (automated)
- [ ] Validation report generated
- [ ] Code reviewed
- [ ] No regressions introduced

**Checkpoint type:** `checkpoint:human-verify`
**Audit entry:** `gate-approval` or `gate-rejection`

---

### Gate 5: PRODUCTION READY (Operations)

**When:** Before deployment to production
**Who approves:** Technical Lead + Product Owner
**Evidence required:**
- [ ] All units complete and integrated
- [ ] Deployment plan exists and reviewed
- [ ] Runbooks generated
- [ ] Observability configured (monitoring, alerting, logging)
- [ ] Rollback procedure tested
- [ ] Performance requirements validated
- [ ] Security review passed (if applicable)

**Checkpoint type:** `checkpoint:human-verify`
**Audit entry:** `gate-approval` or `gate-rejection`

---

## Agent Behavior at Gates

1. **Before presenting a gate:** Collect all evidence items. Present them as a checklist.
2. **Present the gate:** Show the evidence checklist. Ask "Do you approve passing this gate?"
3. **If approved:** Log in audit.md with type `gate-approval`. Proceed to next phase/stage.
4. **If rejected:** Log in audit.md with type `gate-rejection`. Ask what needs to change. Don't proceed.
5. **If partially ready:** Show what's complete and what's missing. Let human decide whether to approve with known gaps (which become accepted risks).

## Gate Failure Handling

When a gate is rejected:
- Log the rejection and reason in audit.md
- Present the gaps that need to be addressed
- Route back to the appropriate stage/bolt
- Don't re-present the gate until the gaps are addressed
