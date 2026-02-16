# AI-SDLC Rituals

> Team rituals for AI-native development. These adapt traditional Agile ceremonies for AI-assisted workflows. Optional for solo developers, recommended for teams of 2+.

## Mob Elaboration

**When:** During Inception, before INCEPTION EXIT gate
**Who:** Product Owner + Tech Lead + Engineer(s)
**Duration:** 1-2 hours
**Purpose:** Collaborative refinement of requirements, units, and risk register

### How it works

1. One person shares screen running `__CMD_PREFIX__new-project` + `__CMD_PREFIX__elaborate`
2. Team discusses each unit's bounded context and acceptance criteria together
3. AI proposes decomposition, team debates and refines
4. Risk register reviewed collaboratively — risks the AI missed surface in group discussion
5. Requirements Approved gate passed with team consensus

### Why it matters

- AI is good at decomposition but misses domain nuance
- Team members catch edge cases and interdependencies the AI doesn't see
- Shared understanding of units prevents integration problems later
- The human perspective on risk is irreplaceable

### Solo developer adaptation

Even working alone, the principle applies: don't rush through Inception. Take time to challenge the AI's decomposition. Sleep on it. Review with fresh eyes before passing the INCEPTION EXIT gate.

## Mob Construction

**When:** During bolt execution, especially for complex or risky units
**Who:** Engineer(s) + Tech Lead (optional)
**Duration:** 2-4 hour sessions
**Purpose:** Collaborative coding with AI assistance

### How it works

1. One person drives (runs `__CMD_PREFIX__build-unit`), others observe and contribute
2. AI generates code, team reviews together in real-time
3. Design decisions made collaboratively, logged in audit trail
4. Rotate driver every 30-60 minutes
5. Particularly valuable for:
   - Units touching multiple bounded contexts
   - Security-sensitive code
   - Complex integration points
   - First bolt on a new project (establishing patterns)

### Solo developer adaptation

Work in focused sessions (2-3 hours). Review AI-generated code carefully — you are the mob. Use the Design Approved gate as your checkpoint to pause and reflect.

## Guardrail Retro

**When:** After completing a unit (Unit Complete gate) or milestone
**Who:** Full team
**Duration:** 30-60 minutes
**Command:** `__CMD_PREFIX__retro`
**Purpose:** Review what the AI did well/poorly and improve for next time

### How it works

1. Run `__CMD_PREFIX__retro {UNIT-ID}` — AI analyzes audit trail, gate results, rework cycles
2. AI presents findings: what went well, what went wrong, guardrail effectiveness
3. Team adds human observations the data doesn't capture
4. Together, produce concrete improvement actions for the next unit
5. Optionally update risk register with newly discovered risks

### What to review

| Question | Source |
|----------|--------|
| Which gates passed on first try? | audit.md gate records |
| Where did we need rework? | Multiple bolt attempts on same unit |
| Which risks materialized? | risk-register.md vs. actual issues |
| What guardrails were missing? | Problems that no risk/constraint anticipated |
| What did the AI consistently get wrong? | Human observation |
| What patterns should we keep? | Successful bolt executions |

### Key principle

The retro is not about blame. It's about tuning the system — better prompts, better guardrails, better risk anticipation. Every retro should produce at least one concrete change for the next unit.

### Solo developer adaptation

Still valuable. Run `__CMD_PREFIX__retro` after each unit. The data analysis alone surfaces patterns you won't notice in the flow of work. Add your own observations before finalizing.

## Ritual Frequency

| Ritual | Frequency | Skip when... |
|--------|-----------|-------------|
| Mob Elaboration | Once per project inception | Solo developer doing a well-understood domain |
| Mob Construction | Per complex unit or first unit of a project | Simple units with clear acceptance criteria |
| Guardrail Retro | After each unit completion | Never skip — this is how you get better |

## Principle Alignment

| Ritual | Principles |
|--------|-----------|
| Mob Elaboration | #2 Reverse Conversation, #3 Design Core (DDD), #6 User Stories as Contract |
| Mob Construction | #1 Reimagine (Bolts not Sprints), #4 Align with AI Capability, #8 Streamline Responsibilities |
| Guardrail Retro | #2 Reverse Conversation, #4 Align with AI Capability, #9 Maximize Flow |
