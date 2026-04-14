---
name: record-learnings
description: Records discovered dev rules, domain rules, and plan changes from the current session into structured learnings tables. Propagates entries to their target files (CLAUDE.md, domain docs, plan files). Triggers on "record learnings", "capture rules", "save what we learned", or when summarize-session or summarize-conversation needs learnings captured. Does NOT write STATUS.md — that is update-status.
user-invocable: false
---

# Record Learnings

Scans the session conversation for discovered rules, knowledge, and plan changes. Records them in structured learnings tables under `session/learnings/` and propagates to target files.

---

## Before Starting

Read `${CLAUDE_SKILL_DIR}/references/learnings-schemas.md`. It defines all three table formats and their column specifications. Use these schemas for all table formatting.

---

## Flow

### 1. Scan for discovered learnings

Review the session conversation for three categories:

**Dev rules** — how Claude should behave during development:
- "Ask before calling external APIs"
- "Don't modify files in inputs/"
- "Always run tests after editing src/"

**Domain rules** — domain logic and edge cases discovered during work:
- "Invoice amounts must include tax in EU regions"
- "User IDs are UUIDs, not integers"
- "The API rate limit resets every 15 minutes"

**Plan changes** — deviations from existing plans with rationale:
- "Switched from REST to GraphQL because client needs real-time subscriptions"
- "Moved auth to Phase 3 instead of Phase 2 due to data layer dependency"

**No learnings in any category?** → Stop. No files written, no propagation.

### 2. Record dev rules

If dev rules were discovered:

1. Check if `session/learnings/dev-rules.md` exists. If not, create it with the `# Development Rules — Discovered` header and table header row.
2. Append a row per rule:
   - **Date:** today (YYYY-MM-DD)
   - **Rule:** one sentence
   - **Rationale:** one sentence
   - **Updated:** `No`

### 3. Record domain rules

If domain rules were discovered:

1. For each rule, ask the user: "Which file should this domain rule be documented in?" User provides a file path or says `[TBD]` to defer.
2. Check if `session/learnings/domain-rules.md` exists. If not, create it with the `# Domain Rules — Discovered` header and table header row.
3. Append a row per rule:
   - **Date:** today
   - **Feature:** which feature this relates to (infer from context or ask)
   - **Rule:** one sentence
   - **Documented In:** target file path or `[TBD]`
   - **Updated:** `No`

### 4. Record plan changes

If plan changes were discovered:

1. For each change, check if the referenced plan file **exists on disk**. If not → skip this change.
2. Check if `session/learnings/plan-changes.md` exists. If not, create it with the `# Plan Changes` header and table header row.
3. Append a row per change:
   - **Date:** today
   - **Plan File:** path to the plan file
   - **Feature:** which feature this relates to
   - **Change:** one sentence
   - **Rationale:** one sentence
   - **Updated:** `No`

### 5. Propagate to target files

For each category with recorded entries:

**Dev rules →** Invoke `/context-scaffolding-plugin:update-dev-rules`. It presents rules to the user for approval and appends approved ones to CLAUDE.md's Development Rules section.

**Domain rules →** For each entry:
- **`Documented In` has a real path?** → Read the target file. Find where the rule fits contextually. Integrate editorially — place it where it belongs, not blind appending. Mark `Updated: Yes` in domain-rules.md.
- **`Documented In` is `[TBD]`?** → Skip propagation. Handled in step 6.

**Plan changes →** For each entry: read the plan file, find the relevant section, update editorially to reflect the change. Mark `Updated: Yes` in plan-changes.md.

### 6. Resolve [TBD] entries

Check all learnings files for entries where `Documented In` = `[TBD]`.

**Any found?** → Prompt: "There are [N] learnings with unassigned targets. Want to assign them now?"
- Yes → walk through each, ask for target file path, update `Documented In`, propagate immediately.
- No → leave for next time.

**None found?** → Done.

---

## Edge Cases

- **No learnings discovered:** Stop entirely. No files written.
- **First-ever learnings:** Create files on first write with `#` header and table header row.
- **Plan file doesn't exist:** Skip that plan change silently.
- **Target file for domain rule doesn't exist:** Ask the user — create the file or use `[TBD]`.
- **`[TBD]` targets:** Record the entry, skip propagation, prompt for resolution in step 6.
