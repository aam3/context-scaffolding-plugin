---
name: create-feature
description: Creates or updates feature context files at commands/prime/features/. Generates feature-level orientation documents covering what a feature is, its status, and what files to read. Triggers on "create feature", "new feature", "add feature context", "update feature", or when prime skill or summarize-session needs a feature created or refreshed. Do NOT use for loading an existing feature — use /prime:features:{name} directly.
user-invocable: false
---

# Create Feature

Creates or updates feature context files at `.claude/commands/prime/features/{kebab-case-name}.md`. Each feature file orients Claude on what a feature is, its current status, and what files to read. Accessible via `/prime:features:{name}`.

---

## Routing

Auto-detected — no mode argument needed.

1. Identify the target feature file path (from the feature name provided, or from `session/active-feature.txt` if called by summarize-session).
2. Check if `.claude/commands/prime/features/{name}.md` exists.

**File does not exist?** → Follow the Create Flow.

**File exists?** → Follow the Update Flow.

---

## Output Schema

Both flows produce a feature file following this template:

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

Three sections only. No Open Questions — plan files handle unknowns.

**Status lifecycle:** `brainstorming → designing → planning → building → complete`. Descriptive, not enforced. Can move in any direction — if a building session leads to redesign, status goes back to `designing`.

**Key Files one-liners:** Each entry explains why the file matters **for this feature specifically** — not a generic file description. During create, the user provides these (or leaves empty). During update, Claude derives them from session context and the user confirms.

---

## Create Flow

Interactive creation. Gather input, draft, review, write.

### 1. Gather input

Ask the user for:
- **Feature name** (required) — display name, converted to kebab-case for the filename
- **Description** (required) — what this feature involves. One sentence or a paragraph.

Only these two are required. Handle sparse input gracefully.

### 2. Convert name to kebab-case

- `Auth System` → `auth-system`
- `JWT Tokens` → `jwt-tokens`
- `Phase 2 API` → `phase-2-api`
- Lowercase, hyphens for spaces, preserve numbers.

### 3. Check for collision

Check if `.claude/commands/prime/features/{kebab-case-name}.md` already exists. If it does, prompt: rename or cancel. **Do not overwrite.**

### 4. Set defaults

- **Status:** `brainstorming`
- **Key Files:** Ask the user if they have file pointers to include. Key Files can start empty.

### 5. Handle sub-features

**When the user specifies this is a sub-feature of an existing feature:**

1. Determine the parent feature name (kebab-case)
2. Create the parent directory if needed: `.claude/commands/prime/features/{parent}/`
3. File goes at: `.claude/commands/prime/features/{parent}/{child}.md`
4. Accessible via `/prime:features:{parent}:{child}`

### 6. Draft and present

Assemble the feature file following the output schema. Present for review before writing.

### 7. Write

After confirmation, write to `.claude/commands/prime/features/{name}.md` (or `.../features/{parent}/{name}.md` for sub-features).

---

## Update Flow

Refreshes an existing feature context file. Called by summarize-session at session end.

### 1. Read existing feature file

Derive the file path from `session/active-feature.txt`:
- Read `active-feature.txt` to get the feature key (e.g., `auth-system` or `auth-system/jwt-tokens`)
- Map to file: `.claude/commands/prime/features/{key}.md`
- Read the file. Parse its sections.

### 2. Replace Status

Assess what happened during the session and set the appropriate lifecycle value:
1. Review the session's work — was it brainstorming? designing? building code?
2. Set status to match. Status can move in any direction.
3. Present the proposed status change to the user for confirmation.

### 3. Replace Key Files

Rebuild the Key Files section from session work:

1. **Compile candidates** — files created, modified, or significantly referenced during the session that are relevant to this feature
2. **Validate existence** — only include files that exist on disk
3. **Add one-liners** — feature-specific relevance derived from session context
4. **Deduplicate:**
   - Read project primer (`commands/prime/project-primer.md`) Key Project Files. Exclude duplicates.
   - If sub-feature, read parent feature's Key Files. Exclude duplicates.
5. **Present candidates** with one-liners. User confirms which to keep.

### 4. Preserve Description

Do not modify Description unless the user explicitly requests a change.

### 5. Preserve custom sections

Any sections beyond the standard schema (Status, Description, Key Files) were added by the user. Preserve in place.

### 6. Present and write

Show updated feature context for review. Write after confirmation.

---

## Edge Cases

- **Minimal input:** Name + one-line description is enough. Key Files empty. Status defaults to `brainstorming`.
- **Name collision:** Prompt to rename or cancel. Never overwrite silently.
- **Sub-feature with no parent file:** Create the parent directory. A parent feature file is not required — the directory is organizational.
- **No Key Files:** Section present with directive text but no list items.
