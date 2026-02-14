# Runbook: {Title}

> Template for operational runbooks. Create one per scenario.
> Common runbooks: incident-response, scaling, maintenance, backup-restore, monitoring-alerts

## Overview

- **Purpose:** {what this runbook covers}
- **Last updated:** {date}
- **Owner:** {team/person responsible}
- **Severity:** {P1-critical / P2-high / P3-medium / P4-low}

## When to Use

**Trigger conditions:**
- {specific condition or alert that triggers this runbook}
- {specific condition or alert that triggers this runbook}

**Symptoms:**
- {what the user/operator will observe}

## Prerequisites

- Access to: {systems, dashboards, tools needed}
- Permissions: {required access levels}

## Steps

### 1. Assess

```bash
# Commands to assess the situation
```

**Expected output:** {what you should see}
**If unexpected:** {what to do instead}

### 2. Act

```bash
# Commands to resolve the issue
```

**Expected output:** {what success looks like}

### 3. Verify

```bash
# Commands to confirm resolution
```

**Success criteria:**
- [ ] {check 1}
- [ ] {check 2}

## Escalation

| Condition | Escalate To | Contact |
|---|---|---|
| {when to escalate} | {team/person} | {how to reach them} |

**Escalation timeline:**
- 0-15 min: {first responder actions}
- 15-30 min: {escalate if unresolved}
- 30+ min: {management notification}

## Post-Incident

- [ ] Document what happened in incident log
- [ ] Update this runbook if steps were incorrect or missing
- [ ] Create follow-up tasks for permanent fixes
- [ ] Schedule post-mortem if P1/P2

## Related

- {link to other relevant runbooks}
- {link to monitoring dashboard}
- {link to architecture docs}
