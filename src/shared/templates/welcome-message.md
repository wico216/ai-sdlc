# Welcome Message Template

Template for the initial greeting when a user starts working with the AI-SDLC framework.

**Display:** Once at the start of a new workflow (first interaction with `__CMD_PREFIX__new-project`). Do not display on subsequent interactions to conserve context.

---

## Message Template

```markdown
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 AI-SDLC — AI-Native Software Development Lifecycle
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A structured, adaptive framework for building software with AI.
Three phases take you from idea to production — with evidence-based gates,
conversational requirement discovery, and a complete audit trail.

## The Three Phases

  INCEPTION (What + Why)        CONSTRUCTION (How)           OPERATIONS (Where + When)
  ─────────────────────         ──────────────────           ─────────────────────────
  Deep questioning              Unit planning + design       Deployment planning
  Requirements analysis         Bolt execution (rapid        Runbook generation
  Application design              iterations)                Observability setup
  Unit decomposition            Build + verify loop          Release approval
        |                             |                             |
        v                             v                             v
  [Gate: Inception Exit]        [Gate: Unit Complete]        [Gate: Production Ready]

## Quick Start

1. **__CMD_PREFIX__new-project** — Initialize your project (questioning + intent + config)
2. **__CMD_PREFIX__elaborate** — Build inception artifacts (requirements, design, execution plan)
3. **__CMD_PREFIX__approve-inception** — Pass gates 1 and 2
4. **__CMD_PREFIX__plan-unit 1** — Plan bolts for Unit 1
5. **__CMD_PREFIX__build-unit 1** — Execute bolt plans
6. **__CMD_PREFIX__verify-unit 1** — User acceptance testing
7. **__CMD_PREFIX__operations** — Deployment and operations
8. **__CMD_PREFIX__approve-release** — Final gate

## Key Features

**Conversational Discovery** — The framework starts by asking what you want to build
and follows threads to uncover requirements, constraints, and edge cases.

**Adaptive Depth** — Three levels (minimal / standard / comprehensive) control how
much detail each stage produces. Simple changes stay fast; complex systems get
thorough coverage. Set during project config or inferred from complexity.

**Structured Questions** — During elaboration, questions are written to files so they
survive across sessions. You can review and answer at your pace.

**Unit/Bolt Model** — Work is decomposed into units (bounded contexts) then into
bolts (smallest executable iteration). Bolts can run in parallel waves.

**Evidence-Based Gates** — Five gates require proof before progression. No skipping
gates without explicit override and documented rationale.

## Other Commands

| Command | Purpose |
|---------|---------|
| `__CMD_PREFIX__status` | Check progress, next action |
| `__CMD_PREFIX__resume-work` | Restore context after a break |
| `__CMD_PREFIX__pause-work` | Save context before stopping |
| `__CMD_PREFIX__quick` | Fast path for small tasks |
| `__CMD_PREFIX__debug` | Systematic debugging with persistent state |
| `__CMD_PREFIX__retro` | Post-unit retrospective |
| `__CMD_PREFIX__settings` | Change workflow preferences |
| `__CMD_PREFIX__help` | Full command reference |

## Ready?

Tell me what you want to build, and we'll get started.
```

---

<usage>

**When to display:**
- First time a user runs `__CMD_PREFIX__new-project` (before questioning begins)
- Optionally when a user asks "what is AI-SDLC?" or "how does this work?"

**When NOT to display:**
- On subsequent `new-project` runs (project already exists)
- On `resume-work` or `status` (user already knows the framework)
- On any construction or operations command

**How to display:**
- Render the template above, replacing `__CMD_PREFIX__` with the actual command prefix
- Display as markdown output (not as a code block)
- Proceed to Phase 1 of new-project after display

</usage>
