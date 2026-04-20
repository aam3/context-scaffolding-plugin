# Session-Context Flow

Drafts a primer from the full session conversation. Called by summarize-session when no primer exists at session end. Produces richer content than the Create Flow because Claude has full session context.

## 1. Draft from conversation

- **Overview:** Inferred from what the project is and what the session worked on.
- **Current State:** Derived from session progress and STATUS.md (written by update-status).
- **Key Project Files:** Compiled from files created, modified, or referenced during the session. Validate existence on disk. Each gets a one-liner.

## 2. Present and write

Show the complete primer for review. Same output schema as the parent SKILL.md. After confirmation, write to `.claude/commands/prime/project-primer.md`.
