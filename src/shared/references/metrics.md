# Delivery Metrics

Measurement makes AI-SDLC accountable. Without metrics, you can't prove the methodology works or identify where it breaks.

## Standard Metrics (Minimum — track from day 1)

| Metric | What to measure | How | Target |
|--------|----------------|-----|--------|
| **Bolt cycle time** | Time from bolt plan approval to PR merged | Timestamps in audit.md | Decreasing over time |
| **Gate pass rate** | % of gates passed on first attempt | Gate checker results in audit.md | > 80% |
| **Rework ratio** | Bolts requiring re-plan or re-build / total bolts | audit.md entries | < 15% |
| **Defect escape rate** | Bugs found after unit approval / total bugs | Post-release tracking | < 10% |
| **Evidence completeness** | % of gate evidence at "Wired" or "Functional" level | Verification pattern level | > 90% |

## Engineering Metrics (Recommended — add when stable)

| Metric | What to measure | Target |
|--------|----------------|--------|
| **PR size** | Average lines changed per PR | < 400 |
| **Review turnaround** | Time from PR opened to first review | < 4 hours |
| **AI accuracy** | % of AI-generated code accepted without modification | Track trend, not target |
| **Context utilisation** | Average % of context window used per bolt | 30-60% sweet spot |
| **Cost per unit** | Token/API cost per completed unit | Decreasing per unit of value |

## How to Track

### Option 1: Audit Trail (built-in)
The `audit.md` file already captures gate decisions with timestamps. Add these fields to each entry:
- `cycle_time_hours:` — time from start to gate pass
- `attempt:` — 1 for first-pass, 2+ for rework
- `evidence_level:` — Exists/Substantive/Wired/Functional

### Option 2: Retro Aggregation
During Guardrail Retro (`/sdlc:retro`), compute metrics from the audit trail. The retro output should include a metrics summary section.

### Option 3: External Dashboard
Export audit.md data to your team's dashboard tool. The structured format makes this straightforward.

## What NOT to Measure
- Lines of code (AI makes this meaningless)
- Commits per day (gaming metric)
- Hours worked (measure outcomes, not presence)
- "AI vs human" contribution % (counterproductive framing)

## When to Review
- **Per unit:** Quick metrics check during unit approval gate
- **Per project:** Full metrics review during Guardrail Retro
- **Per quarter:** Trend analysis across projects (if doing multiple)
