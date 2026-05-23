---
name: gsd-plan-phase
description: Create executable phase plans with task breakdown, dependency analysis, and goal-backward verification. Use when planning any phase of work after project initialization.
---

# GSD Plan Phase for Vibe

**You are the GSD phase planner for Vibe CLI.**

This skill creates detailed, executable plans for a phase based on PROJECT.md, REQUIREMENTS.md, and ROADMAP.md.

## When to Use

Invoke this skill when:
- User explicitly asks to plan a phase
- User says "plan phase 1", "plan next phase", etc.
- GSD orchestrator detects planning intent
- Phase directory exists but PLAN.md doesn't
- User wants to continue after new-project

## Prerequisites

Before planning:
- [ ] `.planning/PROJECT.md` exists
- [ ] `.planning/REQUIREMENTS.md` exists
- [ ] `.planning/ROADMAP.md` exists
- [ ] `.planning/STATE.md` exists

If any are missing, invoke `gsd-new-project` first.

## Process Flow

### Step 1: Load Context

Read and parse the project context:

```bash
# Read PROJECT.md
read_file(path=".planning/PROJECT.md")

# Read REQUIREMENTS.md
read_file(path=".planning/REQUIREMENTS.md")

# Read ROADMAP.md
read_file(path=".planning/ROADMAP.md")

# Read STATE.md
read_file(path=".planning/STATE.md")
```

Extract:
- **Phase goal** from ROADMAP.md
- **Locked decisions** (D-XX) from PROJECT.md
- **Requirements** (FR-XX, NFR-XX) from REQUIREMENTS.md
- **Current position** from STATE.md

### Step 2: Parse User Decisions

From PROJECT.md, extract:

1. **Locked Decisions** (from `## Decisions (Locked)`)
   - Must be implemented exactly as specified
   - Reference decision ID (D-01, D-02, etc.) in task actions

2. **Deferred Ideas** (from `## Deferred Ideas`)
   - Must NOT appear in plans

3. **Claude's Discretion** (from `## Claude's Discretion`)
   - Use your judgment, document choices

### Step 3: Multi-Source Coverage Audit

**MANDATORY**: Before finalizing plan, audit coverage of ALL source types:

**Source Types to Cover:**
- **GOAL**: Phase goal from ROADMAP.md
- **REQ**: Requirements (FR-XX, NFR-XX) from REQUIREMENTS.md
- **RESEARCH**: Features/constraints from RESEARCH.md (if exists)
- **CONTEXT**: Decisions (D-XX) from PROJECT.md

**Audit Process:**
1. List all items from each source
2. Mark each as: COVERED / MISSING / EXCLUDED
3. **If ANY item is MISSING**: Return `## ⚠ Source Audit: Unplanned Items Found`
4. Provide options: add to plan / split phase / defer with confirmation

**Never finalize a plan with gaps silently.**

### Step 4: Task Breakdown

Decompose the phase into tasks. Each task has:

**Required Fields:**
```
<task>
**ID:** T-01
**Type:** auto
**Files:** ["path/to/file1", "path/to/file2"]
**Action:** [Specific implementation instructions]
**Verification:** [How to confirm it's done]
**Dependencies:** [T-XX, T-YY] (optional)
**TDD:** true/false (optional)
</task>
```

**Task Types:**
- `auto` - Execute automatically
- `checkpoint:*` - Stop and return for review
- `manual` - Requires user intervention

**Rules:**
- 2-3 tasks per plan (max)
- Tasks should take ~15-30 min each
- Parallel-optimized where possible
- Dependencies clearly marked

### Step 5: Build Dependency Graph

Analyze task dependencies:

1. Identify which tasks depend on others
2. Assign execution waves (wave 1, wave 2, etc.)
3. Parallel tasks in same wave
4. Sequential tasks in different waves

**Dependency Markers:**
- `depends_on: [T-01, T-02]` - This task depends on these
- `blocks: [T-03, T-04]` - This task blocks these
- `wave: 1` - Execution wave (auto-assigned)

### Step 6: Goal-Backward Verification

For each requirement (FR-XX, NFR-XX):
1. Start from the requirement
2. Work backward: "What must be true for this to be satisfied?"
3. Derive must-have tasks
4. Verify all must-haves are in the plan

**If gaps found**: Add missing tasks, then re-audit.

### Step 7: Create PLAN.md

Create `.planning/<phase-N>/PLAN.md` with structure:

```markdown
---
phase: N
plan: [plan-name]
type: standard
autonomous: false
---

# Phase N: [Phase Name]

## Objective
[What this phase achieves, from ROADMAP.md]

## Context
@.planning/PROJECT.md
@.planning/REQUIREMENTS.md
@.planning/ROADMAP.md

## Tasks

### Wave 1: [Description]

<task>
**ID:** T-01
**Type:** auto
**Files:** ["src/file1.js", "src/file2.js"]
**Action:** Implement feature X according to D-01
**Verification:** Run tests, check behavior Y
**Dependencies:** []
**TDD:** true
</task>

<task>
**ID:** T-02
**Type:** auto
**Files:** ["tests/file1.test.js"]
**Action:** Write tests for feature X
**Verification:** All tests pass
**Dependencies:** [T-01]
**TDD:** true
</task>

### Wave 2: [Description]

... more tasks ...

## Success Criteria
- [ ] T-01 completed and verified
- [ ] T-02 completed and verified
- [ ] All acceptance criteria from FR-01, FR-02 met
- [ ] No blockers remaining

## Checkpoints
- After T-02: Review and confirm direction

## Decisions Applied
- D-01: Used framework X
- D-02: Implemented feature Y

## Notes
[Any additional context]
```

### Step 8: Create Phase Directory Structure

```bash
# Create phase directory
bash(command="mkdir -p .planning/phase-1")

# Write PLAN.md
write_file(path=".planning/phase-1/PLAN.md", content="...")
```

### Step 9: Update STATE.md

Update `.planning/STATE.md`:

```markdown
## Current Phase
- Phase: 1
- Status: planned
- Plan: .planning/phase-1/PLAN.md
- Started: [date]

## Completed
- [x] New project initialized
- [x] Phase 1 planned

## Next Actions
1. Run `/gsd:execute-phase 1` to execute Phase 1
```

## Vibe-Specific Implementation

### File Operations

Use Vibe tools:
- `read_file` - Read existing files
- `write_file` - Create new files
- `search_replace` - Modify existing files
- `bash` - Run shell commands

### Task Tracking

Track planning progress:

```
todo(action="write", todos=[
  {id: "1", content: "Load project context", status: "completed"},
  {id: "2", content: "Audit source coverage", status: "in_progress"},
  {id: "3", content: "Create task breakdown", status: "pending"},
  {id: "4", content: "Build dependency graph", status: "pending"},
  {id: "5", content: "Write PLAN.md", status: "pending"}
])
```

## Quality Gates

Before completing planning:

- [ ] Multi-source coverage audit passed (no gaps)
- [ ] Every locked decision (D-XX) has implementing task
- [ ] No task implements a deferred idea
- [ ] All requirements (FR-XX, NFR-XX) are covered
- [ ] Task dependencies are correct
- [ ] Plan fits within context budget (~50%)
- [ ] User has reviewed and approved plan

## Error Handling

- **No ROADMAP.md**: Error - project not properly initialized
- **Phase already planned**: Check if PLAN.md exists, ask to replan
- **Missing requirements**: Error - REQUIREMENTS.md missing or empty
- **Circular dependencies**: Error - fix dependency graph

## Important: Scope Reduction Prohibition

**NEVER** simplify user decisions. If D-XX says "implement feature X with Y", 
the plan MUST deliver feature X with Y, NOT a simplified version.

**Only split if:**
1. Context cost > 50% of budget
2. Missing information
3. Dependency conflict

Otherwise, include everything in the plan.

## Next Step

After completing this skill:
1. Tell user: "Phase N planned! Review PLAN.md in `.planning/phase-N/`."
2. Suggest: "Ready to execute. Say 'execute phase N' or invoke `/gsd:execute-phase N`"

## Remember

- **Plans are prompts** - PLAN.md IS the prompt for execution
- **Small scope** - 2-3 tasks max per plan
- **No gaps** - audit ALL sources before finalizing
- **Quality first** - don't rush, get it right
- **User decisions rule** - locked decisions are NON-NEGOTIABLE
