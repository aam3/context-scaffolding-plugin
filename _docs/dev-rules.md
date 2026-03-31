---
name: dev-rules
description: Cross-project development constraints and workflow rules
applies-to: all development work
---

# Development Rules
- IMPORTANT: Always ask for explicit approval from the user before calling any LLM API
- Always launch `PLAN` mode when requesting a response from the user.
- Each phase implementation must have its own folder with the name being the phase number and name (e.g., `01-alignment/`, `02-decomposition/`)
- NEVER make domain assumptions - always ask the user explicitly for feedback and clarification
- Treat `inputs/` as read-only; never modify files in this directory

## Writing Style

Be succinct and precise and straightforward. High signal-to-word ratio without losing meaning. Structure and organize the info cleanly for communicationm relying on lists where applicable and minimizing long segments of prose. 

**Note** - this writing style should get passed through to subagents and agent teams as well.