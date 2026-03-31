---
name: claudemd-principles
description: Principles governing the authoring of all CLAUDE.md files
applies-to: all CLAUDE.md files
---

# CLAUDE.md Principles

Governs how CLAUDE.md files are authored and maintained. CLAUDE.md is loaded before every conversation — structure and brevity directly affect Claude's performance.

---

## Purpose

CLAUDE.md holds project-specific instructions that persist across sessions: conventions, commands, architecture, style, and gotchas. Without it, context is lost between sessions and Claude makes wrong assumptions. This is a largely *static* file: it should not include frequently-changing information, such as status updates.

---

## Placement

| Location | Scope | Version control |
|---|---|---|
| Project root `CLAUDE.md` | Whole project | Commit |
| `.claude/CLAUDE.md` | Whole project (alt) | Commit |
| `~/.claude/CLAUDE.md` | All projects (user-level) | No |
| `CLAUDE.local.md` | Personal preferences | `.gitignore` |
| Subdirectory `CLAUDE.md` | That subtree only | Commit |

Subdirectory files load only when Claude works in that part of the codebase — useful for monorepos or modules with distinct conventions.

The filename is case-sensitive: must be exactly `CLAUDE.md`.

---

## Essential Content

- **Project context** — one-liner orienting Claude ("Next.js e-commerce app with Stripe integration")
- **Code style** — specific, actionable preferences (not "format code properly")
- **Commands** — exact commands for test, build, lint, deploy
- **Architecture** — key directories and their purposes
- **Gotchas** — project-specific warnings, files that shouldn't be modified, quirky behaviors

---

## Structure

- Clear markdown headings for each content section
- Bullet points for scannability
- Specific commands over vague instructions
- Under 300 lines — every line competes for attention with actual work
- Move detailed guidance to separate files via `@imports`

---

## @Imports

Reference external files with `@path/to/file` syntax to keep the main file lean:

```markdown
See @docs/api-patterns.md for API conventions
See @package.json for available scripts
```

Supports relative paths, absolute paths, and `~/.claude/` paths. Imports can be recursive — use sparingly.

---

## Modular Rules

For larger projects, `.claude/rules/` splits instructions into focused files that load automatically with the same priority as CLAUDE.md:

```
.claude/rules/
├── code-style.md
├── testing.md
└── security.md
```

Useful when different teams own different rule sets — no merge conflicts in one giant file.

---

## Maintenance

- **Add as you work** — when Claude makes a wrong assumption, add the correction to CLAUDE.md
- **Review periodically** — consolidate redundant rules, remove outdated ones
- **Update from PR reviews** — undocumented conventions surfaced in reviews belong in CLAUDE.md
- **Emphasize sparingly** — "IMPORTANT" and "MUST" increase attention but aren't guarantees; if everything is emphasized, nothing is