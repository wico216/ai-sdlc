# Requirements Template

Template for `.aidlc/inception/requirements.md` — checkable requirements that define "done."

> Requirements use MUST/SHOULD/MAY classification (RFC 2119 style).
> Every requirement has a REQ-ID for traceability through the Golden Thread.

## Instructions for agents

- Generate during `__CMD_PREFIX__new-project` (initial draft)
- Refine during `__CMD_PREFIX__elaborate` (Requirements Refinement stage)
- Use Reverse Conversation pattern: AI proposes, human refines
- Every requirement MUST be testable and atomic
- Traceability maps requirements to units (not phases)

## Template

```markdown
---
type: requirements
project: "{project-name}"
status: "{draft | reviewed | approved}"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
traces_to:
  intent: "inception/intent.md"
---

# Requirements: {Project Name}

**Core Value:** {from intent.md — the ONE thing this project must deliver}

## v1 Requirements

Requirements for initial release. Each maps to units.

### {Category 1}

- [ ] **{CAT}-01** [MUST]: {Requirement description — testable, atomic}
- [ ] **{CAT}-02** [MUST]: {Requirement description}
- [ ] **{CAT}-03** [SHOULD]: {Requirement description}
- [ ] **{CAT}-04** [MAY]: {Requirement description}

### {Category 2}

- [ ] **{CAT}-01** [MUST]: {Requirement description}
- [ ] **{CAT}-02** [SHOULD]: {Requirement description}

### {Category 3}

- [ ] **{CAT}-01** [MUST]: {Requirement description}
- [ ] **{CAT}-02** [MAY]: {Requirement description}

## v2 Requirements

Deferred to future release. Tracked but not in current scope.

### {Category}

- **{CAT}-01**: {Requirement description}
- **{CAT}-02**: {Requirement description}

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| {Feature} | {Why excluded} |
| {Feature} | {Why excluded} |

## Traceability

Which units cover which requirements. Updated during unit decomposition.

| Requirement | Priority | Unit | Status |
|-------------|----------|------|--------|
| {CAT}-01 | MUST | UNIT-001 | {pending | in-progress | complete | blocked} |
| {CAT}-02 | MUST | UNIT-001 | pending |
| {CAT}-03 | SHOULD | UNIT-002 | pending |
| {CAT}-04 | MAY | UNIT-003 | pending |

**Coverage:**
- v1 requirements: {X} total ({M} MUST, {S} SHOULD, {Y} MAY)
- Mapped to units: {N}
- Unmapped: {Z} ⚠️

---
*Requirements defined: {date}*
*Last updated: {date} after {trigger}*
*Approved at gate: Requirements Approved*
```

<guidelines>

**Requirement Format:**
- ID: `[CATEGORY]-[NUMBER]` (AUTH-01, CONT-02, SOCL-03)
- Priority: `[MUST]`, `[SHOULD]`, or `[MAY]` — RFC 2119 style
- Description: User-centric, testable, atomic
- Checkbox: Only for v1 requirements (v2 are not yet actionable)

**Priority Classification (RFC 2119):**
- **MUST:** Required for v1. Project fails without it.
- **SHOULD:** Expected for v1 but can ship without. Strong justification needed to skip.
- **MAY:** Nice-to-have for v1. Include if time permits.

**Categories:**
- Derive from project domain and intent.md scope
- Keep consistent with domain conventions
- Typical: Authentication, Content, Social, Notifications, Moderation, Payments, Admin

**v1 vs v2:**
- v1: Committed scope, will be decomposed into units
- v2: Acknowledged but deferred, not in current units
- Moving v2 → v1 requires re-elaboration

**Traceability:**
- Empty initially, populated during unit decomposition (elaborate)
- Each requirement maps to exactly one unit
- Unmapped requirements = unit decomposition gap

**Status Values:**
- pending: Not started
- in-progress: Unit is active
- complete: Requirement verified
- blocked: Waiting on external factor

</guidelines>

<evolution>

**After each unit completes:**
1. Mark covered requirements as complete
2. Update traceability status
3. Note any requirements that changed scope

**After re-elaboration:**
1. Verify all v1 requirements still mapped
2. Add new requirements if scope expanded
3. Move requirements to v2/out of scope if descoped

**Requirement completion criteria:**
- Requirement is "complete" when:
  - Feature is implemented
  - Feature is verified (tests pass, acceptance criteria met)
  - Feature is committed
  - Validation report confirms it

</evolution>
