# Update Flow

Refreshes an existing primer. Called by summarize-session at session end.

## 1. Read existing primer

Read `.claude/commands/prime/project-primer.md`. Parse its sections (Overview, Current State, Key Project Files).

## 2. Rewrite Current State

1. Read recent `session/STATUS.md` entries for project-level context. If STATUS.md is empty, use session conversation context instead.
2. Rewrite at **trajectory altitude**: "Auth system in active development, data pipeline design complete."
3. Not a list of session accomplishments — a high-level snapshot of where the project stands.
4. Present proposed Current State to the user for review.

## 3. Check Key Project Files

If new project-level docs were created during the session, prompt:

> "You created `specs/architecture.md` this session. Add to Key Project Files?"

- One prompt covering all new candidates. User confirms which to add.
- Each added file gets a one-liner.
- If no new project-level docs were created, skip. Key Project Files stays as-is.

## 4. Preserve Overview

Do not modify Overview unless the user explicitly requests a change.

## 5. Present and write

Show updated primer for review. Write after confirmation.
