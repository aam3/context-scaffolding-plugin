# /system:summarize-conversation

Mid-session learnings capture. Records discovered dev rules, domain rules, and plan changes without writing STATUS.md or updating context files.

Use this anytime during a session to capture learnings before they're lost to context window limits. Safe to run multiple times — entries are appended, not duplicated.

---

## Flow

1. Invoke `/context-scaffolding-plugin:record-learnings`. It handles everything:
   - Scans the conversation for discovered learnings
   - Records them in the appropriate tables
   - Propagates to target files (CLAUDE.md, docs, plans)
   - Prompts for any `[TBD]` targets

That's it. This command is a thin wrapper.

---

## What This Does NOT Do

- **Does not write STATUS.md.** STATUS.md entries are created by update-status, which is only called by `/system:summarize-session` at session end.
- **Does not update feature contexts.** Feature context rewrites happen at session end.
- **Does not update the project primer.** Primer updates happen at session end.
