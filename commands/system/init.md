# /system:init

One-time project setup. Copies governance source files into the project, creates the directory structure, and assembles CLAUDE.md from source materials.

Safe to re-run — directories are created if missing, existing `_docs/` and `_reference/` files are not overwritten, CLAUDE.md owned sections are rebuilt, user additions are preserved.

---

## Flow

### 1. Create directories

Create each of these if it doesn't already exist. Skip silently if it does.

- `.claude/commands/prime/`
- `.claude/commands/prime/features/`
- `.claude/_docs/`
- `.claude/_reference/`
- `session/`
- `session/learnings/`

Do not create any files in these directories yet. Files are populated in step 2 or by the skills that own them:
- Context files (primer, features) are created by the prime skill when the user is ready.
- Session files (STATUS.md, learnings) are created by summarize on first write.

### 2. Seed `_docs/` and `_reference/`

Copy the plugin's default governance files into the project so the user has a starting point they can customize.

**`_docs/`:**
- Check if the project's `.claude/_docs/` already has `.md` files.
- **If empty:** Copy all files from this plugin's `_docs/` directory into the project's `.claude/_docs/`. The plugin's `_docs/` is at the root of this plugin's package (sibling to the `commands/` directory this command is in).
- **If already has files:** Skip. The user has already set up or customized their docs.

**`_reference/`:**
- Check if the project's `.claude/_reference/` already has `.md` files (recursively, including subdirectories).
- **If empty:** Copy all files and subdirectories from this plugin's `_reference/` directory into the project's `.claude/_reference/`.
- **If already has files:** Skip.

**After copying**, present the user with a summary of what was copied. Tell the user these files are the source material that CLAUDE.md will be assembled from, and ask if they want to review or edit any of them before proceeding. Pause here until the user confirms they're ready to continue.

The user may want to:
- Edit `_docs/` files to match their project's actual structure, conventions, and constraints.
- Remove `_reference/` files for Claude Code features they don't use.
- Add their own `_docs/` files with project-specific governance content.

### 3. Build reference catalog

Check `.claude/_reference/` for `.md` files.

- **If reference files exist:** activate the **create-reference-catalog** skill. It scans the files, extracts or collaborates on frontmatter, and returns a catalog table. Hold onto the table for step 5.
- **If `_reference/` is empty or doesn't exist:** skip this step. No catalog to build.

### 4. Gather project description

Before building CLAUDE.md, check whether there's enough project-specific context to write a meaningful intro paragraph and populate the sections.

Check for project documentation or code outside of `.claude/` — things like `src/`, `docs/`, `plans/`, `inputs/`, `README.md`, or other project files.

- **If the project repo has existing files:** Read key files to understand the project. Use what you find as context for the CLAUDE.md intro paragraph and to inform how `_docs/` content is applied to this project.
- **If the project repo is empty or minimal:** Ask the user to describe their project — what they're building, and any important context. A few sentences is enough. This description will be used for the CLAUDE.md intro paragraph.

Hold onto this project description for step 5.

### 5. Build CLAUDE.md

Check `.claude/_docs/` for files.

**If `_docs/` has content:**

Activate the **create-claudemd** skill. Pass it:
- The reference catalog table from step 3 (if one was built).
- The project description from step 4.

The skill reads `_docs/`, condenses and routes content into CLAUDE.md sections, inserts the catalog table and session management rules, and writes `CLAUDE.md` to the project root. The project description is used for the intro paragraph at the top of the file.

**If `_docs/` is empty or doesn't exist:**

Stop and inform the user. The `_docs/` directory should have been seeded in step 2. If it's still empty, something went wrong — ask the user to verify the plugin is installed correctly and that `.claude/_docs/` contains governance source files before retrying.

### 6. Present to user

Show the user the written CLAUDE.md. They review and edit as they see fit. Init is done.

---

## Re-run Behavior

- **Directories:** created if missing, skipped if they exist. Not destructive.
- **`_docs/` and `_reference/` seeding:** skipped if the project already has files in these directories. Existing files are never overwritten.
- **CLAUDE.md:** create-claudemd replaces its owned sections (Repo Structure, Coding Conventions, Reference Documentation, Session Management) and preserves everything else (Development Rules, user-added sections).
- **Development Rules:** checks `session/learnings/dev-rules.md` for `Updated: No` entries and folds them in.

---

## Does NOT Create

- `.claude/` skill/command structure — the plugin ships with this already in place.
- Project primer — created by the prime skill when the user is ready.
- Feature contexts — emerge during work.
- Session files (STATUS.md, learnings) — created by summarize skills on first write.
- Project root directories (`src/`, `docs/`, `plans/`) — created when work starts.
