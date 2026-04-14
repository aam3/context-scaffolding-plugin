---
name: create-project-primer
description: Creates or updates the project primer at commands/prime/project-primer.md. Generates the project-level orientation document that tells Claude what this project is, where it stands, and what to read. Triggers on "create primer", "set up project context", "update primer", or when prime skill or summarize-session needs a primer created or refreshed. Do NOT use for loading an existing primer — use /prime:project-primer directly.
user-invocable: false
---

# Create Project Primer

Creates or updates the project primer at `.claude/commands/prime/project-primer.md`. The primer orients Claude on what this project is, where it stands, and what files to read. Accessible via `/prime:project-primer`.

---

## Routing

Auto-detected — no mode argument needed.

Check if `.claude/commands/prime/project-primer.md` exists.

**File exists?** → Follow the Update Flow.

**File does not exist?** → Check the calling context:
- **Called during interactive session (from prime skill)?** → Follow the Create Flow.
- **Called at session end (from summarize-session)?** → Follow the Session-Context Flow.

---

## Output Schema

All three flows produce a primer following this template:

```markdown
# Project: [Name]

## Overview
[What this project is and the problem it solves]

## Current State
[High-level project trajectory — which features/areas are in progress,
which are complete, overall direction. Not a list of accomplishments.]

## Key Project Files
Read these files for project orientation before starting work.

- `docs/overview.md` — project scope, goals, and target users
- `docs/architecture.md` — system design and component relationships
```

Three sections only. No Constraints section — constraints live in referenced docs and CLAUDE.md.

---

## Create Flow

Interactive creation. Ask questions, draft, review, write.

### 1. Walk through questions

Ask the user three questions, one at a time:

1. **What is this project?** — Elevator pitch. What is it, what problem does it solve?
2. **What's the current state?** — Where does the project stand? Which areas are in progress, complete, what's the direction?
3. **Any existing files Claude should read for orientation?** — Explore the file system conversationally. Scan `docs/`, `plans/`, `inputs/`, and project root. Present what you find, let the user confirm which to include. Each included file gets a one-liner.

Handle sparse answers gracefully. Brief sections are valid.

### 2. Draft the primer

Assemble from the user's answers following the output schema:

- **Overview:** Condensed from question 1. Clear and specific.
- **Current State:** From question 2. Trajectory altitude — "auth system in active development, data pipeline complete" — not a task list.
- **Key Project Files:** From question 3. File path + one-liner per entry. If user had no files, leave just the directive text with no list items.

### 3. Present and write

Show the complete primer for review. After confirmation, write to `.claude/commands/prime/project-primer.md`.

If the file already exists, warn and ask — overwrite or cancel.

---

## Update Flow

Refreshes an existing primer. Called by summarize-session at session end.

### 1. Read existing primer

Read `.claude/commands/prime/project-primer.md`. Parse its sections (Overview, Current State, Key Project Files).

### 2. Rewrite Current State

1. Read recent `session/STATUS.md` entries for project-level context. If STATUS.md is empty, use session conversation context instead.
2. Rewrite at **trajectory altitude**: "Auth system in active development, data pipeline design complete."
3. Not a list of session accomplishments — a high-level snapshot of where the project stands.
4. Present proposed Current State to the user for review.

### 3. Check Key Project Files

If new project-level docs were created during the session, prompt:

> "You created `docs/architecture.md` this session. Add to Key Project Files?"

- One prompt covering all new candidates. User confirms which to add.
- Each added file gets a one-liner.
- If no new project-level docs were created, skip. Key Project Files stays as-is.

### 4. Preserve Overview

Do not modify Overview unless the user explicitly requests a change.

### 5. Present and write

Show updated primer for review. Write after confirmation.

---

## Session-Context Flow

Drafts a primer from the full session conversation. Called by summarize-session when no primer exists at session end. Produces richer content than the Create Flow because Claude has full session context.

### 1. Draft from conversation

- **Overview:** Inferred from what the project is and what the session worked on.
- **Current State:** Derived from session progress and STATUS.md (written by update-status).
- **Key Project Files:** Compiled from files created, modified, or referenced during the session. Validate existence on disk. Each gets a one-liner.

### 2. Present and write

Show the complete primer for review. Same schema as Create Flow output. After confirmation, write to `.claude/commands/prime/project-primer.md`.

---

## Edge Cases

- **No existing docs/plans/files:** Key Project Files starts empty — directive text only, no list items.
- **File already exists (create flow):** Warn and ask — overwrite or cancel.
- **Very brief user answers (create flow):** Valid. One-line Overview and one-line Current State are fine.
- **No new project docs (update flow):** Key Project Files stays unchanged. No prompt needed.
- **Primer missing at session end:** Offer session-context creation. If user declines, no primer written.

---

## Section Ownership

| Section | Created by | Updated by | How |
|---|---|---|---|
| Overview | This skill (create) | User request only | Stable after creation |
| Current State | This skill (create) | This skill (update) | Rewritten from STATUS.md trajectory |
| Key Project Files | This skill (create) | This skill (update) | Prompts for new files created during session |
