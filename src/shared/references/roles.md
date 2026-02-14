# AI-SDLC Roles

> Who does what and who approves which gate. Roles can overlap — on small teams, one person may hold multiple roles.

## Role Definitions

### Product Owner (PO)

**Owns:** Requirements scope, success criteria, business priorities
**Approves:** Requirements Approved gate, INCEPTION EXIT gate
**Key actions:**
- Defines what's in v1 vs. v2 vs. out-of-scope
- Reviews intent document and requirements
- Accepts or rejects unit decomposition
- Approves scope changes (logged in audit trail)

### Technical Lead (Tech Lead)

**Owns:** Architecture decisions, design patterns, technical standards
**Approves:** Design Approved gate (per unit)
**Key actions:**
- Reviews unit design documents (architecture, data models, interfaces)
- Ensures no conflicts between units
- Makes technical decisions logged in audit trail
- Identifies technical risks for the risk register

### Engineer

**Owns:** Implementation, tests, code quality
**Approves:** N/A (executes, doesn't gate)
**Key actions:**
- Executes bolts (plan → build → test)
- Works with AI on code generation and review
- Runs `/sdlc:bolt` and validates AI output
- Reports deviations and blockers

### QA / Reviewer

**Owns:** Verification, acceptance criteria validation
**Approves:** UNIT COMPLETE gate
**Key actions:**
- Validates acceptance criteria are met with evidence
- Runs `/sdlc:verify-work` for UAT
- Reviews test coverage and edge cases
- Ensures no regressions across units

### Operations / DevOps

**Owns:** Deployment, infrastructure, monitoring
**Approves:** PRODUCTION READY gate
**Key actions:**
- Reviews deployment plan and rollback procedures
- Validates runbooks and observability config
- Ensures environment configuration is correct
- Tests rollback procedure before production

### Security (if applicable)

**Owns:** Security controls, compliance
**Approves:** Contributes to PRODUCTION READY gate
**Key actions:**
- Reviews risk register for security items
- Validates security controls in deployment plan
- Reviews authentication/authorization patterns in design

## Role-to-Gate Mapping

| Gate | Primary Approver | Secondary Reviewer |
|------|-----------------|-------------------|
| Requirements Approved | Product Owner | Tech Lead |
| INCEPTION EXIT | Product Owner | Tech Lead, QA |
| Design Approved | Tech Lead | Engineer |
| UNIT COMPLETE | QA / Reviewer | Tech Lead |
| PRODUCTION READY | Operations | Security, Tech Lead |

## AI Facilitator

The AI agent is not a role that approves gates. It is a tool that:
- **Proposes** plans, designs, code, and documentation
- **Executes** bolt plans under human supervision
- **Analyzes** risks, audit trails, and verification results
- **Never** auto-approves gates or makes scope decisions

The human is always accountable. AI does the heavy lifting, humans make the judgment calls.

## Small Teams

On small teams (1-3 people), roles naturally overlap:

| Team Size | Typical Role Mapping |
|-----------|---------------------|
| Solo developer | One person holds all roles. All gates still require conscious approval — don't rubber-stamp. |
| 2 people | PO + Tech Lead on one person, Engineer + QA on the other. Cross-review at gates. |
| 3 people | PO, Tech Lead/Engineer, QA/Ops. Each gate has a different approver. |

The gates exist regardless of team size. The point is conscious human review with evidence, not ceremony.
