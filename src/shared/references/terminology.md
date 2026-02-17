# AI-SDLC Terminology

Canonical glossary of all AI-SDLC terms. When agents or documents use these terms, this is the authoritative definition. Cross-references link related terms.

---

## Phases

The AI-SDLC lifecycle has three macro-phases, executed sequentially.

| Term | Definition |
|------|-----------|
| **Inception** | Phase 1 (WHAT + WHY). Converts intent into testable, decomposed work. Produces requirements, user stories, application design, execution plan, and risk register. Governed by Gate 1 (Requirements Approved) and Gate 2 (Inception Exit). |
| **Construction** | Phase 2 (HOW). Designs, builds, and validates units via bolts. Includes conditional stages (NFR requirements, NFR design, infrastructure design) and mandatory stages (bolt planning, code generation, build and test). Governed by Gate 3 (Design Approved) and Gate 4 (Unit Complete). |
| **Operations** | Phase 3 (WHERE + WHEN). Productionizes with safety and observability. Covers deployment planning, runbook generation, monitoring setup, and release. Governed by Gate 5 (Production Ready). |

---

## Inception Terms

| Term | Definition |
|------|-----------|
| **Intent Document** | The project's foundational document (`intent.md`). Captures purpose, success criteria, scope boundaries, and stakeholders. The starting point of the Golden Thread. Created by `new-project`. |
| **Requirements** | Scoped functional and non-functional requirements with unique IDs (e.g., `AUTH-01`, `DATA-02`). Classified as MUST, SHOULD, or MAY per RFC 2119. Every MUST requirement must map to at least one unit. See also: *Golden Thread*, *Traceability*. |
| **User Stories** | User journeys in As-a / I-want / So-that format with Given/When/Then acceptance criteria. Created for UI-facing apps or multi-persona systems. Includes persona definitions (demographics, pain points, success criteria) and INVEST validation. See also: *INVEST*. |
| **Application Design** | High-level architecture document covering component inventory, component methods, service layer, dependency diagrams, data flow, data model, API contracts, and technology decisions. Created for multi-unit or multi-component projects. Runs after requirements, before execution planning. |
| **Execution Plan** | The construction roadmap (`execution-plan.md`). Decomposes requirements into units, defines unit dependencies, risk levels, estimated bolts, and recommended build order. Includes the rigor levels table that controls Adaptive Depth across all subsequent stages. |
| **Unit** | A parallel-deliverable work chunk aligned to a DDD bounded context. Identified as `UNIT-NNN` (e.g., `UNIT-001`). Each unit has a goal, acceptance criteria, risk level, requirement mappings, and dependency list. Units are the primary building block of the execution plan. See also: *Bounded Context*, *Unit Dependency Matrix*. |
| **Unit Dependency Matrix** | A table (`unit-dependency-matrix.md`) showing unit-to-unit dependencies with types: `BLOCKS` (hard dependency), `INFORMS` (soft/data dependency), or `-` (none). Identifies the critical path — the longest chain of BLOCKS dependencies. |
| **Risk Register** | Document (`risk-register.md`) tracking identified risks with probability, impact, and mitigation strategies. Populated during inception, referenced throughout construction. |
| **Questioning** | The stage where clarifying questions are derived from intent.md gaps. Questions are written as structured multiple-choice files to `.aidlc/inception/questions/`. See also: *Structured Questions*, *Contradiction Detection*. |
| **Research** | Optional inception stage triggered by unfamiliar technology, external APIs, or architectural unknowns. Produces actionable findings in `.aidlc/inception/research/`. |

---

## Construction Terms

| Term | Definition |
|------|-----------|
| **Bolt** | The smallest iteration unit in AI-SDLC (hours, not weeks). Replaces the concept of a Sprint. A bolt is an executable prompt containing objective, context, tasks, verification criteria, and success criteria. Each bolt targets ~50% context usage to maintain quality. See also: *Bolt Plan*, *Wave*, *Context Budget*. |
| **Bolt Plan** | The file (`bolt-NN-plan.md`) that defines a bolt. Contains YAML frontmatter (unit, bolt number, wave, dependencies, files modified, must-haves) and XML-structured tasks. A bolt plan IS the prompt — it is not a document that becomes a prompt. |
| **Bolt Summary** | The file (`bolt-NN-summary.md`) created after a bolt completes execution. Documents what was built, decisions made, deviations from plan, tech stack changes, and key files created/modified. Used by subsequent bolts and verification. |
| **Wave** | A parallelization group for bolts. Bolts in the same wave have no dependencies on each other and can execute concurrently. Wave 1 contains independent root bolts; Wave N contains bolts that depend only on bolts in waves 1 through N-1. Wave numbers are pre-computed during planning. |
| **Gate** | A human approval checkpoint requiring objective evidence. There are 5 gates in AI-SDLC: Requirements Approved (G1), Inception Exit (G2), Design Approved (G3), Unit Complete (G4), and Production Ready (G5). No gate can be passed without explicit human approval AND supporting evidence. See also: *Proof Over Prose*. |
| **Functional Design** | Technology-agnostic business logic design for a unit (also called Domain Design). Covers bounded contexts, data models, and component architecture. |
| **NFR Requirements** | Per-unit stage that identifies non-functional requirements (performance, security, scalability, availability, compliance) and selects the tech stack needed to meet them. Conditional — skipped for simple units with no quality attribute concerns. Output: `nfr-requirements.md`. |
| **NFR Design** | Per-unit stage that maps NFR requirements to implementation patterns (caching, rate limiting, circuit breaker, retry, etc.). Depends on NFR Requirements having been executed. Output: `nfr-design.md`. |
| **Infrastructure Design** | Per-unit stage that maps logical components to actual infrastructure services (cloud resources, databases, networking, deployment architecture). Conditional — skipped for units with no infrastructure changes. Output: `infrastructure-design.md`. |
| **Verification Report** | Document (`validation-report.md`) recording three-level verification results. The three levels are: existence (file exists), substantive (file has real implementation, not stubs), and wired (file is imported and used by other parts of the system). Created by the unit verifier. |
| **Test Instructions** | Document (`test-instructions.md`) providing actionable, reproducible instructions for building, testing, and validating a unit. Covers prerequisites, build steps, unit tests, integration tests, and performance tests. Generated alongside the verification report. |
| **Task** | A single unit of work within a bolt. Each task has four required fields: `<files>` (exact paths), `<action>` (specific instructions), `<verify>` (objective check), and `<done>` (acceptance criteria). Tasks are typed: `auto` (fully autonomous), `checkpoint:human-verify`, `checkpoint:decision`, or `checkpoint:human-action`. |
| **Deviation** | Work discovered during bolt execution that was not in the original plan. Handled by four deviation rules: Rule 1 (auto-fix bugs), Rule 2 (auto-add missing critical functionality), Rule 3 (auto-fix blocking issues), Rule 4 (ask about architectural changes). |
| **Ralph Loop** | The build-verify-loop pattern for bolt execution. Build the bolt, verify the results, and if gaps are found, create new bolts to close them. The loop continues until acceptance criteria are met. |

---

## Operations Terms

| Term | Definition |
|------|-----------|
| **Deployment** | The process of moving a built system to a target environment. Covered by the deployment plan, which documents strategy, rollback procedures, and environment configuration. |
| **Deployment Plan** | Document (`deployment-plan.md`) specifying how the system reaches production. Includes deployment strategy, rollback procedures, environment configuration, and pre/post-deployment checks. |
| **Runbook** | Operational playbook generated by AI for handling specific operational scenarios (incidents, scaling, maintenance). Stored in `operations/runbooks/`. |
| **Observability** | Monitoring, alerting, and logging configuration for production systems. Documented in `operations/observability.md`. |
| **Retrospective** | Post-project or post-unit review to improve AI collaboration rules and prompt effectiveness. Called a Guardrail Retro in AI-SDLC. |
| **Cost Estimate** | Document tracking AI token usage, infrastructure costs, and human time costs. Helps teams understand the true cost of AI-assisted development. |

---

## Cross-Cutting Terms

| Term | Definition |
|------|-----------|
| **Depth Levels** | Three levels of artifact detail: **Minimal** (simple/low-risk — brief artifacts, fewer questions), **Standard** (normal complexity — full artifacts, standard coverage), **Comprehensive** (complex/high-risk — detailed artifacts, deep coverage). Depth controls detail within artifacts, not which artifacts are created. See also: *Adaptive Depth*, *Rigor Level*. |
| **Adaptive Depth** | Principle (P6) that rigor scales to risk level. Simple tasks get lightweight process; critical systems get formal verification. High-risk projects cannot use Minimal depth. Depth is determined by request clarity, problem complexity, scope, risk, available context, and user preferences. |
| **Rigor Level** | The risk-based setting (Low/Medium/High) that controls process depth. Set per unit in the execution plan's rigor levels table. Low risk = spot checks and broad bolts. Medium risk = standard verification. High risk = fine-grained bolts with comprehensive verification. See also: *Adaptive Depth*. |
| **Structured Questions** | Clarifying questions written to `.md` files during elaboration and planning stages. Format: multiple-choice with `[Answer]:` tags, always including an "Other" option. Questions go in `questions/` directories. See also: *Question Format Guide*, *Contradiction Detection*. |
| **Contradiction Detection** | Mandatory analysis of user responses to structured questions before proceeding. Checks for logically inconsistent answers, ambiguous responses ("depends", "maybe"), and answers that conflict with existing artifacts. If contradictions are found, clarification questions are created. |
| **Overconfidence Prevention** | Cross-cutting rule requiring agents to default to asking rather than assuming. When uncertain about requirements, ASK. When multiple approaches exist, PRESENT OPTIONS. Never fill in blanks, never skip question categories without justification. |
| **Golden Thread** | Continuous bidirectional traceability from Intent through Requirements through Units through Code to Deployment. Every requirement traces forward to units, and every unit traces back to requirements. Established during inception and maintained throughout. See also: *Traceability*. |
| **Traceability** | The specific mapping between artifacts in the Golden Thread. Requirements map to units via REQ-IDs. Stories map to requirements via STORY-IDs. Units map to bolts via bolt plans. Each level references the layer above and below. |
| **Proof Over Prose** | Principle (P1) that "done" requires objective evidence (passing tests, measurable outcomes), not textual claims. Every requirement must have a testable description. Every task must have a `<verify>` with an objective check. |
| **Reverse Conversation** | Principle (P2) that AI proposes and humans approve, inverting the traditional workflow. For every artifact, the agent proposes a complete draft first; the user refines. Never present a blank template for the user to fill in. |
| **Content Validation** | Rules for validating generated content before writing to files. Covers ASCII diagram standards (using only `+` `-` `|` characters, no Unicode box-drawing), text alternatives for visual content, and structural consistency. |
| **Audit Trail** | Append-only decision log (`audit.md`). Records inception decisions, gate approvals/rejections, planning choices, execution deviations, errors, and recoveries with timestamps and evidence links. |
| **State** | The project tracking file (`state.md`). Records current position (phase, unit, bolt), accumulated decisions, blockers/concerns, session continuity information, and gate status. |
| **Adaptive Stages** | Stages that are conditionally executed based on project characteristics. Some stages are ALWAYS executed (e.g., requirements, execution plan, code generation), while others are CONDITIONAL (e.g., user stories, application design, NFR requirements). The agent detects which stages to run based on project type and complexity signals. |
| **Conditional Stages** | Synonym for stages that may be skipped based on project type. Examples: User Stories (skipped for CLIs), Application Design (skipped for single-component projects), NFR Requirements (skipped for simple units). The skip/execute decision is logged to audit.md. |
| **INVEST** | Validation criteria for user stories: Independent, Negotiable, Valuable, Estimable, Small, Testable. All stories must pass INVEST validation before being presented to the user. |

---

## Architecture Terms

| Term | Definition |
|------|-----------|
| **Multi-Agent** | The AI-SDLC architecture where specialized agents are spawned by orchestrator commands. Each agent has a focused role, dedicated tools, and fresh context. Orchestrators manage agent lifecycle and data flow between agents. |
| **Inception Agent** | Agent (`sdlc-inception`) that adaptively determines and executes needed inception stages. Spawned by the `elaborate` command. Produces all inception artifacts end-to-end. |
| **Bolt Planner** | Agent (`sdlc-bolt-planner`) that decomposes units into parallel-optimized bolts with task breakdown, dependency analysis, and goal-backward verification. Spawned by the `plan-unit` command. |
| **Bolt Executor** | Agent (`sdlc-bolt-executor`) that executes bolt plans atomically, creating per-task commits, handling deviations, pausing at checkpoints, and producing bolt summaries. Spawned by the `build-unit` command. |
| **Unit Verifier** | Agent (`sdlc-unit-verifier`) that verifies goal achievement through goal-backward analysis. Checks that the codebase delivers what the unit promised, not just that tasks completed. Creates the verification report. |
| **Gate Checker** | Agent (`sdlc-gate-checker`) that validates gate prerequisites. Checks artifact existence, completeness, and basic quality indicators. Read-only — never modifies files. Fast and deterministic. |
| **Plan Checker** | Agent (`sdlc-plan-checker`) that verifies plans will achieve the goal before execution. Checks requirement coverage, task completeness, dependency correctness, key links, scope sanity, and must-haves derivation. |
| **Research Synthesizer** | Agent (`sdlc-research-synthesizer`) that synthesizes research outputs into a cohesive summary. Reads research files and produces roadmap implications with confidence levels. |
| **Codebase Mapper** | Agent (`sdlc-codebase-mapper`) that explores an existing codebase and writes structured analysis documents (STACK.md, ARCHITECTURE.md, CONVENTIONS.md, etc.) for consumption by other agents. |
| **Integration Checker** | Agent (`sdlc-integration-checker`) that verifies cross-unit integration and end-to-end flows. Checks that units work together as a system, not just individually. |
| **Debugger** | Agent (`sdlc-debugger`) that systematically diagnoses and fixes issues using structured debugging methodology. |
| **Goal-Backward Methodology** | Planning and verification approach that starts from the desired outcome and works backwards. Derives observable truths (what must be TRUE), required artifacts (what must EXIST), required wiring (what must be CONNECTED), and key links (where things are most likely to break). Used by the bolt planner and unit verifier. |
| **Bounded Context** | A DDD (Domain-Driven Design) concept — a self-contained domain area that owns its data and logic. Units are derived from bounded contexts during inception. |
| **Orchestrator** | A command file (e.g., `elaborate.md`, `plan-unit.md`, `build-unit.md`) that coordinates agent spawning, context passing, and result handling. Orchestrators manage the workflow; agents do the work. |

---

## File and Path Conventions

| Term | Definition |
|------|-----------|
| **`.aidlc/` Directory** | The project's AI-SDLC working directory. Contains all planning, execution, and tracking artifacts. Structure: `inception/` (inception artifacts), `construction/` (per-unit construction artifacts), `codebase/` (codebase analysis), and root-level files (`state.md`, `audit.md`, `config.json`, `execution-plan.md`). |
| **Unit Numbering** | Units are identified as `UNIT-NNN` with zero-padded three-digit numbers (e.g., `UNIT-001`, `UNIT-002`). Unit specs live in `.aidlc/inception/units/UNIT-NNN.md`. Construction artifacts live in `.aidlc/construction/unit-NNN/`. |
| **Bolt Numbering** | Bolts within a unit are numbered sequentially with zero-padded two-digit numbers. Files follow the pattern `bolt-NN-plan.md` and `bolt-NN-summary.md` (e.g., `bolt-01-plan.md`, `bolt-02-summary.md`). |
| **Question File Locations** | Inception questions: `.aidlc/inception/questions/{stage}-questions.md`. Construction questions: `.aidlc/construction/unit-NNN/questions/planning-questions.md`. Clarification follow-ups: `{stage}-clarification-questions.md` in the same directory. |
| **Construction Directory** | Per-unit construction directory at `.aidlc/construction/unit-NNN/`. Contains bolt plans, bolt summaries, verification reports, test instructions, research, design, NFR artifacts, infrastructure design, and questions. |
| **Inception Directory** | All inception artifacts live under `.aidlc/inception/`. Contains `requirements.md`, `user-stories.md`, `application-design.md`, `research/`, `questions/`, and `units/`. |
| **Config File** | Project configuration at `.aidlc/config.json`. Controls settings like `commit_docs` (whether planning docs are git-committed), `depth` (default depth level), `model_profile` (quality/balanced/budget), and workflow toggles (`research`, `plan_check`). |

---

## Common Abbreviations

| Abbreviation | Meaning |
|-------------|---------|
| **AI-SDLC** | AI-Driven Software Development Lifecycle |
| **DDD** | Domain-Driven Design |
| **NFR** | Non-Functional Requirement |
| **REQ-ID** | Requirement Identifier (e.g., `AUTH-01`, `DATA-02`) |
| **TDD** | Test-Driven Development (red-green-refactor cycle) |
| **UAT** | User Acceptance Testing |
| **IaC** | Infrastructure as Code |
| **MCP** | Model Context Protocol |
| **SLO** | Service Level Objective |
| **PO** | Product Owner |

---

*Reference this file in agent prompts as:*
```
@__SDLC_REFS__/terminology.md
```
