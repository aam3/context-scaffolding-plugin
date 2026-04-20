# /system:init

One-time project setup. Creates the directory structure and invokes create-claudemd to assemble CLAUDE.md from governance source files.

Safe to re-run — directories are created if missing, CLAUDE.md owned sections are rebuilt, user additions are preserved.

---

## Flow

### 1. Create directories

```bash
mkdir -p .claude/commands/prime/features
mkdir -p .claude/_docs
mkdir -p .claude/_reference
mkdir -p session/learnings
mkdir -p brainstorm
mkdir -p specs
mkdir -p plans/project
mkdir -p plans/features
mkdir -p src
```

### 2. Deploy subdirectory CLAUDE.md files

Copy governance templates into `plans/` and `src/`. Skip if the file already exists.

```bash
# Only write if not already present
[ ! -f plans/CLAUDE.md ] && cp "${CLAUDE_PLUGIN_ROOT}/_docs/plans-claudemd.md" plans/CLAUDE.md
[ ! -f src/CLAUDE.md ] && cp "${CLAUDE_PLUGIN_ROOT}/_docs/src-claudemd.md" src/CLAUDE.md
```

### 3. Build CLAUDE.md

Invoke `/context-scaffolding-plugin:create-claudemd initialize`.

This skill handles everything needed to produce CLAUDE.md:
- Seeds `.claude/_docs/` and `.claude/_reference/` from plugin defaults (if empty)
- Pauses for user review of seeded files
- Scans `.claude/_reference/` and builds the reference catalog
- Gathers project description from existing files or user input
- Reads `.claude/_docs/`, condenses content, and assembles CLAUDE.md
- Writes CLAUDE.md to the project root
- Presents the result to the user

### 4. Done

Init is complete. The user reviews and edits CLAUDE.md as they see fit.

---

## Re-run Behavior

- **Directories:** created if missing, skipped if they exist. Not destructive.
- **Subdirectory CLAUDE.md files:** written only if not already present. User edits are preserved.
- **Root CLAUDE.md:** Invoke `/context-scaffolding-plugin:create-claudemd update` to rebuild owned sections and preserve user content.

---

## Does NOT Create

- `.claude/` skill/command structure — the plugin ships with this already in place.
- Project primer — created by the prime skill when the user is ready.
- Feature contexts — emerge during work.
- Session files (STATUS.md, learnings) — created by summarize skills on first write.
