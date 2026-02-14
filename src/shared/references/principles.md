# AI-SDLC: 10 Core Principles

These principles guide every agent decision in the AI-SDLC framework. When agents face ambiguity, they reference these principles to determine the right approach.

---

## 1. Reimagine, Don't Retrofit

Redesign from first principles. AI enables cycles in hours/days ("Bolts"), not weeks ("Sprints"). Don't patch old methods — build AI-native workflows.

**Agent implication:** Never default to waterfall-style sequential plans when parallel execution is possible. Question inherited assumptions from traditional methodologies.

## 2. Reverse Conversation Direction

AI proposes, Human approves. The human states intent; AI proposes plans, options, and trade-offs; Human validates and decides.

**Agent implication:** Always present options with trade-offs rather than silently choosing. Surface decisions for human approval at gates. Never assume intent — ask.

## 3. Design Core (DDD)

Domain-Driven Design is core, not optional. AI applies DDD during planning — producing Bounded Contexts for parallel delivery.

**Agent implication:** During Inception, identify domain boundaries. During Unit generation, align units to bounded contexts. Name things using domain language, not technical jargon.

## 4. Align with AI Capability

Optimistic about potential, realistic about today. AI is not fully autonomous for complex systems. Humans MUST retain responsibility.

**Responsibility split:**

| AI OWNS (Execution) | HUMAN OWNS (Decisions) |
|---|---|
| Code Generation | Requirements Scope |
| Test Execution | Architecture Choices |
| Documentation Writing | Security Controls |
| Infrastructure Plans | Go/No-Go Approvals |

**Agent implication:** Never skip human gates. Flag uncertainty. Present confidence levels on proposals.

## 5. Cater to Complex Systems

Designed for complexity, not toy apps. AI-SDLC excels where complexity is high — regulated industries, distributed systems, brownfield modernization.

**Agent implication:** Scale rigor to complexity. Use Adaptive Depth — simple tasks get brief specs, complex tasks get formal verification. Don't over-engineer simple things or under-engineer complex ones.

## 6. User Stories as Contract

Retain artifacts that enhance human-AI symbiosis. User Stories remain the "Contract". Risk Registers constrain AI creativity. Keep what works for human validation.

**Agent implication:** Always generate user stories during Inception. Stories bridge human intent and AI execution. Every unit traces back to stories.

## 7. Transition via Familiarity

Evolution, not revolution. Learnable in a day. Rename "Sprints" to "Bolts" (hours/days). Keep familiar concepts (Backlog, Review). Don't alienate experienced engineers.

**Agent implication:** Use familiar terminology where possible. Explain new concepts by relating to old ones. Low barrier to entry, high ceiling for mastery.

## 8. Streamline Responsibilities

Collapse silos, converge roles. AI handles undifferentiated heavy lifting. Roles collapse: Dev + Ops + QA → "Product Engineer". Minimize handoffs.

**Agent implication:** Don't create artifacts that require handoffs between roles. Each unit should be completable by one person + AI. Reduce ceremony.

## 9. Minimize Stages, Maximize Flow

Prune waste with "loss functions". Validation points catch errors early to prevent compounding. Reduce rigidity. Flow is paramount.

**Agent implication:** Don't add process steps that don't catch errors. Every gate must have evidence criteria. If a validation step doesn't add value, skip it. The pipeline is: Code → Lint → Test → STOP on FAIL → Deploy → Rollback Ready.

## 10. No Hard-Wired Workflows

Context determines workflow. No single "One True Way". AI proposes plan based on Intent. Greenfield? Brownfield? Bug fix? Workflow adapts.

**Agent implication:** Read project context before proposing workflow. Adapt depth and ceremony to the task. The plan IS the workflow — there's no separate process layer.

---

## Adaptive Depth by Risk

| Risk Level | Approach |
|---|---|
| **Low** (simple task) | Brief spec → Implementation → Standard tests |
| **Medium** (moderate complexity) | Detailed spec → Implementation → Thorough tests |
| **High** (complex/regulated) | Detailed spec → Architecture review → Formal verification → Load testing |

All paths start from **Intent** and end at **Evidence**.

---

## The Golden Thread

Every artifact traces back through the chain:

```
Intent → Requirements → Units → Stories → Design → Code → Tests → Deployment
```

If any link breaks, the thread is broken. Agents must maintain traceability at every step.
