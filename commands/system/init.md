# /system:init

One-time project setup. Creates the directory structure and assembles CLAUDE.md from source materials.

Safe to re-run — directories are created if missing, CLAUDE.md owned sections are rebuilt, user additions are preserved.

---

## Flow

### 1. Create directories

Create each of these if it doesn't already exist. Skip silently if it does.

- `.claude/commands/prime/`
- `.claude/commands/prime/features/`
- `session/`
- `session/learnings/`

Do not create any files in these directories. Files are created by the skills that own them:
- Context files (primer, features) are created by the prime skill when the user is ready.
- Session files (STATUS.md, learnings) are created by summarize on first write.

### 2. Build reference catalog

Check `.claude/_reference/` for `.md` files.

- **If reference files exist:** activate the **create-reference-catalog** skill. It scans the files, extracts or collaborates on frontmatter, and returns a catalog table. Hold onto the table for step 3.
- **If `_reference/` is empty or doesn't exist:** skip this step. No catalog to build.

### 3. Build CLAUDE.md

Check `.claude/_docs/` for files.

**If `_docs/` has content:**

Activate the **create-claudemd** skill. Pass it the reference catalog table from step 2 (if one was built). The skill reads `_docs/`, condenses and routes content into CLAUDE.md sections, inserts the catalog table and session management rules, and writes `CLAUDE.md` to the project root.

**If `_docs/` is empty or doesn't exist:**

Enter the interactive path. Ask the user:

1. **What are you building?** — Get a one-liner project description.
2. **What kind of project?** — Language, framework, domain.
3. **Any conventions or constraints?** — Code style, naming rules, structural preferences.

You can look at the existing project structure (`src/`, `docs/`, `plans/` if they exist) conversationally to inform the draft — but don't do a formal automated scan.

From the answers, draft a minimal `CLAUDE.md` at the project root with:
- `## Repo Structure` — appropriate directory guidance based on the project type.
- `## Coding Conventions` — if language/framework conventions apply from the answers.
- `## Session Management` — always include the three hardcoded lines:
  ```
  - Feature status lifecycle: brainstorming → designing → planning → building → complete.
  - Accessing context files via `/prime:*` is read-only — does not switch the active feature.
  ```
- `## Development Rules` — header always present, even if empty.

If a reference catalog was built in step 2, include the `## Reference Documentation` section with the catalog table.

### 4. Present to user

Show the user the written CLAUDE.md. They review and edit as they see fit. Init is done.

---

## Re-run Behavior

- **Directories:** created if missing, skipped if they exist. Not destructive.
- **CLAUDE.md:** create-claudemd replaces its owned sections (Repo Structure, Coding Conventions, Reference Documentation, Session Management) and preserves everything else (Development Rules, user-added sections).
- **Development Rules:** checks `session/learnings/dev-rules.md` for `Updated: No` entries and folds them in.

---

## Does NOT Create

- `.claude/` skill/command structure — the plugin ships with this already in place.
- Project primer — created by the prime skill when the user is ready.
- Feature contexts — emerge during work.
- Session files (STATUS.md, learnings) — created by summarize skills on first write.
- Project root directories (`src/`, `docs/`, `plans/`) — created when work starts.
