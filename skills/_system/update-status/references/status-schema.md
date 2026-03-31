# STATUS.md Schema

**Location:** `session/STATUS.md`

## Format

```markdown
# Project Status

## Session 2 — 2026-03-24 [auth-system]
Implemented JWT token validation and created test coverage for token expiry edge cases.
- **Key areas:** `src/03-auth/middleware/`, `tests/03-auth/`

## Session 1 — 2026-03-24 [data-pipeline, auth-system]
Designed data extraction approach and sketched auth system requirements.
- **Key areas:** `plans/design/01-data-extraction.md`, `plans/design/03-auth-system.md`

## Session 1 — 2026-03-23 [data-pipeline]
Completed CSV and JSON extraction parsers. All parser tests passing.
- **Key areas:** `src/01-data-extraction/`, `tests/01-data-extraction/`
```

## Rules

- **Session ID leads.** `Session N — YYYY-MM-DD` where N restarts each day.
- **Feature labels in brackets.** All features worked on, inferred from conversation. Can be multiple: `[auth-system, data-pipeline]`.
- **Prose summary.** 1-3 sentences. What moved forward. Not a task list.
- **Key areas.** 3-5 most significant directories/files touched. Structural fingerprint, not exhaustive manifest.
- **No deferred items.** STATUS.md records what happened, not what didn't.

## Session ID Generation

- Count entries for today's date in STATUS.md, add one.
- Numbers restart each day.
- Session IDs don't need to be contiguous across days.

## Rolling Window

- Keep 10 entries max. Newest at top, oldest removed from bottom.
- Count-based, not time-based.
- After cleanup, the project primer's Current State is the only record of earlier history.
