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

| Condition | Workflow | File |
|---|---|---|
| Primer exists | Update | `workflows/update.md` |
| Primer missing + interactive session (from prime skill) | Create | `workflows/create.md` |
| Primer missing + session end (from summarize-session) | Session-Context | `workflows/session-context.md` |

Read the workflow file for the matched condition and follow it exactly.

---

## Output Schema

All three workflows produce a primer following this template:

```markdown
# Project: [Name]

## Overview
[What this project is and the problem it solves]

## Current State
[High-level project trajectory — which features/areas are in progress,
which are complete, overall direction. Not a list of accomplishments.]

## Key Project Files
Read these files for project orientation before starting work.

- `specs/overview.md` — project scope, goals, and target users
- `specs/architecture.md` — system design and component relationships
```

Three sections only. No Constraints section — constraints live in referenced docs and CLAUDE.md.

---

## Edge Cases

- **No existing specs/plans/files:** Key Project Files starts empty — directive text only, no list items.
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
