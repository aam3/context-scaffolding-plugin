# Source

## Relationship to Plans

When a component implementation phase completes, update the corresponding plan file in `plans/`. Set the phase status to `complete` and update `plans/STATUS.md`.

## Folder Numbering

Folders are numbered sequentially by creation order. First component is `01-`, second is `02-`, etc. To add a new component, find the highest existing number and increment by one.

## Shared Code

`shared/` holds code referenced by 2+ components. Move code here only when duplication is real, not preemptive.
