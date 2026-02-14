# AI-SDLC Glossary

| Term | Definition |
|------|-----------|
| **Acceptance Criteria** | Testable conditions that must be met for a unit to pass the UNIT COMPLETE gate |
| **Adaptive Depth** | Principle that rigor scales to risk level — simple tasks get light process, critical systems get formal verification |
| **AI Facilitator** | Role that maintains prompts, rules, and guardrails as code; orchestrates Mob sessions |
| **Application Design** | Technical design document for a unit, covering data model, APIs, and integration points |
| **Bolt** | Smallest iteration unit (hours to days); replaces Sprint |
| **Bounded Context** | DDD concept — a self-contained domain area that owns its data and logic |
| **Brownfield** | Existing codebase being modified or extended |
| **Build and Test** | Construction sub-phase where code is written and validated against acceptance criteria |
| **Construction** | Phase 2 — HOW. Design, build, and validate units via Bolts |
| **Context Rot** | AI quality degradation as context window fills with irrelevant information |
| **Cost Estimate** | Document tracking AI token usage, infrastructure, and human time costs |
| **Design Approved** | Gate 3 — Technical Lead approves unit design before implementation begins |
| **Domain Design** | Construction sub-phase for unit architecture (also called Functional Design) |
| **Gate** | Human approval checkpoint requiring evidence. 5 gates in AI-SDLC |
| **Golden Thread** | Continuous traceability: Intent → Requirements → Units → Code → Deployment |
| **Greenfield** | New project with no existing codebase |
| **Guardrail Retro** | Post-unit review to improve AI collaboration rules and prompt effectiveness |
| **IaC** | Infrastructure as Code — managing infrastructure through version-controlled definitions |
| **Inception** | Phase 1 — WHAT + WHY. Convert intent into testable, decomposed work |
| **INCEPTION EXIT** | Gate 2 — confirms all units decomposed, roadmap approved, risks identified |
| **Intent** | High-level statement of business purpose that starts the lifecycle |
| **MCP** | Model Context Protocol — standard for connecting AI models to external tools and data |
| **Mob Construction** | Collaborative ritual for delivering Bolts with driver rotation (AI generates, humans validate) |
| **Mob Elaboration** | Collaborative ritual to convert intent into requirements and units with stakeholders |
| **NFR** | Non-Functional Requirement — performance, security, scalability, availability constraints |
| **NFR Design** | Construction sub-phase addressing cross-cutting non-functional requirements |
| **Operations** | Phase 3 — WHERE/WHEN. Deployment, observability, reliability |
| **Product Engineer** | Collapsed role: Dev + Ops + QA in one person, enabled by AI assistance |
| **PRODUCTION READY** | Gate 5 — Operations approves deployment readiness (runbooks, observability, rollback) |
| **Proof Over Prose** | "Done" requires objective evidence (passing tests), not textual claims |
| **Ralph Loop** | Pattern of looping an AI agent until completion with objective success criteria |
| **Requirements Approved** | Gate 1 — Product Owner confirms requirements are clear, complete, and scoped |
| **Reverse Conversation** | AI proposes plans; Human approves. Inverted from traditional workflow |
| **Risk Register** | Document tracking identified risks, probability, impact, and mitigation strategies |
| **Rigor Level** | The risk-based setting (Low/Medium/High) that controls process depth via Adaptive Depth |
| **SLO** | Service Level Objective — target reliability metric (e.g., 99.9% uptime) |
| **Unit** | Parallel-deliverable work chunk aligned to DDD bounded contexts |
| **UNIT COMPLETE** | Gate 4 — QA/Reviewer confirms all acceptance criteria met with evidence |
| **Verification Report** | Document recording three-level verification results (existence, substantive, wired) |
