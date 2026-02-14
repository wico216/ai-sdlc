# DDD Unit Decomposition Protocol

## Overview

This protocol defines the structured 5-step process for decomposing requirements into implementable units using Domain-Driven Design. Used during the Inception phase.

## Step 1: Identify Bounded Contexts

Read REQUIREMENTS.md and identify distinct business domains:
- Each bounded context has its own language, rules, and data
- Look for natural seams where terminology or ownership changes
- Document context boundaries explicitly

**Output:** List of bounded contexts with their scope and terminology.

## Step 2: Map Domain Events

For each bounded context:
- List events that happen (past tense: "OrderPlaced", "PaymentProcessed")
- Identify which context owns each event
- Map event flows between contexts

**Output:** Event map showing ownership and cross-context flows.

## Step 3: Define Aggregates

Within each bounded context:
- Identify aggregate roots (entities that own consistency boundaries)
- Define what data belongs together (must be consistent)
- Establish invariants (rules that must always be true)

**Output:** Aggregate definitions with invariants.

## Step 4: Derive Units

Transform aggregates into implementable units:
- Each unit maps to one or more aggregates
- Units have clear acceptance criteria derived from invariants
- Units specify `traces_to: [REQ-IDs]` for traceability
- Units are ordered by dependency (core entities first, then features that depend on them)

**Output:** Unit definitions in `.aidlc/units/UNIT-NNN.md`.

## Step 5: Validate Coverage

- Every REQ-ID from REQUIREMENTS.md must appear in at least one unit's `traces_to`
- Every unit must trace back to at least one requirement
- Coverage gaps are flagged, not silently ignored

**Output:** Coverage matrix confirming 100% requirement coverage.

## Unit File Structure

Each unit gets a file in `.aidlc/units/UNIT-NNN-{name}.md` with:

```yaml
---
id: UNIT-NNN
name: "{Unit Name}"
bounded_context: "{context name}"
traces_to: ["REQ-001", "REQ-002"]
estimated_bolts: N
dependencies: ["UNIT-MMM"]
status: pending
---
```

Followed by:
- Description (what this unit delivers)
- Acceptance criteria (testable, specific)
- Interface contracts (what it exposes, what it depends on)
- Notes (implementation hints, risk flags)
