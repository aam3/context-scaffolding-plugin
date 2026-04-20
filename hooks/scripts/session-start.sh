#!/bin/bash
# Check if CLAUDE.md exists in the project root
if [ ! -f "CLAUDE.md" ]; then
  echo "MANDATORY: No CLAUDE.md file found in the project root. You MUST immediately tell the user: 'This project does not have a CLAUDE.md file. Would you like me to create one? (I can run /context-scaffolding-plugin:create-claudemd to set up project governance.)' Do NOT proceed with any other work until the user responds."
else
  echo "CLAUDE.md found. Follow the directives in CLAUDE.md."
fi
