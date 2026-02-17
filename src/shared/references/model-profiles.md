# Model Profiles

Model profiles control which Claude model each AI-SDLC agent uses. This allows balancing quality vs token spend.

## Profile Definitions

| Agent | `quality` | `balanced` | `budget` |
|-------|-----------|------------|----------|
| sdlc-inception | opus | sonnet | sonnet |
| sdlc-bolt-planner | opus | opus | sonnet |
| sdlc-bolt-executor | opus | sonnet | sonnet |
| sdlc-unit-verifier | sonnet | sonnet | haiku |
| sdlc-gate-checker | sonnet | sonnet | haiku |
| sdlc-research-synthesizer | sonnet | sonnet | haiku |
| sdlc-debugger | opus | sonnet | sonnet |
| sdlc-codebase-mapper | sonnet | haiku | haiku |
| sdlc-plan-checker | sonnet | sonnet | haiku |
| sdlc-integration-checker | sonnet | sonnet | haiku |

## Profile Philosophy

**quality** - Maximum reasoning power
- Opus for all decision-making agents
- Sonnet for read-only verification
- Use when: quota available, critical architecture work

**balanced** (default) - Smart allocation
- Opus only for planning (where architecture decisions happen)
- Sonnet for execution and research (follows explicit instructions)
- Sonnet for verification (needs reasoning, not just pattern matching)
- Use when: normal development, good balance of quality and cost

**budget** - Minimal Opus usage
- Sonnet for anything that writes code
- Haiku for research and verification
- Use when: conserving quota, high-volume work, less critical phases

## Resolution Logic

Orchestrators resolve model before spawning:

```
1. Read .aidlc/config.json
2. Get model_profile (default: "balanced")
3. Look up agent in table above
4. Pass model parameter to Task call
```

## Switching Profiles

Runtime: `__CMD_PREFIX__set-profile <profile>`

Per-project default: Set in `.aidlc/config.json`:
```json
{
  "model_profile": "balanced"
}
```

## Design Rationale

**Why Opus for sdlc-bolt-planner?**
Planning involves architecture decisions, goal decomposition, and task design. This is where model quality has the highest impact.

**Why Sonnet for sdlc-bolt-executor?**
Executors follow explicit bolt-plan.md instructions. The plan already contains the reasoning; execution is implementation.

**Why Sonnet (not Haiku) for sdlc-unit-verifier in balanced?**
Verification requires goal-backward reasoning - checking if code *delivers* what the unit promised, not just pattern matching. Sonnet handles this well; Haiku may miss subtle gaps.

**Why Haiku for sdlc-codebase-mapper?**
Read-only exploration and pattern extraction. No reasoning required, just structured output from file contents.
