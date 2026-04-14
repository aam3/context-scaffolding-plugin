# /system:init

One-time project setup. Creates the directory structure and invokes create-claudemd to assemble CLAUDE.md from governance source files.

Safe to re-run — directories are created if missing, CLAUDE.md owned sections are rebuilt, user additions are preserved.

---

## Flow

### 1. Create directories

Run these commands. Each creates the directory only if it does not already exist:

```bash
mkdir -p .claude/commands/prime/features
mkdir -p .claude/_docs
mkdir -p .claude/_reference
mkdir -p session/learnings
```

Do not create any files in these directories. Files are populated in step 2 or by the skills that own them:
- Context files (primer, features) are created by the prime skill when the user is ready.
- Session files (STATUS.md, learnings) are created by summarize on first write.

### 2. Build CLAUDE.md

Invoke `/context-scaffolding-plugin:create-claudemd initialize`.

This skill handles everything needed to produce CLAUDE.md:
- Seeds `.claude/_docs/` and `.claude/_reference/` from plugin defaults (if empty)
- Pauses for user review of seeded files
- Scans `.claude/_reference/` and builds the reference catalog
- Gathers project description from existing files or user input
- Reads `.claude/_docs/`, condenses content, and assembles CLAUDE.md
- Writes CLAUDE.md to the project root
- Presents the result to the user

### 3. Done

Init is complete. The user reviews and edits CLAUDE.md as they see fit.

---

## Re-run Behavior

- **Directories:** created if missing, skipped if they exist. Not destructive.
- **CLAUDE.md:** Invoke `/context-scaffolding-plugin:create-claudemd update` to rebuild owned sections and preserve user content.

---

## Does NOT Create

- `.claude/` skill/command structure — the plugin ships with this already in place.
- Project primer — created by the prime skill when the user is ready.
- Feature contexts — emerge during work.
- Session files (STATUS.md, learnings) — created by summarize skills on first write.
- Project root directories (`src/`, `docs/`, `plans/`) — created when work starts.
