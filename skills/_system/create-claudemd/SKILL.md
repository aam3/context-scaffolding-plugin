---
name: create-claudemd
description: Assembles project root CLAUDE.md from _docs/ content, reference catalog, and static session management rules
disable-model-invocation: true
---

# Create CLAUDE.md

Reads `.claude/_docs/`, condenses the content, routes it to the appropriate sections, and combines with the reference catalog table and static session management lines. Writes the result to project root `CLAUDE.md`.

---

## When Activated

Called by `/system:init`. Can also be re-run to rebuild CLAUDE.md from sources.

---

## Inputs

1. **`.claude/_docs/*`** — all files in the directory. No expected filenames. Read everything and interpret what each file is about.
2. **Reference catalog table** — output from create-reference-catalog skill (if it produced output). Passed by init.
3. **Project description** — passed by init. A short description of what the project is, gathered from existing project files or from the user directly. Used for the intro paragraph.
4. **Static session management lines** — hardcoded below.
5. **Authoring principles** — read `references/claudemd-principles.md` from this skill's directory before writing any content.

---

## Flow

### 1. Read authoring principles

Read `references/claudemd-principles.md`. Apply these principles to all content you write: brevity, scannability, actionable specifics, imperative voice, no frequently-changing information. Every line in CLAUDE.md costs context.

### 2. Read all `_docs/` files

Read every file in `.claude/_docs/`. Don't assume filenames — interpret each file's content to determine what it covers.

If `_docs/` is empty or has no files, **stop here and return control to init**. Init will inform the user that `_docs/` needs to be populated before CLAUDE.md can be built.

### 3. Route content to sections

Route at the **subsection level**, not the file level. A single `_docs/` file may contain content for multiple sections — split by its internal headings and route each piece independently.

| Section | Routes here if content is about... |
|---|---|
| Repo Structure | Directory layout, file placement, naming conventions, folder organization, phase numbering, convention-based connections, key files and their roles, project structure overview |
| Coding Conventions | Code style, formatting, language patterns, code-level rules, data models, schemas, structural/technical patterns |
| Development Rules | Development behavior, workflow constraints, communication style, interaction patterns, domain rules, domain constraints, non-negotiable business rules, project phases or process constraints |

**Project overview content** (project purpose, what it does, high-level description): condense to a 2-3 sentence intro paragraph placed before the first `##` header in the assembled file. Do not create a separate section for project description.

**The section structure is fixed.** All `_docs/` content must be routed into Repo Structure, Coding Conventions, or Development Rules. These three plus Reference Documentation and Session Management are the only `##`-level headers allowed in CLAUDE.md. Do not create sections with other names (e.g., do not create "Project Purpose", "Key Files", "Domain Rules", "Data Model", etc. as standalone sections — route that content into the appropriate standard section).

**Preserving subsections:** If a `_docs/` file has internal headings (e.g., `## Writing Style` inside a dev-rules file), preserve those as `###` subsection headings within the target `##` section. Don't flatten everything into a single bullet list — keep meaningful groupings visible.

**Content that doesn't fit:** If content doesn't clearly match any routing target, ask the user which of the standard sections it should go into. Default to Development Rules if the user doesn't have a preference.

### 4. Condense

Do **not** copy `_docs/` content verbatim. Condense it — but **respect the content type**:

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

### 5. Assemble CLAUDE.md

Build the file with exactly these sections in this order. Do not add, rename, or substitute sections. The only `##`-level headers in the output must be from this list:

**Intro paragraph** (before any `##` header):
- 2-3 sentences describing the project — what it is and what problem it solves.
- Use the project description passed by init. Supplement with any project overview content found in `_docs/`.

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
- Insert the catalog table from create-reference-catalog exactly as provided.
- Do not modify the table content.
- **Omit this section entirely** if no catalog was provided.

**Section 4: `## Session Management`**
- Three hardcoded lines — do not condense or modify:

```
- Feature status lifecycle: brainstorming → designing → planning → building → complete.
- Accessing context files via `/prime:*` is read-only — does not switch the active feature.
```

- **Always include** this section.

**Section 5: `## Development Rules`**
- Condensed from `_docs/` content routed here.
- **Always include the header**, even if no content routes here. This section is appended to by summarize over time.

### 6. Write to project root

Write the assembled content to `CLAUDE.md` at the project root (not inside `.claude/`).

### 7. Present to user

Show the user the written CLAUDE.md for review. They can edit as they see fit.

---

## Re-run Behavior

When CLAUDE.md already exists at project root:

1. Read the existing file. Identify sections by their `##` headers.
2. **Replace** these owned sections with rebuilt content:
   - Repo Structure
   - Coding Conventions
   - Reference Documentation
   - Session Management
3. **Preserve Development Rules entirely.** It contains rules appended by summarize that don't exist in `_docs/`. Do not overwrite or rebuild this section.
4. **Preserve any non-owned sections** — any `##` header that isn't one of the five standard headers was added manually by the user. Keep it in place.
5. **Check `session/learnings/dev-rules.md`** for entries where Updated = `No`. If any exist, fold them into the Development Rules section as bullets. Mark them `Updated: Yes` in dev-rules.md.

---

## Section Ownership

| Section | Owner | Rebuilt on re-run? |
|---|---|---|
| Repo Structure | create-claudemd | Yes |
| Coding Conventions | create-claudemd | Yes |
| Reference Documentation | create-reference-catalog → create-claudemd | Yes |
| Session Management | create-claudemd (hardcoded) | Yes |
| Development Rules | create-claudemd + update-dev-rules | **No** — preserved |
| (any other sections) | User | **No** — preserved |
