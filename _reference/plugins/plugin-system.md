---
topic: Plugin system
last_synced: 2026-03-31
description: Managing reusable Claude Code plugins — structure, plugin.json, standalone vs plugin approaches
---

# Claude Code Plugin System

Reference for managing reusable plugins across projects.

## Core Concepts

### Standalone vs Plugin

| Approach | Skill names | Best for |
|----------|-------------|----------|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing across projects, versioned releases, reusable libraries |

### Three Configuration Scopes

| Scope | Location | Effect |
|-------|----------|--------|
| **User** (global) | `~/.claude/` | Always loaded in every project — baseline config |
| **Project** | `.claude/settings.json` | Shared with collaborators via the repo |
| **Local** | Per-repo, not shared | Just you, just this repo |

`~/.claude/` is NOT the only reusable layer. Plugins provide selective, per-project reuse.

## Plugin Structure

A plugin is a self-contained directory with a manifest:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Required manifest (name, description, version)
├── commands/               # Slash commands (markdown files)
├── agents/                 # Custom agent definitions
├── skills/                 # Agent Skills (SKILL.md files)
├── hooks/                  # Event handlers (hooks.json)
├── .mcp.json               # MCP server configurations
├── .lsp.json               # LSP server configurations
└── settings.json           # Default settings applied when enabled
```

**Important:** `commands/`, `agents/`, `skills/`, `hooks/` go at the plugin root — NOT inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`.

### Minimal plugin.json

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "version": "1.0.0",
  "author": { "name": "Your Name" }
}
```

The `name` field doubles as the namespace prefix for all skills (e.g., `/my-plugin:hello`).

## Maintaining a Personal Plugin Library

Store multiple plugins in a single parent directory:

```
~/my-plugins/
├── data-analysis-workflow/
│   ├── .claude-plugin/plugin.json
│   ├── commands/
│   └── skills/
├── web-dev-workflow/
│   ├── .claude-plugin/plugin.json
│   ├── commands/
│   └── agents/
└── planning-phases/
    ├── .claude-plugin/plugin.json
    ├── commands/
    └── skills/
```

## Loading Plugins Per Project

### Option 1: `--plugin-dir` flag (ad hoc, at launch)

```bash
# Single plugin
claude --plugin-dir ~/my-plugins/planning-phases

# Multiple plugins
claude --plugin-dir ~/my-plugins/data-analysis-workflow --plugin-dir ~/my-plugins/planning-phases
```

### Option 2: Install with scope (persistent)

```bash
# Install to user scope (all projects)
/plugin install plugin-name@marketplace-name

# Install to project scope (shared with collaborators)
/plugin install plugin-name@marketplace-name --scope project

# Install to local scope (just you, just this repo)
/plugin install plugin-name@marketplace-name --scope local
```

### Option 3: Personal marketplace (organized library)

Create a marketplace to browse and install from your own collection. See §6.

## Converting Standalone Config to Plugin

If you have an existing `.claude/` directory with commands, skills, and agents:

1. Create the plugin directory and manifest:
   ```bash
   mkdir -p my-plugin/.claude-plugin
   # Create my-plugin/.claude-plugin/plugin.json
   ```
2. Copy `commands/`, `agents/`, `skills/` to the plugin root.
3. Move hooks from `settings.json` into `hooks/hooks.json`.
4. Test: `claude --plugin-dir ./my-plugin`

## Marketplaces

A marketplace is a catalog of plugins. Sources can be:

- **GitHub repos:** `/plugin marketplace add owner/repo`
- **Git URLs:** `/plugin marketplace add https://gitlab.com/company/plugins.git`
- **Local paths:** `/plugin marketplace add ./my-marketplace`
- **Remote URLs:** `/plugin marketplace add https://example.com/marketplace.json`

### Team marketplaces

Add `extraKnownMarketplaces` to `.claude/settings.json` so collaborators auto-discover plugins:

```json
{
  "extraKnownMarketplaces": {
    "my-team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

## Plugin Management Commands

| Command | Effect |
|---------|--------|
| `/plugin` | Open interactive plugin manager (Discover / Installed / Marketplaces / Errors tabs) |
| `/plugin install name@marketplace` | Install a plugin |
| `/plugin disable name@marketplace` | Disable without uninstalling |
| `/plugin enable name@marketplace` | Re-enable |
| `/plugin uninstall name@marketplace` | Remove completely |
| `/plugin marketplace list` | List configured marketplaces |
| `/plugin marketplace update name` | Refresh marketplace listings |
| `/plugin marketplace remove name` | Remove a marketplace (uninstalls its plugins) |

## Requirements

- Claude Code version **1.0.33+** (run `claude --version` to check)
- Plugin skills are namespaced: `/plugin-name:skill-name`
