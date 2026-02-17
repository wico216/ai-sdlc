# Question Format Guide

## Purpose

Structured question files ensure user answers are captured, traceable, and contradiction-free. This guide governs how AI-SDLC agents write clarifying questions during inception and construction stages.

## When This Applies

| Context | Question Format |
|---------|----------------|
| `new-project` questioning | **Conversational** — open-ended, follow-the-thread (see `questioning.md`) |
| `elaborate` stages (requirements, stories, design) | **File-based** — structured questions written to `.md` files |
| `plan-unit` clarifications | **File-based** — questions written to unit's `questions/` directory |
| Bolt execution | **Inline** — executor handles deviations directly |

**Rule:** During elaboration and planning, write clarifying questions to files. During intent discovery (`new-project`), keep it conversational. During execution, handle inline.

---

## File-Based Question Format

### File Naming Convention

Questions go in a `questions/` directory within the relevant phase:

```
.aidlc/inception/questions/requirements-questions.md
.aidlc/inception/questions/stories-questions.md
.aidlc/inception/questions/design-questions.md
.aidlc/construction/unit-NNN/questions/planning-questions.md
```

### Question Structure

Every question must include meaningful options plus "Other" as the last option:

```markdown
## Question [Number]
[Clear, specific question text]

A) [First meaningful option]
B) [Second meaningful option]
[...additional options as needed...]
X) Other (please describe after [Answer]: tag below)

[Answer]:
```

### Rules

- **"Other" is MANDATORY** as the LAST option for every question
- Only include meaningful options — don't pad with filler
- Minimum: 2 meaningful options + Other (A, B, C)
- Maximum: 5 meaningful options + Other (A, B, C, D, E, F)
- Make options mutually exclusive
- Cover the most common scenarios
- Be specific and clear

### Complete Example

```markdown
# Requirements Clarification Questions

Please answer the following questions to help clarify the requirements.
Fill in the letter choice after each [Answer]: tag. If none match, choose Other and describe.

## Question 1
What is the primary authentication method?

A) Username and password
B) Social login (Google, GitHub)
C) Single Sign-On (SSO / SAML)
D) API key / token-based
E) Other (please describe after [Answer]: tag below)

[Answer]:

## Question 2
What is the deployment target?

A) Cloud (AWS, Azure, GCP)
B) On-premises / self-hosted
C) Hybrid (cloud + on-premises)
D) Other (please describe after [Answer]: tag below)

[Answer]:
```

---

## Workflow Integration

### Step 1: Create Question File

Write questions to the appropriate `questions/` directory. Group by stage (requirements, stories, design, planning).

### Step 2: Inform User

```
I've created {filename} with {N} questions.
Please answer each question by filling in the letter choice after the [Answer]: tag.
If none of the options match, choose Other and describe your preference.
Let me know when you're done.
```

### Step 3: Wait for Confirmation

Wait for user to say "done", "completed", "finished", or similar.

### Step 4: Read and Analyze

1. Read the question file
2. Extract answers after `[Answer]:` tags
3. Validate all questions are answered
4. Run contradiction and ambiguity detection (see below)
5. Proceed with analysis based on responses

---

## Contradiction and Ambiguity Detection

**MANDATORY:** After reading user responses, check for contradictions and ambiguities before proceeding.

### Detecting Contradictions

Look for logically inconsistent answers:

- **Scope mismatch:** "Simple fix" but "entire codebase affected"
- **Risk mismatch:** "Low risk" but "breaking API changes"
- **Timeline mismatch:** "Quick task" but "multiple subsystems involved"
- **Priority mismatch:** "MUST have" but "only if time permits"

### Detecting Ambiguities

Look for unclear or borderline responses:

- Answers that could fit multiple interpretations
- Responses that lack specificity ("depends", "maybe", "not sure")
- Conflicting indicators across questions

### Creating Clarification Questions

If contradictions or ambiguities are detected:

1. **Create clarification file:** `{stage}-clarification-questions.md` in the same `questions/` directory
2. **Explain the issue:** State what contradiction/ambiguity was detected
3. **Ask targeted questions:** Use the same multiple-choice format
4. **Reference original questions:** Show which questions had conflicting answers

**Example:**

```markdown
# Requirements Clarification — Follow-up

I detected contradictions in your responses that need clarification:

## Contradiction 1: Scope vs Complexity
You indicated "Simple bug fix" (Q1: A) but also "Multiple subsystems affected" (Q3: C).
These conflict because a simple bug fix typically affects one subsystem.

### Clarification Question 1
Which better describes this work?

A) Simple fix in one subsystem (revise Q3 answer)
B) Multi-subsystem change (revise Q1 — this is not a simple fix)
C) Other (please describe after [Answer]: tag below)

[Answer]:
```

### Clarification Workflow

1. **Detect:** Analyze all responses for contradictions/ambiguities
2. **Create:** Generate clarification question file if issues found
3. **Inform:** Tell user about the issues and the clarification file
4. **Wait:** Do not proceed until user provides clarifications
5. **Re-validate:** After clarifications, check again for consistency
6. **Proceed:** Only move forward when all contradictions are resolved

---

## When to Write Questions vs Ask Inline

**Write to file when:**
- Questions will be referenced later (traceability)
- Multiple questions need answering at once (3+)
- Answers inform artifact generation (requirements, design)
- User might want to review/revise answers later

**Ask inline (AskUserQuestion) when:**
- Single binary decision ("proceed or revise?")
- Quick clarification during conversation flow
- Gate checkpoint approval
- Stage selection confirmation

**Ask conversationally when:**
- Intent discovery (`new-project`)
- Following conversational threads
- Exploring vague ideas

---

## Summary

- File-based questions for elaboration and planning stages
- Conversational questions for intent discovery
- Always include "Other" as last option
- Always check for contradictions before proceeding
- Never proceed with unresolved ambiguity
- Question files provide audit trail and traceability
