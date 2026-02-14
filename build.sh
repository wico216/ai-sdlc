#!/bin/bash
set -euo pipefail

# AI-SDLC Build Script
# Generates tool-specific commands from single-source files in src/shared/commands/
# Output: src/claude/commands/ and src/cursor/commands/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BUILD_CLAUDE=false
BUILD_CURSOR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --claude)  BUILD_CLAUDE=true; shift ;;
        --cursor)  BUILD_CURSOR=true; shift ;;
        --all)     BUILD_CLAUDE=true; BUILD_CURSOR=true; shift ;;
        -h|--help) echo "Usage: ./build.sh [--claude|--cursor|--all]"; exit 0 ;;
        *)         echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Default: build all
if [ "$BUILD_CLAUDE" = false ] && [ "$BUILD_CURSOR" = false ]; then
    BUILD_CLAUDE=true
    BUILD_CURSOR=true
fi

build_commands() {
    local src_cmd_dir="${SRC_DIR}/shared/commands"
    local claude_cmd_dir="${SRC_DIR}/claude/commands"
    local cursor_cmd_dir="${SRC_DIR}/cursor/commands"

    if [ "$BUILD_CLAUDE" = true ]; then
        # Clean previous build (preserve .generated marker)
        find "$claude_cmd_dir" -name "*.md" -delete 2>/dev/null || true

        for cmd in "${src_cmd_dir}/"*.md; do
            [ -f "$cmd" ] || continue
            local filename=$(basename "$cmd")

            # Claude Code variant
            sed \
                -e 's|__ARGUMENTS__|$ARGUMENTS|g' \
                -e 's|__SDLC_REFS__|~/.claude/ai-sdlc/references|g' \
                -e 's|__SDLC_TEMPLATES__|~/.claude/ai-sdlc/templates|g' \
                -e 's|__SDLC_WORKFLOWS__|~/.claude/ai-sdlc/workflows|g' \
                -e 's|__AGENTS_DIR__|~/.claude/agents|g' \
                -e 's|__CMD_PREFIX__|/sdlc:|g' \
                -e '/__CURSOR_ONLY_START__/,/__CURSOR_ONLY_END__/d' \
                -e '/__CLAUDE_ONLY_START__/d' \
                -e '/__CLAUDE_ONLY_END__/d' \
                "$cmd" > "${claude_cmd_dir}/${filename}"
        done

        # Claude-only commands (no Cursor equivalent)
        for cmd in "${SRC_DIR}/claude-only/"*.md; do
            [ -f "$cmd" ] || continue
            cp "$cmd" "${claude_cmd_dir}/$(basename "$cmd")"
        done

        local claude_count=$(ls "${claude_cmd_dir}/"*.md 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✓${NC} Claude commands built: ${claude_count}"
    fi

    if [ "$BUILD_CURSOR" = true ]; then
        # Clean previous build (preserve .generated marker)
        find "$cursor_cmd_dir" -name "*.md" -delete 2>/dev/null || true

        for cmd in "${src_cmd_dir}/"*.md; do
            [ -f "$cmd" ] || continue
            local filename=$(basename "$cmd")

            # Cursor variant
            sed \
                -e 's|__ARGUMENTS__|the context provided by the user after this command|g' \
                -e 's|__SDLC_REFS__|~/.cursor/skills/ai-sdlc/references|g' \
                -e 's|__SDLC_TEMPLATES__|~/.cursor/skills/ai-sdlc/templates|g' \
                -e 's|__SDLC_WORKFLOWS__|~/.cursor/skills/ai-sdlc/workflows|g' \
                -e 's|__AGENTS_DIR__|~/.claude/agents|g' \
                -e 's|__CMD_PREFIX__|/sdlc-|g' \
                -e '/__CLAUDE_ONLY_START__/,/__CLAUDE_ONLY_END__/d' \
                -e '/__CURSOR_ONLY_START__/d' \
                -e '/__CURSOR_ONLY_END__/d' \
                "$cmd" > "${cursor_cmd_dir}/${filename}"
        done

        local cursor_count=$(ls "${cursor_cmd_dir}/"*.md 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✓${NC} Cursor commands built: ${cursor_count}"
    fi
}

echo "Building AI-SDLC commands..."
build_commands
echo "Build complete."
