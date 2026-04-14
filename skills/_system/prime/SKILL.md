---
name: prime
description: Session-start context loader. Loads project primer and feature contexts into the conversation by running them as slash commands. Manages feature selection, sub-feature traversal, and active-feature tracking. Triggers on session start, "load context", "switch feature", "prime", "load project", "change feature". Do NOT use for reading a single feature file — use /prime:features:{name} directly.
---

# Prime

Orchestrates context loading by running context files as commands. Does not contain context content itself — it checks what exists, presents choices, invokes commands, and tracks the active feature.

---

## Rules

These govern every step below.

- **Run commands, don't read files.** Context files in `commands/prime/` are commands with directives (like reading Key Files). Use `/prime:project-primer` and `/prime:features:{name}`, not the Read tool.
- **Parent contexts stay loaded.** Sub-features are additive, not replacements.
- **Only this skill writes `active-feature.txt`.** Running `/prime:features:{name}` directly mid-session is read-only — it does not change the active feature.

---

## Routing

**Session start (no context loaded yet)?** → Follow the Session Start Flow.

**Mid-session re-run (switching features)?** → Follow the Mid-Session Flow.

---

## Session Start Flow

### 1. Check project state

Check if both `.claude/commands/prime/project-primer.md` and `.claude/commands/prime/features/` are empty (no primer, no features).

**Both empty (first-ever session)?** → Ask:

> "No project context exists yet. Want to set up a project primer and your first feature, or just start working?"

- Setup → invoke `/context-scaffolding-plugin:create-project-primer`, then `/context-scaffolding-plugin:create-feature`
- Just work → skip to step 4

**Either exists?** → Proceed to step 2.

### 2. Load project primer

**`project-primer.md` exists?** → Run `/prime:project-primer`.

**Missing?** → Ask: "No project primer exists. Create one?" Yes → invoke `/context-scaffolding-plugin:create-project-primer`. No → proceed.

### 3. Select and load feature

Scan `.claude/commands/prime/features/` for `.md` files at the top level only (not subdirectories).

**Features exist?** → Present the list with options:
- Select an existing feature
- Create a new feature → invoke `/context-scaffolding-plugin:create-feature`
- Skip feature selection

**No features exist?** → Ask: "No feature contexts exist. Create one, or skip?" Create → invoke `/context-scaffolding-plugin:create-feature`. Skip → proceed.

**When a feature is selected:**

1. Run the feature command (e.g., `/prime:features:auth-system`)
2. Check for a matching subdirectory (e.g., `features/auth-system/`):
   - **Contains `.md` files?** → Present sub-feature options: select existing, create new (invoke `/context-scaffolding-plugin:create-feature` with parent), or proceed at current level
   - **Sub-feature selected?** → Run that sub-feature command. Check for deeper nesting. Repeat.
   - **No subdirectory or user skips?** → Proceed with current selection.

### 4. Write active-feature.txt

**Feature selected?** → Write the deepest selected feature key to `session/active-feature.txt`.

- Format: single line, feature key with full nested path for sub-features
- Examples: `auth-system`, `auth-system/jwt-tokens`, `data-pipeline/extraction`
- Path mapping: `auth-system/jwt-tokens` → `commands/prime/features/auth-system/jwt-tokens.md`

**No feature selected?** → Delete `session/active-feature.txt` if it exists. No stale state from prior sessions.

### 5. Confirm

State what was loaded:
- "Loaded project primer and auth-system feature context. Ready to work."
- "Loaded project primer. No feature selected. Ready to work."
- "No context loaded. Ready to work."

---

## Mid-Session Flow

When the user runs prime again to switch features:

1. Read `session/active-feature.txt` if it exists
2. Acknowledge current feature: "Currently working on [feature]. Want to switch?"
3. Run step 3 (Select and load feature) from the Session Start Flow
4. Update `active-feature.txt` per step 4 (overwrite with new selection, or delete if skipped)
