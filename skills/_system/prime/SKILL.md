---
name: prime
description: Session-start context loader. Loads project primer and feature contexts, manages feature selection and sub-feature traversal. Activate at the start of every session or to switch features mid-session.
---

# Prime

Thin orchestrator for session-start context loading. Checks for context files, runs them as commands, manages feature selection and nesting traversal. Does not contain context loading logic itself — the context files are commands that handle their own directives.

---

## Flow

### 1. Check project state

Check if both `.claude/commands/prime/project-primer.md` and `.claude/commands/prime/features/` are empty (no primer file, no feature files).

**If both are empty (first-ever session):**

Collapse into a single onboarding prompt:

> "No project context exists yet. Want to set up a project primer and your first feature, or just start working?"

- If user wants setup → activate the create-project-primer skill, then the create-feature skill.
- If user wants to just work → proceed without context. Skip to step 4.

**If either exists:** proceed through steps 2 and 3.

### 2. Project primer

Check if `.claude/commands/prime/project-primer.md` exists.

- **Exists** → run `/prime:project-primer`. The primer command handles its own directives (reading Key Project Files). Do not read the file directly — run it as a command.
- **Missing** → ask the user: "No project primer exists yet. Want to create one?" If yes, activate the create-project-primer skill. If no, proceed without.

### 3. Feature selection

Scan `.claude/commands/prime/features/` for `.md` files at the top level only (not in subdirectories).

**If features exist:**

Present the list to the user. Options:
- Select an existing feature (by name)
- Create a new feature (activates the create-feature skill)
- Skip feature selection

**If no features exist:**

Ask: "No feature contexts exist. Want to create one, or skip?" If create, activate the create-feature skill. If skip, proceed.

**When user selects a feature:**

1. Run the feature command (e.g., `/prime:features:auth-system`). The feature command handles its own directives (reading Key Files). Do not read the file directly — run it as a command.

2. Check for a matching subdirectory (e.g., `features/auth-system/`). If it exists and contains `.md` files:
   - Present sub-feature options:
     - Select an existing sub-feature
     - Create a new sub-feature (activates create-feature skill with parent)
     - Proceed at current level
   - If user selects a sub-feature → run that sub-feature command. Check for deeper nesting. Repeat.
   - Parent contexts stay loaded — sub-features are additive, not replacements.

3. If user skips or no subdirectory exists → proceed with current selection.

### 4. Write active-feature.txt

**If a feature was selected:**

Write the deepest selected feature key to `session/active-feature.txt`.

- Format: single line, the feature key. Full nested path for sub-features.
- Examples: `auth-system`, `auth-system/jwt-tokens`, `data-pipeline/extraction`
- Path mapping: `auth-system/jwt-tokens` → `commands/prime/features/auth-system/jwt-tokens.md`

**If no feature was selected (user skipped):**

Delete `session/active-feature.txt` if it exists. Don't leave stale state from a prior session.

### 5. Confirm

State what was loaded. Examples:
- "Loaded project primer and auth-system feature context. Ready to work."
- "Loaded project primer. No feature selected. Ready to work."
- "No context loaded. Ready to work."

---

## Mid-Session Re-run

If the user activates prime again mid-session (to switch features):

1. Check if `session/active-feature.txt` exists.
2. If it does → read it and acknowledge the current feature: "Currently working on [feature]. Want to switch?"
3. If user confirms → run through step 3 (feature selection) again.
4. Overwrite `active-feature.txt` with the new selection (or delete it if user skips).

---

## Key Principles

- **Run commands, don't read files.** Context files in `commands/prime/` are commands. Running them loads content and executes directives (like reading Key Files). Use `/prime:project-primer` and `/prime:features:{name}`, not `Read`.
- **The skill is a decision tree with command invocations.** It doesn't contain context content — it orchestrates loading.
- **Parent contexts stay loaded** when traversing sub-features. Sub-features are additive.
- **Feature selection is the only thing that writes active-feature.txt.** Running `/prime:features:{name}` directly mid-session does NOT change the active feature — that's governed by the Session Management rule in CLAUDE.md.
