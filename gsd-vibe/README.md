# GSD for Vibe CLI

**Get Shit Done (GSD) - A spec-driven development system, ported for Mistral Vibe CLI**

This is a port of the [GSD (Get Shit Done)](https://github.com/open-gsd/get-shit-done-redux) meta-prompting workflow from Claude Code/OpenCode to Mistral Vibe CLI.

## What is GSD?

GSD is a **spec-driven development system** that solves **context rot** - the quality degradation that happens as your AI fills its context window. It provides:

- **Structured workflow**: New Project → Plan Phase → Execute Phase → Complete Milestone → Repeat
- **Context engineering**: Keeps all relevant information organized and accessible
- **Subagent orchestration**: Automatically delegates tasks to specialized agents
- **State management**: Tracks progress, decisions, and blockers
- **Quality assurance**: Comprehensive verification before shipping

## Installation

### Quick Install

```bash
# Clone this repository
 git clone https://github.com/open-gsd/get-shit-done-redux.git
 cd get-shit-done-redux

 # Run the Vibe installer
 ./gsd-vibe/install.sh
```

### From Released Package

```bash
# Download and run directly (when available)
curl -sSL https://raw.githubusercontent.com/open-gsd/get-shit-done-redux/main/gsd-vibe/install.sh | bash
```

### What Gets Installed

| Location | Purpose |
|----------|---------|
| `~/.vibe/skills/gsd-*` | GSD skill symlinks |
| `~/.vibe/gsd/` | GSD source directory (symlink) |
| `~/.vibe/AGENTS.md` | GSD configuration (created if missing) |
| `~/.vibe/update-gsd.sh` | Update script |

## Usage

After installation, Vibe CLI will automatically use GSD skills when appropriate.

### Starting a New Project

```
User: Let's build a React todo app

Vibe: (automatically invokes gsd-new-project)
      "Initializing new GSD project..."
      "What problem does this project solve?"
```

### Planning a Phase

```
User: Plan phase 1

Vibe: (invokes gsd-plan-phase)
      "Loading project context..."
      "Creating executable plan..."
```

### Executing a Phase

```
User: Execute phase 1

Vibe: (invokes gsd-execute-phase)
      "Executing tasks from PLAN.md..."
      "Task T-01: Implementing..."
```

### Completing a Milestone

```
User: Complete phase 1

Vibe: (invokes gsd-complete-milestone)
      "Running verification..."
      "All tests passed! Ready to ship."
```

### Manual Invocation

You can manually invoke any GSD skill:

```
skill(name="gsd-orchestrator")      # Main orchestrator
skill(name="gsd-new-project")       # Initialize project
skill(name="gsd-plan-phase")        # Plan a phase
skill(name="gsd-execute-phase")    # Execute a phase
skill(name="gsd-complete-milestone") # Verify and ship
```

## GSD Workflow

### 1. New Project

Creates the foundation:
- `.planning/PROJECT.md` - Project vision, purpose, success criteria
- `.planning/config.json` - Workflow configuration
- `.planning/REQUIREMENTS.md` - Functional and non-functional requirements
- `.planning/ROADMAP.md` - Phase structure and milestones
- `.planning/STATE.md` - Current project state
- `.planning/backlog.md` - Deferred ideas

### 2. Plan Phase

Creates executable plans:
- `.planning/phase-N/PLAN.md` - Detailed task breakdown
- Dependency graph with execution waves
- Goal-backward verification
- Multi-source coverage audit

### 3. Execute Phase

Implements the plan:
- Atomic task execution
- Per-task commits
- Deviation handling (Rules 1-5)
- Checkpoint protocol
- Creates SUMMARY.md

### 4. Complete Milestone

Verifies and ships:
- Comprehensive verification
- Requirements compliance check
- Decisions compliance check
- Creates VERIFICATION.md
- Updates STATE.md and ROADMAP.md

## Project Structure

```
project/
├── .planning/                   # GSD workspace
│   ├── PROJECT.md               # Project vision
│   ├── config.json              # Configuration
│   ├── REQUIREMENTS.md          # Requirements
│   ├── ROADMAP.md               # Roadmap
│   ├── STATE.md                 # Current state
│   ├── backlog.md               # Backlog
│   └── phase-1/                 # Phase 1
│       ├── PLAN.md              # Execution plan
│       ├── SUMMARY.md           # Completion summary
│       └── VERIFICATION.md      # Quality report
├── src/                        # Source code
├── tests/                      # Tests
└── README.md                   # Project readme
```

## Vibe-Specific Adaptations

### Tool Mappings

GSD was designed for Claude Code. For Vibe, use these equivalents:

| GSD/Claude Tool | Vibe Tool | Notes |
|----------------|-----------|-------|
| `Read` | `read_file` | Reading files |
| `Write` | `write_file` | Creating files |
| `Edit` | `search_replace` | Modifying files |
| `Bash` | `bash` | Running commands |
| `Grep` | `grep` | Pattern searching |
| `Glob` | `bash` with `find` | Finding files |
| `Agent` | `task` | Subagent dispatch |
| `AskUserQuestion` | `ask_user_question` | Multi-choice questions |
| `WebFetch` | `web_fetch` | HTTP requests |
| `mcp__context7__*` | `web_fetch` + processing | Documentation lookup |

### SDK Replacement

GSD uses `gsd-sdk` for state management. In Vibe, use direct file operations:

```bash
# Instead of: gsd-sdk query state.load
# Use: read_file(path=".planning/STATE.md")

# Instead of: gsd-sdk query init.execute-phase
# Use: read_file(path=".planning/phase-1/PLAN.md")
```

### Task Tracking

Use Vibe's `todo` tool instead of GSD's internal tracking:

```
todo(action="write", todos=[
  {id: "T-01", content: "Implement feature X", status: "pending"},
  {id: "T-02", content: "Write tests", status: "pending"}
])
```

## Key Features Ported

### ✅ Orchestrator
- Manages the complete GSD workflow
- Routes to appropriate skills
- Maintains context across phases

### ✅ New Project
- Deep context gathering
- Requirement elicitation
- Roadmap creation
- State initialization

### ✅ Plan Phase
- Multi-source coverage audit
- Task breakdown (2-3 tasks per plan)
- Dependency graph
- Goal-backward verification

### ✅ Execute Phase
- Atomic task execution
- Per-task commits
- Deviation handling (Rules 1-5)
- Checkpoint protocol

### ✅ Complete Milestone
- Comprehensive verification
- Requirements compliance
- Decisions compliance
- Ship preparation

## What's NOT Ported (Yet)

The following GSD features are not yet ported:

- Advanced agents (gsd-debugger, gsd-verifier, etc.)
- Review workflows
- Integration checks
- Advanced settings
- Multi-repo support
- GitHub integration

These may be added in future versions.

## Configuration

### config.json

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

### Customization

Edit `~/.vibe/AGENTS.md` to customize GSD behavior for your workflow.

## Updating

To update GSD to the latest version:

```bash
~/.vibe/update-gsd.sh
```

Or manually:

```bash
cd ~/.vibe/gsd
git pull
```

## Uninstallation

To remove GSD:

```bash
# Remove skill symlinks
rm -rf ~/.vibe/skills/gsd-*

# Remove GSD directory
rm -rf ~/.vibe/gsd

# Remove update script
rm -f ~/.vibe/update-gsd.sh

# Optionally keep AGENTS.md
# rm -f ~/.vibe/AGENTS.md
```

## Troubleshooting

### Skills not loading
1. Check symlinks: `ls -la ~/.vibe/skills/gsd-*`
2. Verify SKILL.md files exist in each directory
3. Restart Vibe CLI

### "GSD not active"
- Check `~/.vibe/AGENTS.md` exists and has GSD content
- Verify `.planning/` directory exists in your project
- Manually invoke `skill(name="gsd-orchestrator")`

### Permission denied
```bash
chmod +x ~/.vibe/update-gsd.sh
```

## Comparison: GSD vs Superpowers

Both are meta-prompting systems, but they serve different purposes:

| Feature | GSD | Superpowers |
|---------|-----|-------------|
| Purpose | Spec-driven project development | General AI agent skills |
| Scope | Full project lifecycle | Individual tasks/skills |
| Structure | Phased workflow | Modular skills |
| Artifacts | `.planning/` directory | None (inline) |
| Best for | Building new projects | Enhancing any workflow |

**Use GSD for:** New projects, major features, structured development

**Use Superpowers for:** Code review, debugging, brainstorming, any task

**They can work together:** Use GSD for project structure, Superpowers for individual skills within phases.

## Contributing

To add more GSD agents to Vibe:

1. Convert the agent `.md` file to Vibe skill format:
   - Remove Claude-specific frontmatter (`tools:`, `color:`, etc.)
   - Keep only `name` and `description` in YAML
   - Replace `@~/.claude/get-shit-done/...` references with inline content or Vibe equivalents
   - Replace SDK calls with Vibe tool calls

2. Save as `gsd-vibe/skills/gsd-[name]/SKILL.md`

3. Test the skill

4. Submit a PR

## License

This port is licensed under the [MIT License](../LICENSE), same as the original GSD project.

## Credits

- **Original GSD**: [TÂCHES](https://github.com/gsd-build) / [open-gsd](https://github.com/open-gsd)
- **Vibe Port**: Created for Mistral Vibe CLI
- **Superpowers**: [obra/superpowers](https://github.com/obra/superpowers) - compatible skill system

## Links

- [GSD Repository](https://github.com/open-gsd/get-shit-done-redux)
- [Vibe CLI](https://github.com/mistralai/vibe)
- [Superpowers](https://github.com/obra/superpowers)
- [Original GSD](https://github.com/gsd-build/get-shit-done) (archived)
