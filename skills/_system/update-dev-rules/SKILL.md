---
name: update-dev-rules
description: Propagates approved dev-rules from session/learnings/dev-rules.md into CLAUDE.md's Development Rules section. Lightweight, incremental — does not rebuild the full file. Triggers on "propagate dev rules", "update CLAUDE.md rules", or when record-learnings needs rules pushed to CLAUDE.md. Do NOT use for full CLAUDE.md rebuilds — use create-claudemd instead.
user-invocable: false
---

# Update Dev Rules

Propagates discovered development rules from the learnings table into CLAUDE.md's Development Rules section. Incremental — does not rebuild the full file (that's create-claudemd's job).

---

## Scope

This skill ONLY touches two sections of CLAUDE.md:

- `## Development Rules` — appends approved rules as bullets
- `## Reference Documentation` — optionally refreshes via create-claudemd

It does NOT touch Repo Structure, Coding Conventions, Session Management, or user-added sections.

---

## Flow

### 1. Read CLAUDE.md

Read project root `CLAUDE.md`. Identify sections by `##` headers. Locate `## Development Rules`.

**CLAUDE.md missing?** → Warn user. This should not happen after init.

### 2. Check for unpropagated dev-rules

Read `session/learnings/dev-rules.md`. Look for entries where `Updated` = `No`.

**No file, or all entries already `Updated: Yes`?** → Skip to step 5.

### 3. Present rules to user

For each unpropagated entry, show:
- **Rule** column value
- **Rationale** column value

Ask the user to approve or reject each rule for inclusion in CLAUDE.md.

### 4. Append approved rules

**Approved rules:** Append as a bullet (`- Rule text`) to the `## Development Rules` section. If the section has subsections (like `### Writing Style`), append to the main section body before any subsections. Mark `Updated: Yes` in dev-rules.md.

**Rejected rules:** Leave `Updated: No`. The rule stays available for future review.

### 5. Optionally refresh Reference Documentation

**User indicates reference files in `_reference/` have changed?** → Invoke `/context-scaffolding-plugin:create-claudemd update` to rebuild CLAUDE.md with the updated reference catalog.

**No reference changes?** → Done.

---

## Edge Cases

- **No dev-rules.md file:** Nothing to propagate. Skip silently.
- **All entries already propagated:** Nothing to do. Skip silently.
- **CLAUDE.md missing:** Warn user — should not happen after init.
- **User rejects all rules:** No changes to CLAUDE.md. Entries stay `Updated: No` for future review.
