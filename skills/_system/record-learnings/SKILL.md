---
name: record-learnings
description: Records discovered dev rules, domain rules, and plan changes from the current session into learnings tables. Handles propagation to target files. Does NOT write STATUS.md.
disable-model-invocation: true
---

# Record Learnings

Scans the current session conversation for discovered rules, knowledge, and plan changes. Records them in structured learnings tables and propagates to target files. This skill handles learnings only — STATUS.md is update-status's responsibility (Phase 5).

---

## When Activated

- **By `/system:summarize-conversation`** — mid-session learnings capture.
- **By `/system:summarize-session`** — session-end learnings capture (safety net for anything not yet recorded).

---

## Reference Files

Read `references/learnings-schemas.md` from this skill's directory before recording any entries. It defines all three table formats and their column specifications.

---

## Flow

### 1. Read schemas

Read `references/learnings-schemas.md`. Use these schemas for all table formatting.

### 2. Scan for discovered learnings

Review the session conversation for three categories of discoveries:

**Dev rules** — things about how Claude should behave during development. Examples:
- "Ask before calling external APIs"
- "Don't modify files in inputs/"
- "Always run tests after editing src/"

**Domain rules** — domain logic and edge cases discovered during work. Examples:
- "Invoice amounts must include tax in EU regions"
- "User IDs are UUIDs, not integers"
- "The API rate limit resets every 15 minutes"

**Plan changes** — deviations from existing plans with rationale. Examples:
- "Switched from REST to GraphQL because client needs real-time subscriptions"
- "Moved auth to Phase 3 instead of Phase 2 due to data layer dependency"

If no learnings in any category → **skip entirely**. No files written, no propagation, done.

### 3. Record dev rules

If dev rules were discovered:

1. Check if `session/learnings/dev-rules.md` exists.
   - If not, create it with the `# Development Rules — Discovered` header and table header row.
2. For each discovered rule, append a table row:
   - **Date:** today's date (YYYY-MM-DD)
   - **Rule:** one sentence
   - **Rationale:** one sentence
   - **Updated:** `No`

### 4. Record domain rules

If domain rules were discovered:

1. For each rule, ask the user: "Which file should this domain rule be documented in?" User provides a file path or says `[TBD]` to defer.
2. Check if `session/learnings/domain-rules.md` exists.
   - If not, create it with the `# Domain Rules — Discovered` header and table header row.
3. Append a table row for each rule:
   - **Date:** today's date
   - **Feature:** which feature this relates to (infer from context or ask)
   - **Rule:** one sentence
   - **Documented In:** the target file path or `[TBD]`
   - **Updated:** `No`

### 5. Record plan changes

If plan changes were discovered:

1. For each change, check if the referenced plan file **actually exists on disk**.
   - If it doesn't → **skip this change**. Don't record it.
2. Check if `session/learnings/plan-changes.md` exists.
   - If not, create it with the `# Plan Changes` header and table header row.
3. Append a table row for each change:
   - **Date:** today's date
   - **Plan File:** path to the plan file
   - **Feature:** which feature this relates to
   - **Change:** one sentence
   - **Rationale:** one sentence
   - **Updated:** `No`

### 6. Propagate

For each category with recorded entries, propagate to targets:

**Dev rules → CLAUDE.md:**
- Activate the update-dev-rules skill. It handles presenting rules to the user for approval and appending approved ones to the Development Rules section.

**Domain rules → target files:**
- For entries with a real `Documented In` path (not `[TBD]`):
  - Read the target file.
  - Find where the rule fits contextually within the file's existing content.
  - Integrate it editorially — not blind appending. Place it where it belongs.
  - Mark the entry `Updated: Yes` in domain-rules.md.
- For entries with `[TBD]`: skip propagation. Note for step 7.

**Plan changes → plan files:**
- For each entry:
  - Read the plan file.
  - Find the relevant section.
  - Update it editorially to reflect the change.
  - Mark the entry `Updated: Yes` in plan-changes.md.

### 7. Scan for [TBD] entries

Check all learnings files for entries where `Documented In` = `[TBD]`. If any exist, prompt the user:

> "There are [N] learnings with unassigned targets. Want to assign them now?"

If yes, walk through each one and ask for the target file path. If the user provides one, update the `Documented In` column and propagate immediately.

If no, leave them for next time.

---

## Edge Cases

- **No learnings discovered:** Skip entirely. No files written.
- **First-ever learnings:** Create files on first write with `#` header and table header row.
- **Plan file doesn't exist:** Don't record the plan change. Skip silently.
- **[TBD] targets:** Record the entry but don't propagate. Prompt for resolution.
- **Target file for domain rule doesn't exist:** Ask the user if they want to create it or use `[TBD]`.
