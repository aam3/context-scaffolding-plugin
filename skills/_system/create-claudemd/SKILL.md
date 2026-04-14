---
name: create-claudemd
description: Assembles or updates project root CLAUDE.md from _docs/ content, reference catalog, and session management rules. Invoke with mode argument — initialize or update.
argument-hint: "[initialize|update]"
---

# Create CLAUDE.md

Self-contained skill for assembling and maintaining the project root `CLAUDE.md`. Takes a mode argument to determine behavior.

**Mode:** `$ARGUMENTS`

- **`initialize`** — Full setup. Seeds governance files from plugin defaults, pauses for user review, scans references, gathers project description, assembles and writes CLAUDE.md.
- **`update`** — Rebuild. Re-reads `_docs/`, rebuilds owned sections, rebuilds reference catalog, preserves Development Rules and user-added sections, checks learnings.

---

## Read Authoring Principles First

Before writing any content, read `${CLAUDE_SKILL_DIR}/references/claudemd-principles.md`. Apply these principles to all content: brevity, scannability, actionable specifics, imperative voice, no frequently-changing information. Every line in CLAUDE.md costs context.

---

## Initialize Mode

Follow these steps when the mode argument is `initialize`.

### Step 1: Seed `_docs/`

Check if the project's `.claude/_docs/` already has `.md` files.

- **If empty:** Copy all `.md` files from the plugin's defaults into the project. Run:

```bash
cp -n ${CLAUDE_SKILL_DIR}/../../../_docs/*.md .claude/_docs/
```

Confirm the copy succeeded by listing `.claude/_docs/` and verifying files are present.

- **If already has files:** Skip. The user has already set up or customized their docs.

### Step 2: Seed `_reference/`

Check if the project's `.claude/_reference/` already has `.md` files (recursively, including subdirectories).

- **If empty:** Copy all files and subdirectories from the plugin's defaults. Run:

```bash
cp -rn ${CLAUDE_SKILL_DIR}/../../../_reference/* .claude/_reference/
```

Confirm the copy succeeded by listing `.claude/_reference/` recursively.

- **If already has files:** Skip.

### Step 3: Pause for user review

Present the user with a summary of what was seeded (or that seeding was skipped because files already exist). Tell the user these files are the source material that CLAUDE.md will be assembled from. Ask if they want to review or edit any files before proceeding.

The user may want to:
- Edit `_docs/` files to match their project's actual structure, conventions, and constraints.
- Remove `_reference/` files for Claude Code features they don't use.
- Add their own `_docs/` files with project-specific governance content.

**Pause here until the user confirms they are ready to continue.**

### Step 4: Build reference catalog

Scan `.claude/_reference/` recursively for `.md` files.

- **If no `.md` files exist:** Skip. No catalog to build.
- **If reference files exist:** Build the catalog table following the Reference Catalog Procedure below. Hold onto the table for Step 7.

### Step 5: Gather project description

Check for project documentation or code outside of `.claude/` — things like `src/`, `docs/`, `plans/`, `inputs/`, `README.md`, or other project files.

- **If the project repo has existing files:** Read key files to understand the project. Use what you find as context for the CLAUDE.md intro paragraph and to inform how `_docs/` content is applied.
- **If the project repo is empty or minimal:** Ask the user to describe their project — what they are building, and any important context. A few sentences is enough.

Hold onto this project description for Step 7.

### Step 6: Read and route `_docs/` content

Read all files in `.claude/_docs/`. If `_docs/` is empty or has no files, stop and inform the user that the `_docs/` directory needs governance source files before CLAUDE.md can be built.

Route and condense content following the Content Routing and Condensing procedures below.

### Step 7: Assemble and write CLAUDE.md

Assemble CLAUDE.md following the Assembly Procedure below. Use the reference catalog from Step 4, the project description from Step 5, and the routed content from Step 6.

Write to `CLAUDE.md` at the project root (not inside `.claude/`).

### Step 8: Present to user

Show the user the written CLAUDE.md for review. They can edit as they see fit.

---

## Update Mode

Follow these steps when the mode argument is `update`.

### Step 1: Read existing CLAUDE.md

Read project root `CLAUDE.md`. Identify sections by their `##` headers.

### Step 2: Rebuild reference catalog

Scan `.claude/_reference/` recursively for `.md` files. If reference files exist, build the catalog table following the Reference Catalog Procedure below. If none exist, the Reference Documentation section will be omitted.

### Step 3: Re-read and route `_docs/` content

Read all files in `.claude/_docs/`. Route and condense following the Content Routing and Condensing procedures below.

### Step 4: Rebuild owned sections

Replace these sections in the existing CLAUDE.md with rebuilt content:
- Intro paragraph (before any `##` header)
- Repo Structure
- Coding Conventions
- Reference Documentation
- Session Management

### Step 5: Preserve non-owned content

- **Preserve Development Rules entirely.** It contains rules appended by summarize that do not exist in `_docs/`. Do not overwrite or rebuild this section.
- **Preserve any non-owned sections** — any `##` header that is not one of the five standard headers was added manually by the user. Keep it in place.

### Step 6: Check learnings

Check `session/learnings/dev-rules.md` for entries where Updated = `No`. If any exist, fold them into the Development Rules section as bullets. Mark them `Updated: Yes` in dev-rules.md.

### Step 7: Write and present

Write the updated CLAUDE.md. Present to the user for review.

---

## Reference Catalog Procedure

Used by both initialize and update modes to build the Reference Documentation table.

### 1. Scan for reference files

Recursively find all `.md` files in `.claude/_reference/`, including subdirectories. If none exist, return nothing.

### 2. Extract metadata from each file

For each file, check for YAML frontmatter:

```yaml
---
topic: [display name]
last_synced: [YYYY-MM-DD]
description: [what the file covers]
---
```

**If frontmatter is present and complete:** extract all three fields.

**If frontmatter is missing or incomplete:**
- Read the file's title (first `#` heading) and opening content.
- Suggest a topic, description, and today's date for last_synced.
- Present the suggestion to the user for confirmation or editing.
- After confirmation, write the frontmatter to the top of the file.

### 3. Build the catalog table

Assemble using this format:

```markdown
Before answering questions or making decisions about the topics below, check the
corresponding reference file in `.claude/_reference/`. Read the file before
proceeding rather than relying on training knowledge, as these contain
project-specific conventions and up-to-date details.

| Topic | File | Description |
|-------|------|-------------|
| Hooks system | `_reference/hooks-reference.md` | How hooks work — configuration, script placement, event types |
| ... | ... | ... |

If a question touches on any of these topics, read the relevant file first.
If unsure whether a reference exists, list the contents of `.claude/_reference/`.
```

**File paths** are relative to `.claude/` (e.g., `_reference/hooks-reference.md`, `_reference/plugins/plugin-system.md`).

**Sort order:** alphabetical by topic.

### 4. Edge cases

- **`_reference/` has subdirectories:** include files from all levels.
- **File has frontmatter but missing fields:** prompt for the missing fields only.
- **Non-markdown files:** ignore them.

---

## Content Routing Procedure

Route at the **subsection level**, not the file level. A single `_docs/` file may contain content for multiple sections — split by its internal headings and route each piece independently.

| Section | Routes here if content is about... |
|---|---|
| Repo Structure | Directory layout, file placement, naming conventions, folder organization, phase numbering, convention-based connections, key files and their roles, project structure overview |
| Coding Conventions | Code style, formatting, language patterns, code-level rules, data models, schemas, structural/technical patterns |
| Development Rules | Development behavior, workflow constraints, communication style, interaction patterns, domain rules, domain constraints, non-negotiable business rules, project phases or process constraints |

**Project overview content** (project purpose, what it does, high-level description): condense to a 2-3 sentence intro paragraph placed before the first `##` header. Do not create a separate section.

**The section structure is fixed.** All `_docs/` content must route into Repo Structure, Coding Conventions, or Development Rules. These three plus Reference Documentation and Session Management are the only `##`-level headers allowed. Do not create sections with other names (e.g., do not create "Project Purpose", "Key Files", "Domain Rules", "Data Model", etc. as standalone sections — route that content into the appropriate standard section).

**Preserving subsections:** If a `_docs/` file has internal headings (e.g., `## Writing Style` inside a dev-rules file), preserve those as `###` subsection headings within the target `##` section. Don't flatten everything into a single bullet list — keep meaningful groupings visible.

**Content that does not fit:** Ask the user which of the standard sections it should go into. Default to Development Rules if the user doesn't have a preference.

---

## Condensing Procedure

Do **not** copy `_docs/` content verbatim. Condense — but **respect the content type**:

**Prose** (paragraphs, explanations):
- Extract the rules, conventions, and actionable guidance.
- Drop explanatory prose that isn't needed for ongoing governance.
- Convert paragraphs to bullets where possible.
- Follow claudemd-principles.md: scannable, specific, brief, imperative voice.

**Structural content** (directory trees, annotated code blocks, tables):
- **Preserve directory tree diagrams and their annotations.** These are already condensed structural information — don't flatten or simplify them further.
- Include subdirectory detail for key folders. A top-level-only tree that says `├── plans/` without showing `design/` and `implementation/` underneath makes the phase numbering rules incomprehensible.
- Brief annotations after tree items (inline comments like `# Plugin infrastructure`) are good CLAUDE.md content — keep them.
- Long paragraph descriptions below a tree item → condense to a one-line bullet.

The goal is governance-weight content, not documentation-weight content. But structural diagrams are already governance-weight — pass them through.

---

## Assembly Procedure

Build the file with exactly these sections in this order. Do not add, rename, or substitute sections. The only `##`-level headers in the output must be from this list:

**Intro paragraph** (before any `##` header):
- 2-3 sentences describing the project — what it is and what problem it solves.
- Use the project description. Supplement with any project overview content found in `_docs/`.

**Section 1: `## Repo Structure`**
- Condensed from `_docs/` content routed here.
- Must cover: project root directory layout, phase numbering convention, convention-based connection chain (plan → src via matching numbers), `.claude/` organization.
- **Project root tree:** Include subdirectories for key folders — `plans/` (showing `design/`, `implementation/`), `session/` (showing `STATUS.md`, `active-feature.txt`, `learnings/`), `src/` (showing phase-numbered examples). Without these, the phase numbering rules have no context.
- **`.claude/` tree:** Include the skill domains (`_system/`, `_reference/`, `_workflow/`) and command namespaces (`system/`, `prime/` with `features/`, `workflow/`). These are bespoke to this plugin and need to be visible.
- Use `###` subsections to separate Project Root, Phase Numbering, and .claude/ Organization — these are distinct topics.
- **Omit this section entirely** if no content routes here.

**Section 2: `## Coding Conventions`**
- Condensed from `_docs/` content routed here.
- **Omit this section entirely** if no content routes here.

**Section 3: `## Reference Documentation`**
- Insert the catalog table from the Reference Catalog Procedure exactly as built.
- Do not modify the table content.
- **Omit this section entirely** if no catalog was built.

**Section 4: `## Session Management`**
- Two hardcoded lines — do not condense or modify:

```
- Feature status lifecycle: brainstorming → designing → planning → building → complete.
- Accessing context files via `/prime:*` is read-only — does not switch the active feature.
```

- **Always include** this section.

**Section 5: `## Development Rules`**
- In initialize mode: condensed from `_docs/` content routed here.
- In update mode: **preserved entirely** from existing CLAUDE.md (not rebuilt from `_docs/`).
- **Always include the header**, even if no content routes here. This section is appended to by summarize over time.

---

## Section Ownership

| Section | Owner | Rebuilt on re-run? |
|---|---|---|
| Repo Structure | create-claudemd | Yes |
| Coding Conventions | create-claudemd | Yes |
| Reference Documentation | create-claudemd | Yes |
| Session Management | create-claudemd (hardcoded) | Yes |
| Development Rules | create-claudemd + update-dev-rules | **No** — preserved in update mode |
| (any other sections) | User | **No** — preserved |
