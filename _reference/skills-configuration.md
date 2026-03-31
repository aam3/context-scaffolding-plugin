---
topic: Skills configuration
last_synced: 2026-02-23
description: Creating, configuring, and managing Claude Code skills — SKILL.md format, frontmatter, references, auto-discovery
---

# Skills — Configuration & Setup

**Last synced:** 2026-02-23

Reference for creating, configuring, and managing Claude Code skills. Once configured, see [skills-writing-guide.md](skills-writing-guide.md) to write and organize content.

---

## Skill Fundamentals

Reusable instruction packages that extend Claude's capabilities. Each skill is a directory with a `SKILL.md` file. Claude uses skills automatically when relevant, or you invoke one directly with `/skill-name`.

Skills follow the [Agent Skills](https://agentskills.io) open standard. They replace the older `.claude/commands/` pattern — skills take precedence on name conflicts, but commands still work.

**Content types:** Skills are either **reference** (knowledge Claude applies to current work — conventions, patterns, domain rules; runs inline) or **task** (step-by-step actions — deploy, generate, commit; often `disable-model-invocation: true`). Content type shapes both configuration choices and writing approach.

**Loading model (progressive disclosure):** Claude loads skill metadata at startup (~100 tokens each). Full instructions load only when triggered. Bundled files load only as needed.

| Layer | What goes here | When loaded |
|-------|---------------|-------------|
| **Description** (~100 words) | Trigger logic | Always in context |
| **SKILL.md body** (<500 lines) | Core workflow, rules, formats | When skill activates |
| **Bundled files** (unlimited) | Deep references, large examples, scripts | On demand |

The context window is shared — your skill competes with the system prompt, conversation history, other skills' metadata, and the user's request.

Enable extended thinking by including the word "ultrathink" in skill content.

---

## Minimum Viable Skill

```yaml
---
name: my-skill-name
description: Does X and Y. Use when the user asks about Z or mentions W.
---

# My Skill Name

## Instructions
Step-by-step guidance here.
```

One file, two frontmatter fields, markdown body.

---

## Directory Structure

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

---

## Frontmatter Fields

All fields are optional. Only `description` is recommended.

| Field                      | Default          | Constraints | Description                                                           |
|:---------------------------|:-----------------|:------------|:----------------------------------------------------------------------|
| `name`                     | directory name   | Lowercase, numbers, hyphens. Max 64 chars. No `anthropic`/`claude`. No XML. | Slash command name. |
| `description`              | first paragraph  | Max 1024 chars. Third person. No XML tags. | What it does + when to use it. See [writing guide](skills-writing-guide.md#description-authoring). |
| `argument-hint`            | —                | — | Autocomplete hint. e.g. `[issue-number]` |
| `disable-model-invocation` | `false`          | — | `true` = only user can invoke (via `/name`). |
| `user-invocable`           | `true`           | — | `false` = hidden from `/` menu. Only Claude can invoke. |
| `allowed-tools`            | —                | — | Tools Claude can use without permission while skill active. |
| `model`                    | —                | — | Override model when skill is active. |
| `context`                  | —                | — | `fork` = run in isolated subagent. |
| `agent`                    | `general-purpose`| — | Subagent type when `context: fork`. Options: `Explore`, `Plan`, custom. |
| `hooks`                    | —                | — | Hooks scoped to this skill's lifecycle. |

### Skill Naming

Use **kebab-case** (lowercase-with-hyphens). Folder name must match the `name` field.

```
Good: pr-summary, deep-research, pdf-processor, code-review
Bad:  PR_Summary, DeepResearch, pdf processor, codeReview
```

Keep names short (1–3 words), descriptive, and action- or domain-oriented.

**Avoid:** vague (`helper`, `utils`), generic (`documents`, `data`), reserved words (`anthropic-helper`, `claude-tools`), and mismatches between directory name and `name` field.

---

## Invocation Control

| Config                           | User invokes | Claude invokes | Context behavior                              |
|:---------------------------------|:-------------|:---------------|:----------------------------------------------|
| *(defaults)*                     | Yes          | Yes            | Description always loaded; full content on use |
| `disable-model-invocation: true` | Yes          | No             | Not in context; loads when user invokes        |
| `user-invocable: false`          | No           | Yes            | Description always loaded; full content on use |

**Use `disable-model-invocation: true`** for side-effect workflows: deploy, commit, send messages.

**Use `user-invocable: false`** for background knowledge Claude should apply but users shouldn't invoke directly.

`user-invocable: false` only hides from the `/` menu — it does NOT block the Skill tool.

---

## String Substitutions

| Variable               | Description                                                              |
|:-----------------------|:-------------------------------------------------------------------------|
| `$ARGUMENTS`           | All args passed when invoking. Auto-appended if not present in content.  |
| `$ARGUMENTS[N]` / `$N`| Specific arg by 0-based index. e.g. `$0`, `$1`, `$2`                    |
| `${CLAUDE_SESSION_ID}` | Current session ID.                                                      |
| `` !`command` ``       | Shell command output. Runs **before** Claude sees content; output replaces the placeholder. |

**Example:**
```yaml
---
name: migrate
description: Migrate a component between frameworks
---
Migrate the $0 component from $1 to $2.
```
`/migrate SearchBar React Vue` → "Migrate the SearchBar component from React to Vue."

---

## Skill Locations

| Scope      | Path                                     | Applies to            |
|:-----------|:-----------------------------------------|:----------------------|
| Enterprise | Via managed settings                     | All org users         |
| Personal   | `~/.claude/skills/<name>/SKILL.md`       | All your projects     |
| Project    | `.claude/skills/<name>/SKILL.md`         | This project only     |
| Plugin     | `<plugin>/skills/<name>/SKILL.md`        | Where plugin enabled  |

**Priority:** enterprise > personal > project. Plugin skills use `plugin-name:skill-name` namespace (no conflicts).

**Auto-discovery:** Claude finds skills in nested `.claude/skills/` dirs (supports monorepos). Skills from `--add-dir` directories are also loaded and support live editing.

**Sharing:** Commit `.claude/skills/` to version control (project), add `skills/` to your plugin (plugin), or deploy via managed settings (org-wide).

---

## Multi-File Skills

### File Splitting

SKILL.md is always loaded when the skill triggers — use this guarantee. Put essential principles in SKILL.md so they can't be skipped. Move detailed reference material to bundled files.

Split when approaching the 500-line SKILL.md limit. **Keep references one level deep.** SKILL.md → bundled file is fine. SKILL.md → A.md → B.md is not — Claude may only partially read deeply nested files. Add a table of contents to reference files over 100 lines.

### Router Pattern

For skills with multiple distinct workflows, separate routing, procedures, and knowledge into different files.

```
skill-name/
├── SKILL.md              # Router + essential principles (always loaded)
├── workflows/            # Step-by-step procedures
│   ├── workflow-a.md
│   └── workflow-b.md
└── references/           # Domain knowledge
    ├── reference-a.md
    └── reference-b.md
```

| Problem | Cause | Solution |
|---------|-------|----------|
| Essential principles get skipped | Important content is in a bundled file Claude may not read | Put essential principles directly in SKILL.md |
| Wrong context loaded | A "build" task loads debugging references | Intake question → routes to specific workflow → workflow specifies references |
| Monolithic skill is overwhelming | 500+ lines of mixed content | Small router (SKILL.md) + focused workflows + reference library |
| Procedures mixed with knowledge | "How to do X" interleaved with "What X means" | Workflows contain procedures. References contain knowledge. |

**Use router pattern when:**
- Multiple distinct workflows (build vs debug vs ship)
- Different workflows need different references
- Essential principles must not be skipped
- Skill has grown beyond 200 lines

**Use single-file skill when:**
- One workflow
- Small reference set
- Under 200 lines total

**Content placement:**

| Location | Contains |
|----------|----------|
| **SKILL.md** (always loaded) | Essential principles, intake question, routing logic |
| **workflows/** | Step-by-step procedures, required references for that workflow, success criteria |
| **references/** | Patterns, examples, technical details, domain expertise |

For guidance on writing router content and workflow files, see [skills-writing-guide.md](skills-writing-guide.md#router-content).

---

## Subagents, Tool Restrictions, and Permissions

### Subagents (`context: fork`)

Runs the skill in isolation — no conversation history. The skill content becomes the subagent's task prompt.

Only use `context: fork` for skills with explicit tasks. Guidelines-only skills produce no useful output in a subagent.

### Tool Restrictions

```yaml
---
name: safe-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
```

### Permission Control

**Disable all skills:** Add `Skill` to deny rules in `/permissions`.

**Allow/deny specific skills:**
```
Skill(commit)         # exact match
Skill(review-pr *)    # prefix match
```

---

## Examples

### Task skill (user-only, manual trigger)

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---

Deploy $ARGUMENTS to production:
1. Run test suite
2. Build application
3. Push to deployment target
```

### Reference skill (Claude-only, background knowledge)

```yaml
---
name: api-conventions
description: API design patterns for this codebase
user-invocable: false
---

When writing API endpoints:
- Use RESTful naming
- Return consistent error formats
```

### Forked subagent skill

```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files
2. Analyze the code
3. Summarize with file references
```

### Dynamic context injection

```yaml
---
name: pr-summary
description: Summarize PR changes
context: fork
agent: Explore
---

PR diff: !`gh pr diff`
Changed files: !`gh pr diff --name-only`

Summarize this pull request.
```

---

## Troubleshooting

| Problem                  | Fix                                                                         |
|:-------------------------|:----------------------------------------------------------------------------|
| Skill not triggering     | Check description has matching keywords. Verify with "What skills are available?" Try `/skill-name` directly. |
| Triggers too often       | Make description more specific, or set `disable-model-invocation: true`.    |
| Claude doesn't see skill | Too many skills may exceed char budget (~2% of context window, ~16K chars fallback). Check `/context` for warnings. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. |

---

## Platform Differences

| | Claude Code | Claude API | claude.ai |
|---|---|---|---|
| Custom skills | Yes (filesystem) | Yes (upload via `/v1/skills`) | Yes (zip upload in Settings) |
| Pre-built skills | No | Yes (pptx, xlsx, docx, pdf) | Yes |
| Network access | Full | None | Varies |
| Sharing | Git commit / plugins | Workspace-wide | Individual only |
| Package install | Local only | Pre-installed only | npm/PyPI/GitHub |

Skills do NOT sync across platforms. Manage separately for each.

---

**Sources:**
- https://code.claude.com/docs/en/skills
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart
