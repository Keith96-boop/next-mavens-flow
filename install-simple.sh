#!/bin/bash
# ============================================================================
# Maven Flow Simple Installation Script (Unix/Linux/macOS)
# ============================================================================
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
INSTALL_MODE="${1:-global}"
PROJECT_DIR="${2:-$PWD}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Maven Flow Installation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================================================
# Step 0: Check and install jq (required for Maven Flow hooks)
# ============================================================================
echo -e "${BLUE}[Step 0/5]${NC} Checking for jq (JSON processor)..."

if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}  ⚠ jq not found. Installing jq...${NC}"
    if [ -f "$SCRIPT_DIR/install/install-jq.sh" ]; then
        bash "$SCRIPT_DIR/install/install-jq.sh"
    else
        echo -e "${RED}  ❌ jq installer not found. Please install jq manually:${NC}"
        echo "     macOS:   brew install jq"
        echo "     Linux:   sudo apt-get install jq"
        echo "     Windows: winget install jqlang.jq"
        exit 1
    fi
else
    JQ_VERSION=$(jq --version)
    echo -e "${GREEN}  ✓ jq found: $JQ_VERSION${NC}"
fi

# Install globally
if [ "$INSTALL_MODE" = "global" ]; then
    echo "Installing globally to ~/.claude/"

    # Maven Flow internal files
    TARGET_DIR="$HOME/.claude/maven-flow"
    # Global locations for Claude Code
    AGENTS_DIR="$HOME/.claude/agents"
    COMMANDS_DIR="$HOME/.claude/commands"
    SKILLS_DIR="$HOME/.claude/skills"

    # Create directories
    mkdir -p "$TARGET_DIR"/{hooks,config,.claude}
    mkdir -p "$AGENTS_DIR"
    mkdir -p "$COMMANDS_DIR"
    mkdir -p "$SKILLS_DIR"

    # Copy agents to global location
    if [ -d "$SCRIPT_DIR/.claude/agents" ]; then
        cp -n "$SCRIPT_DIR"/.claude/agents/*.md "$AGENTS_DIR/" 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Agents installed to ~/.claude/agents/"
    fi

    # Copy commands to global location
    if [ -d "$SCRIPT_DIR/.claude/commands" ]; then
        cp -n "$SCRIPT_DIR"/.claude/commands/*.md "$COMMANDS_DIR/" 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Commands installed to ~/.claude/commands/"
    fi

    # Copy skills
    if [ -d "$SCRIPT_DIR/.claude/skills" ]; then
        for skill_dir in "$SCRIPT_DIR"/.claude/skills/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                mkdir -p "$SKILLS_DIR/$skill_name"
                if [ -f "$skill_dir/SKILL.md" ]; then
                    cp -n "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/" 2>/dev/null || true
                fi
            fi
        done
        echo -e "${GREEN}✓${NC} Skills installed"
    fi

    # Copy hooks
    if [ -d "$SCRIPT_DIR/.claude/maven-flow/hooks" ]; then
        cp -n "$SCRIPT_DIR"/.claude/maven-flow/hooks/*.sh "$TARGET_DIR/hooks/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Hooks installed"
    fi

    # Copy config
    if [ -d "$SCRIPT_DIR/.claude/maven-flow/config" ]; then
        cp -n "$SCRIPT_DIR"/.claude/maven-flow/config/*.mjs "$TARGET_DIR/config/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Config installed"
    fi

    # Copy settings
    if [ -f "$SCRIPT_DIR/.claude/maven-flow/.claude/settings.json" ]; then
        mkdir -p "$TARGET_DIR/.claude"
        cp -n "$SCRIPT_DIR/.claude/maven-flow/.claude/settings.json" "$TARGET_DIR/.claude/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Settings configured"
    fi

    echo ""
    echo -e "${GREEN}✅ Maven Flow installed globally!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Create a PRD: /flow-prd"
    echo "  2. Convert to JSON: /flow-convert"
    echo "  3. Start development: /flow start"

# Install locally
elif [ "$INSTALL_MODE" = "local" ]; then
    echo "Installing locally to $PROJECT_DIR"

    TARGET_DIR="$PROJECT_DIR/.claude/maven-flow"
    SKILLS_DIR="$PROJECT_DIR/.claude/skills"

    # Create directories
    mkdir -p "$TARGET_DIR"/{agents,commands,hooks,config,.claude}
    mkdir -p "$SKILLS_DIR"
    mkdir -p "$PROJECT_DIR/docs"

    # Copy agents
    if [ -d "$SCRIPT_DIR/.claude/agents" ]; then
        cp -n "$SCRIPT_DIR"/.claude/agents/*.md "$TARGET_DIR/agents/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Agents installed"
    fi

    # Copy commands
    if [ -d "$SCRIPT_DIR/.claude/commands" ]; then
        cp -n "$SCRIPT_DIR"/.claude/commands/*.md "$TARGET_DIR/commands/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Commands installed"
    fi

    # Copy skills
    if [ -d "$SCRIPT_DIR/.claude/skills" ]; then
        for skill_dir in "$SCRIPT_DIR"/.claude/skills/*/; do
            if [ -d "$skill_dir" ]; then
                skill_name=$(basename "$skill_dir")
                mkdir -p "$SKILLS_DIR/$skill_name"
                if [ -f "$skill_dir/SKILL.md" ]; then
                    cp -n "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/" 2>/dev/null || true
                fi
            fi
        done
        echo -e "${GREEN}✓${NC} Skills installed"
    fi

    # Copy hooks
    if [ -d "$SCRIPT_DIR/.claude/maven-flow/hooks" ]; then
        cp -n "$SCRIPT_DIR"/.claude/maven-flow/hooks/*.sh "$TARGET_DIR/hooks/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Hooks installed"
    fi

    # Copy config
    if [ -d "$SCRIPT_DIR/.claude/maven-flow/config" ]; then
        cp -n "$SCRIPT_DIR"/.claude/maven-flow/config/*.mjs "$TARGET_DIR/config/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Config installed"
    fi

    # Copy settings
    if [ -f "$SCRIPT_DIR/.claude/maven-flow/.claude/settings.json" ]; then
        cp -n "$SCRIPT_DIR/.claude/maven-flow/.claude/settings.json" "$TARGET_DIR/.claude/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Settings configured"
    fi

    # Create prd.json if not exists
    if [ ! -f "$PROJECT_DIR/docs/prd.json" ]; then
        cat > "$PROJECT_DIR/docs/prd.json" << 'EOF'
{
  "projectName": "My Project",
  "branchName": "main",
  "stories": []
}
EOF
        echo -e "${GREEN}✓${NC} Created docs/prd.json"
    fi

    # Create progress.txt if not exists
    if [ ! -f "$PROJECT_DIR/docs/progress.txt" ]; then
        cat > "$PROJECT_DIR/docs/progress.txt" << 'EOF'
# Maven Flow Progress

## Codebase Patterns
<!-- Add reusable patterns discovered during development -->

## Iteration Log
<!-- Progress from each iteration will be appended here -->
EOF
        echo -e "${GREEN}✓${NC} Created docs/progress.txt"
    fi

    echo ""
    echo -e "${GREEN}✅ Maven Flow installed locally!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Create a PRD: /flow-prd"
    echo "  2. Convert to JSON: /flow-convert"
    echo "  3. Start development: /flow start"

else
    echo -e "${RED}❌ Invalid install mode: $INSTALL_MODE${NC}"
    echo ""
    echo "Usage:"
    echo "  ./install-simple.sh global     # Install globally"
    echo "  ./install-simple.sh local      # Install locally"
    exit 1
fi
