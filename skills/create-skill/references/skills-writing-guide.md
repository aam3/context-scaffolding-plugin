---
name: skills-writing-guide
description: Writing and formatting guidance for all skill content
applies-to: all SKILL.md files
---

# Skills Writing & Formatting Guide

Guidance for writing effective skill content and structuring its presentation. Covers word choice, sentence framing, content decisions, formatting, and format selection by data type.

---

## Writing Principles

### Token Economy

The context window is shared between your skill, conversation history, other skills' metadata, and the user's request. Only add context Claude doesn't already have. Challenge every paragraph: does this justify its token cost?

**Test:** If you can delete a sentence without losing meaning, delete it.

### Scannability

- Lead each section with its most important rule or step
- Bold critical keywords within longer passages
- Do not bury critical rules in the middle of a paragraph

### Specificity Calibration

Match how prescriptive an instruction is to how fragile the operation is.

| Freedom level | When to use | Format |
|---------------|-------------|--------|
| **High** (guidelines) | Multiple valid approaches, context-dependent | Prose instructions |
| **Medium** (templates) | Preferred pattern exists, some variation OK | Templates, pseudocode |
| **Low** (exact scripts) | Fragile operations, consistency critical | Exact commands, code blocks |

---

## Instruction Clarity

### Directness

Write instructions Claude can act on immediately. Lead with the verb. Drop "you should," "try to," and "it would be good to."

```
Bad:  "You might want to consider validating the input"
Good: "Validate input exists before processing. If missing, tell the user."

Bad:  "It is recommended that you use pdfplumber."
Good: "Use pdfplumber."
```

### Positive Framing

Tell Claude the correct behavior rather than listing prohibitions. Positive instructions are more specific.

```
Bad:  "Do NOT include any text before the JSON output."
Good: "Output valid JSON starting with an opening brace. No preamble."

Bad:  "Never leave fields blank."
Good: "Populate every field. Use null for missing values."
```

When a prohibition is genuinely needed (safety, data loss), state it — but pair it with the correct alternative.

### Contextual Motivation

When a rule exists for a non-obvious reason, briefly explain why. A reason gives Claude the judgment to handle situations the rule didn't anticipate.

```
Bad:  "Always use pdfplumber, never PyPDF2."
Good: "Use pdfplumber — it handles multi-column layouts and table extraction
       that PyPDF2 misses."

Bad:  "MUST output dates in ISO 8601 format."
Good: "Output dates in ISO 8601 format (YYYY-MM-DD) — downstream parsers expect it."
```

Keep explanations to one line. Longer explanations belong in a bundled reference file.

### Terminological Consistency

Pick one term and use it throughout the entire skill. Alternating between synonyms creates ambiguity about whether you mean the same thing or different things.

```
Bad:  "endpoint" / "URL" / "API route" / "path"
Good: "endpoint" (everywhere)
```

### Edge Case Handling

Define behavior at boundaries so Claude doesn't guess.

```markdown
## Edge Cases
- If the file has no text content, report "No extractable text found" and stop.
- If multiple formats are detected, ask the user which to prioritize.
```

---

## Formatting

Match format to data shape. No single format is universally best — the deciding factor is the structure of the data.

Each structural language owns one level: XML for system-prompt-level semantic boundaries. Markdown for skill body content. JSON/YAML for schemas and programmatically parsed data. Do not mix them for the same purpose.

Modern Claude models understand well-organized Markdown without XML wrappers. Use Markdown as the default; reserve XML for specific cases.

### Markdown Elements

| Element | Use case |
|---------|----------|
| **Headers** (`##`) | Section boundaries |
| **Tables** | Quick-reference lookups, decision matrices |
| **Code blocks** | Commands, templates, examples |
| **Bold** | Critical rules, key term emphasis |
| **Numbered lists** | Sequential steps |
| **Bullet lists** | Non-sequential items, rules, constraints |

### XML Use Cases

- **Wrapping variable/dynamic user data**: `<document>{{USER_INPUT}}</document>`
- **Structuring Claude's output**: "Put reasoning in `<thinking>` tags and your answer in `<answer>` tags"
- **Parseable output boundaries**: When downstream code needs to extract sections from Claude's response

Avoid wrapping every section in XML tags (wastes tokens), mixing XML and Markdown for the same structural purpose, and heavy role-prompting preambles ("You are a world-class expert...").

### XML Tag Names

No magic tag names exist — Claude has no special training on specific tags. Use names that clearly describe their content.

**Convention:** `lowercase-with-hyphens`

```
Good: <user-input>, <review-criteria>, <quality-gate>, <source-document>
Bad:  <UserInput>, <REVIEW_CRITERIA>, <qi>, <d1>
```

- Name tags for what they contain, not what they do
- Be consistent — once you use `<context>`, don't switch to `<background>` or `<info>`
- Refer to tags by name in instructions: "Using the contract in `<contract>` tags..."

### Format by Data Type

| Data Type | Format | Why |
|-----------|--------|-----|
| Hard rules / constraints | Heading + short bullets | Named groups are scannable; bullets isolate each rule |
| Principles / soft guidance | Bold label + prose | Reasoning needs room; labels enable scanning |
| Procedures | Numbered list | Sequence requires explicit order |
| Configuration / parameters | `Key: value - context` list | Readable; doesn't need parsing |
| Schemas / output specs | JSON in fenced code block | Machine-parseable; doubles as a literal template |
| Examples | Labeled Input → Output | Shows shape by demonstration |
| Conditional routing | `**When X?** → Do Y` | Branching is relational; arrow format is scannable |
| Code reference | Fenced code block with language tag | Syntax highlighting; copy-ready |

### Constraints and Rules

Hard requirements. Heading per constraint group, short imperative bullets underneath. One rule per bullet, 1–2 sentences.

```markdown
### Zero Formula Errors
- Every Excel model MUST be delivered with ZERO formula errors (#REF!, #DIV/0!, #VALUE!, #N/A, #NAME?)

### Preserve Existing Templates (when updating templates)
- Study and EXACTLY match existing format, style, and conventions when modifying files
- Existing template conventions ALWAYS override these guidelines
```

When constraints share parallel structure across multiple attributes, use a table — the data is relational and benefits from cross-row scanning.

### Principles and Guidelines

Soft guidance where Claude exercises judgment. Bold label, colon, then 1–3 sentences of reasoning. Not numbered — principles are not sequential.

```markdown
- **Typography**: Choose fonts that are distinctive and contextual. Avoid
  generic defaults like Arial and Inter; characterful choices elevate the result.
- **Color & Theme**: Commit to a cohesive palette. Dominant colors with sharp
  accents outperform timid, evenly-distributed palettes.
```

Include concrete positive and negative examples inline — negatives define boundaries.

### Procedures

Sequential steps. Numbered list with bold action name, em-dash or colon separating name from description.

```markdown
1. **Capture Intent** — Understand what the skill should do and when it should trigger.
2. **Interview and Research** — Ask about edge cases, input/output formats, dependencies.
3. **Write the SKILL.md** — Fill in components based on the interview.
```

Horizontal rules (`---`) separate major workflow phases. Two levels of nesting maximum — a third level means the content belongs in a separate file.

### Configuration and Parameters

Key-value data Claude needs to understand and apply. Markdown list: `Key: value - explanation`.

```markdown
## Colors
- Dark: '#141413' - Primary text and dark backgrounds
- Light: '#faf9f5' - Light backgrounds and text on dark
```

The explanation after the value provides the reasoning Claude needs to apply it correctly.

### Schemas and Output Specifications

Structured data Claude must produce or consume. JSON inside a fenced code block — it serves as both definition and literal template.

```json
{
  "summary": "2-3 sentence overview",
  "steps": ["step 1", "step 2"],
  "assumptions": ["assumption 1"],
  "risks": ["risk 1"]
}
```

For document structure (not machine-parsed), a template in a plain fenced block:

```markdown
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

For strict requirements: "ALWAYS use this exact structure." For flexible requirements: "Use this structure as a guide. Adapt sections as needed."

Explicit output format specification is one of the highest-leverage prompt techniques.

### Examples

Concrete input/output pairs that anchor format and style. 1–3 high-quality examples outperform many mediocre ones.

```markdown
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

Ensure examples exactly match desired behavior. Include both positive and negative examples when defining boundaries. Make examples realistic — concrete file paths, column names, casual phrasing. Abstract examples ("Format this data") test nothing.

### Conditional Routing

Branching logic. Arrow format for scannable routing:

```markdown
**Creating presentations?** → Read `./slide-decks.md`
**Creating professional documents?** → Read `./docs.md`
```

One or two levels of branching. For many branches, point to separate files rather than inlining all paths.

### Code Reference

Fenced code blocks with language annotation. One operation per snippet, placed immediately after the context that introduces it.

```python
from pypdf import PdfReader, PdfWriter
reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")
```

Scripts over ~30 lines belong in a separate file referenced from the skill.

---

## Description Authoring

The description is how Claude decides whether to trigger a skill. It is the single most important field.

- Write in third person ("Processes files", not "I process files")
- Include what the skill does AND when to use it
- Include keywords users would naturally say
- List explicit trigger phrases, file types, and adjacent concepts
- Include negative triggers ("Do NOT use for X — use Y skill instead")
- Err on the side of over-triggering rather than under-triggering
- Put all "when to use" information in the description, not the body

**Good:** `Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`

**Bad:** `Helps with documents`

---

## Content Patterns

### Decision Routing

When a skill handles multiple input variants:

```markdown
## Approach

| Input type | Method |
|-----------|--------|
| Single PDF | pdfplumber direct extraction |
| Scanned PDF | OCR with pytesseract first |
| Multi-file | Process sequentially, merge results |
```

### Plan-Validate-Execute

For high-stakes or batch operations:

```markdown
## Workflow
1. Analyze inputs and create `changes.json` plan
2. Run `scripts/validate.py changes.json` to catch errors
3. Only after validation passes, execute changes
4. Verify results match plan
```

### Guardrails and Boundaries

State what the skill does NOT do:

```markdown
## Out of Scope
- Scanned/image-only PDFs (use OCR skill)
- Password-protected files
- Files over 50MB
```

---

## Bundled Scripts

Skills can bundle scripts in any language (generating HTML reports, validating data, etc.). Scripts are more reliable than generated code, save tokens (only output enters context, not source code), and ensure consistency.

**Be explicit about intent in SKILL.md:**
- "Run `analyze.py` to extract fields" → Claude executes it
- "See `analyze.py` for the algorithm" → Claude reads it as reference

**Script rules:**
- Handle errors explicitly; don't punt to Claude
- Document magic constants (no unexplained values)
- Use forward slashes in paths (never backslashes)
- List required packages in SKILL.md

**Referencing bundled files:** Reference all bundled files explicitly from SKILL.md so Claude knows they exist:

```markdown
For API field definitions, see `references/api-reference.md`.
For form-filling procedures, see `workflows/forms.md`.
```

---

## Router Content

When using the router pattern (see [skills-configuration.md](skills-configuration.md#router-pattern)), the SKILL.md collects user intent and maps it to a workflow file. Structure the rest of the file (principles, reference index, etc.) per [document-structure-guidelines.md](document-structure-guidelines.md).

```markdown
## Intake

**Ask the user:**

What would you like to do?
1. [Option A]
2. [Option B]
3. [Option C]
4. Something else

**Wait for response before proceeding.**

## Routing

| Response | Workflow |
|----------|----------|
| 1, "keyword", "keyword" | `workflows/option-a.md` |
| 2, "keyword", "keyword" | `workflows/option-b.md` |
| 3, "keyword", "keyword" | `workflows/option-c.md` |
| 4, other | Clarify, then select |

**After reading the workflow, follow it exactly.**
```

Workflow files are task files; reference files are reference files. Structure both per [document-structure-guidelines.md](document-structure-guidelines.md).

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Too many options (`use X or Y or Z...`) | Provide a default with escape hatch |
| Time-sensitive info (`after Aug 2025...`) | Use "old patterns" `<details>` section |
| Long preambles before instructions | Lead with the workflow; add context where needed |
| Over-engineering for hypothetical edge cases | Handle real cases; let the user report the rest |
| Over-weighting (every rule is MUST/NEVER/ALL CAPS) | Reserve strong emphasis for genuinely critical constraints |

---

## Checklists

### Writing

- [ ] Description: third-person, trigger keywords, negative triggers
- [ ] No time-sensitive information
- [ ] Instructions are actionable — imperative voice, positive framing
- [ ] Non-obvious rules include a brief reason
- [ ] Terminology consistent throughout — no synonym drift
- [ ] Edge cases and boundaries defined
- [ ] Examples are concrete with realistic input/output
- [ ] Tested with realistic prompts — both should-trigger and should-not-trigger

### Formatting

- [ ] SKILL.md body under 500 lines
- [ ] References one level deep (no nested references)
- [ ] Output format specified with example or template

---

**Sources:**
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://code.claude.com/docs/en/skills
