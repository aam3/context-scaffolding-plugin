---
name: update-dev-rules
description: Propagates approved dev-rules from session/learnings/dev-rules.md into the CLAUDE.md Development Rules section. Optionally refreshes the Reference Documentation table.
disable-model-invocation: true
---

# Update Dev Rules

Propagates discovered development rules from the learnings table into CLAUDE.md's Development Rules section. Lightweight, incremental — does not rebuild the full file (that's create-claudemd's job).

---

## When Activated

Called by the record-learnings skill after dev-rules entries are recorded. Can also be called standalone to propagate pending rules.

---

## Scope

This skill ONLY touches two sections of CLAUDE.md:

- `## Development Rules` — appends approved rules as bullets
- `## Reference Documentation` — optionally refreshes the catalog table

It does NOT touch Repo Structure, Coding Conventions, Session Management, or user-added sections. Those are create-claudemd's responsibility.

---

## Flow

### 1. Read CLAUDE.md

Read project root `CLAUDE.md`. Identify sections by their `##` headers. Locate the `## Development Rules` section.

### 2. Check for unpropagated dev-rules

Read `session/learnings/dev-rules.md`. Look for entries where `Updated` = `No`.

If no unpropagated entries exist, skip to step 5.

### 3. Present rules to user

For each unpropagated entry, show the user:
- **Rule** column value
- **Rationale** column value

Ask the user to approve or reject each rule for inclusion in CLAUDE.md.

### 4. Append approved rules

For each approved rule:
- Append it as a bullet (`- Rule text`) to the `## Development Rules` section of CLAUDE.md.
- If Development Rules has subsections (like `### Writing Style`), append the bullet to the main section body, before any subsections.
- Mark the entry `Updated: Yes` in `session/learnings/dev-rules.md`.

For rejected rules:
- Leave `Updated: No` in dev-rules.md. The rule stays available for future review.

### 5. Optionally refresh Reference Documentation

If the user indicates that reference files in `_reference/` have changed (new files added, descriptions updated), re-run the create-reference-catalog logic:
- Scan `_reference/` for `.md` files, extract frontmatter, rebuild the catalog table.
- Replace the `## Reference Documentation` section in CLAUDE.md with the updated table.

If no reference changes, skip this step.

---

## Edge Cases

- **No dev-rules.md file:** Nothing to propagate. Skip silently.
- **All entries already Updated: Yes:** Nothing to propagate. Skip silently.
- **CLAUDE.md missing:** Error — this should not happen after init. Warn user.
- **User rejects all rules:** No changes to CLAUDE.md. Entries stay `Updated: No` for future review.
