---
topic: Agent teams
last_synced: 2026-02-22
description: Multi-agent orchestration in Claude Code — experimental feature for parallel agent coordination
---

# Claude Code Agent Teams — Complete Reference

**Last synced:** 2026-02-22

**Status:** Experimental, disabled by default.

---

## What Are Agent Teams?

Multiple Claude Code instances coordinated as a team. One session acts as **team lead**, spawning **teammates** that work independently in their own context windows, communicate directly with each other, and coordinate through a shared task list.

### Agent Teams vs Subagents

| Aspect            | Subagents                                    | Agent Teams                                      |
|:------------------|:---------------------------------------------|:-------------------------------------------------|
| Context           | Own window; results return to caller         | Own window; fully independent                    |
| Communication     | Report back to main agent only               | Teammates message each other directly            |
| Coordination      | Main agent manages all work                  | Shared task list with self-coordination          |
| Best for          | Focused tasks where only the result matters  | Complex work needing discussion and collaboration|
| Token cost        | Lower (results summarized)                   | Higher (each teammate = separate Claude instance)|

**Use subagents** for quick, focused workers that report back. **Use agent teams** when teammates need to share findings, challenge each other, and self-coordinate.

---

## Enable Agent Teams

Add to `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your shell environment.

---

## Architecture

| Component     | Role                                                          |
|:--------------|:--------------------------------------------------------------|
| **Team lead** | Main session that creates team, spawns teammates, coordinates |
| **Teammates** | Separate Claude Code instances working on assigned tasks      |
| **Task list** | Shared work items teammates claim and complete                |
| **Mailbox**   | Messaging system for inter-agent communication                |

**Storage:**
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

The config contains a `members` array with each teammate's name, agent ID, and agent type. Teammates can read this to discover each other.

---

## Starting a Team

Describe the task and team structure in natural language. Claude creates the team, spawns teammates, and coordinates.

```
Create an agent team to review PR #142. Spawn three reviewers:
- One focused on security implications
- One checking performance impact
- One validating test coverage
Have them each review and report findings.
```

Claude can also **propose** a team if it determines your task would benefit. You confirm before it proceeds.

---

## Display Modes

| Mode         | Behavior                                                             | Requirement           |
|:-------------|:---------------------------------------------------------------------|:----------------------|
| `in-process` | All teammates in main terminal. **Shift+Down** to cycle between them.| Any terminal          |
| `tmux`       | Each teammate gets its own split pane.                               | tmux or iTerm2 + `it2` CLI |
| `auto`       | Split panes if already in tmux, otherwise in-process.                | —                     |

Set in `settings.json`:
```json
{ "teammateMode": "in-process" }
```

Or per-session: `claude --teammate-mode in-process`

**In-process controls:**
- **Shift+Down**: Cycle through teammates
- **Enter**: View a teammate's session
- **Escape**: Interrupt teammate's current turn
- **Ctrl+T**: Toggle task list

**Split-pane mode:** Click into a pane to interact directly.

---

## Controlling the Team

### Specify teammates and models

```
Create a team with 4 teammates to refactor these modules in parallel.
Use Sonnet for each teammate.
```

### Require plan approval

```
Spawn an architect teammate to refactor the authentication module.
Require plan approval before they make any changes.
```

Teammate works in read-only plan mode → submits plan to lead → lead approves or rejects with feedback → teammate revises or begins implementation.

Influence approval criteria in your prompt: "only approve plans that include test coverage."

### Talk to teammates directly

Each teammate is a full, independent Claude Code session. Message any teammate directly to give instructions, ask questions, or redirect.

### Assign and claim tasks

Tasks have three states: **pending**, **in progress**, **completed**. Tasks can have dependencies (blocked until dependencies complete).

- **Lead assigns**: Tell the lead which task to give to whom
- **Self-claim**: After finishing, teammates pick up the next unassigned, unblocked task

Task claiming uses file locking to prevent race conditions.

### Send messages between agents

- **message**: Send to one specific teammate
- **broadcast**: Send to all teammates (use sparingly — costs scale with team size)

Messages are delivered automatically. The lead doesn't need to poll.

### Shut down teammates

```
Ask the researcher teammate to shut down
```

Teammate can approve (exits gracefully) or reject with explanation.

### Clean up the team

```
Clean up the team
```

Always use the **lead** for cleanup. Shut down all teammates first — cleanup fails if any are still running. Teammates should never run cleanup.

---

## Permissions

- Teammates start with the lead's permission settings
- If lead runs with `--dangerously-skip-permissions`, all teammates do too
- Individual teammate modes can be changed **after** spawning, not at spawn time
- Pre-approve common operations in permission settings before spawning to reduce prompt friction

---

## Context

Teammates load project context automatically (CLAUDE.md, MCP servers, skills) but do **not** inherit the lead's conversation history. Include task-specific details in the spawn prompt:

```
Spawn a security reviewer teammate with the prompt: "Review the authentication
module at src/auth/ for security vulnerabilities. Focus on token handling,
session management, and input validation."
```

---

## Quality Gates with Hooks

| Hook Event       | When it fires                    | Exit code 2 behavior                     |
|:-----------------|:---------------------------------|:------------------------------------------|
| `TeammateIdle`   | Teammate is about to go idle     | Sends feedback, keeps teammate working    |
| `TaskCompleted`  | Task being marked complete       | Prevents completion, sends feedback       |

---

## Best Use Cases

- **Research & review**: Multiple angles investigated simultaneously
- **New modules/features**: Teammates each own separate pieces
- **Debugging with competing hypotheses**: Test different theories in parallel, debate to converge
- **Cross-layer coordination**: Frontend, backend, tests each owned by a different teammate

**Avoid for:** Sequential tasks, same-file edits, highly interdependent work.

---

## Best Practices

- **Give enough context** in spawn prompts (teammates don't inherit lead's history)
- **Size tasks right**: Self-contained units with clear deliverables (not too small, not too large). Aim for 5-6 tasks per teammate.
- **Avoid file conflicts**: Each teammate should own different files
- **Monitor and steer**: Check progress, redirect, synthesize findings. Don't leave unattended too long.
- **Wait for teammates**: If the lead starts implementing instead of delegating, tell it to wait
- **Start with read-only tasks**: Reviews, research, and investigations before parallel implementation

---

## Troubleshooting

| Problem                        | Solution                                                                    |
|:-------------------------------|:----------------------------------------------------------------------------|
| Teammates not appearing        | Press Shift+Down (may be running but not visible). Check tmux is installed. |
| Too many permission prompts    | Pre-approve operations in permission settings before spawning.              |
| Teammates stopping on errors   | Message them directly or spawn replacements.                                |
| Lead shuts down too early      | Tell it to wait for teammates to finish.                                    |
| Task status stuck              | Check if work is done; manually update or nudge teammate via lead.          |
| Orphaned tmux sessions         | `tmux ls` then `tmux kill-session -t <name>`                               |

---

## Known Limitations

- **No session resumption** for in-process teammates (`/resume` and `/rewind` don't restore them)
- **Task status can lag**: Teammates may fail to mark tasks as completed
- **Slow shutdown**: Teammates finish current operation before stopping
- **One team per session**: Clean up before starting a new team
- **No nested teams**: Teammates cannot spawn their own teams
- **Lead is fixed**: Cannot promote teammate to lead or transfer leadership
- **Permissions set at spawn**: Can change after, not during
- **Split panes require tmux or iTerm2**: Not supported in VS Code terminal, Windows Terminal, or Ghostty

---

**Source:** <https://code.claude.com/docs/en/agent-teams>
