---
name: create-claudemd
description: Assembles or updates project root CLAUDE.md from _docs/ content, reference catalog, and session management rules. Invoke with mode argument — initialize for first-time setup, update to rebuild owned sections. Triggers on CLAUDE.md creation, reference catalog changes, governance file updates.
argument-hint: "[initialize|update]"
---

# Create CLAUDE.md

Assembles and maintains the project root `CLAUDE.md` from governance source files in `_docs/`, reference files in `_reference/`, and session management rules.

---

## Before Writing Any Content

Read `${CLAUDE_SKILL_DIR}/references/claudemd-principles.md`. Apply these principles to all content written to CLAUDE.md — brevity, scannability, actionable specifics, imperative voice. Every line costs context.

---

## Mode Routing

**Mode:** `$ARGUMENTS`

| Argument | Workflow | When |
|----------|----------|------|
| `initialize` | `workflows/initialize.md` | First-time setup — seeds files, gathers project info, builds CLAUDE.md |
| `update` | `workflows/update.md` | Rebuilds owned sections, preserves Development Rules and user sections |

Read the workflow file for the given mode and follow it exactly.

Both workflows use shared procedures in `references/assembly-procedures.md`. Read that file when a workflow step references it.

---

## Reference Index

- `references/claudemd-principles.md` — authoring principles for CLAUDE.md content (brevity, scannability, voice)
- `references/assembly-procedures.md` — shared procedures: content routing, condensing, assembly order, reference catalog, section ownership
- `workflows/initialize.md` — full setup workflow (seed files, gather context, assemble)
- `workflows/update.md` — rebuild workflow (re-read sources, rebuild owned sections, preserve user content)
