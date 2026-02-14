# Contributing to AI-SDLC

## What is AI-SDLC?

AI-SDLC is an AI-native software development lifecycle framework for Claude Code. It implements the [AI-SDLC methodology](https://ai-sdlc-explainer.vercel.app/) — three phases (Inception, Construction, Operations) with evidence-based gates, a Golden Thread for traceability, and an append-only audit trail.

## Repository Structure

```
ai-sdlc/
├── src/
│   ├── agents/          # 11 specialized AI agents (.md)
│   ├── commands/        # User-facing /sdlc:* commands (.md)
│   ├── hooks/           # Statusline + update checker (.js)
│   ├── references/      # Methodology guidance (principles, gates, roles, rituals)
│   ├── templates/       # Artifact templates (unit, intent, audit, etc.)
│   └── workflows/       # Internal workflow orchestration
├── install.sh           # Installer (bash, no npm)
├── README.md
└── CONTRIBUTING.md
```

## How Commands Work

Commands are markdown files with YAML frontmatter and structured sections:

```markdown
---
name: sdlc:command-name
description: What this command does
allowed-tools:
  - Read
  - Write
  - Bash
---

<objective>
What the command achieves.
</objective>

<execution_context>
@__SDLC_HOME__/references/file.md
</execution_context>

<process>
Step-by-step instructions for the AI agent.
</process>

<success_criteria>
- [ ] What must be true when done
</success_criteria>
```

- `__SDLC_HOME__` is replaced with the actual install path by `install.sh`
- `__CLAUDE_HOME__` is replaced with `~/.claude`
- Commands reference templates and agents via these placeholders

## Key Methodology Concepts

Before contributing, understand these core concepts:

| Concept | What it means |
|---------|---------------|
| **Golden Thread** | Every artifact traces back: Intent → Requirements → Units → Code → Deployment |
| **Gates** | 5 human approval checkpoints with evidence requirements. AI never auto-approves. |
| **Bolts** | The smallest iteration. Hours to days, not weeks. Replaces Sprints. |
| **Units** | Parallel-deliverable work chunks aligned to DDD bounded contexts. |
| **Audit Trail** | Append-only decision log. Never deleted, never modified. |

See `src/references/principles.md` for the 10 principles and `src/references/gates.md` for gate definitions.

## Contributing Guidelines

### Adding a New Command

1. Create `src/commands/your-command.md` following the command format above
2. Add the command to `src/commands/help.md` in the appropriate section
3. If the command produces new artifact types, create templates in `src/templates/`
4. If the command references methodology concepts, link to `src/references/`
5. Test the command by installing locally (`./install.sh`) and running it in Claude Code

### Modifying an Agent

Agents are in `src/agents/sdlc-*.md`. They are spawned by commands via the Task tool. Key agents:

- `sdlc-planner` — Creates execution plans
- `sdlc-executor` — Executes plans
- `sdlc-verifier` — Verifies work against goals
- `sdlc-plan-checker` — Validates plans before execution

When modifying agents, preserve:
- Context fidelity patterns (CONTEXT.md respect in planner, plan-checker, phase-researcher, executor)
- Goal-backward verification (verifier checks what must be TRUE, not what was done)
- Wave-based parallel execution (executor groups plans by dependency)

### Adding a Reference

References in `src/references/` are loaded into agent context via `@__SDLC_HOME__/references/file.md`. Keep them concise — every line costs context window tokens.

### Stack Agnosticism

AI-SDLC must remain stack-agnostic. Do not add:
- Technology-specific code or configurations
- Framework-specific templates
- Language-specific patterns

Commands and templates should work for any tech stack. Stack-specific knowledge is discovered per-project via research agents.

## Testing Changes

1. Run `./install.sh` to install your changes
2. Open a test project directory in Claude Code
3. Run the commands you modified
4. Verify artifacts are created correctly
5. Check that the Golden Thread is maintained (traces intact)

## Submitting Changes

1. Fork the repository
2. Create a branch for your change
3. Make your changes following the guidelines above
4. Test locally
5. Submit a pull request with:
   - What you changed and why
   - Which AI-SDLC concepts are affected
   - How you tested it
