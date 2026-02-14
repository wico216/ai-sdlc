#!/bin/bash
set -euo pipefail

# AI-SDLC Framework Installer for Claude Code
# Installs commands, agents, references, templates, and workflows

VERSION="0.1.0"
CLAUDE_HOME="${HOME}/.claude"
SDLC_HOME="${CLAUDE_HOME}/ai-sdlc"
COMMANDS_DIR="${CLAUDE_HOME}/commands/sdlc"
AGENTS_DIR="${CLAUDE_HOME}/agents"
HOOKS_DIR="${CLAUDE_HOME}/hooks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

print_banner() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  AI-SDLC Framework for Claude Code${NC}"
    echo -e "  Version ${VERSION}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect script location (where the source files are)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"

if [ ! -d "${SRC_DIR}" ]; then
    print_error "Source directory not found at ${SRC_DIR}"
    print_error "Run this script from the ai-sdlc repository root."
    exit 1
fi

print_banner

# Check for Claude Code
if ! command -v claude &> /dev/null; then
    print_warn "Claude Code CLI not found in PATH."
    print_warn "Install it from: https://claude.ai/download"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for existing installation
if [ -d "${SDLC_HOME}" ]; then
    print_warn "Existing AI-SDLC installation found."
    read -p "Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

echo "Installing AI-SDLC Framework..."
echo ""

# Create directories
mkdir -p "${SDLC_HOME}"
mkdir -p "${COMMANDS_DIR}"
mkdir -p "${AGENTS_DIR}"
mkdir -p "${HOOKS_DIR}"

# Function to copy files with path substitution
install_file() {
    local src="$1"
    local dest="$2"

    # Copy file and substitute path placeholders
    sed \
        -e "s|__SDLC_HOME__|${SDLC_HOME}|g" \
        -e "s|__CLAUDE_HOME__|${CLAUDE_HOME}|g" \
        "$src" > "$dest"
}

# Install framework core (references, templates, workflows)
echo "Installing framework core..."
for dir in references templates workflows; do
    if [ -d "${SRC_DIR}/${dir}" ]; then
        # Recursively copy directory structure
        find "${SRC_DIR}/${dir}" -type d | while read -r subdir; do
            relative="${subdir#${SRC_DIR}/${dir}}"
            mkdir -p "${SDLC_HOME}/${dir}${relative}"
        done
        find "${SRC_DIR}/${dir}" -type f | while read -r file; do
            relative="${file#${SRC_DIR}/${dir}/}"
            install_file "$file" "${SDLC_HOME}/${dir}/${relative}"
        done
    fi
done
print_step "Framework core installed to ${SDLC_HOME}/"

# Install commands
echo "Installing commands..."
for cmd in "${SRC_DIR}/commands/"*.md; do
    if [ -f "$cmd" ]; then
        filename=$(basename "$cmd")
        install_file "$cmd" "${COMMANDS_DIR}/${filename}"
    fi
done
CMD_COUNT=$(ls "${COMMANDS_DIR}"/*.md 2>/dev/null | wc -l | tr -d ' ')
print_step "${CMD_COUNT} commands installed to ${COMMANDS_DIR}/"

# Install agents
echo "Installing agents..."
for agent in "${SRC_DIR}/agents/"*.md; do
    if [ -f "$agent" ]; then
        filename=$(basename "$agent")
        install_file "$agent" "${AGENTS_DIR}/${filename}"
    fi
done
AGENT_COUNT=$(ls "${AGENTS_DIR}"/sdlc-*.md 2>/dev/null | wc -l | tr -d ' ')
print_step "${AGENT_COUNT} agents installed to ${AGENTS_DIR}/"

# Install hooks
echo "Installing hooks..."
for hook in "${SRC_DIR}/hooks/"*.js; do
    if [ -f "$hook" ]; then
        filename=$(basename "$hook")
        install_file "$hook" "${HOOKS_DIR}/${filename}"
    fi
done
print_step "Hooks installed to ${HOOKS_DIR}/"

# Install VERSION
echo "${VERSION}" > "${SDLC_HOME}/VERSION"
print_step "Version ${VERSION}"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  AI-SDLC Framework installed successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  Quick Start:"
echo ""
echo "  1. Open a project directory in Claude Code"
echo "  2. Run: /sdlc:new-project"
echo "  3. Follow the Inception flow"
echo ""
echo "  Available commands:"
echo "  /sdlc:new-project    — Initialize a new project"
echo "  /sdlc:inception      — Run full Inception phase"
echo "  /sdlc:bolt <unit>    — Execute a Construction bolt"
echo "  /sdlc:deploy         — Run Operations phase"
echo "  /sdlc:help           — Full command reference"
echo ""
echo "  Learn more: https://ai-sdlc-explainer.vercel.app/"
echo ""
