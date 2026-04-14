---
name: create-feature
description: Creates or updates feature context files at commands/prime/features/. Use when creating a new feature context or when summarize-session needs to update an existing one.
user-invocable: false
---

# Create Feature

Creates feature-level orientation documents that tell Claude what a feature is, its current status, and what files to read. Output lives at `.claude/commands/prime/features/{kebab-case-name}.md` and is accessible via `/prime:features:{name}`.

---

## When Activated

- **By the prime skill** — when the user wants to create a new feature context.
- **By `/system:summarize-session`** — to update an existing feature at session end (Phase 5 adds update mode).

---

## Output Schema

```markdown
# Feature: [Name]

## Status
[brainstorming | designing | planning | building | complete]

## Description
[What this feature involves, its scope, key technical aspects.
Adaptable length — as much or as little as needed.]

## Key Files
Read these files for feature context. Files already listed in the
project primer or a parent feature are not repeated here.

- `plans/design/03-auth-system.md` — technical approach and design decisions
- `plans/implementation/03-auth-system.md` — implementation steps and progress
```

Three sections. No Open Questions — plan files handle unknowns.

---

## Mode Detection

Before starting, determine the mode:

1. Identify the target feature file path (from the feature name provided, or from `session/active-feature.txt` if called by summarize-session).
2. Check if the file exists at `.claude/commands/prime/features/{name}.md`.
   - **File does not exist** → **create mode**. Follow the Create Mode flow below.
   - **File exists** → **update mode**. Follow the Update Mode flow (added in Phase 5).

This detection is automatic — callers don't need to pass a mode argument.

---

## Flow (Create Mode)

### 1. Gather input

Ask the user for:

- **Feature name** (required) — the display name. Will be converted to kebab-case for the filename.
- **Description** (required) — what this feature involves. Can be one sentence or a paragraph.

Only these two are required. Handle sparse input gracefully — don't force information the user doesn't have yet.

### 2. Convert name to kebab-case

Rules:
- `Auth System` → `auth-system`
- `JWT Tokens` → `jwt-tokens`
- `Phase 2 API` → `phase-2-api`
- Lowercase, hyphens for spaces, preserve numbers.

### 3. Check for collision

Check if `.claude/commands/prime/features/{kebab-case-name}.md` already exists.

If it does, prompt the user: rename or cancel. **Do not overwrite.**

### 4. Set defaults

- **Status:** `brainstorming`
- **Key Files:** Ask the user if they have file pointers to include. Don't force it — Key Files can start empty.

### 5. Handle sub-features

If the user specifies this is a sub-feature of an existing feature:

- Determine the parent feature name (kebab-case).
- Create the parent directory if it doesn't exist: `.claude/commands/prime/features/{parent}/`
- File goes at: `.claude/commands/prime/features/{parent}/{child}.md`
- Accessible via `/prime:features:{parent}:{child}`

### 6. Draft and present

Assemble the feature file following the output schema. Present to the user for review before writing.

### 7. Write

After confirmation, write to `.claude/commands/prime/features/{name}.md` (or `.../features/{parent}/{name}.md` for sub-features).

---

## Flow (Update Mode)

Called by summarize-session at session end to refresh an existing feature context file.

### 1. Read the existing feature file

Derive the file path from `session/active-feature.txt`:
- Read `active-feature.txt` to get the feature key (e.g., `auth-system` or `auth-system/jwt-tokens`).
- Map to file: `.claude/commands/prime/features/{key}.md`.
- Read the existing file. Parse its sections.

### 2. Replace Status

Assess what happened during the session and set the appropriate lifecycle value.

- Review the session's work: was it brainstorming? designing? building code?
- Set the status to match. Status can move in any direction — if a building session led to redesign, set `designing`.
- Present the proposed status change to the user for confirmation.

### 3. Replace Key Files

Rebuild the Key Files section from session work:

1. **Compile candidates** — gather files created, modified, or significantly referenced during the session that are relevant to this feature.
2. **Validate file existence** — only include files that actually exist on disk. Check each candidate.
3. **Add one-liners** — for each candidate, write a feature-specific one-liner derived from session context (what role this file plays for this feature, not a generic description).
4. **Deduplicate:**
   - Read the project primer (`commands/prime/project-primer.md`) Key Project Files list. Exclude any file that appears there.
   - If this is a sub-feature, read the parent feature's Key Files list. Exclude any file that appears there.
5. **Present candidates** to the user with their one-liners. User confirms which to keep.

### 4. Preserve Description

Do not modify the Description section unless the user explicitly requests a change.

### 5. Preserve custom sections

Any sections beyond the standard schema (Status, Description, Key Files) were added by the user. Preserve them in place.

### 6. Present and write

Show the updated feature context to the user for review. Write after confirmation.

---

## Key Files One-Liners

Each file pointer includes a short note explaining why the file matters **for this feature specifically**. Not a generic file description — a feature-specific relevance note.

During create, the user provides these (or leaves the section empty). During update, Claude derives them from session context and the user confirms.

---

## Feature Status Lifecycle

```
brainstorming → designing → planning → building → complete
```

Descriptive, not enforced. Can move in any direction. If a building session leads to redesign, status goes back to `designing`. No validation — the user decides.

---

## Edge Cases

- **Minimal input:** Name + one-line description is enough. Key Files empty. Status defaults to brainstorming.
- **Name collision:** Prompt to rename or cancel. Never overwrite silently.
- **Sub-feature with no parent file:** Create the parent directory but don't require a parent feature file to exist. The directory is just organizational.
- **No Key Files:** Section is present with the directive text but no list items.
