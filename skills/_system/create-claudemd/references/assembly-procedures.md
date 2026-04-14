---
name: assembly-procedures
description: Shared procedures for building and maintaining CLAUDE.md content
applies-to: create-claudemd skill workflows
---

# CLAUDE.md Assembly Procedures

Shared procedures used by both initialize and update workflows. Each procedure is self-contained — read the one referenced by the workflow step.

---

## Content Routing Procedure

Route at the **subsection level**, not the file level. A single `_docs/` file may contain content for multiple sections — split by internal headings and route each piece independently.

| Section | Routes here if content is about... |
|---|---|
| Repo Structure | Directory layout, file placement, naming conventions, folder organization, phase numbering, convention-based connections, key files and their roles, project structure overview |
| Coding Conventions | Code style, formatting, language patterns, code-level rules, data models, schemas, structural/technical patterns |
| Development Rules | Development behavior, workflow constraints, communication style, interaction patterns, domain rules, domain constraints, non-negotiable business rules, project phases or process constraints |

**Project overview content** (project purpose, what it does, high-level description): condense to a 2-3 sentence intro paragraph placed before the first `##` header. Do not create a separate section.

**The section structure is fixed.** All `_docs/` content must route into Repo Structure, Coding Conventions, or Development Rules. These three plus Reference Documentation and Session Management are the only `##`-level headers allowed. Do not create sections with other names (e.g., "Project Purpose", "Key Files", "Domain Rules", "Data Model" as standalone sections — route that content into the appropriate standard section).

**Preserving subsections:** If a `_docs/` file has internal headings (e.g., `## Writing Style` inside a dev-rules file), preserve those as `###` subsection headings within the target `##` section. Keep meaningful groupings visible.

**Content that does not fit:** Ask the user which standard section it should go into. Default to Development Rules if the user has no preference.

---

## Condensing Procedure

Do **not** copy `_docs/` content verbatim. Condense — but **respect the content type**:

**Prose** (paragraphs, explanations):
- Extract rules, conventions, and actionable guidance
- Drop explanatory prose not needed for ongoing governance
- Convert paragraphs to bullets where possible
- Follow claudemd-principles.md: scannable, specific, brief, imperative voice

**Structural content** (directory trees, annotated code blocks, tables):
- **Preserve directory tree diagrams and their annotations.** Already condensed structural information — don't flatten further.
- Include subdirectory detail for key folders. A top-level-only tree that says `├── plans/` without showing `design/` and `implementation/` underneath makes phase numbering rules incomprehensible.
- Brief annotations after tree items (inline comments like `# Plugin infrastructure`) are good CLAUDE.md content — keep them.
- Long paragraph descriptions below a tree item: condense to a one-line bullet.

The goal is governance-weight content, not documentation-weight content. Structural diagrams are already governance-weight — pass them through.

---

## Assembly Procedure

Build the file with exactly these sections in this order. Do not add, rename, or substitute sections. The only `##`-level headers in the output must be from this list:

**Intro paragraph** (before any `##` header):
- 2-3 sentences describing the project — what it is and what problem it solves
- Use the project description; supplement with project overview content from `_docs/`

**Section 1: `## Repo Structure`**
- Condensed from `_docs/` content routed here
- Must cover: project root directory layout, phase numbering convention, convention-based connection chain (plan -> src via matching numbers), `.claude/` organization
- **Project root tree:** Include subdirectories for key folders — `plans/` (showing `design/`, `implementation/`), `session/` (showing `STATUS.md`, `active-feature.txt`, `learnings/`), `src/` (showing phase-numbered examples). Without these, phase numbering rules have no context.
- **`.claude/` tree:** Include skill domains (`_system/`, `_reference/`, `_workflow/`) and command namespaces (`system/`, `prime/` with `features/`, `workflow/`)
- Use `###` subsections to separate Project Root, Phase Numbering, and .claude/ Organization
- **Omit entirely** if no content routes here

**Section 2: `## Coding Conventions`**
- Condensed from `_docs/` content routed here
- **Omit entirely** if no content routes here

**Section 3: `## Reference Documentation`**
- Insert the catalog table from the Reference Catalog Procedure exactly as built
- Do not modify the table content
- **Omit entirely** if no catalog was built

**Section 4: `## Session Management`**
- Two hardcoded lines — do not condense or modify:

```
- Feature status lifecycle: brainstorming -> designing -> planning -> building -> complete.
- Accessing context files via `/prime:*` is read-only — does not switch the active feature.
```

- **Always include** this section

**Section 5: `## Development Rules`**
- In initialize mode: condensed from `_docs/` content routed here
- In update mode: **preserved entirely** from existing CLAUDE.md (not rebuilt from `_docs/`)
- **Always include the header**, even if no content routes here — this section is appended to by summarize over time

---

## Reference Catalog Procedure

Builds the Reference Documentation table from `.claude/_reference/` files.

### 1. Scan for reference files

Recursively find all `.md` files in `.claude/_reference/`, including subdirectories. If none exist, return nothing.

### 2. Extract metadata from each file

Check for YAML frontmatter:

```yaml
---
topic: [display name]
last_synced: [YYYY-MM-DD]
description: [what the file covers]
---
```

**Frontmatter present and complete:** Extract all three fields.

**Frontmatter missing or incomplete:**
- Read the file's title (first `#` heading) and opening content
- Suggest a topic, description, and today's date for last_synced
- Present the suggestion to the user for confirmation or editing
- After confirmation, write the frontmatter to the top of the file

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

**Sort order:** Alphabetical by topic.

### 4. Edge cases

- **Subdirectories in `_reference/`:** Include files from all levels
- **File has frontmatter but missing fields:** Prompt for missing fields only
- **Non-markdown files:** Ignore

---

## Section Ownership

| Section | Owner | Rebuilt on update? |
|---|---|---|
| Repo Structure | create-claudemd | Yes |
| Coding Conventions | create-claudemd | Yes |
| Reference Documentation | create-claudemd | Yes |
| Session Management | create-claudemd (hardcoded) | Yes |
| Development Rules | create-claudemd + update-dev-rules | **No** — preserved in update mode |
| (any other sections) | User | **No** — preserved |
