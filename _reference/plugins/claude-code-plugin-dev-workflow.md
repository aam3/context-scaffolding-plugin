---
topic: Plugin development workflow
last_synced: 2026-03-31
description: Developing plugins across projects — keeping the plugin repo as source of truth while iterating in host projects
---

# Claude Code Plugin Development Workflow
## Publishing to GitHub While Developing Across Projects

---

## The Problem

Plugins don't develop in isolation — they only reveal themselves when *applied* to a real project. But your plugin lives in its own GitHub repo. This guide explains how to reconcile the two so your plugin repo stays the source of truth, even while you iterate on it from inside other projects.

---

## The Core Strategy

Your plugin repo is the **source of truth**. Your project simply *references* it. You never edit plugin files inside the project directory — you edit them in the plugin repo, and the project picks up changes automatically.

---

## Option 1: Absolute Path Reference (Simplest for Solo Dev)

Point your local marketplace at your plugin's actual git repo using an absolute path.

### Directory Structure

```
~/code/
├── my-plugin/              ← your plugin's GitHub repo (cloned)
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   └── skills/
│
├── dev-marketplace/        ← local marketplace pointing to the plugin
│   └── .claude-plugin/
│       └── marketplace.json
│
└── my-project/             ← where you actually work
    └── ...
```

### Marketplace Manifest

```json
// ~/code/dev-marketplace/.claude-plugin/marketplace.json
{
  "name": "dev-marketplace",
  "owner": { "name": "Your Name" },
  "plugins": [{
    "name": "my-plugin",
    "source": "/home/you/code/my-plugin",
    "description": "My plugin (local dev)"
  }]
}
```

### Setup Commands

```bash
# Register the marketplace once
/plugin marketplace add ~/code/dev-marketplace

# Install the plugin
/plugin install my-plugin@dev-marketplace
```

Now when you work inside `my-project`, your plugin is live from its own repo. Edit files in `~/code/my-plugin/`, reinstall, and iterate. Commit and push from the plugin repo independently.

---

## Option 2: Git Submodule (Cleanest for Multi-Project Use)

Add your plugin repo as a submodule inside each project that uses it.

### Setup

```bash
# Inside my-project:
git submodule add https://github.com/you/my-plugin .claude-plugins/my-plugin
```

### Directory Structure

```
my-project/
├── .claude-plugins/
│   └── my-plugin/          ← submodule pointing to your GitHub repo
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       └── skills/
└── ...
```

### Updating After Changes

```bash
# From inside the submodule directory, commit plugin changes:
cd .claude-plugins/my-plugin
git add .
git commit -m "Improve X command"
git push origin main

# Back in the project, update the submodule pointer:
cd ../..
git add .claude-plugins/my-plugin
git commit -m "Update plugin to latest"
```

---

## The Development Iteration Loop

Regardless of which approach you use, the cycle looks like this:

1. You're working in `my-project` and notice the plugin needs a change
2. Open a terminal in the **plugin's directory** (not the project's)
3. Edit the plugin files there
4. In Claude Code, reinstall to pick up changes:
   ```
   /plugin uninstall my-plugin@dev-marketplace
   /plugin install my-plugin@dev-marketplace
   ```
5. Test the change inside your project
6. Commit and push from the **plugin repo**
7. The project repo tracks which version of the plugin it references

---

## Plugin Structure Reference

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Required: plugin metadata
├── commands/                # Optional: custom slash commands
│   └── my-command.md
├── agents/                  # Optional: custom agents
│   └── my-agent.md
├── skills/                  # Optional: Agent Skills
│   └── my-skill/
│       └── SKILL.md
└── hooks/                   # Optional: event handlers
    └── hooks.json
```

### Minimal `plugin.json`

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

---

## Publishing to GitHub

Your GitHub repo for the plugin is just the plugin directory itself — no wrapper needed. Because the `source` field in a marketplace manifest accepts both local paths and remote Git URLs, your plugin repo on GitHub doubles as both the marketplace and the plugin.

Users can install it directly:

```bash
/plugin marketplace add https://github.com/you/my-plugin
/plugin install my-plugin@my-plugin
```

### Recommended GitHub Repo Structure

```
my-plugin/                   ← repo root
├── .claude-plugin/
│   └── plugin.json
├── commands/
├── agents/
├── skills/
├── hooks/
└── README.md                ← installation and usage instructions
```

### README Essentials

Include in your README:
- What the plugin does
- Installation command
- Available commands/agents/skills
- Any configuration required
- Version changelog

---

## Key Principle

> **Edit in the plugin repo. Reference from the project. Never the other way around.**

This keeps your GitHub repo clean, your commit history meaningful, and makes it trivial to use the same plugin across many projects simultaneously.
