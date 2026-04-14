---
name: update-status
description: Writes a session entry to session/STATUS.md. Generates session ID, infers feature labels, writes prose summary with key areas. Does NOT handle learnings or feature context updates.
user-invocable: false
---

# Update Status

Writes a single session entry to `session/STATUS.md`. Each entry captures what moved forward during the session — a prose summary with feature labels and key areas touched.

---

## When Activated

- **By `/system:summarize-session`** — session-end status capture. This is the only caller.

---

## Reference Files

Read `references/status-schema.md` from this skill's directory before writing any entry. It defines the STATUS.md format, session ID generation, and rolling window rules.

---

## Flow

### 1. Read schema

Read `references/status-schema.md`. Use this format for all STATUS.md entries.

### 2. Read or create STATUS.md

Check if `session/STATUS.md` exists.

- **Exists:** Read it. Parse existing entries to determine session ID.
- **Does not exist:** Will be created in step 6 with the `# Project Status` header.

### 3. Generate session ID

Count existing `## Session` entries in STATUS.md that have **today's date** (YYYY-MM-DD). The new session ID is that count + 1.

Examples:
- No entries for today → `Session 1`
- One entry for today → `Session 2`
- First-ever STATUS.md → `Session 1`

### 4. Infer feature labels

Determine which features were worked on during this session:

1. Read `session/active-feature.txt` if it exists — this is the primary feature.
2. Scan the session conversation for work on other features (files in other feature directories, discussion of other features).
3. Combine into bracket format: `[auth-system]` or `[auth-system, data-pipeline]`.
4. If no features identified, use empty brackets: `[]`.

### 5. Compose the entry

Write the STATUS.md entry following the schema:

```markdown
## Session N — YYYY-MM-DD [feature-labels]
[1-3 sentence prose summary. What moved forward. High-level, not a task list.]
- **Key areas:** `path/one/`, `path/two/`, `path/three/`
```

**Prose summary guidelines:**
- Focus on what moved forward, not tasks performed.
- High-level: "Implemented auth middleware and test coverage" not "Created handler.ts, wrote 5 tests, fixed import bug."
- 1-3 sentences max.

**Key areas guidelines:**
- 3-5 most significant directories or files touched.
- Structural fingerprint — helps future sessions understand scope.
- Prefer directories over individual files when multiple files in the same directory were touched.

### 6. Write to STATUS.md

- **If STATUS.md exists:** Prepend the new entry immediately after the `# Project Status` header line (newest entries at top).
- **If STATUS.md does not exist:** Create the file with the `# Project Status` header, then the entry.

Always present the entry to the user before writing.

### 7. Return session ID

Return the session ID string (e.g., "Session 2") for use by the calling command. The session ID is used only in the STATUS.md entry — learnings tables use date only.

---

## Edge Cases

- **Empty session:** If very little happened, ask the user whether to write a minimal entry or skip. Don't write an empty entry.
- **First-ever session:** Create STATUS.md from scratch. Session ID is `Session 1`.
- **Multiple sessions same day:** Session ID increments per day. Third session today → `Session 3`.
- **No active feature:** Feature labels may be empty `[]` or inferred from conversation context.
- **Rolling window cleanup:** This skill does NOT handle cleanup. The summarize-session command handles that after all other steps complete.
