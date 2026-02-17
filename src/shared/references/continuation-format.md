# Continuation Format

Standard format for presenting next steps after completing a command or workflow.

## Core Structure

```
---

## ▶ Next Up

**{identifier}: {name}** — {one-line description}

`{command to copy-paste}`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `{alternative option 1}` — description
- `{alternative option 2}` — description

---
```

## Format Rules

1. **Always show what it is** — name + description, never just a command path
2. **Pull context from source** — execution-plan.md for units, bolt-plan.md `<objective>` for bolts
3. **Command in inline code** — backticks, easy to copy-paste, renders as clickable link
4. **`/clear` explanation** — always include, keeps it concise but explains why
5. **"Also available" not "Other options"** — sounds more app-like
6. **Visual separators** — `---` above and below to make it stand out

## Variants

### Execute Next Bolt

```
---

## ▶ Next Up

**Bolt 02-03: Refresh Token Rotation** — Add /api/auth/refresh with sliding expiry

`__CMD_PREFIX__build-unit 002`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- Review bolt plan before executing

---
```

### Execute Final Bolt in Unit

Add note that this is the last bolt and what comes after:

```
---

## ▶ Next Up

**Bolt 02-03: Refresh Token Rotation** — Add /api/auth/refresh with sliding expiry
<sub>Final bolt in Unit 002</sub>

`__CMD_PREFIX__build-unit 002`

<sub>`/clear` first → fresh context window</sub>

---

**After this completes:**
- Unit 002 complete → Unit 003 next
- Next: **Unit 003: Core Features** — User dashboard and settings

---
```

### Plan a Unit

```
---

## ▶ Next Up

**Unit 002: Authentication** — JWT login flow with refresh tokens

`__CMD_PREFIX__plan-unit 002`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__elaborate` — gather context first
- Review execution plan

---
```

### Unit Complete, Ready for Next

Show completion status before next action:

```
---

## ✓ Unit 002 Complete

3/3 bolts executed

## ▶ Next Up

**Unit 003: Core Features** — User dashboard, settings, and data export

`__CMD_PREFIX__plan-unit 003`

<sub>`/clear` first → fresh context window</sub>

---

**Also available:**
- `__CMD_PREFIX__elaborate` — gather context first
- Review what Unit 002 built

---
```

### Multiple Equal Options

When there's no clear primary action:

```
---

## ▶ Next Up

**Unit 003: Core Features** — User dashboard, settings, and data export

**To plan directly:** `__CMD_PREFIX__plan-unit 003`

**To discuss context first:** `__CMD_PREFIX__elaborate`

<sub>`/clear` first → fresh context window</sub>

---
```

## Pulling Context

### For units (from execution-plan.md):

```markdown
### Unit 002: Authentication
**Goal**: JWT login flow with refresh tokens
```

Extract: `**Unit 002: Authentication** — JWT login flow with refresh tokens`

### For bolt plans (from execution-plan.md):

```markdown
Plans:
- [ ] 02-03: Add refresh token rotation
```

Or from PLAN.md `<objective>`:

```xml
<objective>
Add refresh token rotation with sliding expiry window.

Purpose: Extend session lifetime without compromising security.
</objective>
```

Extract: `**02-03: Refresh Token Rotation** — Add /api/auth/refresh with sliding expiry`

## Anti-Patterns

### Don't: Command-only (no context)

```
## To Continue

Run `/clear`, then paste:
__CMD_PREFIX__build-unit UNIT-002
```

User has no idea what the unit is about.

### Don't: Missing /clear explanation

```
`__CMD_PREFIX__plan-unit UNIT-003`

Run /clear first.
```

Doesn't explain why. User might skip it.

### Don't: "Other options" language

```
Other options:
- Review execution plan
```

Sounds like an afterthought. Use "Also available:" instead.

### Don't: Fenced code blocks for commands

```
```
__CMD_PREFIX__plan-unit UNIT-003
```
```

Fenced blocks inside templates create nesting ambiguity. Use inline backticks instead.
