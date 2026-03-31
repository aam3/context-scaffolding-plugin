---
topic: Subagents
last_synced: 2026-02-22
description: Specialized AI assistants with custom context, tool access, and permissions — delegation and orchestration
---

# Claude Code Subagents — Complete Reference

**Last synced:** 2026-02-22

---

## What Are Subagents?

Specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates tasks to them based on their `description` field and returns results to the main conversation.

**Key constraint:** Subagents cannot spawn other subagents.

---

## Built-in Subagents

| Agent           | Model   | Tools      | Purpose                                        |
|:----------------|:--------|:-----------|:-----------------------------------------------|
| Explore         | Haiku   | Read-only  | Fast codebase search/analysis. Thoroughness: quick, medium, very thorough |
| Plan            | Inherit | Read-only  | Research for plan mode                         |
| general-purpose | Inherit | All        | Complex multi-step tasks needing read + write  |
| Bash            | Inherit | Bash       | Terminal commands in separate context           |
| Claude Code Guide | Haiku | Read-only  | Questions about Claude Code features           |

---

## File Format

Markdown file with YAML frontmatter + system prompt body:

```markdown
---
name: my-agent
description: When Claude should delegate to this agent
tools: Read, Grep, Glob
model: sonnet
---

You are a [role]. When invoked:
1. Do X
2. Do Y
3. Return results
```

The body becomes the subagent's system prompt. It receives only this prompt (plus basic environment info like working directory), **not** the full Claude Code system prompt.

---

## Where Subagents Live

| Location                 | Scope           | Priority     | Notes                                    |
|:-------------------------|:----------------|:-------------|:-----------------------------------------|
| `--agents` CLI flag      | Current session | 1 (highest)  | JSON, not saved to disk                  |
| `.claude/agents/`        | Project         | 2            | Check into version control for team use  |
| `~/.claude/agents/`      | All projects    | 3            | Personal, available everywhere           |
| Plugin's `agents/` dir   | Plugin scope    | 4 (lowest)   | Installed with plugins                   |

Same-name subagents: higher priority wins.

---

## Frontmatter Fields

| Field             | Required | Description                                                                     |
|:------------------|:---------|:--------------------------------------------------------------------------------|
| `name`            | **Yes**  | Unique ID. Lowercase letters and hyphens only.                                  |
| `description`     | **Yes**  | When Claude should delegate. Include "use proactively" to encourage auto-use.   |
| `tools`           | No       | Allowed tools (allowlist). Inherits all if omitted.                             |
| `disallowedTools` | No       | Tools to deny (denylist). Removed from inherited/specified list.                |
| `model`           | No       | `sonnet`, `opus`, `haiku`, or `inherit` (default).                              |
| `permissionMode`  | No       | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan`.            |
| `maxTurns`        | No       | Max agentic turns before stopping.                                              |
| `skills`          | No       | Skills to preload into context at startup. Full content injected, not just available. |
| `mcpServers`      | No       | MCP servers available to this subagent.                                         |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent.                                        |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`.                         |
| `background`      | No       | `true` = always run as background task. Default: `false`.                       |
| `isolation`       | No       | `worktree` = run in temporary git worktree (auto-cleaned if no changes).        |

---

## Tools

Subagents can use any [internal Claude Code tool](https://code.claude.com/docs/en/settings#tools-available-to-claude). Control access via:

- **`tools`** (allowlist): Only these tools available
- **`disallowedTools`** (denylist): These tools removed from available set

```yaml
tools: Read, Grep, Glob, Bash
disallowedTools: Write, Edit
```

### Restricting spawnable subagents

When an agent runs as main thread with `claude --agent`, use `Task(name)` syntax:

```yaml
tools: Task(worker, researcher), Read, Bash   # only these subagents
tools: Task, Read, Bash                        # any subagent
# omit Task entirely = no subagent spawning
```

This only applies to `claude --agent` main threads, not subagent definitions.

---

## Permission Modes

| Mode                | Behavior                                              |
|:--------------------|:------------------------------------------------------|
| `default`           | Standard permission prompts                           |
| `acceptEdits`       | Auto-accept file edits                                |
| `dontAsk`           | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all checks (**use with caution**)                |
| `plan`              | Read-only exploration                                 |

Parent `bypassPermissions` overrides all and cannot be changed.

---

## Persistent Memory

Gives the subagent a directory that persists across conversations.

```yaml
memory: user
```

| Scope     | Location                                      | Use case                                |
|:----------|:----------------------------------------------|:----------------------------------------|
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings across all projects (recommended default) |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via VCS     |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked in        |

When enabled: first 200 lines of `MEMORY.md` auto-included in system prompt. Read/Write/Edit tools auto-enabled.

---

## Preloading Skills

Injects full skill content into subagent context at startup. Subagents do NOT inherit parent skills — list them explicitly.

```yaml
skills:
  - api-conventions
  - error-handling-patterns
```

This is the inverse of a skill's `context: fork` (where the skill controls the prompt and picks an agent type).

---

## Hooks

### In subagent frontmatter (runs while subagent is active)

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```

Supported events: `PreToolUse`, `PostToolUse`, `Stop` (auto-converted to `SubagentStop`).

### In settings.json (runs in main session)

```json
{
  "hooks": {
    "SubagentStart": [{ "matcher": "db-agent", "hooks": [{ "type": "command", "command": "./scripts/setup.sh" }] }],
    "SubagentStop": [{ "hooks": [{ "type": "command", "command": "./scripts/cleanup.sh" }] }]
  }
}
```

Hook scripts receive JSON via stdin. Exit code `2` blocks the operation.

---

## Foreground vs Background

| Mode       | Behavior                                                                    |
|:-----------|:----------------------------------------------------------------------------|
| Foreground | Blocks main conversation. Permission prompts pass through to user.          |
| Background | Runs concurrently. Permissions pre-approved at launch. MCP tools unavailable. |

- Ask Claude to "run this in the background" or press **Ctrl+B** to background a running task.
- Failed background subagents can be resumed in foreground.
- Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

---

## Resuming Subagents

Each invocation is fresh by default. To continue where a subagent left off, ask Claude to resume it — it retains full conversation history.

Transcripts stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

---

## Disabling Subagents

In settings or permissions:

```json
{ "permissions": { "deny": ["Task(Explore)", "Task(my-custom-agent)"] } }
```

Or via CLI: `claude --disallowedTools "Task(Explore)"`

---

## CLI-Defined Subagents

For one-off sessions or automation:

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob"],
    "model": "sonnet"
  }
}'
```

Accepts same fields as frontmatter. Use `prompt` for the system prompt body.

---

## Creating Subagents

**Interactive:** Run `/agents` in Claude Code → Create new agent → choose scope → generate or write manually.

**Manual:** Create a `.md` file in the appropriate agents directory. Restart session or use `/agents` to load.

**CLI listing:** Run `claude agents` to see all configured subagents.

---

## When to Use Subagents vs Main Conversation

**Use subagents when:**
- Task produces verbose output (tests, logs, docs)
- You want enforced tool restrictions
- Work is self-contained and can return a summary
- You want parallel independent research

**Use main conversation when:**
- Frequent back-and-forth needed
- Multiple phases share significant context
- Quick, targeted change
- Latency matters (subagents start fresh)

**Consider skills instead** when you want reusable prompts that run in the main conversation context.

---

## Best Practices

- **Focused scope:** Each subagent should excel at one task
- **Detailed descriptions:** Claude uses these to decide when to delegate
- **Minimal tools:** Grant only what's needed
- **Version control:** Check project subagents (`.claude/agents/`) into VCS
- **Memory instructions:** Include prompts to read/update memory in the system prompt

---

**Source:** <https://code.claude.com/docs/en/sub-agents>
