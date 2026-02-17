# ASCII Diagram Standards

## Rule: Use Basic ASCII Only

**ALWAYS use basic ASCII characters for diagrams (maximum compatibility).**

### Allowed: `+` `-` `|` `^` `v` `<` `>` and alphanumeric text

### Forbidden: Unicode box-drawing characters
- NO: `┌` `─` `│` `└` `┐` `┘` `├` `┤` `┬` `┴` `┼` `▼` `▲` `►` `◄`
- Reason: Inconsistent rendering across terminals, fonts, and platforms

---

## Critical: Character Width Rule

**Every line in a box MUST have EXACTLY the same character count (including spaces).**

Correct (all lines same width):
```
+-----------------------------------------------+
|              Component Name                   |
|  Description text here                        |
+-----------------------------------------------+
```

Wrong (inconsistent widths):
```
+-----------------------------------------------+
|              Component Name                   |
|  Description text here                   |
+-----------------------------------------------+
```

---

## Standard Patterns

### Box
```
+---------------------------------------------+
|                                             |
|           Calculator Application            |
|                                             |
|  Provides basic arithmetic operations       |
|  through a web-based interface              |
|                                             |
+---------------------------------------------+
```

### Nested Boxes
```
+---------------------------------------------------+
|            Web Server (PHP Runtime)               |
|  +---------------------------------------------+  |
|  |  index.php (Monolithic Application)         |  |
|  |  +---------------------------------------+  |  |
|  |  |  HTML Template (View Layer)           |  |  |
|  |  |  - Form rendering                     |  |  |
|  |  |  - Result display                     |  |  |
|  |  +---------------------------------------+  |  |
|  +---------------------------------------------+  |
+---------------------------------------------------+
```

### Arrows and Connections
```
+----------+
|  Source  |
+----------+
     |
     | HTTP POST
     v
+----------+
|  Target  |
+----------+
```

### Horizontal Flow
```
+-------+     +-------+     +-------+
| Step1 | --> | Step2 | --> | Step3 |
+-------+     +-------+     +-------+
```

### Vertical Flow with Labels
```
User Action Flow:
    |
    v
+----------+
|  Input   |
+----------+
    |
    | validates
    v
+----------+
| Process  |
+----------+
    |
    | returns
    v
+----------+
|  Output  |
+----------+
```

---

## Validation Checklist

Before creating diagrams:

- [ ] Basic ASCII only: `+` `-` `|` `^` `v` `<` `>`
- [ ] No Unicode box-drawing characters
- [ ] Spaces (not tabs) for alignment
- [ ] Corners use `+`
- [ ] ALL box lines same character width (count characters including spaces)
- [ ] Verify corners align vertically in monospace font

## Alternative

For complex diagrams where ASCII is insufficient, use Mermaid (see `content-validation.md` for Mermaid validation rules).
