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

## Personas

### {Persona 1 Name}
- **Role:** {role description}
- **Goal:** {what they want to achieve}
- **Context:** {relevant background — technical skill, frequency of use, etc.}

### {Persona 2 Name}
- **Role:** {role description}
- **Goal:** {what they want to achieve}
- **Context:** {relevant background}

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
- 2-4 personas for most projects (more = probably too granular)

</guidelines>
