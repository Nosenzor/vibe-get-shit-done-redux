#!/bin/bash

# GSD for Vibe CLI - Installer
# This script installs the GSD (Get Shit Done) workflow as Vibe skills
# Usage: ./install.sh [--update]

set -euo pipefail

# Configuration
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${HOME}/.vibe"
SKILLS_DIR="${INSTALL_DIR}/skills"
GSD_DIR="${INSTALL_DIR}/gsd"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Create directory structure
setup_directories() {
    log_info "Creating directory structure..."
    mkdir -p "${INSTALL_DIR}"
    mkdir -p "${SKILLS_DIR}"
    mkdir -p "${GSD_DIR}"
    log_success "Directories created"
}

# Install GSD skills
install_skills() {
    log_info "Installing GSD skills..."
    
    local skills_source="${SOURCE_DIR}/skills"
    local count=0
    
    if [[ ! -d "${skills_source}" ]]; then
        log_error "Skills directory not found at ${skills_source}"
        exit 1
    fi
    
    for skill_dir in "${skills_source}"/*/; do
        if [[ -d "${skill_dir}" ]]; then
            local skill_name=$(basename "${skill_dir}")
            local target="${SKILLS_DIR}/${skill_name}"
            
            # Remove existing
            if [[ -e "${target}" || -L "${target}" ]]; then
                rm -rf "${target}"
            fi
            
            # Create symlink
            ln -s "${skill_dir}" "${target}"
            log_info "  Installed: ${skill_name}"
            ((count++))
        fi
    done
    
    if [[ ${count} -eq 0 ]]; then
        log_warning "No GSD skills were installed"
    else
        log_success "Installed ${count} GSD skills"
    fi
}

# Create GSD directory symlink
create_gsd_symlink() {
    local target="${INSTALL_DIR}/gsd"
    
    if [[ ! -L "${target}" ]]; then
        ln -sf "${SOURCE_DIR}" "${target}"
        log_info "Created symlink: ~/.vibe/gsd -> ${SOURCE_DIR}"
    fi
}

# Create AGENTS.md with GSD defaults
install_agents_config() {
    local agents_file="${INSTALL_DIR}/AGENTS.md"
    
    if [[ ! -f "${agents_file}" ]]; then
        log_info "Creating AGENTS.md with GSD defaults..."
        
        cat > "${agents_file}" << 'AGENTS_EOF'
# GSD (Get Shit Done) Workflow Guidelines for Vibe

## For Vibe AI Agent

**GSD is NOW ACTIVE.** This changes how you work.

### Core Principle

**Always check for GSD first:** Before responding to ANY request, check:
1. Does a `.planning/` directory exist?
2. Is this a project management/planning/execution request?
3. Should GSD workflow be used?

**If YES to any of the above → Invoke `gsd-orchestrator` skill IMMEDIATELY.**

### When GSD Applies

GSD applies to:
- Starting new projects
- Planning work (phases, milestones, tasks)
- Implementing planned work
- Verifying/completing work
- Any mention of: GSD, get-shit-done, spec-driven, phase, milestone, roadmap

GSD does NOT apply to:
- Quick one-off questions
- Exploring existing codebases (use brainstorming skill instead)
- Simple file edits
- Debugging existing issues (use systematic-debugging skill)

### GSD Workflow

The GSD workflow is:

```
New Project → Plan Phase → Execute Phase → Complete Milestone → Repeat
```

Each step creates artifacts in `.planning/`:

```
.planning/
├── PROJECT.md          # Project vision
├── config.json         # GSD configuration
├── REQUIREMENTS.md     # What to build
├── ROADMAP.md          # What order
├── STATE.md            # Current position
├── backlog.md          # Deferred work
└── phase-1/            # Phase 1
    ├── PLAN.md         # How to build it
    ├── SUMMARY.md      # What was built
    └── VERIFICATION.md # Quality check
```

### Your Role in GSD

1. **Orchestrator**: You manage the workflow
2. **Planner**: You create detailed plans
3. **Executor**: You implement the plans
4. **Verifier**: You ensure quality

### GSD Command Mappings

| User Says | You Do |
|-----------|--------|
| "new project" | Invoke `gsd-new-project` |
| "plan phase 1" | Invoke `gsd-plan-phase` |
| "execute phase 1" | Invoke `gsd-execute-phase` |
| "complete phase 1" | Invoke `gsd-complete-milestone` |
| "plan next" | Invoke `gsd-orchestrator` |

### Critical Rules

1. **NEVER start a project without GSD**: If user says "Let's build X", invoke `gsd-new-project`
2. **NEVER plan without context**: Always read PROJECT.md, REQUIREMENTS.md, ROADMAP.md
3. **NEVER skip verification**: Always run `gsd-complete-milestone` before shipping
4. **NEVER rationalize**: If D-XX says to do it, do it exactly

### GSD Overrides Default Behavior

When GSD is active:
- Use GSD skills INSTEAD of default brainstorming/planning
- Follow GSD file formats and structures
- Use GSD deviation rules (Rules 1-5)
- Create GSD artifacts in `.planning/`

### When NOT to Use GSD

For non-GSD work (exploring, debugging, simple tasks):
- Use the appropriate superpowers skill
- Do NOT create `.planning/` directory
- Do NOT follow GSD workflow

### How to Decide

Ask yourself:
1. Is this a new project or significant feature? → GSD
2. Is there a `.planning/` directory? → GSD
3. Is the user asking for structured planning/execution? → GSD
4. Is this a simple question or small change? → Superpowers skill

When in doubt: **Invoke `gsd-orchestrator`**

### Remember

- **GSD is mandatory for projects** - not optional
- **GSD prevents scope rot** - keeps work focused
- **GSD documents everything** - full traceability
- **User is in control** - but you enforce the process

---

*GSD: Get Shit Done - A spec-driven development system*
AGENTS_EOF
        
        log_success "AGENTS.md created with GSD defaults"
    else
        log_info "AGENTS.md already exists, skipping"
    fi
}

# Create update script
create_update_script() {
    local update_script="${INSTALL_DIR}/update-gsd.sh"
    
    cat > "${update_script}" << 'UPDATE_EOF'
#!/bin/bash
# GSD for Vibe - Update Script

set -euo pipefail

INSTALL_DIR="${HOME}/.vibe"
GSD_DIR="${INSTALL_DIR}/gsd"

echo "Updating GSD for Vibe..."

# Pull latest from source
if [[ -d "${GSD_DIR}/.git" ]]; then
    cd "${GSD_DIR}"
    git pull --ff-only
    cd -
    echo "GSD repository updated"
else
    echo "GSD is not a git repository at ${GSD_DIR}"
    echo "To update manually, pull the source and reinstall"
fi

# Recreate symlinks
echo "Updating skill symlinks..."
SKILLS_DIR="${INSTALL_DIR}/skills"
GSD_SKILLS="${GSD_DIR}/skills"

if [[ -d "${GSD_SKILLS}" ]]; then
    # Remove old symlinks
    for link in "${SKILLS_DIR}"/gsd-* 2>/dev/null; do
        if [[ -L "${link}" ]]; then
            rm "${link}"
        fi
    done
    
    # Create new symlinks
    for skill_dir in "${GSD_SKILLS}"/*/; do
        if [[ -d "${skill_dir}" ]]; then
            ln -s "${skill_dir}" "${SKILLS_DIR}/$(basename ${skill_dir})"
        fi
    done
    
    echo "Skill symlinks updated"
fi

echo "GSD updated successfully!"
UPDATE_EOF
    
    chmod +x "${update_script}"
    log_success "Update script created: ${update_script}"
}

# Main installation
main() {
    echo ""
    echo "=========================================="
    echo "GSD for Vibe CLI - Installation"
    echo "=========================================="
    echo ""
    
    setup_directories
    install_skills
    create_gsd_symlink
    install_agents_config
    create_update_script
    
    echo ""
    log_success "GSD installation complete!"
    echo ""
    echo "What was installed:"
    echo "  - GSD skills: ${SKILLS_DIR}/gsd-*"
    echo "  - GSD directory: ${GSD_DIR}"
    echo "  - AGENTS.md: ${INSTALL_DIR}/AGENTS.md"
    echo "  - Update script: ${INSTALL_DIR}/update-gsd.sh"
    echo ""
    echo "To use:"
    echo "  1. Restart your Vibe CLI"
    echo "  2. Start a new project: 'Let's build X' → invokes GSD"
    echo "  3. Or manually: skill(name='gsd-new-project')"
    echo ""
    echo "To update:"
    echo "  ${INSTALL_DIR}/update-gsd.sh"
    echo ""
}

# Parse arguments
ACTION="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --update|-u)
            ACTION="update"
            shift
            ;;
        --help|-h)
            echo "Usage: $(basename "$0") [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --update, -u    Update existing installation"
            echo "  --help, -h      Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [[ "${ACTION}" == "update" ]]; then
    echo "Updating GSD..."
    # Just recreate symlinks
    install_skills
    log_success "GSD updated!"
else
    main
fi

# Run main if no action specified
main
