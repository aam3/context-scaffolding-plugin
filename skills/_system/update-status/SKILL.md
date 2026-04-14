---
name: update-status
description: Writes a session entry to session/STATUS.md. Generates session ID, infers feature labels, writes prose summary with key areas touched. Triggers on "update status", "write status entry", or when summarize-session needs the session recorded. Does NOT handle learnings, feature context updates, or rolling window cleanup.
user-invocable: false
---

# Update Status

Writes a single session entry to `session/STATUS.md`. Each entry captures what moved forward — a prose summary with feature labels and key areas touched.

---

## Before Starting

Read `${CLAUDE_SKILL_DIR}/references/status-schema.md`. It defines the STATUS.md format, session ID generation, and rolling window rules. Use this schema for all entry formatting.

---

## Flow

### 1. Read or create STATUS.md

Check if `session/STATUS.md` exists.

**Exists?** → Read it. Parse existing entries to determine session ID.

**Does not exist?** → Will be created in step 5 with the `# Project Status` header.

### 2. Generate session ID

Count existing `## Session` entries in STATUS.md with **today's date** (YYYY-MM-DD). New session ID = count + 1.

- No entries for today → `Session 1`
- One entry for today → `Session 2`
- First-ever STATUS.md → `Session 1`

### 3. Infer feature labels

1. Read `session/active-feature.txt` if it exists — this is the primary feature.
2. Scan the session conversation for work on other features (files in other feature directories, discussion of other features).
3. Combine into bracket format: `[auth-system]` or `[auth-system, data-pipeline]`.
4. No features identified → `[]`.

### 4. Compose the entry

Write the entry following the format and rules in `status-schema.md`. Use the session ID from step 2 and feature labels from step 3.

### 5. Write to STATUS.md

**STATUS.md exists?** → Prepend the new entry immediately after the `# Project Status` header (newest at top).

**Does not exist?** → Create the file with `# Project Status` header, then the entry.

Present the entry to the user before writing.

### 6. Return session ID

Return the session ID string (e.g., "Session 2") for use by the calling command. The session ID is used only in the STATUS.md entry — learnings tables use date only.

---

## Edge Cases

- **Empty session:** Ask the user whether to write a minimal entry or skip. No empty entries.
- **First-ever session:** Create STATUS.md from scratch. Session ID is `Session 1`.
- **Multiple sessions same day:** Session ID increments per day. Third session today → `Session 3`.
- **No active feature:** Feature labels may be `[]` or inferred from conversation context.
- **Rolling window cleanup:** This skill does NOT handle cleanup — summarize-session handles that after all steps complete.
