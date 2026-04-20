# Create Flow

Interactive creation. Check existing sources first, then fill gaps with user input.

## 1. Gather project summary

Check these sources in order for a project summary:

1. Root `CLAUDE.md` — look for an existing project summary or description
2. `specs/project-context.md`
3. A project overview file in `inputs/`

**Source found?** → Use it to draft the Overview section. Present to the user for confirmation.

**No source found?** → Ask the user: "What is this project? Elevator pitch — what is it, what problem does it solve?"

## 2. Gather project status

Check these sources in order for project status:

1. An existing project primer (`.claude/commands/prime/project-primer.md`) — read the Current State section
2. Plan files in `plans/` — read phase statuses to infer where the project stands

**Source found?** → Use it to draft the Current State section. Present to the user for confirmation.

**No source found?** → Ask the user: "What's the current state? Which areas are in progress, complete, what's the direction?"

## 3. Gather key files

Explore the file system conversationally. Scan `specs/`, `plans/`, `inputs/`, and project root. Present what you find, let the user confirm which to include. Each included file gets a one-liner.

Handle sparse answers gracefully. Brief sections are valid.

## 4. Draft the primer

Assemble from gathered content following the output schema in the parent SKILL.md:

- **Overview:** Condensed from step 1 source or user input. Clear and specific.
- **Current State:** From step 2 source or user input. Trajectory altitude — "auth system in active development, data pipeline complete" — not a task list.
- **Key Project Files:** From step 3. File path + one-liner per entry. If no files, leave just the directive text with no list items.

## 5. Present and write

Show the complete primer for review. After confirmation, write to `.claude/commands/prime/project-primer.md`.

If the file already exists, warn and ask — overwrite or cancel.
