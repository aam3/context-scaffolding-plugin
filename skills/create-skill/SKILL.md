---
name: create-skill
description: Creates new skill documents (SKILL.md files and bundles). Use when the user wants to create a skill, write a skill, build a new slash command, or add a new capability as a skill. Triggers on "create skill", "new skill", "write a skill", "make a skill", "build a command". Do NOT use for editing existing skills — edit those directly.
---

## Orientation

This skill creates skill documents. Use it when a new skill needs to be created.

## What a Skill Is


## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. They can be a document (or bundle of files) that Claude reads mid-conversation to augment its capabilities. A skill exists alongside conversational context — it doesn't need to be the reader's entire world.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

#### File architecture 

A skill can be a single file or a bundle.

**Single file** — one SKILL.md contains everything. Use when the skill has one workflow, a small reference set, and stays under 200 lines.

```
skill-name/
└── SKILL.md
```

**Bundle** — SKILL.md is the entry point; supporting files hold separable content. Each file owns a defined scope. Files reference what they use from other files; they do not restate it. Content lives where it's authoritative and maintained.

```
skill-name/
├── SKILL.md              # Core instructions (always loaded)
├── references/           # Domain knowledge, lookup tables
│   ├── concepts.md
│   └── api-reference.md
└── scripts/              # Executable code
    └── validate.py
```

**Router bundle** — when a skill branches into distinct workflows, each workflow gets its own file and SKILL.md routes between them based on the situation.

```
skill-name/
├── SKILL.md              # Intake questions + routing logic (always loaded)
├── workflows/            # One file per distinct workflow
│   ├── workflow-a.md
│   └── workflow-b.md
└── references/           # Shared domain knowledge
    └── domain-rules.md
```


#### SKILL.md (required)

Bundled file is one level deep. Bundled files do not reference other bundled files — Claude may only partially read deeply nested chains.

**Metadata Quality:** The `name` and `description` in YAML frontmatter determine when Claude will use the skill. Be specific about what the skill does and when to use it. Use the third-person (e.g. "This skill should be used when..." instead of "Use this skill when...").

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited*)

*Unlimited because scripts can be executed without reading into context window.

## Procedure

### Step 1: Understanding the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples that are validated with user feedback.

For example, when building an image-editor skill, relevant questions include:

- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, avoid asking too many questions in a single message. Start with the most important questions and follow up as needed for better effectiveness.

Conclude this step when there is a clear sense of the functionality the skill should support.

### Step 2. Determine file architecture

Single file or bundle? If bundle, define what each file owns before drafting. Content owned by a referenced file is accessed through the reference, not restated.

**When to use single file:** one workflow, small reference set, under 200 lines total.

**When to use bundle:** multiple distinct workflows, different workflows need different references, skill would exceed 200 lines.


### Step 3: Read writing and formatting guidelines

Read `references/skills-writing-guide.md` before drafting. This loads prose style, format selection, description authoring, and formatting guidance into context so it informs the draft from the start.

### Step 4: Write the Skill

Draft the skill by following the structural guidelines in `references/document-structure-guidelines.md` and the writing guidelines loaded in Step 3.

When editing the (newly-generated or existing) skill, remember that the skill is being created for another instance of Claude to use. Focus on including information that would be beneficial and non-obvious to Claude.

**Rules**:
- Scope each file to only the content it owns.
- For any information that is unclear, explicitly ask the user.

### Step 5: Package the Skill

Once the skill is ready, it should be packaged into a distributable zip file that gets shared with the user. The packaging process automatically validates the skill first to ensure it meets all requirements:

```bash
scripts/package_skill.py <path/to/skill-folder>
```

Optional output directory specification:

```bash
scripts/package_skill.py <path/to/skill-folder> ./dist
```

The packaging script will:

1. **Validate** the skill automatically, checking:
   - YAML frontmatter format and required fields
   - Skill naming conventions and directory structure
   - Description completeness and quality
   - File organization and resource references

2. **Package** the skill if validation passes, creating a zip file named after the skill (e.g., `my-skill.zip`) that includes all files and maintains the proper directory structure for distribution.

If validation fails, the script will report the errors and exit without creating a package. Fix any validation errors and run the packaging command again.


## Reference Index

- `references/document-structure-guidelines.md` — section derivation, ordering, hierarchy, and structural validation
- `references/skills-writing-guide.md` — prose style, format selection, description authoring, and checklists
