# Overconfidence Prevention Guide

## Problem Statement

AI agents exhibit overconfidence by not asking enough clarifying questions, skipping requirement categories, and making assumptions instead of gathering proper information. This leads to poor implementations that must be reworked.

## Root Cause

Overconfidence is caused by directives that encourage skipping questions:

1. "Skip entire categories if not applicable" — agents skip too aggressively
2. "Only ask questions if absolutely necessary" — agents default to assuming
3. "Use categories as inspiration, not mandatory checklist" — agents treat everything as optional
4. Stage-completion pressure — agents rush to produce artifacts rather than clarify inputs

## Core Principle

**When in doubt, ask the question — overconfidence leads to poor outcomes.**

The cost of asking one extra question is negligible. The cost of implementing the wrong solution based on assumptions is hours of rework.

---

## Guiding Principles

### 1. Default to Asking
When there's any ambiguity, ask clarifying questions. Do not fill in blanks with assumptions.

### 2. Comprehensive Coverage
Evaluate ALL relevant question categories for the current stage. Don't skip areas without explicit justification.

### 3. Thorough Analysis
Carefully analyze ALL user responses for vagueness, ambiguity, and contradiction. Look for:
- "depends", "maybe", "not sure", "mix of", "somewhere between"
- Undefined terms and references to external concepts
- Contradictory or incomplete answers

### 4. Mandatory Follow-up
Create follow-up questions for ANY unclear responses. Don't interpret vagueness — clarify it.

### 5. No Proceeding with Ambiguity
Don't move forward until ALL ambiguities are resolved. A clear, complete understanding now prevents costly corrections later.

---

## Implementation per Stage

### Inception: Requirements Analysis
- ALWAYS create clarifying questions unless the request is exceptionally clear
- Evaluate ALL areas: functional, non-functional, user scenarios, business context, technical constraints, quality attributes
- Don't accept vague requirements — probe for testable specifics

### Inception: User Stories
- Evaluate ALL question categories: personas, story granularity, acceptance criteria, user journeys, business context
- Don't skip categories because "they probably don't apply"
- Analyze answers thoroughly before generating stories

### Construction: Bolt Planning
- When multiple implementation approaches exist, PRESENT OPTIONS — never pick silently
- When uncertain about scope, ASK — don't guess what the unit includes
- Use confidence levels when proposing approaches:
  - **High confidence:** Clear requirement, well-known pattern, established codebase convention
  - **Medium confidence:** Multiple valid approaches, some ambiguity in requirements
  - **Low confidence:** Novel problem, conflicting requirements, unclear constraints → MUST ask

### Construction: Design
- Don't assume data models — ask about entities and relationships
- Don't assume API contracts — ask about consumers and formats
- Don't assume technology choices — present options with trade-offs

---

## Red Flags

Watch for these indicators of overconfidence:

- Stages completing without asking any questions on complex projects
- Proceeding with vague or ambiguous user responses
- Skipping entire question categories without justification
- Making technology or architecture assumptions without presenting alternatives
- Filling in "reasonable defaults" for requirements the user didn't specify
- Using "standard approach" without confirming it matches user expectations

## Success Indicators

- Appropriate number of clarifying questions for project complexity
- Thorough analysis of user responses with follow-up when needed
- Clear, unambiguous requirements before proceeding to implementation
- Reduced need for changes during later stages due to better upfront clarification
- Explicit confidence levels on proposals

---

## Agent Integration

**ALL agents MUST include overconfidence prevention behavior:**

1. Before generating artifacts, verify you have sufficient clarity
2. Before making implementation choices, check if alternatives should be presented
3. Before proceeding past a stage, confirm no ambiguity remains
4. When in doubt, ask — never assume

**Reference this file in agent prompts as:**
```
@__SDLC_REFS__/overconfidence-prevention.md
```
