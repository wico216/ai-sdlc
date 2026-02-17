#!/bin/bash
set -euo pipefail

# AI-SDLC Framework Installer
# Supports both Claude Code and Cursor
# Usage: ./install.sh [--claude|--cursor|--all|--uninstall] [--dry-run]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/src"
VERSION=$(cat "${SRC_DIR}/VERSION" 2>/dev/null || echo "unknown")

# Paths
CLAUDE_HOME="${HOME}/.claude"
CURSOR_HOME="${HOME}/.cursor"
MANIFEST_DIR="${HOME}/.config/ai-sdlc"

# Parse arguments
INSTALL_CLAUDE=false
INSTALL_CURSOR=false
UNINSTALL=false
DRY_RUN=false
AUTO_DETECT=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --claude)    INSTALL_CLAUDE=true; AUTO_DETECT=false; shift ;;
        --cursor)    INSTALL_CURSOR=true; AUTO_DETECT=false; shift ;;
        --all)       INSTALL_CLAUDE=true; INSTALL_CURSOR=true; AUTO_DETECT=false; shift ;;
        --uninstall) UNINSTALL=true; AUTO_DETECT=false; shift ;;
        --dry-run)   DRY_RUN=true; shift ;;
        -h|--help)   print_usage; exit 0 ;;
        *)           echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_banner() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  AI-SDLC Framework${NC}"
    echo -e "  Version ${VERSION}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() { echo -e "${GREEN}✓${NC} $1"; }
print_warn() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

print_usage() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --claude      Install for Claude Code only"
    echo "  --cursor      Install for Cursor only"
    echo "  --all         Install for both tools"
    echo "  --uninstall   Remove AI-SDLC files"
    echo "  --dry-run     Preview what would be installed"
    echo "  -h, --help    Show this help"
    echo ""
    echo "With no options, auto-detects installed tools."
}

# --- Manifest tracking ---
track_file() {
    local tool="$1"
    local filepath="$2"
    if [ "$DRY_RUN" = true ]; then return; fi
    mkdir -p "$MANIFEST_DIR"
    echo "$filepath" >> "${MANIFEST_DIR}/manifest-${tool}.txt"
}

install_file_copy() {
    local src="$1"
    local dest="$2"
    local tool="$3"
    if [ "$DRY_RUN" = true ]; then
        echo "  [dry-run] $dest"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    track_file "$tool" "$dest"
}

# --- Error handling ---
INSTALLED_FILES=()
cleanup_on_error() {
    if [ ${#INSTALLED_FILES[@]} -gt 0 ]; then
        echo ""
        print_error "Installation failed. Cleaning up ${#INSTALLED_FILES[@]} partially installed files..."
        for f in "${INSTALLED_FILES[@]}"; do
            [ -f "$f" ] && rm "$f"
        done
    fi
    exit 1
}
trap cleanup_on_error ERR

check_permissions() {
    local dirs=()
    [ "$INSTALL_CLAUDE" = true ] && dirs+=("${CLAUDE_HOME}")
    [ "$INSTALL_CURSOR" = true ] && dirs+=("${CURSOR_HOME}")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ] && [ ! -w "$dir" ]; then
            print_error "$dir is not writable"
            exit 1
        fi
    done
}

# --- Build step ---
build_commands() {
    "${SCRIPT_DIR}/build.sh" --all 2>/dev/null || {
        print_error "Build failed. Run ./build.sh manually to debug."
        exit 1
    }
}

# --- Install shared content ---
install_shared() {
    local target_dir="$1"
    local tool="$2"
    for dir in references templates workflows; do
        if [ -d "${SRC_DIR}/shared/${dir}" ]; then
            if [ "$DRY_RUN" = false ]; then
                find "${SRC_DIR}/shared/${dir}" -type d | while read -r subdir; do
                    relative="${subdir#${SRC_DIR}/shared/${dir}}"
                    mkdir -p "${target_dir}/${dir}${relative}"
                done
            fi
            find "${SRC_DIR}/shared/${dir}" -type f | while read -r file; do
                relative="${file#${SRC_DIR}/shared/${dir}/}"
                install_file_copy "$file" "${target_dir}/${dir}/${relative}" "$tool"
            done
        fi
    done
}

# --- Claude Code installation ---
install_claude() {
    local SDLC_HOME="${CLAUDE_HOME}/ai-sdlc"
    local COMMANDS_DIR="${CLAUDE_HOME}/commands/sdlc"
    local AGENTS_DIR="${CLAUDE_HOME}/agents"
    local HOOKS_DIR="${CLAUDE_HOME}/hooks"

    if [ "$DRY_RUN" = true ]; then
        echo "Would install for Claude Code..."
        echo "  Source:  ${SRC_DIR}"
        echo "  Target:  ${CLAUDE_HOME}"
    else
        echo "Installing for Claude Code..."
    fi

    # Check for existing installation
    if [ -d "${SDLC_HOME}" ] && [ "$DRY_RUN" = false ]; then
        print_warn "Existing AI-SDLC installation found — overwriting."
    fi

    # Create directories
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "${SDLC_HOME}" "${COMMANDS_DIR}" "${AGENTS_DIR}" "${HOOKS_DIR}"
    fi

    # Shared content (references, templates, workflows)
    local ref_count=$(find "${SRC_DIR}/shared/references" -type f 2>/dev/null | wc -l | tr -d ' ')
    local tpl_count=$(find "${SRC_DIR}/shared/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
    local wf_count=$(find "${SRC_DIR}/shared/workflows" -type f 2>/dev/null | wc -l | tr -d ' ')
    install_shared "$SDLC_HOME" "claude"
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install framework core: ${ref_count} references, ${tpl_count} templates, ${wf_count} workflows"
    else
        print_step "Framework core installed to ${SDLC_HOME}/"
    fi

    # Generated Claude commands (in dry-run, count source commands since build is skipped)
    if [ "$DRY_RUN" = true ]; then
        local cmd_count=$(ls "${SRC_DIR}/shared/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
        print_step "Would install ${cmd_count} commands to ${COMMANDS_DIR}/"
    else
        for cmd in "${SRC_DIR}/claude/commands/"*.md; do
            [ -f "$cmd" ] && install_file_copy "$cmd" "${COMMANDS_DIR}/$(basename "$cmd")" "claude"
        done
        local cmd_count=$(ls "${SRC_DIR}/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
        print_step "${cmd_count} commands installed to ${COMMANDS_DIR}/"
    fi

    # Shared agents (path-agnostic — no substitution needed)
    for agent in "${SRC_DIR}/agents/"*.md; do
        [ -f "$agent" ] && install_file_copy "$agent" "${AGENTS_DIR}/$(basename "$agent")" "claude"
    done
    local agent_count=$(ls "${SRC_DIR}/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install ${agent_count} agents to ${AGENTS_DIR}/"
    else
        print_step "${agent_count} agents installed to ${AGENTS_DIR}/"
    fi

    # Claude hooks
    local hook_count=$(ls "${SRC_DIR}/claude/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
    for hook in "${SRC_DIR}/claude/hooks/"*.js; do
        [ -f "$hook" ] && install_file_copy "$hook" "${HOOKS_DIR}/$(basename "$hook")" "claude"
    done
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install ${hook_count} hooks to ${HOOKS_DIR}/"
    else
        print_step "Hooks installed to ${HOOKS_DIR}/"
    fi

    # VERSION
    if [ "$DRY_RUN" = false ]; then
        echo "${VERSION}" > "${SDLC_HOME}/VERSION"
        track_file "claude" "${SDLC_HOME}/VERSION"
    fi
    print_step "Claude Code: $([ "$DRY_RUN" = true ] && echo "would install" || echo "installed") (v${VERSION})"
}

# --- Cursor installation ---
install_cursor() {
    local SKILL_DIR="${CURSOR_HOME}/skills/ai-sdlc"
    local COMMANDS_DIR="${CURSOR_HOME}/commands"
    local AGENTS_DIR="${CURSOR_HOME}/agents"
    local RULES_DIR="${CURSOR_HOME}/rules"
    local SHARED_AGENTS_DIR="${CLAUDE_HOME}/agents"

    if [ "$DRY_RUN" = true ]; then
        echo "Would install for Cursor..."
        echo "  Source:  ${SRC_DIR}"
        echo "  Target:  ${CURSOR_HOME}"
    else
        echo "Installing for Cursor..."
    fi

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "${SKILL_DIR}" "${COMMANDS_DIR}" "${AGENTS_DIR}" "${RULES_DIR}" "${SHARED_AGENTS_DIR}"
    fi

    # Shared content
    local ref_count=$(find "${SRC_DIR}/shared/references" -type f 2>/dev/null | wc -l | tr -d ' ')
    local tpl_count=$(find "${SRC_DIR}/shared/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
    local wf_count=$(find "${SRC_DIR}/shared/workflows" -type f 2>/dev/null | wc -l | tr -d ' ')
    install_shared "$SKILL_DIR" "cursor"
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install framework core: ${ref_count} references, ${tpl_count} templates, ${wf_count} workflows"
    else
        print_step "Framework core installed to ${SKILL_DIR}/"
    fi

    # Generate SKILL.md
    if [ "$DRY_RUN" = false ]; then
        cat > "${SKILL_DIR}/SKILL.md" << 'SKILL_EOF'
---
name: ai-sdlc
description: "Use when the user wants to plan, build, or deploy software; start a new project; create requirements; break work into tasks; review code quality; track progress; or asks about development process, methodology, or 'what to do next'. Also matches: SDLC, inception, construction, operations, gates, bolts, units, sprints, project planning."
disable-model-invocation: false
---

# AI-SDLC Framework

You are using the AI-SDLC framework. This skill provides:

- **References** in `references/` — methodology docs (gates, principles, roles, rituals, phases)
- **Templates** in `templates/` — artifact templates for all lifecycle documents
- **Workflows** in `workflows/` — orchestration guides for each phase

Key concepts: 3 phases (Inception, Construction, Operations), 5 gates, Golden Thread traceability, Bolts (rapid iterations), Units (DDD-aligned work chunks).

Always read `references/gates.md` and `references/principles.md` when enforcing methodology.
SKILL_EOF
        track_file "cursor" "${SKILL_DIR}/SKILL.md"
    fi
    print_step "SKILL.md $([ "$DRY_RUN" = true ] && echo "would be generated" || echo "generated")"

    # Generated Cursor commands (prefixed with sdlc-)
    if [ "$DRY_RUN" = true ]; then
        local cmd_count=$(ls "${SRC_DIR}/shared/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
        print_step "Would install ${cmd_count} commands to ${COMMANDS_DIR}/"
    else
        for cmd in "${SRC_DIR}/cursor/commands/"*.md; do
            if [ -f "$cmd" ]; then
                local filename=$(basename "$cmd")
                install_file_copy "$cmd" "${COMMANDS_DIR}/sdlc-${filename}" "cursor"
            fi
        done
        local cmd_count=$(ls "${SRC_DIR}/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
        print_step "${cmd_count} commands installed to ${COMMANDS_DIR}/"
    fi

    # Cursor subagent wrappers
    for agent in "${SRC_DIR}/cursor/agents/"*.md; do
        [ -f "$agent" ] && install_file_copy "$agent" "${AGENTS_DIR}/$(basename "$agent")" "cursor"
    done

    # ALSO install shared agents to ~/.claude/agents/ (Cursor reads this natively)
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "${SHARED_AGENTS_DIR}"
    fi
    for agent in "${SRC_DIR}/agents/"*.md; do
        [ -f "$agent" ] && install_file_copy "$agent" "${SHARED_AGENTS_DIR}/$(basename "$agent")" "cursor"
    done
    local agent_count=$(ls "${SRC_DIR}/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    local cursor_agent_count=$(ls "${SRC_DIR}/cursor/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install ${agent_count} shared agents + ${cursor_agent_count} cursor agents"
    else
        print_step "Agents installed"
    fi

    # Cursor rules
    local rule_count=$(ls "${SRC_DIR}/cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
    for rule in "${SRC_DIR}/cursor/rules/"*.mdc; do
        [ -f "$rule" ] && install_file_copy "$rule" "${RULES_DIR}/$(basename "$rule")" "cursor"
    done
    if [ "$DRY_RUN" = true ]; then
        print_step "Would install ${rule_count} rules to ${RULES_DIR}/"
    fi

    # Merge hooks (not replace!)
    merge_cursor_hooks

    # VERSION
    if [ "$DRY_RUN" = false ]; then
        echo "${VERSION}" > "${SKILL_DIR}/VERSION"
        track_file "cursor" "${SKILL_DIR}/VERSION"
    fi
    print_step "Cursor: $([ "$DRY_RUN" = true ] && echo "would install" || echo "installed") (v${VERSION})"
}

# --- Hooks merge ---
merge_cursor_hooks() {
    local src_hooks_dir="${SRC_DIR}/cursor/hooks"
    local target_hooks_dir="${CURSOR_HOME}/hooks"
    local target_hooks_json="${CURSOR_HOME}/hooks.json"

    # Install hook .js files
    if [ -d "$src_hooks_dir" ]; then
        for hook_js in "${src_hooks_dir}/"*.js; do
            [ -f "$hook_js" ] && install_file_copy "$hook_js" "${target_hooks_dir}/$(basename "$hook_js")" "cursor"
        done
    fi

    if [ "$DRY_RUN" = true ]; then
        echo "  [dry-run] Would merge hooks into ${target_hooks_json}"
        return
    fi

    # Our hooks definition
    local sdlc_hooks='[{"event":"sessionStart","type":"command","command":"node ~/.cursor/hooks/sdlc-session-start.js","description":"[ai-sdlc] Framework status on session start"},{"event":"stop","type":"command","command":"node ~/.cursor/hooks/sdlc-status.js","description":"[ai-sdlc] Show current phase on completion"},{"event":"afterFileEdit","type":"command","command":"node ~/.cursor/hooks/sdlc-audit-watch.js","description":"[ai-sdlc] Track audit trail modifications"}]'

    if [ -f "$target_hooks_json" ]; then
        # Backup original (only first time)
        if [ ! -f "${target_hooks_json}.pre-sdlc" ]; then
            cp "$target_hooks_json" "${target_hooks_json}.pre-sdlc"
        fi

        # Check if node is available for JSON merge
        if command -v node &>/dev/null; then
            node -e "
                const fs = require('fs');
                const existing = JSON.parse(fs.readFileSync('${target_hooks_json}', 'utf8'));
                const sdlcHooks = ${sdlc_hooks};
                existing.hooks = (existing.hooks || []).filter(h =>
                    !h.description || !h.description.startsWith('[ai-sdlc]')
                );
                existing.hooks.push(...sdlcHooks);
                fs.writeFileSync('${target_hooks_json}', JSON.stringify(existing, null, 2));
            "
            print_step "Cursor hooks merged (existing hooks preserved)"
        else
            print_warn "Node.js not found — skipping hooks.json merge"
        fi
    else
        # No existing file — create fresh
        if command -v node &>/dev/null; then
            mkdir -p "$(dirname "$target_hooks_json")"
            echo "{\"hooks\": ${sdlc_hooks}}" | node -e "
                const fs = require('fs');
                let input = '';
                process.stdin.on('data', d => input += d);
                process.stdin.on('end', () => {
                    fs.writeFileSync('${target_hooks_json}', JSON.stringify(JSON.parse(input), null, 2));
                });
            "
            print_step "Cursor hooks.json created"
        fi
    fi

    track_file "cursor" "$target_hooks_json"
}

# --- Uninstall ---
uninstall() {
    local tool="$1"

    if [ "$tool" = "all" ]; then
        uninstall "claude"
        uninstall "cursor"
        return
    fi

    local manifest="${MANIFEST_DIR}/manifest-${tool}.txt"
    if [ ! -f "$manifest" ]; then
        echo "No manifest found for ${tool}. Nothing to uninstall."
        return
    fi

    echo "Uninstalling AI-SDLC for ${tool}..."
    local count=0
    while IFS= read -r filepath; do
        if [ -f "$filepath" ]; then
            rm "$filepath"
            ((count++))
        fi
    done < "$manifest"

    # Restore hooks.json backup if it exists (Cursor)
    if [ "$tool" = "cursor" ] && [ -f "${CURSOR_HOME}/hooks.json.pre-sdlc" ]; then
        mv "${CURSOR_HOME}/hooks.json.pre-sdlc" "${CURSOR_HOME}/hooks.json"
        echo "Restored original hooks.json"
    fi

    # Clean up empty directories
    for dir in "${CLAUDE_HOME}/ai-sdlc" "${CLAUDE_HOME}/commands/sdlc" \
               "${CURSOR_HOME}/skills/ai-sdlc" "${CURSOR_HOME}/hooks"; do
        [ -d "$dir" ] && find "$dir" -type d -empty -delete 2>/dev/null || true
    done

    rm "$manifest"
    print_step "Removed ${count} files for ${tool}."
}

# --- Auto-detection ---
if [ "$AUTO_DETECT" = true ] && [ "$UNINSTALL" = false ]; then
    if command -v claude &>/dev/null; then INSTALL_CLAUDE=true; fi
    if [ -d "${CURSOR_HOME}" ] || command -v cursor &>/dev/null; then INSTALL_CURSOR=true; fi
    if [ "$INSTALL_CLAUDE" = false ] && [ "$INSTALL_CURSOR" = false ]; then
        print_error "No supported tool detected. Use --claude, --cursor, or --all."
        exit 1
    fi
fi

# --- Source check ---
if [ ! -d "${SRC_DIR}" ]; then
    print_error "Source directory not found at ${SRC_DIR}"
    print_error "Run this script from the ai-sdlc repository root."
    exit 1
fi

# --- Main execution ---
print_banner

if [ "$UNINSTALL" = true ]; then
    if [ "$INSTALL_CLAUDE" = true ]; then uninstall "claude"
    elif [ "$INSTALL_CURSOR" = true ]; then uninstall "cursor"
    else uninstall "all"
    fi
    exit 0
fi

if [ "$DRY_RUN" != "true" ]; then
    check_permissions
fi

# Build commands from single source
if [ "$DRY_RUN" = "true" ]; then
    # In dry-run mode, verify source files exist but don't build
    if [ ! -d "${SRC_DIR}/shared/commands" ]; then
        print_error "Source commands directory not found at ${SRC_DIR}/shared/commands"
        exit 1
    fi
else
    build_commands
fi

# Install
[ "$INSTALL_CLAUDE" = true ] && install_claude
[ "$INSTALL_CURSOR" = true ] && install_cursor

# Summary
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}${BOLD}  AI-SDLC Framework dry-run complete!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  No files were written. Run without --dry-run to install."
    echo ""
    # Warn about potential issues in real mode
    if [ "$INSTALL_CLAUDE" = true ] && [ -d "${CLAUDE_HOME}" ] && [ ! -w "${CLAUDE_HOME}" ]; then
        print_warn "${CLAUDE_HOME} is not writable — real install may fail"
    fi
    if [ "$INSTALL_CURSOR" = true ] && [ -d "${CURSOR_HOME}" ] && [ ! -w "${CURSOR_HOME}" ]; then
        print_warn "${CURSOR_HOME} is not writable — real install may fail"
    fi
else
    echo -e "${GREEN}${BOLD}  AI-SDLC Framework installed successfully!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$INSTALL_CLAUDE" = true ]; then
        echo "  Claude Code Quick Start:"
        echo "  1. Open a project directory in Claude Code"
        echo "  2. Run: /sdlc:new-project"
        echo "  3. Follow the Inception flow"
        echo ""
    fi

    if [ "$INSTALL_CURSOR" = true ]; then
        echo "  Cursor Quick Start:"
        echo "  1. Open a project in Cursor"
        echo "  2. Run: /sdlc-new-project"
        echo "  3. Follow the Inception flow"
        echo ""
    fi
fi

echo "  Learn more: https://ai-sdlc-explainer.vercel.app/"
echo ""
