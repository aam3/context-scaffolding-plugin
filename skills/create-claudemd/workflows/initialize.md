# Initialize Workflow

Full first-time setup. Seeds governance files from plugin defaults, pauses for user review, scans references, gathers project description, assembles and writes CLAUDE.md.

---

## Step 1: Seed `_docs/`

Check if `.claude/_docs/` already has `.md` files.

**If empty:** Copy plugin defaults into the project:

```bash
cp -n ${CLAUDE_SKILL_DIR}/../../_docs/*.md .claude/_docs/
```

Confirm copy succeeded by listing `.claude/_docs/`.

**If already has files:** Skip. User has customized their docs.

---

## Step 2: Seed `_reference/`

Check if `.claude/_reference/` already has `.md` files (recursively).

**If empty:** Copy plugin defaults:

```bash
cp -rn ${CLAUDE_SKILL_DIR}/../../_reference/* .claude/_reference/
```

Confirm copy succeeded by listing `.claude/_reference/` recursively.

**If already has files:** Skip.

---

## Step 3: Pause for user review

Present a summary of what was seeded (or that seeding was skipped). Explain these files are the source material CLAUDE.md will be assembled from.

The user may want to:
- Edit `_docs/` files to match their project's structure, conventions, and constraints
- Remove `_reference/` files for Claude Code features they don't use
- Add their own `_docs/` files with project-specific governance content

**Pause here until the user confirms they are ready to continue.**

---

## Step 4: Build reference catalog

Scan `.claude/_reference/` recursively for `.md` files.

- **No files found:** Skip. No catalog to build.
- **Files found:** Follow the Reference Catalog Procedure in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md`. Hold onto the resulting table for Step 7.

---

## Step 5: Gather project description

Check for project documentation or code outside of `.claude/` — `src/`, `docs/`, `plans/`, `inputs/`, `README.md`, or other project files.

- **Project has existing files:** Read key files to understand the project. Use as context for the CLAUDE.md intro paragraph and to inform how `_docs/` content is applied.
- **Project is empty or minimal:** Ask the user to describe their project — what they are building and any important context. A few sentences is enough.

Hold onto this project description for Step 7.

---

## Step 6: Read and route `_docs/` content

Read all files in `.claude/_docs/`. If `_docs/` is empty, stop and inform the user that governance source files are needed before CLAUDE.md can be built.

Route and condense content following the Content Routing Procedure and Condensing Procedure in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md`.

---

## Step 7: Assemble and write CLAUDE.md

Assemble CLAUDE.md following the Assembly Procedure in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md`. Use the reference catalog from Step 4, the project description from Step 5, and the routed content from Step 6.

Write to `CLAUDE.md` at the project root (not inside `.claude/`).

---

## Step 8: Present to user

Show the written CLAUDE.md for review. The user can edit as they see fit.
