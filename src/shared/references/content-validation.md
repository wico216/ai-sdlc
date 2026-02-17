# Content Validation Rules

## Purpose

All generated content MUST be validated before writing to files to prevent parsing errors, rendering issues, and inconsistencies.

---

## ASCII Diagram Standards

**Before creating ANY file with ASCII diagrams:**

1. **LOAD** `ascii-diagram-standards.md` rules
2. **VALIDATE** each diagram:
   - Count characters per line (all lines in a box MUST have same width)
   - Use ONLY: `+` `-` `|` `^` `v` `<` `>` and spaces
   - NO Unicode box-drawing characters (`┌` `─` `│` `└` etc.)
   - Spaces only (NO tabs)
3. **TEST** alignment by verifying box corners align vertically

See `ascii-diagram-standards.md` for patterns and validation checklist.

---

## Mermaid Diagram Validation

### Required Validation Steps

Before writing Mermaid diagrams to files:

1. **Syntax check:** Validate node IDs use only alphanumeric + underscore
2. **Character escaping:** Escape special characters in labels (`"` → `\"`)
3. **Connection validation:** Verify all node connections reference defined nodes
4. **Fallback content:** Always provide a text alternative alongside Mermaid

### Implementation Pattern

Always include both a Mermaid diagram and a text fallback:

```markdown
## Workflow Visualization

### Diagram
\```mermaid
[validated diagram content]
\```

### Text Alternative
Phase 1: INCEPTION
- Stage 1: Requirements Analysis (COMPLETED)
- Stage 2: User Stories (IN PROGRESS)
[continue with text representation]
```

### When Mermaid Validation Fails

1. Log the validation error
2. Use the text-based alternative instead
3. Continue workflow (don't block on diagram failures)
4. Inform user that a simplified representation was used

---

## Markdown Content Validation

### Pre-Creation Checklist

Before writing any artifact file:

- [ ] Embedded code blocks are properly fenced (``` with language identifier)
- [ ] Special characters are escaped where needed
- [ ] YAML frontmatter is valid (if present)
- [ ] Markdown syntax is correct (headers, lists, tables)
- [ ] No broken internal links (references to other artifacts)
- [ ] Fallback content exists for complex visual elements

### Table Validation

- Column counts must be consistent across all rows
- Header separator row must match column count
- No empty tables (at least header + one row or a "None" indicator)

### Code Block Validation

- Language identifier present on fenced blocks
- No nested triple-backtick fences (use indentation or different fence style)
- Closing fence present for every opening fence

---

## YAML Frontmatter Validation

For artifact files with YAML frontmatter:

1. Opening `---` on first line
2. Valid YAML syntax (proper indentation, correct types)
3. Closing `---` before content
4. Required fields present (varies by template)
5. Dates in ISO 8601 format
6. Arrays use consistent format (inline `[]` or block `-` items)

---

## Validation Failure Handling

### When Validation Fails

1. **Log the error** in audit.md with specifics
2. **Use fallback content** (text-based alternatives for diagrams, simplified structure for complex content)
3. **Continue workflow** — content validation failures should NOT block progress
4. **Inform user** — mention that simplified content was used due to validation constraints

### Error Prevention

1. Always validate before writing files
2. Escape special characters in generated content
3. Provide text alternatives for visual content
4. Test complex content structures (tables, diagrams, frontmatter) before committing
