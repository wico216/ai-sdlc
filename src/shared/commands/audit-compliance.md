---
name: sdlc:audit-compliance
description: Verify AI-SDLC compliance — gates passed, Golden Thread intact, audit trail complete
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
---

<objective>

Self-check that the project follows AI-SDLC methodology. Verifies all 5 gates have evidence, the Golden Thread is intact, the audit trail is complete, and all REQ-IDs trace to units.

**When to run:**
- Before sharing deliverables with stakeholders
- Before Production Ready gate
- Anytime you want to verify methodology compliance

**Output:** `.aidlc/COMPLIANCE.md` — pass/fail checklist with evidence links

</objective>

<context>
@.aidlc/state.md
@.aidlc/audit.md
</context>

<process>

## 1. Pre-Flight

```bash
ls .aidlc/ 2>/dev/null
```

**If no .aidlc/:** Error — no project to audit.

Display banner:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► COMPLIANCE AUDIT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 2. Check Golden Thread

Verify each link in the traceability chain:

**Intent → Requirements:**
- Check `.aidlc/intent.md` exists
- Check `.aidlc/inception/requirements.md` exists with REQ-IDs

**Requirements → Units:**
- For each REQ-ID in inception/requirements.md, check it appears in at least one unit file
- Report orphan requirements (REQ-IDs not traced to any unit)

**Units → Design:**
- For each UNIT-NNN.md, check UNIT-NNN-design.md exists
- Report units without design documents

**Design → Code (via bolts):**
- For each unit, check SUMMARY.md files exist in the corresponding construction directory
- Report units with no execution evidence

**Code → Deployment:**
- Check `.aidlc/operations/deployment-plan.md` exists (if Operations phase reached)

## 3. Check Gates

Read `.aidlc/audit.md` and verify gate records exist:

| Gate | Check | How |
|------|-------|-----|
| Requirements Approved | `gate-approval` entry with type matching | grep audit.md |
| INCEPTION EXIT | `gate-approval` entry | grep audit.md |
| Design Approved | One per unit | grep audit.md for each UNIT-ID |
| UNIT COMPLETE | One per unit | grep audit.md for each UNIT-ID |
| PRODUCTION READY | If Operations phase reached | grep audit.md |

For each gate, report:
- **Passed:** Entry found with evidence
- **Skipped:** Entry found as `risk-accepted` (acceptable but flagged)
- **Missing:** No entry found (compliance gap)

## 4. Check Audit Trail Completeness

Verify the audit trail has entries for:
- [ ] At least one `gate-approval` or `gate-rejection` per expected gate
- [ ] No orphan references (entries that reference non-existent REQ-IDs or UNIT-IDs)
- [ ] Timestamps are chronologically ordered
- [ ] Each entry has: Type, Actor, Phase, Context, Decision, Evidence, Traces to

## 5. Check Risk Register

- `.aidlc/inception/risk-register.md` exists
- At least one risk identified
- Each risk has: ID, category, impact, likelihood, mitigation, owner

## 6. Generate Report

Write `.aidlc/COMPLIANCE.md`:

```markdown
# AI-SDLC Compliance Report

**Project:** {name}
**Audited:** {timestamp}
**Status:** {Compliant / Gaps Found}

## Golden Thread

| Link | Status | Evidence |
|------|--------|----------|
| Intent → Requirements | {pass/fail} | {file paths} |
| Requirements → Units | {pass/fail} | {N}/{M} REQ-IDs traced |
| Units → Design | {pass/fail} | {N}/{M} units have design docs |
| Design → Code | {pass/fail} | {N}/{M} units have execution evidence |
| Code → Deployment | {pass/fail/N-A} | {deployment-plan exists?} |

## Gates

| Gate | Status | Audit Entry |
|------|--------|-------------|
| Requirements Approved | {passed/skipped/missing} | Entry #{N} |
| INCEPTION EXIT | {passed/skipped/missing} | Entry #{N} |
| Design Approved | {N}/{M} units passed | Entries #{...} |
| UNIT COMPLETE | {N}/{M} units passed | Entries #{...} |
| PRODUCTION READY | {passed/skipped/missing/N-A} | Entry #{N} |

## Audit Trail

- Total entries: {N}
- Gate records: {N}
- Decisions: {N}
- Completeness: {pass/fail}

## Risk Register

- Risks identified: {N}
- Active: {N}
- Resolved: {N}
- Status: {pass/fail}

## Summary

**Score:** {N}/{M} checks passed
**Gaps:** {list of specific gaps if any}
```

## 7. Present Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC ► COMPLIANCE: {Compliant / Gaps Found}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Score: {N}/{M} checks passed
Report: .aidlc/COMPLIANCE.md

{If gaps found:}
Review the gaps above and address them before proceeding.

{If compliant:}
Project follows AI-SDLC methodology. Ready for stakeholder review.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

</process>

<success_criteria>
- [ ] Golden Thread verified (intent → requirements → units → design → code → deployment)
- [ ] All expected gates checked against audit trail
- [ ] Audit trail completeness verified
- [ ] Risk register existence and structure verified
- [ ] COMPLIANCE.md written with pass/fail for each check
- [ ] Clear summary of gaps if any
</success_criteria>
