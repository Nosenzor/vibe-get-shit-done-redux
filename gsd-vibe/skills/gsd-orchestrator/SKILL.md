---
name: gsd-orchestrator
description: Main GSD orchestrator that manages the complete spec-driven development workflow. Use this when starting any GSD workflow or when the user mentions GSD, get-shit-done, spec-driven development, or similar concepts.
---

# GSD Orchestrator for Vibe

**You are the GSD (Get Shit Done) orchestrator for Vibe CLI.**

This skill manages the complete spec-driven development workflow, adapted for Mistral Vibe.

## When to Invoke This Skill

ALWAYS invoke this skill when:
- User mentions: GSD, get-shit-done, spec-driven, phase, milestone, roadmap
- User starts a new project
- User wants to plan or execute work
- You detect the project uses `.planning/` directory structure

NEVER proceed with project work without checking if GSD applies first.

## GSD Workflow Overview

The GSD workflow follows this sequence:

1. **New Project** → `gsd-new-project` skill
2. **Plan Phase** → `gsd-plan-phase` skill  
3. **Execute Phase** → `gsd-execute-phase` skill
4. **Complete Milestone** → `gsd-complete-milestone` skill
5. **Repeat**

## Entry Points

### Starting a New Project

If the user wants to start a new project:

1. Invoke `gsd-new-project` skill
2. This creates:
   - `.planning/PROJECT.md` - Project context
   - `.planning/config.json` - Workflow preferences
   - `.planning/REQUIREMENTS.md` - Scoped requirements
   - `.planning/ROADMAP.md` - Phase structure
   - `.planning/STATE.md` - Project memory

3. Then guide user to run plan-phase for first milestone

### Planning a Phase

If the user wants to plan work:

1. Check if project is initialized (`.planning/` exists)
2. If not, invoke `gsd-new-project` first
3. Invoke `gsd-plan-phase` skill with phase number
4. This creates `PLAN.md` for the phase

### Executing a Phase

If the user wants to implement/work on a phase:

1. Check if plan exists for the phase
2. If not, invoke `gsd-plan-phase` first
3. Invoke `gsd-execute-phase` skill
4. This executes the PLAN.md tasks

### Completing a Milestone

If the user has completed work and wants to verify:

1. Invoke `gsd-complete-milestone` skill
2. This runs verification and creates SUMMARY.md

## Project State

GSD maintains state in the `.planning/` directory:

```
.planning/
├── PROJECT.md          # Project vision and context
├── config.json         # Workflow configuration
├── REQUIREMENTS.md     # Scoped requirements
├── ROADMAP.md          # Phase structure
├── STATE.md            # Project memory and current state
├── research/           # Domain research (optional)
├── <phase-N>/          # Phase directories
│   ├── PLAN.md         # Execution plan
│   ├── SUMMARY.md      # Completion summary
│   └── ...
└── backlog.md          # Deferred work
```

## Vibe-Specific Adaptations

### Tool Mappings

GSD was designed for Claude Code. For Vibe, use these equivalents:

| GSD/Claude | Vibe Tool | Notes |
|-----------|-----------|-------|
| `Read` | `read_file` | Use for reading files |
| `Write` | `write_file` | Use `overwrite: true` to replace |
| `Edit` | `search_replace` | Use SEARCH/REPLACE blocks |
| `Bash` | `bash` | Use absolute paths |
| `Grep` | `grep` | Pattern searching |
| `Glob` | `bash` with `find` | File finding |
| `Agent` | `task` | Subagent dispatch |
| `AskUserQuestion` | `ask_user_question` | Multi-choice questions |
| `WebFetch` | `web_fetch` | HTTP requests |

### Important Differences

1. **No SDK**: GSD uses `gsd-sdk` for state management. In Vibe, use direct file operations.

2. **No MCP Tools**: GSD uses Context7 MCP. In Vibe, use `web_fetch` or `bash` with `curl`.

3. **Task Management**: Use Vibe's `todo` tool instead of GSD's internal tracking.

4. **State Files**: All state is in `.planning/` directory - read/write directly.

## Quick Start Guide

### First-Time User

```
User: Let's build a new app

You: I'll help you build that with GSD workflow. Let me initialize the project.
     (invoke gsd-new-project skill)
```

### Existing GSD User

```
User: Let's plan phase 1

You: I'll help you plan phase 1. First, let me check project state.
     (check for .planning/ directory)
     (invoke gsd-plan-phase skill with phase=1)
```

## Skill Invocation Flow

```
User Message
    ↓
Does it mention GSD, new project, planning, execution?
    ↓ YES
Invoke gsd-orchestrator
    ↓
Determine entry point:
    - New project? → gsd-new-project
    - Plan phase? → gsd-plan-phase
    - Execute? → gsd-execute-phase
    - Complete? → gsd-complete-milestone
    ↓
Delegate to specific skill
```

## Error Handling

If something goes wrong:

1. **Missing .planning/**: Project not initialized. Invoke `gsd-new-project`.
2. **Missing PLAN.md**: Phase not planned. Invoke `gsd-plan-phase`.
3. **Incomplete state**: Check STATE.md for current position.

## Important: Always Check for Existing State

Before doing ANY work on a project with a `.planning/` directory:

1. Read `.planning/STATE.md` to understand current position
2. Check `.planning/ROADMAP.md` for phase structure
3. Look for existing `.planning/<phase-N>/PLAN.md` files

If STATE.md exists and shows incomplete work, resume from that point.

## Checklist Before Any Response

- [ ] Does this look like a GSD project (has `.planning/` dir)?
- [ ] Is the user asking for planning, execution, or project management?
- [ ] Should I invoke a GSD skill instead of answering directly?

**If ANY of the above are true → Invoke the appropriate GSD skill NOW**

## Command Reference (Vibe Adaptations)

| GSD Command | Vibe Equivalent |
|-------------|----------------|
| `/gsd:new-project` | Invoke `gsd-new-project` skill |
| `/gsd:plan-phase <N>` | Invoke `gsd-plan-phase` with phase=N |
| `/gsd:execute-phase <N>` | Invoke `gsd-execute-phase` with phase=N |
| `/gsd:complete-milestone <N>` | Invoke `gsd-complete-milestone` with milestone=N |

## File Locations

All GSD files are stored in the project's `.planning/` directory, not in `~/.vibe/`.

The skills themselves are in `~/.vibe/skills/gsd-*` and are invoked via the `skill` tool.

## Next Steps

After invoking this skill, delegate to the appropriate specific GSD skill based on the user's intent.
