# .claude/ Repository Structure

Standard layout for the `.claude/` folder. Claude Code auto-discovers content in `skills/`, `commands/`, and `hooks/` — placement conventions are fixed by this constraint. Work with the grain.

---

## Root Layout

```
.claude/
├── CLAUDE.md
├── _docs/
├── _reference/
├── skills/
├── commands/
└── hooks/
```

---

## `CLAUDE.md` — Always-In-Context Governance

Lives at project root (not inside `.claude/`). Loaded on every message. Contains rules and conventions Claude must follow throughout the session.

**Owned sections (built by create-claudemd skill via `/system:init`):**
- Repo Structure — file placement, naming, phase numbering
- Coding Conventions — language or project-specific rules
- Reference Documentation — catalog table of `_reference/` files with topics and trigger conditions
- Session Management — active feature location, feature lifecycle, command pointers
- Dev Rules — accumulated project-specific rules (written by `/system:summarize-session`)

Keep CLAUDE.md short. It's a constitution, not an encyclopedia. Procedures and detailed instructions belong in skills and commands, not here.

---

## `_docs/` — Governance Source Files

Fixed preferences and structural conventions that get assembled into CLAUDE.md by the create-claudemd skill.

```
_docs/
├── repo-structure.md
├── claude-repo-structure.md
├── dev-rules.md
└── ...
```

These are the source-of-truth for CLAUDE.md's governance sections. Edit here, re-run `/system:init` to propagate. Don't edit CLAUDE.md's governance sections directly.

---

## `_reference/` — Active Development References

Reference documentation for active development — Claude Code docs, framework guides, project-specific conventions. These are files Claude should read *before* relying on training knowledge when a relevant topic comes up.

```
_reference/
├── hooks-reference.md
├── skills-configuration.md
├── subagents-reference.md
└── ...
```

The create-claudemd skill (called by `/system:init`) scans these files and builds a lookup table that goes in CLAUDE.md:

| Topic | File | When to consult |
|-------|------|-----------------|
| Hooks system | `_reference/hooks-reference.md` | When configuring or debugging hooks |
| Subagents | `_reference/subagents-reference.md` | When creating or managing subagents |
| ... | ... | ... |

The table tells Claude *when* to read each file and *where* to find it. When a topic is triggered, Claude reads the full reference file before proceeding. This keeps authoritative, project-specific information in play without loading every file into context at all times.

If new reference files are added, re-run `/system:init` to rebuild the catalog.

---

## `skills/` — Auto-Discovered Capabilities

Each skill is a subfolder containing a `SKILL.md`. Claude self-selects skills when relevant or hooks trigger them. Organized by domain.

```
skills/
├── _system/
│   ├── prime/
│   │   └── SKILL.md                  # Context loader: reads primer, layers features
│   ├── create-project-primer/
│   │   └── SKILL.md                  # Schema and logic for project primers
│   ├── create-feature/
│   │   └── SKILL.md                  # Schema and logic for feature contexts (create/update)
│   ├── create-claudemd/
│   │   └── SKILL.md                  # Assembles CLAUDE.md from all sources, builds reference catalog
│   ├── record-learnings/
│   │   └── SKILL.md                  # Records dev rules, domain rules, plan changes
│   ├── update-dev-rules/
│   │   └── SKILL.md                  # Propagates dev-rules to CLAUDE.md
│   └── update-status/
│       └── SKILL.md                  # Writes session entries to STATUS.md
│
├── _reference/
│   └── [domain-knowledge-skills]/
│       └── SKILL.md
│
└── _workflow/
    └── [work-procedure-skills]/
        └── SKILL.md
```

### Skill Domains

| Domain | Namespace | What belongs here |
|---|---|---|
| System | `_system/` | Operates on the `.claude/` environment — context loading, file creation, session management |
| Reference | `_reference/` | Technical and domain knowledge Claude reads passively |
| Workflow | `_workflow/` | Procedures for project work — planning, implementation phases |

### System Skills: Two Sub-Categories

Within `_system/`, skills split by naming convention:
- **`create-*`** — capability builders. Produce or update files with consistent schemas (primers, features, CLAUDE.md).
- **Everything else** — context maintainers. Load context, manage state, maintain the environment.

### Current System Skills

| Skill | Type | Purpose | Called by |
|---|---|---|---|
| `prime` | context maintainer | Loads project and feature context at session start | SessionStart hook |
| `create-project-primer` | capability builder | Schema and logic for project primers | prime skill, `/system:summarize-session` |
| `create-feature` | capability builder | Schema and logic for feature contexts (create/update) | prime skill, `/system:summarize-session` |
| `create-claudemd` | capability builder | Assembles CLAUDE.md from sources, builds reference catalog | `/system:init`, update-dev-rules |
| `record-learnings` | context maintainer | Records dev rules, domain rules, plan changes | `/system:summarize-session`, `/system:summarize-conversation` |
| `update-dev-rules` | context maintainer | Propagates dev-rules to CLAUDE.md | record-learnings |
| `update-status` | context maintainer | Writes session entries to STATUS.md | `/system:summarize-session` |

---

## `commands/` — User-Invoked Actions

Each command is a `.md` file, namespaced by subfolder. The user types a slash command to run it.

```
commands/
├── system/
│   ├── init.md                        # /system:init — one-time repo setup
│   ├── summarize-session.md            # /system:summarize-session — session-end pipeline
│   └── summarize-conversation.md      # /system:summarize-conversation — mid-session learnings
│
├── prime/
│   ├── project-primer.md              # /prime:project-primer — project context
│   └── features/
│       ├── auth-system.md             # /prime:features:auth-system
│       ├── auth-system/
│       │   ├── jwt-tokens.md
│       │   └── oauth.md
│       ├── data-pipeline.md           # /prime:features:data-pipeline
│       └── data-pipeline/
│           ├── extraction.md
│           └── transformation.md
│
└── workflow/
    └── [work-commands].md
```

### Command Domains

| Domain | Namespace | What belongs here |
|---|---|---|
| System | `system/` | Environment setup and maintenance |
| Prime | `prime/` | Priming context files only — project primer, feature contexts. No logic files. |
| Workflow | `workflow/` | User-initiated work sequences |

### `commands/prime/` Rules

This directory holds only context data files. No command logic, no procedures. The prime skill handles loading logic. The create-feature and create-project-primer skills handle creation and updates.

Files here are directly accessible via `/prime:*` for mid-session reference. This is read-only access — it does not change the active feature or trigger any loading flow.

Feature contexts can nest: `features/auth-system.md` can have a matching subdirectory `features/auth-system/` with sub-feature contexts. The prime skill traverses this nesting at session start.

---

## `hooks/` — Automatic Triggers

```
hooks/
├── hooks.json
└── scripts/
    └── session-start.sh
```

`hooks.json` defines when scripts fire. Scripts live in `hooks/scripts/`. The SessionStart hook tells Claude to run `/context-scaffolding-plugin:prime` for context loading.

---

## Conventions Summary

1. **Commands and skills are functionally equivalent** in Claude Code. The directory split is organizational.
2. **Skills are self-selected; commands are user-invoked.** If Claude can figure out when to do it, it's a skill. If the user must say "do this now," it's a command.
3. **`commands/prime/` is data only.** Context files live here for direct user access. Logic lives in skills.
4. **`_docs/` feeds CLAUDE.md's governance sections.** Edit in `_docs/`, run init to propagate.
5. **`_reference/` is cataloged, not passively stored.** The catalog table in CLAUDE.md tells Claude when to read each reference file. These are active development references, not archives.
6. **Naming is discovery.** Skills need a `SKILL.md`. Commands need a `.md` file. Hooks need `hooks.json`.
