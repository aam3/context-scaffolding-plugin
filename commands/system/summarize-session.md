# /system:summarize-session

Session-end orchestrator. Captures everything: STATUS.md entry, learnings, feature context update, primer update, rolling window cleanup.

Run this at the end of a working session to persist all progress and context for the next session.

---

## Flow

Execute these steps in order, respecting the dependencies noted below.

### Step 1: Read active feature

Read `session/active-feature.txt`.

- If the file exists → note the active feature key (e.g., `auth-system` or `auth-system/jwt-tokens`).
- If missing → no feature was active this session. Step 4 will be skipped.

### Step 2: Write STATUS.md entry

Activate the **update-status** skill.

- Writes a session entry to `session/STATUS.md` (creates the file on first write).
- Returns the session ID (e.g., "Session 2").
- **This step MUST complete before steps 5 and 6.**

### Step 3: Record learnings

Activate the **record-learnings** skill.

- Safety net for any learnings not yet captured by mid-session summarize-conversation calls.
- Handles dev-rules, domain-rules, and plan-changes tables.
- Handles propagation to target files (CLAUDE.md, docs, plans).
- Independent of steps 4 and 5.

### Step 4: Update feature context (if feature was active)

**Skip this step if no active feature was identified in step 1.**

Activate the **create-feature** skill.

- The feature key from step 1 maps to a file via convention: `.claude/commands/prime/features/{key}.md`.
- The skill detects update mode automatically (file exists).
- Rewrites Status and Key Files, preserves Description and custom sections.
- Independent of steps 3 and 5.

### Step 5: Update project primer

Activate the **create-project-primer** skill.

- If the primer exists → update mode. Rewrites Current State from STATUS.md, checks Key Project Files for new docs.
- If the primer is missing → offer session-context creation. Claude drafts a primer from the session conversation.
- **This step MUST happen AFTER step 2** (needs STATUS.md data for Current State rewrite).
- **This step MUST complete before step 6.**

### Step 6: Clean STATUS.md — rolling window

After all other steps are complete:

1. Read `session/STATUS.md`.
2. Count `## Session` entries (H2 headers matching the session entry pattern).
3. If more than 10 entries → remove the oldest entries from the **bottom** of the file until exactly 10 remain. Newest entries are at the top.
4. Write the cleaned STATUS.md.

**This step MUST happen AFTER step 5** (primer reads full STATUS.md before cleanup removes old entries).

---

## Step Dependencies

```
Step 1 (read feature)      → feeds Step 4
Step 2 (update-status)     → must complete before → Step 5 (primer needs STATUS.md)
Step 5 (primer update)     → must complete before → Step 6 (cleanup)
Steps 3 and 4 are independent of each other.
Steps 4 and 5 are independent of each other.
```

Recommended execution order: 1 → 2 → 3,4 (parallel) → 5 → 6

---

## Edge Cases

- **Empty session:** update-status asks user whether to write a minimal entry or skip. Other steps still run.
- **First session:** update-status creates STATUS.md. Primer may not exist → step 5 offers creation.
- **No active feature:** Step 4 skipped entirely. All other steps run normally.
- **No primer:** Step 5 offers to create one from session context.
- **Fewer than 10 STATUS.md entries:** Step 6 is a no-op. No entries removed.

---

## What This Does NOT Do

- **Does not replace mid-session summarize-conversation.** That command captures learnings incrementally. This command is the full session-end pipeline.
- **Does not modify CLAUDE.md directly.** Dev-rules propagation to CLAUDE.md is handled by record-learnings → update-dev-rules.
