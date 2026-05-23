---
name: gsd-complete-milestone
description: Verify and complete a milestone with comprehensive testing, documentation review, and ship preparation. Use after executing a phase to verify work and prepare for shipping.
---

# GSD Complete Milestone for Vibe

**You are the GSD milestone completer for Vibe CLI.**

This skill verifies completed work, runs comprehensive testing, reviews documentation, and prepares the milestone for shipping.

## When to Use

Invoke this skill when:
- User explicitly asks to complete a milestone
- User says "complete phase 1", "ship it", "verify work", etc.
- GSD orchestrator detects completion intent
- SUMMARY.md exists but milestone not marked complete
- STATE.md shows phase as "completed" but not verified

## Prerequisites

Before completing:
- [ ] `.planning/<phase-N>/PLAN.md` exists
- [ ] `.planning/<phase-N>/SUMMARY.md` exists
- [ ] STATE.md shows phase as "completed"
- [ ] All tasks in PLAN.md show as completed

If any are missing, invoke `gsd-execute-phase` first.

## Process Flow

### Step 1: Load Milestone Context

Read the milestone files:

```bash
# Read PLAN.md
read_file(path=".planning/phase-1/PLAN.md")

# Read SUMMARY.md
read_file(path=".planning/phase-1/SUMMARY.md")

# Read STATE.md
read_file(path=".planning/STATE.md")

# Read PROJECT.md
read_file(path=".planning/PROJECT.md")

# Read REQUIREMENTS.md
read_file(path=".planning/REQUIREMENTS.md")
```

Extract:
- **Milestone number and name**
- **Objective from PLAN.md**
- **Completed tasks from SUMMARY.md**
- **Deviations from SUMMARY.md**
- **Success criteria from PLAN.md and REQUIREMENTS.md**

### Step 2: Verification Checklist

Run through comprehensive verification:

#### Code Quality
- [ ] All code follows project conventions
- [ ] No linting errors
- [ ] No console.log/debug statements
- [ ] Proper error handling
- [ ] Consistent code style

#### Tests
- [ ] All tests pass
- [ ] Test coverage meets requirements
- [ ] Tests cover all new functionality
- [ ] Edge cases tested

#### Documentation
- [ ] Code has proper comments
- [ ] README updated (if applicable)
- [ ] API documentation complete
- [ ] Changes documented

#### Build
- [ ] Project builds successfully
- [ ] No build warnings
- [ ] All dependencies installed
- [ ] Environment configuration correct

#### Security
- [ ] No hardcoded secrets
- [ ] No sensitive data in code
- [ ] Proper authentication/authorization
- [ ] Input validation in place

### Step 3: Run Automated Verification

Execute verification commands from PLAN.md:

```bash
# Run tests (adjust based on project)
bash(command="npm test", timeout=120)

# Or for Python
bash(command="pytest", timeout=120)

# Or for Go
bash(command="go test ./...", timeout=120)

# Run linter
bash(command="npm run lint", timeout=60)

# Build project
bash(command="npm run build", timeout=120)
```

**If any verification fails:**
1. Document the failure
2. Determine if it's a real issue or test problem
3. Fix if within scope (Rule 1-3 from execute-phase)
4. Report to user if needs their input

### Step 4: Review Against Requirements

For each requirement (FR-XX, NFR-XX) from REQUIREMENTS.md:

1. **Check acceptance criteria** from PLAN.md
2. **Verify implementation** matches criteria
3. **Test manually** if needed
4. **Mark as passed/failed**

**If any requirement fails:**
- Document in verification report
- Determine if rework needed
- Create follow-up tasks if needed

### Step 5: Review Against Decisions

Check each locked decision (D-XX) from PROJECT.md:

1. **Verify implementation** matches decision
2. **Check for rationalization** (didn't follow decision)
3. **Document compliance** in verification report

**If decision not followed:**
- Flag as major issue
- Explain impact
- User must decide: accept deviation or fix

### Step 6: Create Verification Report

Create `.planning/<phase-N>/VERIFICATION.md`:

```markdown
# Phase 1 Verification Report

## Date
[YYYY-MM-DD]

## Milestone
Phase 1: [Name]

## Verification Results

### Code Quality
- [x] Code follows conventions
- [x] No linting errors
- [x] No debug statements
- [ ] Proper error handling (FAILED - see below)
- [x] Consistent style

### Tests
- [x] All tests pass
- [x] Coverage meets requirements
- [x] New functionality tested
- [ ] Edge cases covered (FAILED - missing error cases)

### Documentation
- [x] Code commented
- [x] README updated
- [x] API docs complete
- [x] Changes documented

### Build
- [x] Builds successfully
- [x] No warnings
- [x] Dependencies installed
- [x] Configuration correct

### Security
- [x] No hardcoded secrets
- [x] No sensitive data
- [x] Auth in place
- [x] Input validated

## Failed Items

### FC-01: Error handling incomplete
- **Location:** src/api/handler.js
- **Issue:** Missing error handling for null input
- **Impact:** Runtime errors possible
- **Action:** Add null check before processing

### FC-02: Edge cases not tested
- **Location:** tests/api.test.js
- **Issue:** No tests for error scenarios
- **Impact:** Untested error paths
- **Action:** Add error case tests

## Test Results
```
Test Suites: 15 passed, 1 failed, 20 total
Tests: 148 passed, 2 failed, 150 total
```

## Decisions Compliance
- [x] D-01: Used React hooks - COMPLIANT
- [x] D-02: Used TypeScript - COMPLIANT
- [x] D-03: Used Tailwind CSS - COMPLIANT

## Overall Status
**STATUS: NEEDS WORK**

2 critical issues must be fixed before shipping.

## Recommendations
1. Fix FC-01: Add error handling
2. Fix FC-02: Add edge case tests
3. Re-run verification
```

### Step 7: User Review and Decision

Present verification report to user:

```
## 📋 Verification Report: Phase 1

**Status:** [PASSED / NEEDS WORK / BLOCKED]

**Summary:** [Brief summary of results]

**Critical Issues:** [Number] - Must fix before shipping
**Minor Issues:** [Number] - Can ship but should fix

**Decisions:**
- All locked decisions (D-XX) are compliant
- No unauthorized changes

**Recommendation:** [Ship / Fix and Reverify / Don't Ship]

**Full report:** .planning/phase-1/VERIFICATION.md
```

Wait for user decision:
- **If PASSED or minor issues only**: Proceed to Step 8
- **If NEEDS WORK**: Return to execute-phase or create fix tasks
- **If BLOCKED**: Escalate to user for resolution

### Step 8: Prepare for Shipping

If user approves shipping:

1. **Update ROADMAP.md:**
   ```markdown
   ## Phase 1: [Name]
   **Goal:** [What this phase achieves]
   **Status:** ✅ COMPLETED
   **Completed:** [date]
   **Summary:** .planning/phase-1/SUMMARY.md
   **Verification:** .planning/phase-1/VERIFICATION.md
   ```

2. **Update STATE.md:**
   ```markdown
   ## Current Phase
   - Phase: 1
   - Status: shipped
   - Started: [date]
   - Completed: [date]
   - Shipped: [date]
   - Summary: .planning/phase-1/SUMMARY.md
   - Verification: .planning/phase-1/VERIFICATION.md
   
   ## Completed
   - [x] New project initialized
   - [x] Phase 1 planned
   - [x] Phase 1 executed
   - [x] Phase 1 verified
   - [x] Phase 1 shipped
   
   ## Next Actions
   1. Run `/gsd:plan-phase 2` to plan next phase
   ```

3. **Tag milestone (optional):**
   ```bash
   git tag -a phase-1 -m "Phase 1: [Name] completed"
   git push --tags
   ```

4. **Create release notes (optional):**
   - Extract from SUMMARY.md
   - Create `.planning/phase-1/RELEASE-NOTES.md`

### Step 9: Update Backlog

Move completed items from backlog if applicable:

```bash
# Read backlog
read_file(path=".planning/backlog.md")

# Update backlog - move completed items to "Completed" section
```

## Vibe-Specific Implementation

### File Operations

```bash
# Read verification files
read_file(path=".planning/phase-1/PLAN.md")
read_file(path=".planning/phase-1/SUMMARY.md")

# Write verification report
write_file(path=".planning/phase-1/VERIFICATION.md", content="...")

# Update state files
search_replace(file_path=".planning/STATE.md", content="...")
search_replace(file_path=".planning/ROADMAP.md", content="...")
```

### Task Tracking

```
todo(action="write", todos=[
  {id: "1", content: "Load milestone context", status: "completed"},
  {id: "2", content: "Run code quality checks", status: "in_progress"},
  {id: "3", content: "Run tests", status: "pending"},
  {id: "4", content: "Review documentation", status: "pending"},
  {id: "5", content: "Verify against requirements", status: "pending"},
  {id: "6", content: "Create verification report", status: "pending"},
  {id: "7", content: "Get user approval", status: "pending"},
  {id: "8", content: "Update state files", status: "pending"}
])
```

## Quality Gates

Before completing milestone:

- [ ] All verification checks run
- [ ] Test results documented
- [ ] User has reviewed and approved
- [ ] VERIFICATION.md created
- [ ] STATE.md updated
- [ ] ROADMAP.md updated
- [ ] No critical issues open

## Error Handling

- **No SUMMARY.md**: Error - phase not executed
- **Verification fails**: Document, fix, re-run
- **User rejects**: Save state, note in STATE.md
- **Critical issues**: Must fix before shipping

## Verification Levels

### Level 1: Quick Verify (Default)
- Run tests
- Check build
- Review SUMMARY.md
- Quick decision

### Level 2: Full Verify
- All checks in Step 2
- Full test suite
- Documentation review
- Security scan
- Performance check

### Level 3: Ship Verify
- Level 2 + user acceptance
- Staging deployment (if applicable)
- Final approval

## Next Step

After completing this skill:

1. If PASSED: "Phase N verified and ready to ship!"
2. If NEEDS WORK: "Phase N needs fixes. Here's what to fix: [list]"
3. Suggest: "Ready to plan next phase or make fixes"

## Remember

- **Verification is mandatory** - never skip
- **Document everything** - VERIFICATION.md is the record
- **User decides** - they control shipping
- **No surprises** - user must know what they're shipping
- **Quality first** - don't ship with known issues
- **locked decisions rule** - compliance is non-negotiable
