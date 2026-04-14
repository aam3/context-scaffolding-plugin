# Learnings Schemas

## dev-rules.md

**Location:** `session/learnings/dev-rules.md`
**Propagates to:** CLAUDE.md (via update-dev-rules skill)

```markdown
# Development Rules — Discovered

| Date | Rule | Rationale | Updated |
|------|------|-----------|---------|
| 2026-03-24 | Ask before calling any external API | User corrected after unprompted call; prevents unexpected costs | No |
```

**Columns:**
- **Date** — YYYY-MM-DD when the rule was discovered.
- **Rule** — One sentence. The behavioral constraint.
- **Rationale** — One sentence. Why this rule exists.
- **Updated** — `No` on creation. `Yes` after propagated to CLAUDE.md.

## domain-rules.md

**Location:** `session/learnings/domain-rules.md`
**Propagates to:** The file in the Documented In column. `[TBD]` defers propagation.

```markdown
# Domain Rules — Discovered

| Date | Feature | Rule | Documented In | Updated |
|------|---------|------|--------------|---------|
| 2026-03-24 | checkout | Invoice amounts must include tax in EU regions | `docs/billing-rules.md` | No |
```

**Columns:**
- **Date** — YYYY-MM-DD when the rule was discovered.
- **Feature** — Which feature this rule relates to.
- **Rule** — One sentence. The domain constraint.
- **Documented In** — Target file for propagation. `[TBD]` if unknown.
- **Updated** — `No` on creation. `Yes` after propagated to target file.

## plan-changes.md

**Location:** `session/learnings/plan-changes.md`
**Propagates to:** The plan file in the Plan File column. Only recorded if the plan file exists.

```markdown
# Plan Changes

| Date | Plan File | Feature | Change | Rationale | Updated |
|------|-----------|---------|--------|-----------|---------|
| 2026-03-24 | `plans/design/02-data-layer.md` | data-pipeline | Switched from REST to GraphQL | Client needs real-time subscriptions | No |
```

**Columns:**
- **Date** — YYYY-MM-DD when the change was made.
- **Plan File** — Path to the plan file that was changed.
- **Feature** — Which feature this change relates to.
- **Change** — One sentence. What changed.
- **Rationale** — One sentence. Why it changed.
- **Updated** — `No` on creation. `Yes` after propagated to plan file.

## Common Rules

- All entries start with `Updated: No`. Set to `Yes` after propagation.
- Date column uses YYYY-MM-DD format.
- Tables are append-only. No cleanup. Serve as audit trail.
- Created on first write with the `#` header and table header row.
- Brief entries: rules and rationale should each be one sentence. Detail belongs in the propagation target.
