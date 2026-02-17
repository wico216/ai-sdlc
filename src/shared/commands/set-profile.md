---
name: set-profile
description: Switch model profile for AI-SDLC agents (quality/balanced/budget)
arguments:
  - name: profile
    description: "Profile name: quality, balanced, or budget"
    required: true
---

<objective>
Switch the model profile used by AI-SDLC agents. This controls which Claude model each agent uses, balancing quality vs token spend.
</objective>

<profiles>
| Profile | Description |
|---------|-------------|
| **quality** | Opus everywhere except read-only verification |
| **balanced** | Opus for planning, Sonnet for execution/verification (default) |
| **budget** | Sonnet for writing, Haiku for research/verification |
</profiles>

<process>

## 1. Validate argument

```
if __ARGUMENTS__.profile not in ["quality", "balanced", "budget"]:
  Error: Invalid profile "__ARGUMENTS__.profile"
  Valid profiles: quality, balanced, budget
  STOP
```

## 2. Check for project

```bash
ls .aidlc/config.json 2>/dev/null
```

If no `.aidlc/` directory:
```
Error: No AI-SDLC project found.
Run __CMD_PREFIX__new-project first to initialize a project.
```

## 3. Update config.json

Read current config:
```bash
cat .aidlc/config.json
```

Update `model_profile` field (or add if missing):
```json
{
  "model_profile": "__ARGUMENTS__.profile"
}
```

Write updated config back to `.aidlc/config.json`.

## 4. Confirm

```
✓ Model profile set to: __ARGUMENTS__.profile

Agents will now use:
[Show table from model-profiles.md for selected profile]

Next spawned agents will use the new profile.
```

</process>

<examples>

**Switch to budget mode:**
```
__CMD_PREFIX__set-profile budget

✓ Model profile set to: budget

Agents will now use:
| Agent | Model |
|-------|-------|
| sdlc-bolt-planner | sonnet |
| sdlc-bolt-executor | sonnet |
| sdlc-unit-verifier | haiku |
| ... | ... |
```

**Switch to quality mode:**
```
__CMD_PREFIX__set-profile quality

✓ Model profile set to: quality

Agents will now use:
| Agent | Model |
|-------|-------|
| sdlc-bolt-planner | opus |
| sdlc-bolt-executor | opus |
| sdlc-unit-verifier | sonnet |
| ... | ... |
```

</examples>
