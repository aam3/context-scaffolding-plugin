---
name: create-project-primer
description: Creates or updates the project primer at commands/prime/project-primer.md. Use when setting up project context for the first time or when summarize-session needs to update it.
user-invocable: false
---

# Create Project Primer

Creates the project-level orientation document that tells Claude what this project is, where it stands, and what to read. Output lives at `.claude/commands/prime/project-primer.md` and is accessible via `/prime:project-primer`.

---

## When Activated

- **By the prime skill** — when no primer exists and the user wants to create one.
- **By `/system:summarize-session`** — to update the primer at session end (Phase 5 adds update mode).

---

## Output Schema

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

Three sections. No Constraints section — constraints live in referenced docs and CLAUDE.md.

---

## Mode Detection

Before starting, determine the mode:

1. Check if `.claude/commands/prime/project-primer.md` exists.
   - **File does not exist** → **create mode**. Follow the Create Mode flow below.
   - **File exists** → **update mode**. Follow the Update Mode flow (added in Phase 5).

This detection is automatic — callers don't need to pass a mode argument.

---

## Flow (Create Mode)

### 1. Walk through questions

Ask the user three questions, one at a time:

1. **What is this project?** — Get the elevator pitch. What is it and what problem does it solve?
2. **What's the current state?** — Where does the project stand? Which areas are in progress, which are complete, what's the overall direction?
3. **Any existing files Claude should read for orientation?** — For this question, explore the file system conversationally. Scan `docs/`, `plans/`, `inputs/`, and the project root for existing files. Present what you find and let the user confirm which to include. Each included file gets a one-liner explaining its relevance.

Handle sparse answers gracefully. If the user doesn't have much yet, that's fine — sections can be brief.

### 2. Draft the primer

Assemble the primer from the user's answers following the output schema above.

- **Overview:** Condensed from question 1. Clear and specific.
- **Current State:** From question 2. Trajectory altitude — "auth system in active development, data pipeline complete" — not a task list.
- **Key Project Files:** From question 3. Each entry is a file path + one-liner. If the user had no files to include, leave this section with just the directive text and no list items.

### 3. Present draft

Show the complete primer to the user for review. They can request changes before writing.

### 4. Write

After the user confirms, write to `.claude/commands/prime/project-primer.md`.

If the file already exists, warn the user and ask whether to overwrite or cancel.

---

## Flow (Update Mode)

Called by summarize-session at session end to refresh an existing project primer.

### 1. Read existing primer

Read `.claude/commands/prime/project-primer.md`. Parse its sections (Overview, Current State, Key Project Files).

### 2. Rewrite Current State

Update the Current State section to reflect the project's trajectory:

1. Read recent `session/STATUS.md` entries for project-level context.
2. Rewrite the section at **trajectory altitude**: "Auth system in active development, data pipeline design complete."
3. This is NOT a list of session accomplishments. It's a high-level snapshot of where the project stands and which areas are moving.
4. Present the proposed Current State to the user for review.

### 3. Check Key Project Files

If new project-level docs were created during the session, prompt the user:

> "You created `docs/architecture.md` this session. Add to Key Project Files?"

- Light touch — one prompt covering all new candidates. User confirms which to add.
- For each added file, include a one-liner explaining its relevance.
- If no new project-level docs were created, skip this step. Key Project Files stays as-is.

### 4. Preserve Overview

Do not modify the Overview section unless the user explicitly requests a change.

### 5. Present and write

Show the updated primer to the user for review. Write after confirmation.

---

## Flow (Session-Context Creation)

When the primer is missing at session end and summarize-session offers to create one.

### 1. Draft from conversation

Claude drafts the primer from the full session conversation. This produces richer content than the interactive create path because Claude has the full context of what was discussed and built.

- **Overview:** Inferred from what the project is and what the session worked on.
- **Current State:** Derived from session progress and STATUS.md (just written by update-status).
- **Key Project Files:** Compiled from files created, modified, or referenced during the session. Validated for existence on disk. Each gets a one-liner.

### 2. Present draft

Show the complete primer to the user for review. Same schema as create mode output.

### 3. Write

After the user confirms, write to `.claude/commands/prime/project-primer.md`.

---

## Edge Cases

- **No existing docs/plans/files:** Key Project Files section starts empty. Just the directive text, no list items. No errors.
- **File already exists (create mode):** Warn and ask — overwrite or cancel. Don't silently overwrite.
- **User gives very brief answers:** That's fine. A one-line Overview and one-line Current State are valid. Don't push for more.
- **No new project docs (update mode):** Key Project Files stays unchanged. No prompt needed.
- **Primer missing at session end:** Offer session-context creation. If user declines, no primer written.
- **Empty STATUS.md (update mode):** Write Current State from session conversation context instead.

---

## Section Ownership

| Section | Created by | Updated by | How |
|---|---|---|---|
| Overview | This skill (create) | User request only | Stable after creation |
| Current State | This skill (create) | This skill (update) | Rewritten from STATUS.md trajectory |
| Key Project Files | This skill (create) | This skill (update) | Prompts for new files created during session |
