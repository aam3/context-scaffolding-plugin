---
name: create-reference-catalog
description: Scans .claude/_reference/ recursively, builds a catalog table for CLAUDE.md
disable-model-invocation: true
---

# Create Reference Catalog

Scans `.claude/_reference/` and builds a lookup table that tells Claude when to consult each reference file. The table is inserted into CLAUDE.md's Reference Documentation section by the create-claudemd skill.

---

## When Activated

Called by `/system:init`. Can also be run standalone to rebuild the catalog after adding new reference files.

---

## Flow

### 1. Scan for reference files

Recursively find all `.md` files in `.claude/_reference/`, including subdirectories.

If no `.md` files exist, stop here — return nothing. No catalog to build.

### 2. Extract metadata from each file

For each file, check for YAML frontmatter with this schema:

```yaml
---
topic: [display name for the catalog table]
last_synced: [YYYY-MM-DD — when the file was created or last updated]
description: [what the file covers — becomes the Description column in the catalog]
---
```

**If frontmatter is present and complete:** extract all three fields.

**If frontmatter is missing or incomplete:** collaborate with the user:
- Read the file's title (first `#` heading) and opening content.
- Suggest a topic, description, and today's date for last_synced based on what you see.
- Present the suggestion to the user for confirmation or editing.
- After the user confirms, write the frontmatter to the top of the file so it's present for future runs.

### 3. Build the catalog table

Assemble the table using this exact format:

```markdown
## Reference Documentation

Before answering questions or making decisions about the topics below, check the
corresponding reference file in `.claude/_reference/`. Read the file before
proceeding rather than relying on training knowledge, as these contain
project-specific conventions and up-to-date details.

| Topic | File | Description |
|-------|------|-------------|
| Hooks system | `_reference/hooks-reference.md` | How hooks work — configuration, script placement, event types |
| ... | ... | ... |

If a question touches on any of these topics, read the relevant file first.
If unsure whether a reference exists, list the contents of `.claude/_reference/`.
```

**File paths** in the table are relative to `.claude/` (e.g., `_reference/hooks-reference.md`, `_reference/plugins/plugin-system.md`).

**Sort order:** alphabetical by topic.

### 4. Return the table

Return the assembled table content. Do **not** write CLAUDE.md — that's create-claudemd's responsibility. The table is passed to create-claudemd for insertion.

---

## Edge Cases

- **`_reference/` is empty or missing:** return nothing silently. No error.
- **`_reference/` has subdirectories:** include files from all levels. Use relative paths from `.claude/` in the File column (e.g., `_reference/plugins/plugin-system.md`).
- **File has frontmatter but missing fields:** prompt user for the missing fields specifically. Don't discard the fields that are present.
- **Non-markdown files in `_reference/`:** ignore them. Only process `.md` files.
