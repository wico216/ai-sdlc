# Guardrails Template

Template for `.aidlc/GUARDRAILS.md` — evolving AI collaboration rules for the project.

> Guardrails capture learned preferences about how AI should work on THIS project. They evolve via `__CMD_PREFIX__retro` as the team discovers what works and what doesn't.

---

## File Template

```markdown
---
type: guardrails
project: "{project-name}"
status: active
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
---

# Project Guardrails

## Code Style

- [Language/framework conventions discovered during construction]
- [Naming patterns, file organization preferences]
- [Import ordering, formatting rules not captured by linters]

## Review Depth

- **Default review level:** [quick-scan | standard | thorough]
- **Thorough review triggers:** [security-sensitive, data model changes, public API]
- **Auto-approve threshold:** [test-only changes, documentation, formatting]

## Known Pitfalls

- [Patterns that caused bugs or rework on this project]
- [Common mistakes the AI or team made that should be avoided]
- [Edge cases discovered during construction]

## Team Conventions

- [Patterns the AI should always follow on this project]
- [Patterns the AI should never do on this project]
- [Level of autonomy for different task types]
- [Preferred commit message format]
- [Branch naming conventions]

## Auto-Approve Thresholds

Changes that can be auto-approved without human gate review:
- [test-only changes, documentation, formatting]
- [Dependency version bumps (patch only)]
- [Type-only changes with no runtime effect]

Changes that always require human review:
- [Security-sensitive code, auth, data model changes]
- [Public API changes, breaking changes]

## Testing Expectations

- [What level of test coverage is expected]
- [When to write tests vs. when to skip]
- [Preferred testing patterns/frameworks]

## Construction Preferences

- [Bolt sizing preferences (small/medium/large)]
- [When to checkpoint vs. continue autonomously]
- [Preferred commit granularity]

## Evolution Log

<!-- Added by __CMD_PREFIX__retro after each unit completion -->

| Date | Unit | Change | Rationale |
|------|------|--------|-----------|
| - | - | - | - |

---
*Last updated: {date} via __CMD_PREFIX__retro*
```

<purpose>

GUARDRAILS.md captures project-specific AI collaboration preferences that emerge during construction.

**Problem it solves:** Every project discovers "the AI keeps doing X when we want Y" patterns. Without a place to record these, the same corrections happen repeatedly across sessions and units.

**Solution:** A living document that:
- Starts with sensible defaults during inception
- Evolves via `__CMD_PREFIX__retro` after each unit
- Is read by agents before planning and execution
- Contains concrete rules, not vague aspirations

</purpose>

<lifecycle>

**Creation:** During `__CMD_PREFIX__new-project`, after intent.md
- Initialize with project-appropriate defaults
- Populate code style from detected tech stack
- Set review depth based on project complexity

**Reading:** By planning and execution agents
- `sdlc-bolt-planner` reads before creating bolt plans
- `sdlc-bolt-executor` reads before executing tasks
- Informs autonomous decision-making within bolts

**Writing:** During `__CMD_PREFIX__retro`
- Add new lessons learned
- Update rules based on what worked/didn't
- Remove rules that proved unnecessary

</lifecycle>

<guidelines>

**Good guardrails (concrete, actionable):**
- "Always use named exports, never default exports"
- "API routes must validate input with zod before processing"
- "Prefer server components; only use 'use client' when interactivity needed"
- "Auto-approve: test file changes, comment updates, type-only changes"

**Bad guardrails (vague, aspirational):**
- "Write clean code"
- "Follow best practices"
- "Be careful with security"
- "Keep things simple"

**Size constraint:** Keep under 60 lines of active rules. If it grows beyond that, consolidate or remove stale rules during retro.

</guidelines>
