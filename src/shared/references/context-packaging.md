# Context Supply Chain

AI agents are only as good as the context they receive. This reference defines how to structure and package project context so AI tools can consume it effectively.

## Principles
1. **Right context, right time** — Don't dump everything. Each phase needs different context
2. **Freshness over volume** — Recent, relevant files beat comprehensive archives
3. **Structure enables retrieval** — Consistent naming and paths let agents find what they need
4. **Budget-aware** — Context windows are finite. Prioritise high-value files

## Context by Phase

### Inception Context
Priority files for AI during inception:
1. `intent.md` — what we're building and why
2. Existing codebase map (brownfield) or tech stack decision (greenfield)
3. `requirements.md` (as it develops)
4. `research/` outputs
5. Domain glossary or business rules (if available)

### Construction Context
Priority files for AI during bolt execution:
1. Current bolt plan (`bolt-NN-plan.md`)
2. Unit design (`design.md`)
3. Relevant source files (only those being modified)
4. Test files for modified code
5. `guardrails.md` — what NOT to do
6. Previous bolt summaries (for continuity)

### Operations Context
Priority files for AI during operations:
1. Full `validation-report.md`
2. Deployment configuration files
3. Infrastructure definitions
4. `requirements.md` (for acceptance verification)

## Repo Packaging Standard

### .aidlc/ is the Context Root
All AI-consumable project context lives under `.aidlc/`. This directory is the single source of truth that AI agents reference. Nothing outside `.aidlc/` is methodology context (code and config are separate).

### Context File Sizing
- Individual context files: target < 5KB each
- If a file exceeds 10KB, split it (AI retention degrades with length)
- Exception: `execution-plan.md` may be larger for complex projects

### CONTEXT.md Convention
Each unit MAY include a `CONTEXT.md` file that lists:
- Which source files this unit touches
- Key decisions from design that affect implementation
- Constraints or gotchas the AI should know
- Links to relevant documentation

This file is the "briefing packet" for the AI starting a bolt.

### Multi-Tool Compatibility
The `.aidlc/` structure works with any AI coding tool:
- **Claude Code:** Reads files directly via tool calls
- **Cursor:** Reads via .cursorrules agent instructions
- **Other tools:** Standard markdown files, no tool-specific format
