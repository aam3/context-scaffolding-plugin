# Document Structure and Organization Guidelines

## 1. Purpose and Scope

These guidelines govern **how content is organized and ordered** within a document — not what content to include.

Apply when:
- Organizing new content into a document
- Restructuring existing content

The problem addressed: topical/taxonomic organization feels intuitive but produces documents that are hard to follow. Purpose-driven structure ensures each section earns its place and its position.

---

## 2. Core Principles

These three principles are the reasoning foundation for every decision in this document.

**Purpose-driven spine** — The document's purpose determines its primary organizing axis. Structure follows from what the document is trying to accomplish, not from how the subject matter is classified.

**Cognitive coherence** — Each section asks the reader to do one kind of mental work. A shift in cognitive mode (e.g., from learning to doing) signals a section boundary.

**Dependency ordering** — Information appears after everything it depends on and before everything that depends on it. No forward dependencies.

---

## 3. Determining the Document's Purpose

Identify what should be true for the reader after engaging with the document. That end state determines the structural spine.

**Purpose → natural sequence:**

| Purpose | Organizing axis |
|---|---|
| Building understanding | Conceptual progression |
| Guiding a task | Workflow sequence |
| Enabling application | Situational or capability-based grouping |
| Combined purposes | Primary purpose governs the top-level arc; secondary purposes govern within sections |

For mixed-purpose documents: identify the primary purpose first, use it for the top-level spine, then let secondary purposes govern structure within sections.

---

## 4. Section Boundaries

Sections are the major units of the document's spine.

**Draw a section boundary when** content requires a substantial shift in cognitive mode — a new phase, a new kind of mental work, or a different relationship to the reader.

**Keep content in the same section when** it serves the same purpose and asks the reader to do the same kind of mental work.

Brief inline content of a different type can stay within a section if it's small enough to absorb without triggering a mode shift.

---

## 5. Subsection Boundaries

Subsections decompose a section's work without changing its cognitive mode.

**How subsection boundaries manifest by section type:**

| Section type | Subsection basis |
|---|---|
| Task / execution | Steps, sub-steps, decision points |
| Learning / reference | Components of a concept, building blocks of understanding |
| Application | Distinct scenarios or cases |

**The test:** Does this content require the same cognitive mode as its parent section? If it requires a genuine mode shift, it's a new section — regardless of topical relationship.

---

## 6. Ordering Content

### Sections

Apply dependency ordering as the structural constraint: nothing appears before its prerequisites. Among valid orderings, prefer the sequence where each section's context is best established by what precedes it.

### Within sections

Order follows the section's purpose:
- Learning sections → conceptual dependency order
- Task sections → execution sequence
- Application sections → logical grouping

### Time-of-need placement

Place information as close to its point of use as cognitive coherence allows.
- Brief supporting content → inline
- Substantial supporting content → nearest upstream position where it can stand as its own coherent section

### Constraints, exceptions, and conditionals

Place after the thing they modify. The reader should understand the primary path before encountering its limits.

**Exception:** When a condition routes the reader to different paths, the condition leads — it's not modifying a path, it's selecting one.

### Examples

- Trail the thing they illustrate, never precede it.
- Include only when a concept or rule has non-obvious application.
- Highest structural value at decision points and branch conditions, where abstract rules are hardest to apply.
- When an example is long enough to disrupt section flow, make it a subsection.

---

## 7. Handling Structural Challenges

### Background content

| Scope | Placement |
|---|---|
| Supports one section, brief | Inline |
| Supports one section, substantial | Its own section immediately upstream |
| Supports multiple sections | Once, upstream of all dependents; reference from dependent sections |

### Non-redundancy

When content is relevant to multiple sections, identify it as a shared dependency and place it once. Repetition signals a missed shared dependency.

**Strategic restatement** is the one justified exception: when a critical constraint governs behavior far from where it was established, a brief recalling phrase (not a re-explanation) at the point of application is warranted. Reserve for critical constraints in long documents where distance risks the reader losing track.

### Branching and conditional flows

State the condition → indicate the branches → walk each branch to completion → reconverge. The reader should never be uncertain which path applies to them.

### Content relocation test

If content within a section requires a cognitive mode shift and is too substantial to absorb inline, move it upstream. If removing it makes the section more focused, that confirms relocation was correct.

---

## 8. Structural Validation

Run these checks on the completed document.

| Check | What to look for |
|---|---|
| **Floating sections** | Can any section move without breaking what precedes or follows it? If yes, ordering is not dependency-driven. |
| **Forward references** | Does any section use a term or concept not yet introduced? |
| **Mismatched content** | Does any section contain content serving a visibly different function from the rest of that section? |
| **Repeated information** | Is any concept restated across multiple sections beyond brief strategic restatement? |
| **Workflow interruptions** | Does any task section contain explanatory content longer than a brief inline note? |
| **Unclear branching** | Do all conditional paths clearly indicate which branch applies under which condition? Does each branch resolve before the next begins? |
| **Leading exceptions** | Do any constraints, exceptions, or edge cases appear before the thing they modify? |
