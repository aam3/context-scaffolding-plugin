# Project Repository Structure

Standard directory layout for project repositories. Not every project needs every folder, but when a folder is used, it goes here and follows these rules.

---

## Root Layout

```
project-root/
├── .claude/
├── inputs/
├── docs/
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

## `docs/` — Project Documentation

High-level, stable documents that define the project. Written during planning before implementation begins. These describe *what* and *why*, not *how*.

```
docs/
├── overview.md
├── architecture.md
├── data-model.md
├── api-contracts.md
└── ...
```

Docs change infrequently. If something is changing every session, it probably belongs in `plans/` or `session/`.

---

## `plans/` — Feature and Component Plans

One file per component per phase. Design and implementation are separate concerns kept in parallel so cross-component dependencies are immediately visible.

```
plans/
├── design/
│   ├── 01-data-extraction.md
│   ├── 02-transformation-pipeline.md
│   └── ...
└── implementation/
    ├── 01-data-extraction.md
    ├── 02-transformation-pipeline.md
    └── ...
```

**Rules:**
- Phase numbers are sequential and match across design/, implementation/, and src/. They reflect planning order, not execution order.
- Dependency info lives inside the plan files, not in the numbering.
- If a component splits during implementation, use sub-numbers: `02a-`, `02b-`.
- One component = one design plan = one implementation plan = one src/ folder.

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
- `learnings/domain-rules.md` — discovered domain logic and edge cases. Propagates to docs/.
- `learnings/plan-changes.md` — deviations from plans with rationale. Propagates to plans/.

Don't manually edit these files. They're managed by the prime skill and `/system:summarize`.

---

## `src/` — Implementation

Phase-numbered folders matching `plans/`. Each is a self-contained component.

```
src/
├── 01-data-extraction/
├── 02-transformation-pipeline/
├── 03-api-layer/
├── 04-frontend/
└── shared/
```

**Rules:**
- Folder numbers match the corresponding plan files. `plans/implementation/02-transformation-pipeline.md` → `src/02-transformation-pipeline/`.
- Internal structure within each folder is unconstrained — let the component's domain dictate it.
- `shared/` holds anything referenced by 2+ components. Move code here only when duplication is real, not preemptive.

---

## `tests/`

Mirror `src/` structure or colocate tests within component folders. Pick one convention and hold it.

```
tests/
├── 01-data-extraction/
├── 02-transformation-pipeline/
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

1. **Phase numbering is sequential, not hierarchical.** Planning order, not execution order.
2. **One component ↔ one design plan ↔ one implementation plan ↔ one src folder.** If it splits, split everywhere and sub-number.
3. **`docs/` is stable, `plans/` evolve, `session/` is volatile.** This gradient reflects change frequency.
4. **Convention-based connections, not explicit wiring.** Plan files and src/ folders find each other through matching phase numbers. Feature contexts point to plan files; Claude navigates to src/ from there.
