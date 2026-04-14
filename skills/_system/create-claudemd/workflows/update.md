# Update Workflow

Rebuilds owned CLAUDE.md sections from current `_docs/` and `_reference/` content. Preserves Development Rules and user-added sections.

---

## Step 1: Read existing CLAUDE.md

Read project root `CLAUDE.md`. Identify sections by their `##` headers.

---

## Step 2: Rebuild reference catalog

Scan `.claude/_reference/` recursively for `.md` files.

- **Files found:** Follow the Reference Catalog Procedure in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md`.
- **No files found:** Reference Documentation section will be omitted.

---

## Step 3: Re-read and route `_docs/` content

Read all files in `.claude/_docs/`. Route and condense following the Content Routing Procedure and Condensing Procedure in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md`.

---

## Step 4: Rebuild owned sections

Replace these sections in the existing CLAUDE.md with rebuilt content:
- Intro paragraph (before any `##` header)
- Repo Structure
- Coding Conventions
- Reference Documentation
- Session Management

See the Section Ownership table in `${CLAUDE_SKILL_DIR}/references/assembly-procedures.md` for what is owned vs. preserved.

---

## Step 5: Preserve non-owned content

- **Development Rules:** Preserve entirely. Contains rules appended by summarize that do not exist in `_docs/`. Do not overwrite or rebuild.
- **Non-owned sections:** Any `##` header not in the five standard headers was added manually by the user. Keep in place.

---

## Step 6: Check learnings

Check `session/learnings/dev-rules.md` for entries where `Updated` = `No`. If any exist, fold them into the Development Rules section as bullets. Mark them `Updated: Yes` in dev-rules.md.

---

## Step 7: Write and present

Write the updated CLAUDE.md. Present to the user for review.
