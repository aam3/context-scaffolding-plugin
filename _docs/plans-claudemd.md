# Plans

## Status Tracking

When a phase of a plan is complete, update its status directly in the plan file. Use a `Status:` field at the top of each phase section:

- `not started`
- `in progress`
- `complete`
- `blocked` — include reason

## Plan File Format

Each plan file has:
- A title matching the topic (kebab-case filename)
- Phases as `##` sections, each with a `Status:` field
- Dependencies listed inline where relevant

## Feature Subfolders

Feature plans live in `features/{feature-name}/`. The subfolder name matches the value in `session/active-feature.txt`. Create the subfolder when writing the first plan for a feature.

## Status Summary

Maintain `plans/STATUS.md` as a summary of work across `project/` and `features/`. One line per plan file: name, current phase, and overall status. Update this file whenever a phase status changes.
