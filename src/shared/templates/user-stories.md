# User Stories Template

> User stories capture user-facing capabilities with testable acceptance criteria.
> Only generated during Inception when the project has UI or multiple user types.
> Traces to: intent.md (scope), requirements.md (REQ-IDs)

## Instructions for agents

- Generate during `__CMD_PREFIX__elaborate` when stage "User Stories" is marked required
- Each story maps to one or more REQ-IDs
- Acceptance criteria use Given/When/Then format (testable)
- Group stories by persona, not by technical component
- Keep story count manageable — 5-15 for most projects

## Template

```markdown
---
type: user-stories
project: "{project-name}"
status: "{draft | reviewed | approved}"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
traces_to:
  intent: "inception/intent.md"
  requirements: "inception/requirements.md"
---

# User Stories: {Project Name}

## Persona Definitions

### {Persona 1 Name}
- **Role:** {role description}
- **Goal:** {what they want to achieve}
- **Context:** {relevant background — technical skill, frequency of use, etc.}
- **Demographics:** {age range, technical proficiency, domain experience}
- **Pain Points:** {current frustrations, unmet needs, workflow bottlenecks}
- **Success Criteria:** {what "success" looks like for this persona}

### {Persona 2 Name}
- **Role:** {role description}
- **Goal:** {what they want to achieve}
- **Context:** {relevant background}
- **Demographics:** {age range, technical proficiency, domain experience}
- **Pain Points:** {current frustrations, unmet needs, workflow bottlenecks}
- **Success Criteria:** {what "success" looks like for this persona}

---

## Stories

### STORY-001: {Short Title}

**As a** {persona},
**I want** {capability},
**So that** {benefit}.

**Traces to:** {REQ-ID(s)}
**Priority:** {MUST | SHOULD | MAY}

**Acceptance Criteria:**

- **Given** {precondition}
  **When** {action}
  **Then** {expected result}

- **Given** {precondition}
  **When** {action}
  **Then** {expected result}

---

### STORY-002: {Short Title}

**As a** {persona},
**I want** {capability},
**So that** {benefit}.

**Traces to:** {REQ-ID(s)}
**Priority:** {MUST | SHOULD | MAY}

**Acceptance Criteria:**

- **Given** {precondition}
  **When** {action}
  **Then** {expected result}

---

## INVEST Validation

Validate each story against the INVEST criteria before approval.

| Story | Independent | Negotiable | Valuable | Estimable | Small | Testable | Pass? |
|-------|:-----------:|:----------:|:--------:|:---------:|:-----:|:--------:|:-----:|
| STORY-001 | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} |
| STORY-002 | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} | {Y/N} |

**Criteria definitions:**
- **Independent** — Can be developed and delivered without depending on another story
- **Negotiable** — Details can be discussed; not a rigid contract
- **Valuable** — Delivers clear value to the user or business
- **Estimable** — Enough detail to estimate effort
- **Small** — Completable within a single unit or bolt
- **Testable** — Acceptance criteria are verifiable (Given/When/Then)

**Remediation:** Stories failing any criterion MUST be revised before proceeding. Split large stories, add missing acceptance criteria, or clarify scope as needed.

---

## Story-to-Requirement Traceability

| Story ID | Story Title | REQ-ID(s) | Requirement Description | Priority |
|----------|-------------|-----------|------------------------|----------|
| STORY-001 | {title} | {REQ-ID(s)} | {brief requirement description} | {MUST/SHOULD/MAY} |
| STORY-002 | {title} | {REQ-ID(s)} | {brief requirement description} | {MUST/SHOULD/MAY} |

**Coverage check:**
- **Requirements with stories:** {N} of {M} ({percentage}%)
- **Requirements without stories:** {list REQ-IDs or "None"}
- **Stories without requirements:** {list STORY-IDs or "None" — these may indicate scope creep}

---

## Story Map

| Persona | MUST Stories | SHOULD Stories | MAY Stories |
|---------|-------------|---------------|-------------|
| {Persona 1} | STORY-001, STORY-003 | STORY-005 | STORY-008 |
| {Persona 2} | STORY-002, STORY-004 | STORY-006 | - |

## Coverage

| Story | REQ-ID(s) | Unit | Status |
|-------|-----------|------|--------|
| STORY-001 | AUTH-01, AUTH-02 | UNIT-001 | {defined | in-progress | complete} |
| STORY-002 | CONT-01, CONT-02 | UNIT-002 | {defined | in-progress | complete} |

**Total:** {N} stories covering {M} requirements
**Unmapped requirements:** {list any REQ-IDs without a story, or "None"}

---

*Stories trace: Intent → Requirements → Stories → Units → Code*
*Approved at gate: Requirements Approved*
```

<guidelines>

**When to generate:**
- UI applications with end users
- Multi-user systems with different roles
- Products where user journeys matter

**When to skip:**
- CLI tools, libraries, APIs with no direct end-user
- Infrastructure projects
- Single-purpose scripts

**Story quality:**
- Each story must have at least one acceptance criterion
- Acceptance criteria must be testable (Given/When/Then)
- Stories should be independent where possible
- INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable

**Persona quality:**
- Based on real user research or reasonable assumptions
- Include enough context to inform design decisions
- Define demographics, goals, pain points, and success criteria for each persona
- 2-4 personas for most projects (more = probably too granular)

**INVEST validation:**
- Every story MUST pass all 6 INVEST criteria before approval
- Fill in the INVEST Validation table for each story
- Stories failing criteria must be revised (split, clarified, or rescoped)

**Traceability:**
- Every MUST requirement should have at least one story
- Fill in the Story-to-Requirement Traceability table
- Flag requirements without stories and stories without requirements

</guidelines>
