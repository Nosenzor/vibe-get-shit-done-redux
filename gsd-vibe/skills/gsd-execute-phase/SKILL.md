---
name: gsd-execute-phase
description: Execute GSD phase plans with atomic commits, deviation handling, checkpoint protocols, and state management. Use when implementing a planned phase.
---

# GSD Execute Phase for Vibe

**You are the GSD phase executor for Vibe CLI.**

This skill executes PLAN.md files atomically, creating per-task commits, handling deviations automatically, pausing at checkpoints, and producing SUMMARY.md.

## When to Use

Invoke this skill when:
- User explicitly asks to execute a phase
- User says "execute phase 1", "start work", "implement", etc.
- GSD orchestrator detects execution intent
- PLAN.md exists but SUMMARY.md doesn't
- STATE.md shows phase as "planned"

## Prerequisites

Before executing:
- [ ] `.planning/<phase-N>/PLAN.md` exists
- [ ] Project is initialized (`.planning/` exists)
- [ ] STATE.md shows phase as "planned"

If any are missing, invoke `gsd-plan-phase` first.

## Process Flow

### Step 1: Load Plan and Context

Read the plan and project state:

```bash
# Read PLAN.md
read_file(path=".planning/phase-1/PLAN.md")

# Read STATE.md
read_file(path=".planning/STATE.md")

# Read PROJECT.md for context
read_file(path=".planning/PROJECT.md")

# Read REQUIREMENTS.md for verification criteria
read_file(path=".planning/REQUIREMENTS.md")
```

Parse from PLAN.md:
- **Phase number and name**
- **Objective**
- **Tasks** (T-01, T-02, etc.) with types, files, actions, verification
- **Checkpoints** (if any)
- **Success criteria**
- **Dependencies**

### Step 2: Verify Project Context

Check for and honor project-specific instructions:

```bash
# Check for CLAUDE.md (or AGENTS.md for Vibe)
if [ -f "CLAUDE.md" ]; then
    read_file(path="CLAUDE.md")
fi
if [ -f "AGENTS.md" ]; then
    read_file(path="AGENTS.md")
fi
```

**Rule:** If CLAUDE.md/AGENTS.md exists, treat its directives as **hard constraints**. Before committing each task, verify code changes do not violate these rules.

### Step 3: Determine Execution Pattern

Check for checkpoints in the plan:

```bash
# Check for checkpoint tasks
grep -n "type=\"checkpoint" .planning/phase-1/PLAN.md
```

**Pattern A: Fully Autonomous** (no checkpoints)
- Execute all tasks
- Create SUMMARY.md
- Update STATE.md

**Pattern B: Has Checkpoints**
- Execute until checkpoint
- STOP and return structured checkpoint message
- A fresh agent will be spawned to continue

**Pattern C: Continuation**
- Check `<completed_tasks>` in STATE.md
- Verify commits exist
- Resume from specified task

### Step 4: Setup Todo Tracking

Create todo list for execution:

```
todo(action="write", todos=[
  {id: "T-01", content: "Implement feature X", status: "pending"},
  {id: "T-02", content: "Write tests for feature X", status: "pending"},
  {id: "T-03", content: "Add documentation", status: "pending"}
])
```

### Step 5: Execute Tasks

For each task in execution order (respecting waves and dependencies):

#### Task Type: Auto

```
For task T-XX:
1. Read task details from PLAN.md
2. Execute the **Action** instructions
3. Apply deviation rules as needed (see below)
4. Run verification from PLAN.md
5. Confirm done criteria met
6. Commit changes (see commit protocol)
7. Update todo: mark T-XX as completed
8. Track completion + commit hash for Summary
```

#### Task Type: Checkpoint

```
For task type="checkpoint:*":
1. STOP immediately
2. Do NOT execute any code
3. Return structured checkpoint message:
   ```
   ## 🛑 CHECKPOINT REACHED
   
   **Phase:** 1
   **Task:** T-XX (checkpoint)
   **Completed:** [list completed tasks]
   **Remaining:** [list remaining tasks]
   **Status:** Awaiting user review
   
   **To continue:** Review changes and say "continue" or invoke `/gsd:execute-phase 1 --continue`
   ```
4. Exit - do NOT continue execution
```

#### Task Type: Manual

```
For task type="manual":
1. Describe what user needs to do
2. Wait for user confirmation
3. Mark as completed only after user confirms
```

### Step 6: Deviation Handling

**While executing, you WILL discover work not in the plan.** Apply these rules automatically:

#### Rule 1: Critical Missing Functionality
If task cannot be completed without implementing something not in plan:
- Fix inline (implement the missing piece)
- Add/update tests if applicable
- Verify fix
- Continue task
- Track as `[Rule 1 - Critical] description`

#### Rule 2: Bugs in Existing Code
If you find bugs in code you're modifying:
- Fix inline
- Add test if applicable
- Verify fix
- Continue task
- Track as `[Rule 2 - Bug] description`

#### Rule 3: Build/Dependency Issues
If build fails or dependencies missing:
- Fix inline (install, configure, etc.)
- Verify fix
- Continue task
- Track as `[Rule 3 - Dependency] description`

**Shared process for Rules 1-3:**
Fix inline → add/update tests if applicable → verify fix → continue task → track deviation

**No user permission needed for Rules 1-3.**

#### Rule 4: Auth Gates
If authentication/authorization required:
- STOP execution
- Return auth error with clear instructions
- Do NOT attempt to bypass
- Track as `[Rule 4 - Auth] description`

#### Rule 5: Architecture Issues
If you discover the plan has architectural flaws:
- STOP execution
- Explain issue to user
- Propose fix
- Wait for user decision
- Track as `[Rule 5 - Architecture] description`

### Step 7: Task Commit Protocol

After completing each task (except checkpoints):

1. **Verify all changes:**
   - Check modified files match task **Files** field
   - Verify task **Action** was completed
   - Confirm **Verification** criteria met

2. **Stage changes:**
   ```bash
   git add [files from task]
   ```

3. **Create commit message:**
   ```
   Task: [T-XX] [Brief description]
   
   [Changes made]
   
   Per: D-XX (if applicable)
   Deviations: [Rule N] description (if any)
   ```

4. **Commit:**
   ```bash
   git commit -m "[commit message]"
   ```

5. **Record commit hash:**
   - Store in memory for SUMMARY.md
   - Format: `T-XX: [commit-hash] [description]`

### Step 8: Checkpoint Protocol

If plan has checkpoints:

1. After completing checkpoint task
2. STOP - do NOT continue
3. Return checkpoint message (see Step 5)
4. Update STATE.md:
   ```markdown
   ## Current Position
   - Phase: 1
   - Status: checkpoint
   - Checkpoint: T-XX
   - Completed: [T-01, T-02]
   - Remaining: [T-03, T-04]
   ```

### Step 9: Final Verification

After all tasks (or reaching checkpoint):

1. **Run overall verification** from PLAN.md success criteria
2. **Confirm all acceptance criteria** from REQUIREMENTS.md
3. **Document all deviations**
4. **Verify no blockers** remain

### Step 10: Create SUMMARY.md

Create `.planning/<phase-N>/SUMMARY.md`:

```markdown
# Phase 1 Summary

## Objective
[From PLAN.md]

## Completed Tasks
- T-01: [description] - [commit-hash]
- T-02: [description] - [commit-hash]

## Deviations
- [Rule 1 - Critical] Added missing error handling
- [Rule 2 - Bug] Fixed race condition in X

## Verification Results
- [x] All tests pass
- [x] Build succeeds
- [x] Acceptance criteria met

## Files Changed
- src/file1.js
- tests/file1.test.js

## Time Spent
- Start: [timestamp]
- End: [timestamp]
- Duration: [duration]

## Next Phase
Ready for Phase 2: [name]
```

### Step 11: Update STATE.md

Update `.planning/STATE.md`:

```markdown
## Current Phase
- Phase: 1
- Status: completed
- Started: [date]
- Completed: [date]
- Summary: .planning/phase-1/SUMMARY.md

## Completed
- [x] New project initialized
- [x] Phase 1 planned
- [x] Phase 1 executed

## Next Actions
1. Run `/gsd:complete-milestone 1` to verify and ship
   OR
2. Run `/gsd:plan-phase 2` to plan next phase
```

## Vibe-Specific Implementation

### File Operations

Use Vibe tools for all operations:

```bash
# Read plan
read_file(path=".planning/phase-1/PLAN.md")

# Write/Update files
write_file(path="src/file.js", content="...")

# Edit files
search_replace(file_path="src/file.js", content="<<<<<<< SEARCH...=======
...>>>>>>> REPLACE")

# Run commands
bash(command="npm test", timeout=120)
```

### Git Operations

```bash
# Stage files
git add file1.js file2.js

# Commit
git commit -m "message"

# Check status
git status
```

### Task Tracking

```
todo(action="write", todos=[
  {id: "T-01", content: "Task 1", status: "completed"},
  {id: "T-02", content: "Task 2", status: "in_progress"}
])
```

### Subagents

For complex tasks, use `task` tool:

```
task(task="Implement complex feature X with Y and Z", agent="explore")
```

## Quality Gates

Before completing execution:

- [ ] All tasks executed or checkpoint reached
- [ ] Deviations documented
- [ ] All verifications passed
- [ ] Changes committed with proper messages
- [ ] SUMMARY.md created (if completed)
- [ ] STATE.md updated
- [ ] No unresolved blockers

## Error Handling

- **No PLAN.md**: Error - phase not planned
- **Circular dependencies**: Error - cannot execute
- **Auth errors**: STOP, return clear error (Rule 4)
- **Architecture issues**: STOP, explain to user (Rule 5)
- **User cancels**: Save state, update STATE.md

## Important: Atomic Execution

Each task should be atomic:
- Complete the task
- Commit the changes
- Move to next task

If a task fails midway:
- Do NOT partially commit
- Fix and retry
- Or rollback and report error

## Next Step

After completing this skill:

1. If checkpoint reached: Tell user to review and continue
2. If phase completed: Tell user phase is done
3. Suggest next: complete milestone or plan next phase

## Remember

- **Plans are law** - follow PLAN.md exactly
- **Deviations happen** - handle them automatically (Rules 1-3)
- **Stop at checkpoints** - never continue past checkpoint
- **Commit per task** - atomic commits for traceability
- **Document everything** - SUMMARY.md is crucial
- **User decisions rule** - locked decisions are NON-NEGOTIABLE
