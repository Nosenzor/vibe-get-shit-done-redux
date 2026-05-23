---
name: gsd-new-project
description: Initialize a new GSD project with deep context gathering. Creates PROJECT.md, REQUIREMENTS.md, ROADMAP.md, and STATE.md. Use when starting any new project or when user invokes new project workflow.
---

# GSD New Project for Vibe

**You are the GSD new project initializer for Vibe CLI.**

This skill guides the user through initializing a new project with the GSD (Get Shit Done) workflow.

## When to Use

Invoke this skill when:
- User explicitly asks to start a new project
- User says "Let's build X" or similar
- Project directory exists but `.planning/` doesn't
- GSD orchestrator detects new project intent

## What This Skill Creates

```
.planning/
├── PROJECT.md          # Project vision, purpose, success criteria
├── config.json         # GSD workflow configuration
├── REQUIREMENTS.md     # Scoped functional/non-functional requirements
├── ROADMAP.md          # Phase structure with milestones
├── STATE.md            # Current project state and memory
└── backlog.md          # Deferred ideas and out-of-scope items
```

## Process Flow

### Step 1: Project Context Discovery

Before asking ANY questions:

1. **Scan the project directory:**
   ```bash
   bash(command="ls -la", timeout=30)
   ```

2. **Check for existing files:**
   - `README.md` - Project description
   - `package.json` - Tech stack
   - `requirements.txt` / `pyproject.toml` / `go.mod` - Dependencies
   - `*.md` files in root - Existing documentation

3. **Read relevant context files:**
   - If `CLAUDE.md` exists, read it for project-specific instructions
   - If `AGENTS.md` exists, read it for AI guidelines
   - If `.github/` exists, check for contribution guidelines

### Step 2: Ask Clarifying Questions

Use Vibe's `ask_user_question` tool to gather project requirements. Ask **one question at a time**.

**Essential questions:**

1. **Project purpose:** "What problem does this project solve?"
2. **Target users:** "Who is the primary audience/user?"
3. **Success criteria:** "What does success look like for this project?"
4. **Scope:** "What's the initial scope (MVP)?"
5. **Tech preferences:** "Any preferred technologies or constraints?"
6. **Timeline:** "Any deadlines or time constraints?"

**Optional (ask based on project type):**
- "What's the deployment target?"
- "Any existing systems to integrate with?"
- "Open source or private?"
- "Any compliance/security requirements?"

### Step 3: Create PROJECT.md

Create `.planning/PROJECT.md` with the following structure:

```markdown
# Project: [Name]

## Purpose
[Why this project exists]

## Vision
[Long-term vision]

## Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

## Context
- **Domain:** [domain area]
- **Tech Stack:** [initial choices]
- **Dependencies:** [external systems]
- **Constraints:** [limitations]

## Decisions (Locked)
- D-01: [Decision] - [Rationale]

## Deferred Ideas
- [Idea] - [Reason for deferral]

## Claude's Discretion
[Items where you have decision authority]
```

### Step 4: Create config.json

Create `.planning/config.json`:

```json
{
  "version": "1.0",
  "workflow": "gsd",
  "phaseDuration": "1 week",
  "commitStrategy": "per-task",
  "verification": true,
  "autonomous": false,
  "preferredModel": "vibe",
  "contextBudget": 128000
}
```

### Step 5: Create REQUIREMENTS.md

Create `.planning/REQUIREMENTS.md`:

```markdown
# Requirements

## Functional Requirements

### FR-01: [Requirement]
- **Description:** [What it does]
- **Priority:** [High/Medium/Low]
- **Acceptance Criteria:**
  - [ ] [Criterion 1]
  - [ ] [Criterion 2]

## Non-Functional Requirements

### NFR-01: [Requirement]
- **Category:** [Performance/Security/Usability/etc.]
- **Description:** [What it is]
- **Target:** [Measurable target]

## Assumptions
- [Assumption 1]
- [Assumption 2]

## Dependencies
- [External dependency 1]
- [External dependency 2]
```

### Step 6: Create ROADMAP.md

Create `.planning/ROADMAP.md`:

```markdown
# Roadmap

## Phase 1: [Phase Name]
**Goal:** [What this phase achieves]
**Duration:** [Estimated duration]
**Priority:** High

### Milestones
- [ ] Milestone 1: [Description]
- [ ] Milestone 2: [Description]

## Phase 2: [Phase Name]
**Goal:** [What this phase achieves]
**Duration:** [Estimated duration]
**Priority:** Medium

---

## Current Position
Phase: 1
Status: not-started
Next: /gsd:plan-phase 1
```

### Step 7: Create STATE.md

Create `.planning/STATE.md`:

```markdown
# State

## Current Phase
- Phase: 1
- Status: not-started
- Started: [date]

## Completed
- [ ] New project initialized

## In Progress
- None

## Blockers
- None

## Decisions Made
- D-01: [Decision]

## Next Actions
1. Run `/gsd:plan-phase 1` to plan Phase 1
```

### Step 8: Create backlog.md

Create `.planning/backlog.md`:

```markdown
# Backlog

## Deferred Features
- [Feature] - [Reason]

## Out of Scope
- [Item] - [Reason]

## Future Phases
- [Idea] - [Phase target]
```

## Vibe-Specific Implementation

### File Creation

Use Vibe tools for all file operations:

```bash
# Create directory
bash(command="mkdir -p .planning")

# Write PROJECT.md
write_file(path=".planning/PROJECT.md", content="...")

# Write config.json
write_file(path=".planning/config.json", content="...")
```

### Task Tracking

Use Vibe's `todo` tool to track progress:

```
todo(action="write", todos=[
  {id: "1", content: "Ask project purpose", status: "in_progress"},
  {id: "2", content: "Create PROJECT.md", status: "pending"},
  {id: "3", content: "Create config.json", status: "pending"},
  ...
])
```

### User Interaction

Use `ask_user_question` for multi-choice or free-text questions:

```
ask_user_question(questions=[{
  question: "What problem does this project solve?",
  header: "Purpose",
  options: [],
  multi_select: false
}])
```

## Quality Gates

Before completing new project initialization:

- [ ] PROJECT.md exists and has purpose, vision, success criteria
- [ ] config.json is valid JSON
- [ ] REQUIREMENTS.md has at least 3 functional requirements
- [ ] ROADMAP.md has at least Phase 1 defined
- [ ] STATE.md exists and shows initialization complete
- [ ] User has reviewed and approved all documents

## Next Step

After completing this skill:

1. Tell user: "Project initialized! Review the files in `.planning/`."
2. Suggest: "Ready to plan Phase 1. Say 'plan phase 1' or invoke `/gsd:plan-phase 1`"
3. Optionally invoke `gsd-plan-phase` skill automatically if user wants

## Error Handling

- If directory already has `.planning/`: Ask user if they want to reinitialize
- If user cancels mid-process: Save partial state, note in STATE.md
- If file creation fails: Retry or ask user for alternative location

## Templates

All templates are embedded in this skill. Do not reference external files.

## Remember

- **Ask one question at a time** - don't overload user
- **Document everything** - all decisions go in PROJECT.md or STATE.md
- **Stay in scope** - focus on MVP, defer extras to backlog
- **User is in control** - their decisions override defaults
