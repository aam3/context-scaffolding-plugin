# Project Repository Structure

Standard directory layout for project repositories. Not every project needs every folder, but when a folder is used, it goes here and follows these rules.

---

## Root Layout

```
project-root/
├── .claude/
├── inputs/
├── brainstorm/
├── specs/
├── plans/
├── session/
├── src/
├── tests/
├── scripts/
├── config/
└── README.md
```

---

## `inputs/` — Source Materials

User-supplied materials that predate the project: briefs, domain knowledge, reference documents, source data. Everything else in the repo flows from this folder. Once populated, it rarely changes. Don't put generated content here.

---

## `brainstorm/` — Ideation and Design Exploration

Early-stage thinking before plans exist. Solution sketches, design alternatives, open questions, and exploratory notes. This is the space for ideation — nothing here is committed to.

Files move out of `brainstorm/` when they mature into a plan or spec. Until then, they stay loose.

---

## `specs/` — Project Specifications

High-level, stable documents that define the project. These describe *what* and *why*, not *how*.

```
specs/
├── overview.md
├── architecture.md
├── data-model.md
├── api-contracts.md
└── ...
```

Specs change infrequently. If something is changing every session, it probably belongs in `plans/` or `session/`.

---

## `plans/` — Project and Feature Plans

Two subfolders based on scope. Which folder a plan belongs in depends on whether a feature is active (`session/active-feature.txt`). Contains a `CLAUDE.md` with plan-specific rules (status tracking, format conventions, subfolder structure).

```
plans/
├── CLAUDE.md
├── project/
│   ├── architecture-plan.md
│   ├── deployment-strategy.md
│   └── ...
└── features/
    ├── auth-system/
    │   ├── phase-1-design.md
    │   ├── phase-2-implementation.md
    │   └── ...
    ├── data-extraction/
    │   └── ...
    └── ...
```

- **`project/`** — Plans that apply to the project as a whole. When `session/active-feature.txt` is empty, new plans go here.
- **`features/`** — Plans tied to a specific feature. When `session/active-feature.txt` has a value, new plans go in a subfolder matching the feature name (e.g., `active-feature.txt` contains `auth-system` → plans go in `features/auth-system/`).
- **`CLAUDE.md`** — Plan-specific directives: how to record phase status in plan files, the main status summary file, and subfolder conventions within `features/`.

**Rules:**
- One plan file per topic. Name it descriptively (kebab-case).
- Feature subfolders match the value in `session/active-feature.txt`.
- Dependency info lives inside the plan files, not in the naming.

---

## `session/` — Session Tracking

Files here change every working session. They are the project's running memory.

```
session/
├── STATUS.md
├── active-feature.txt
└── learnings/
    ├── dev-rules.md
    ├── domain-rules.md
    └── plan-changes.md
```

- `STATUS.md` — rolling window project log. Recent session entries with feature labels and key areas. Old entries cleaned by `/system:summarize`. Feeds project primer updates.
- `active-feature.txt` — single-line file with the current feature key. Written by the prime skill, read by `/system:summarize`.
- `learnings/dev-rules.md` — discovered dev patterns and gotchas. Propagates to CLAUDE.md.
- `learnings/domain-rules.md` — discovered domain logic and edge cases. Propagates to specs/.
- `learnings/plan-changes.md` — deviations from plans with rationale. Propagates to plans/.

Don't manually edit these files. They're managed by the prime skill and `/system:summarize`.

---

## `src/` — Implementation

Sequentially numbered folders. Each is a self-contained component. The number reflects creation order — the first component added is `01-`, the second is `02-`, and so on. Contains a `CLAUDE.md` with src-specific rules (relationship to plans, completion triggers).

```
src/
├── CLAUDE.md
├── 01-data-extraction/
├── 02-api-layer/
├── 03-frontend/
└── shared/
```

**Rules:**
- Folder numbers are sequential by creation order, not tied to plan phase numbers. To add a new component, find the highest existing number and increment by one.
- Internal structure within each folder is unconstrained — let the component's domain dictate it.
- `shared/` holds anything referenced by 2+ components. Move code here only when duplication is real, not preemptive.
- **`CLAUDE.md`** — Src-specific directives: when a component implementation phase completes, update the corresponding plan file in `plans/`.

---

## `tests/`

Mirror `src/` structure or colocate tests within component folders. Pick one convention and hold it.

```
tests/
├── 01-data-extraction/
├── 02-api-layer/
├── ...
└── integration/
```

`integration/` is for cross-component tests.

---

## `scripts/` — Automation and Tooling

Shell scripts and CLI utilities that support development but aren't application code: setup, build, deploy, seed, migration scripts.

---

## `config/` — Environment and Service Configuration

Environment files, Docker configs, CI/CD definitions. Keep secrets out of the repo.

---

## Conventions Summary

1. **Plans are scoped by context.** Project-wide plans go in `plans/project/`, feature plans go in `plans/features/{feature-name}/`. Routing depends on `session/active-feature.txt`.
2. **`src/` numbering is sequential by creation order.** Independent of plan numbers. First folder added is `01-`, second is `02-`, etc.
3. **`specs/` is stable, `plans/` evolve, `session/` is volatile.** This gradient reflects change frequency.
4. **Convention-based connections use names, not numbers.** Plan files and src/ folders share component names (e.g., `data-extraction`). Feature contexts point to plan files; Claude navigates to src/ from there.
5. **Subdirectory CLAUDE.md files carry local rules.** `plans/CLAUDE.md` governs plan status and format. `src/CLAUDE.md` governs the relationship between implementation and plans. Root CLAUDE.md stays lean — only global routing and structure.
