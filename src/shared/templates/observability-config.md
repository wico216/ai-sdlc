# Observability Configuration

> Template for the Operations phase. Defines logging, metrics, alerting, and tracing.
> Traces to: operations/deployment-plan.md, operations/runbooks/

## Overview

- **Project:** {project name}
- **Environments:** {dev / staging / production}
- **Stack:** {observability tools in use}

## Logging

### Log Levels

| Level | When to Use | Example |
|---|---|---|
| ERROR | Unrecoverable failures, requires attention | Database connection lost |
| WARN | Recoverable issues, potential problems | Retry succeeded after failure |
| INFO | Key business events, state transitions | User created, order placed |
| DEBUG | Detailed flow for troubleshooting (not in prod) | Request payload, query params |

### Log Format

```json
{
  "timestamp": "ISO-8601",
  "level": "INFO",
  "service": "{service-name}",
  "message": "{human-readable message}",
  "trace_id": "{distributed trace ID}",
  "context": {}
}
```

### Log Destinations

| Environment | Destination | Retention |
|---|---|---|
| Development | stdout | Session |
| Staging | {log service} | 7 days |
| Production | {log service} | 30 days |

## Metrics

### Key Metrics to Track

| Metric | Type | Description | Alert Threshold |
|---|---|---|---|
| `request_duration_ms` | Histogram | API response time | p95 > 500ms |
| `request_count` | Counter | Total requests | - |
| `error_rate` | Gauge | Errors / total requests | > 1% |
| `active_connections` | Gauge | Current connections | > 80% capacity |
| {custom_metric} | {type} | {description} | {threshold} |

### Dashboards

| Dashboard | Purpose | URL |
|---|---|---|
| Overview | Service health at a glance | {url} |
| Performance | Latency, throughput, errors | {url} |
| Business | Key business metrics | {url} |

## Alerting

### Alert Rules

| Alert | Condition | Severity | Action |
|---|---|---|---|
| High Error Rate | error_rate > 5% for 5 min | P1 | Page on-call, see runbook: incident-response |
| Slow Response | p95 latency > 1s for 10 min | P2 | Notify team, see runbook: scaling |
| Service Down | health check fails 3x | P1 | Page on-call, see runbook: incident-response |
| Disk Usage High | disk > 85% | P3 | Notify team, see runbook: maintenance |
| {custom_alert} | {condition} | {severity} | {action + runbook link} |

### Notification Channels

| Channel | Used For | Recipients |
|---|---|---|
| {Slack/PagerDuty/Email} | P1-P2 alerts | {team/person} |
| {Email/Slack} | P3-P4 alerts | {team/person} |

## Tracing

### Distributed Tracing

- **Tool:** {Jaeger / Zipkin / OpenTelemetry / Datadog / etc.}
- **Sampling rate:** {production: 1-10%, staging: 100%}
- **Propagation:** {W3C Trace Context / B3 / etc.}

### Key Spans to Instrument

| Span | Service | Purpose |
|---|---|---|
| HTTP request | API gateway | Track incoming requests |
| Database query | Data layer | Track query performance |
| External API call | Integration layer | Track third-party latency |
| {custom_span} | {service} | {purpose} |

## Health Checks

### Endpoints

| Endpoint | Purpose | Expected Response |
|---|---|---|
| `/health` | Basic liveness | 200 OK |
| `/ready` | Readiness (dependencies up) | 200 OK with dependency status |

### Dependencies Checked

| Dependency | Check Method | Timeout |
|---|---|---|
| Database | Connection ping | 3s |
| Cache | Key read | 1s |
| {external service} | {check method} | {timeout} |
