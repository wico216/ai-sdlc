# Deployment Plan

> Template for the Operations phase. AI fills this in based on project context.
> Traces to: All UNIT-IDs, risk-register.md

## Project

- **Project:** {project name}
- **Version:** {version being deployed}
- **Date:** {target deployment date}
- **Owner:** {deployment owner}

## Deployment Strategy

- **Type:** {rolling / blue-green / canary / recreate / manual}
- **Rollback approach:** {how to revert if deployment fails}
- **Downtime expected:** {yes/no, duration if yes}

## Pre-Deployment Checklist

| # | Check | Status | Evidence |
|---|---|---|---|
| 1 | All unit tests passing | {pass/fail} | {link to test output} |
| 2 | All acceptance criteria verified | {pass/fail} | {link to validation-report.md} |
| 3 | No critical risks unmitigated | {pass/fail} | {link to inception/risk-register.md} |
| 4 | Environment configuration ready | {pass/fail} | {description} |
| 5 | Database migrations tested | {pass/fail/N-A} | {description} |
| 6 | Rollback procedure tested | {pass/fail} | {description} |
| 7 | Monitoring/alerting configured | {pass/fail} | {link to observability.md} |

## Environment Configuration

### Required Environment Variables

| Variable | Description | Example | Secret? |
|---|---|---|---|
| {VAR_NAME} | {what it does} | {example value} | {yes/no} |

### Infrastructure Requirements

- **Compute:** {instances, sizing}
- **Database:** {type, version, sizing}
- **Storage:** {requirements}
- **Network:** {DNS, load balancer, firewall rules}

## Deployment Steps

### 1. Pre-Deployment

```bash
# Step-by-step commands to prepare
```

### 2. Deploy

```bash
# Step-by-step deployment commands
```

### 3. Post-Deployment Verification

```bash
# Health checks and smoke tests
```

### 4. Rollback Procedure

```bash
# Step-by-step rollback if needed
```

**Rollback triggers:**
- {condition that triggers rollback}
- {condition that triggers rollback}

## Dependencies

| Dependency | Version | Required By | Notes |
|---|---|---|---|
| {service/library} | {version} | {which unit} | {notes} |

## Risk Mitigation

| Risk | Mitigation | Owner |
|---|---|---|
| {deployment risk from risk-register} | {specific mitigation for deployment} | {who handles it} |

## Sign-Off

| Role | Name | Approved | Date |
|---|---|---|---|
| Developer | | | |
| Reviewer | | | |
| Ops | | | |
