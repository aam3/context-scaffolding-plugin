---
topic: Hooks system
last_synced: 2026-02-22
description: How hooks work in Claude Code — configuration, script placement, event types, matchers, handlers
---

# Claude Code Hooks — Complete Reference

**Last synced:** 2026-02-22

---

## What Are Hooks?

User-defined shell commands (or LLM prompts) that execute automatically at specific points in Claude Code's lifecycle. Hooks provide **deterministic** control — ensuring actions always happen rather than relying on the LLM to choose.

**Three hook types:**
- `command` — Run a shell command (most common)
- `prompt` — Single-turn LLM evaluation (yes/no decision)
- `agent` — Multi-turn LLM with tool access (can read files, run searches)

---

## Configuration Format

Three levels of nesting: **event** → **matcher group** → **hook handler(s)**

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "regex-pattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh"
          }
        ]
      }
    ]
  }
}
```

All matching hooks run **in parallel**. Identical handlers are auto-deduplicated.

### Where to Define Hooks

| Location                              | Scope                         | Shareable |
|:--------------------------------------|:------------------------------|:----------|
| `~/.claude/settings.json`             | All your projects             | No        |
| `.claude/settings.json`               | Single project                | Yes (VCS) |
| `.claude/settings.local.json`         | Single project                | No        |
| Managed policy settings               | Organization-wide             | Yes       |
| Plugin `hooks/hooks.json`             | Where plugin enabled          | Yes       |
| Skill/agent YAML frontmatter          | While component is active     | Yes       |

Use `/hooks` in Claude Code to manage interactively. Direct file edits require session restart or `/hooks` review.

**Disable all hooks:** Set `"disableAllHooks": true` in settings or toggle in `/hooks` menu.

---

## Hook Events

### Lifecycle Overview

| Event              | When it fires                                    | Matcher field          | Can block? |
|:-------------------|:-------------------------------------------------|:-----------------------|:-----------|
| `SessionStart`     | Session begins or resumes                        | source type            | No         |
| `UserPromptSubmit` | User submits prompt, before Claude processes it  | *(none)*               | Yes        |
| `PreToolUse`       | Before a tool call executes                      | tool name              | Yes        |
| `PermissionRequest`| Permission dialog appears                        | tool name              | Yes        |
| `PostToolUse`      | After a tool call succeeds                       | tool name              | No*        |
| `PostToolUseFailure`| After a tool call fails                          | tool name              | No*        |
| `Notification`     | Claude sends a notification                      | notification type      | No         |
| `SubagentStart`    | Subagent spawned                                 | agent type             | No         |
| `SubagentStop`     | Subagent finishes                                | agent type             | Yes        |
| `Stop`             | Claude finishes responding                       | *(none)*               | Yes        |
| `TeammateIdle`     | Agent team teammate about to go idle             | *(none)*               | Yes        |
| `TaskCompleted`    | Task being marked completed                      | *(none)*               | Yes        |
| `ConfigChange`     | Config file changes during session               | config source          | Yes**      |
| `WorktreeCreate`   | Worktree being created                           | *(none)*               | Yes        |
| `WorktreeRemove`   | Worktree being removed                           | *(none)*               | No         |
| `PreCompact`       | Before context compaction                        | trigger type           | No         |
| `SessionEnd`       | Session terminates                               | exit reason            | No         |

\* Can provide feedback to Claude via `decision: "block"` but tool already ran.
\** Except `policy_settings` which cannot be blocked.

---

## Matchers

Regex patterns that filter when hooks fire. Omit, use `""`, or `"*"` to match all.

| Events                                                           | Matches on         | Example values                                                    |
|:-----------------------------------------------------------------|:-------------------|:------------------------------------------------------------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name    | `Bash`, `Edit\|Write`, `mcp__github__.*`                          |
| `SessionStart`                                                   | source             | `startup`, `resume`, `clear`, `compact`                           |
| `SessionEnd`                                                     | reason             | `clear`, `logout`, `prompt_input_exit`, `other`                   |
| `Notification`                                                   | notification type  | `permission_prompt`, `idle_prompt`, `auth_success`                |
| `SubagentStart`, `SubagentStop`                                  | agent type         | `Bash`, `Explore`, `Plan`, custom names                           |
| `PreCompact`                                                     | trigger            | `manual`, `auto`                                                  |
| `ConfigChange`                                                   | config source      | `user_settings`, `project_settings`, `local_settings`, `skills`   |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove` | *(no matcher)* | Always fires |

**MCP tools** follow pattern `mcp__<server>__<tool>`. Match with `mcp__github__.*`, `mcp__.*__write.*`, etc.

---

## Hook Handler Fields

### Common Fields (all types)

| Field           | Required | Description                                           | Default |
|:----------------|:---------|:------------------------------------------------------|:--------|
| `type`          | Yes      | `"command"`, `"prompt"`, or `"agent"`                 | —       |
| `timeout`       | No       | Seconds before canceling                              | 600 / 30 / 60 |
| `statusMessage` | No       | Custom spinner text while hook runs                   | —       |
| `once`          | No       | Run only once per session (skills only)               | false   |

### Command Hook Fields

| Field     | Required | Description                              |
|:----------|:---------|:-----------------------------------------|
| `command` | Yes      | Shell command to execute                 |
| `async`   | No       | `true` = run in background, non-blocking |

### Prompt & Agent Hook Fields

| Field    | Required | Description                                                    |
|:---------|:---------|:---------------------------------------------------------------|
| `prompt` | Yes      | Prompt text. Use `$ARGUMENTS` for hook input JSON placeholder. |
| `model`  | No       | Model override (defaults to fast model)                        |

### Which Types Each Event Supports

**All three types** (`command`, `prompt`, `agent`): `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `Stop`, `SubagentStop`, `TaskCompleted`, `UserPromptSubmit`

**Command only**: `SessionStart`, `SessionEnd`, `Notification`, `SubagentStart`, `TeammateIdle`, `ConfigChange`, `PreCompact`, `WorktreeCreate`, `WorktreeRemove`

---

## Input & Output

### Common Input Fields (all events, via stdin JSON)

| Field             | Description                       |
|:------------------|:----------------------------------|
| `session_id`      | Current session identifier        |
| `transcript_path` | Path to conversation JSON         |
| `cwd`             | Current working directory         |
| `permission_mode` | Current permission mode           |
| `hook_event_name` | Name of the event that fired      |

Each event adds its own fields (see Event Details below).

### Exit Codes

| Code    | Effect                                                                   |
|:--------|:-------------------------------------------------------------------------|
| **0**   | Success. Action proceeds. stdout parsed for JSON. For `SessionStart`/`UserPromptSubmit`, stdout added as context. |
| **2**   | Block. stderr fed back to Claude as error message. stdout/JSON ignored.  |
| **Other** | Non-blocking error. stderr logged in verbose mode. Action proceeds.    |

### JSON Output (exit 0 only)

Print a JSON object to stdout for structured control:

| Field            | Default | Description                                              |
|:-----------------|:--------|:---------------------------------------------------------|
| `continue`       | `true`  | `false` = stop Claude entirely (overrides all decisions) |
| `stopReason`     | —       | Message shown to user when `continue: false`             |
| `suppressOutput` | `false` | `true` = hide stdout from verbose mode                   |
| `systemMessage`  | —       | Warning message shown to user                            |

---

## Decision Control by Event

| Events                                                               | Pattern              | Key fields                                                      |
|:---------------------------------------------------------------------|:---------------------|:----------------------------------------------------------------|
| `UserPromptSubmit`, `PostToolUse`, `PostToolUseFailure`, `Stop`, `SubagentStop`, `ConfigChange` | Top-level `decision` | `decision: "block"`, `reason`                                   |
| `PreToolUse`                                                         | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest`                                                  | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`), `updatedInput`, `updatedPermissions`, `message` |
| `TeammateIdle`, `TaskCompleted`                                      | Exit code only       | Exit 2 blocks; stderr = feedback                                |
| `WorktreeCreate`                                                     | stdout path          | Print absolute path to created worktree                         |
| All others                                                           | None                 | Side effects only (logging, cleanup)                            |

### PreToolUse JSON Example

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep"
  }
}
```

### Top-level Decision Example

```json
{
  "decision": "block",
  "reason": "Tests must pass before stopping"
}
```

---

## Event-Specific Input Fields

### SessionStart
- `source`: `"startup"`, `"resume"`, `"clear"`, `"compact"`
- `model`: model identifier
- `agent_type`: (optional) if started with `claude --agent`
- **Output:** `additionalContext` added to Claude's context. `CLAUDE_ENV_FILE` available for persisting env vars.

### UserPromptSubmit
- `prompt`: submitted text
- **Output:** `additionalContext` or plain stdout text added as context. `decision: "block"` erases prompt.

### PreToolUse
- `tool_name`, `tool_input`, `tool_use_id`
- **Tool input schemas** vary by tool (Bash: `command`; Write: `file_path`, `content`; Edit: `file_path`, `old_string`, `new_string`; Read: `file_path`; Glob: `pattern`; Grep: `pattern`; Task: `prompt`, `subagent_type`; etc.)

### PostToolUse
- `tool_name`, `tool_input`, `tool_response`, `tool_use_id`
- **Output:** `additionalContext`. For MCP tools: `updatedMCPToolOutput` replaces output.

### PostToolUseFailure
- `tool_name`, `tool_input`, `tool_use_id`, `error`, `is_interrupt`
- **Output:** `additionalContext`

### PermissionRequest
- `tool_name`, `tool_input`, `permission_suggestions`

### Stop / SubagentStop
- `stop_hook_active`: `true` if already continuing from a stop hook (check this to prevent infinite loops!)
- `last_assistant_message`: Claude's final response text
- SubagentStop adds: `agent_id`, `agent_type`, `agent_transcript_path`

### Notification
- `message`, `title`, `notification_type`

### SubagentStart
- `agent_id`, `agent_type`
- **Output:** `additionalContext` injected into subagent

### TeammateIdle
- `teammate_name`, `team_name`

### TaskCompleted
- `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name`

### ConfigChange
- `source`, `file_path`

### WorktreeCreate
- `name` (slug identifier)
- **Output:** Print absolute path to stdout

### WorktreeRemove
- `worktree_path`

### PreCompact
- `trigger`: `"manual"` or `"auto"`
- `custom_instructions`: user text from `/compact` (empty for auto)

### SessionEnd
- `reason`: `"clear"`, `"logout"`, `"prompt_input_exit"`, `"bypass_permissions_disabled"`, `"other"`

---

## Prompt & Agent Hook Response Schema

Both `type: "prompt"` and `type: "agent"` hooks must return:

```json
{ "ok": true }
```
or:
```json
{ "ok": false, "reason": "Explanation fed back to Claude" }
```

---

## Environment Variables

| Variable              | Description                                          |
|:----------------------|:-----------------------------------------------------|
| `$CLAUDE_PROJECT_DIR` | Project root (use for script paths)                  |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's root directory                            |
| `$CLAUDE_ENV_FILE`    | File path for persisting env vars (SessionStart only)|
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments                  |

---

## Async Hooks

Set `"async": true` on command hooks to run in background without blocking Claude.

- Only `type: "command"` supports async
- Cannot block or return decisions (action already proceeded)
- Output delivered on next conversation turn via `systemMessage` or `additionalContext`
- Each firing creates a separate background process

---

## Hooks in Skills & Agents

Define hooks in YAML frontmatter. Scoped to component lifetime.

```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---
```

For agents, `Stop` hooks auto-convert to `SubagentStop`.

---

## Common Patterns

### Auto-format after edits
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }]
    }]
  }
}
```

### Block protected files
```bash
#!/bin/bash
FILE_PATH=$(jq -r '.tool_input.file_path // empty')
for p in ".env" "package-lock.json" ".git/"; do
  if [[ "$FILE_PATH" == *"$p"* ]]; then
    echo "Blocked: matches protected pattern '$p'" >&2
    exit 2
  fi
done
exit 0
```

### Re-inject context after compaction
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "compact",
      "hooks": [{ "type": "command", "command": "echo 'Reminder: use Bun, not npm.'" }]
    }]
  }
}
```

### Desktop notification
```json
{
  "hooks": {
    "Notification": [{
      "matcher": "",
      "hooks": [{ "type": "command", "command": "osascript -e 'display notification \"Claude needs attention\" with title \"Claude Code\"'" }]
    }]
  }
}
```

### Prevent Stop hook infinite loop
```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi
# ... your validation logic
```

---

## Debugging

- **`/hooks`**: View, add, delete hooks interactively
- **`Ctrl+O`**: Toggle verbose mode to see hook output in transcript
- **`claude --debug`**: Full execution details (matched hooks, exit codes, output)
- **Test manually:** `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh && echo $?`

---

## Security

- Hooks run with your full user permissions
- Always quote shell variables (`"$VAR"` not `$VAR`)
- Validate/sanitize inputs; block path traversal (`..`)
- Use absolute paths or `$CLAUDE_PROJECT_DIR`
- Skip sensitive files (`.env`, `.git/`, keys)

---

## Limitations

- Hooks communicate via stdout/stderr/exit codes only — cannot trigger slash commands or tool calls
- Default timeout: 10 minutes (configurable per hook)
- `PostToolUse` cannot undo actions (tool already ran)
- `PermissionRequest` hooks don't fire in non-interactive mode (`-p`) — use `PreToolUse` instead
- `Stop` fires whenever Claude finishes responding, not only at task completion; does not fire on user interrupts

---

**Sources:**
- <https://code.claude.com/docs/en/hooks-guide>
- <https://code.claude.com/docs/en/hooks>
