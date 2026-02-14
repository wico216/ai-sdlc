#!/bin/bash
# No set -e: test script handles errors via check() function

# AI-SDLC Installation Smoke Test
# Tests: build, install (Claude/Cursor/all), uninstall, hooks merge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0
ERRORS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check() {
    local desc="$1"
    local result="$2"
    if [ "$result" = "true" ]; then
        echo -e "  ${GREEN}PASS${NC} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $desc"
        FAIL=$((FAIL + 1))
        ERRORS+=("$desc")
    fi
}

echo "=========================================="
echo " AI-SDLC Smoke Test"
echo "=========================================="
echo ""

# ----- Test 1: Build System -----
echo -e "${YELLOW}Test 1: Build System${NC}"

bash "${SCRIPT_DIR}/build.sh" > /dev/null 2>&1
BUILD_EXIT=$?
check "build.sh exits cleanly" "$([ $BUILD_EXIT -eq 0 ] && echo true || echo false)"

CLAUDE_COUNT=$(ls "${SCRIPT_DIR}/src/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
CURSOR_COUNT=$(ls "${SCRIPT_DIR}/src/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Claude commands generated (>30): ${CLAUDE_COUNT}" "$([ "$CLAUDE_COUNT" -ge 30 ] && echo true || echo false)"
check "Cursor commands generated (>28): ${CURSOR_COUNT}" "$([ "$CURSOR_COUNT" -ge 28 ] && echo true || echo false)"

# Check no raw placeholders in generated files
RAW_PLACEHOLDERS=$(grep -rl '__[A-Z_]*__' "${SCRIPT_DIR}/src/claude/commands/" "${SCRIPT_DIR}/src/cursor/commands/" 2>/dev/null | wc -l | tr -d ' ')
check "No raw placeholders in generated commands: ${RAW_PLACEHOLDERS}" "$([ "$RAW_PLACEHOLDERS" -eq 0 ] && echo true || echo false)"

# Check Claude commands have $ARGUMENTS
CLAUDE_ARGS=$(grep -l '\$ARGUMENTS' "${SCRIPT_DIR}/src/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Claude commands use \$ARGUMENTS (>10): ${CLAUDE_ARGS}" "$([ "$CLAUDE_ARGS" -ge 10 ] && echo true || echo false)"

# Check Cursor commands DON'T have $ARGUMENTS
CURSOR_ARGS=$(grep -l '\$ARGUMENTS' "${SCRIPT_DIR}/src/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Cursor commands don't use \$ARGUMENTS: ${CURSOR_ARGS}" "$([ "$CURSOR_ARGS" -eq 0 ] && echo true || echo false)"

# Check command prefixes
CLAUDE_PREFIX=$(grep -l '/sdlc:' "${SCRIPT_DIR}/src/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
CURSOR_PREFIX=$(grep -l '/sdlc-' "${SCRIPT_DIR}/src/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Claude commands use /sdlc: prefix" "$([ "$CLAUDE_PREFIX" -ge 1 ] && echo true || echo false)"
check "Cursor commands use /sdlc- prefix" "$([ "$CURSOR_PREFIX" -ge 1 ] && echo true || echo false)"

echo ""

# ----- Test 2: Source File Integrity -----
echo -e "${YELLOW}Test 2: Source File Integrity${NC}"

# Check shared commands use placeholders
SHARED_PLACEHOLDER=$(grep -rl '__SDLC_REFS__\|__CMD_PREFIX__\|__ARGUMENTS__' "${SCRIPT_DIR}/src/shared/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Shared commands have placeholders (>20): ${SHARED_PLACEHOLDER}" "$([ "$SHARED_PLACEHOLDER" -ge 20 ] && echo true || echo false)"

# Check agents are path-agnostic (no __SDLC_HOME__)
AGENT_OLD_PATHS=$(grep -rl '__SDLC_HOME__\|__CLAUDE_HOME__' "${SCRIPT_DIR}/src/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Agents have no old path placeholders: ${AGENT_OLD_PATHS}" "$([ "$AGENT_OLD_PATHS" -eq 0 ] && echo true || echo false)"

# Check all 12 shared agents exist
AGENT_COUNT=$(ls "${SCRIPT_DIR}/src/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Shared agents count (12): ${AGENT_COUNT}" "$([ "$AGENT_COUNT" -eq 12 ] && echo true || echo false)"

# Check 7 Cursor subagent wrappers exist
CURSOR_AGENT_COUNT=$(ls "${SCRIPT_DIR}/src/cursor/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Cursor subagent wrappers (7): ${CURSOR_AGENT_COUNT}" "$([ "$CURSOR_AGENT_COUNT" -eq 7 ] && echo true || echo false)"

# Check 7 Cursor rules exist
RULE_COUNT=$(ls "${SCRIPT_DIR}/src/cursor/rules/"*.mdc 2>/dev/null | wc -l | tr -d ' ')
check "Cursor rules (7): ${RULE_COUNT}" "$([ "$RULE_COUNT" -eq 7 ] && echo true || echo false)"

# Check 3 Cursor hooks exist
HOOK_COUNT=$(ls "${SCRIPT_DIR}/src/cursor/hooks/"*.js 2>/dev/null | wc -l | tr -d ' ')
check "Cursor hook scripts (3): ${HOOK_COUNT}" "$([ "$HOOK_COUNT" -eq 3 ] && echo true || echo false)"

# Check references
REF_COUNT=$(ls "${SCRIPT_DIR}/src/shared/references/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Reference files exist (>10): ${REF_COUNT}" "$([ "$REF_COUNT" -ge 10 ] && echo true || echo false)"

# Check new cross-reference files
check "ddd-decomposition.md exists" "$([ -f "${SCRIPT_DIR}/src/shared/references/ddd-decomposition.md" ] && echo true || echo false)"
check "glossary.md exists" "$([ -f "${SCRIPT_DIR}/src/shared/references/glossary.md" ] && echo true || echo false)"
check "application-design.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/application-design.md" ] && echo true || echo false)"
check "cost.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/cost.md" ] && echo true || echo false)"
check "nfr.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/nfr.md" ] && echo true || echo false)"

echo ""

# ----- Test 3: Prompt Quality Fixes -----
echo -e "${YELLOW}Test 3: Prompt Quality Fixes (P0-P6)${NC}"

# P0: Gate bypass warnings
P0_EXEC=$(grep -c "does NOT enforce AI-SDLC gates" "${SCRIPT_DIR}/src/shared/commands/execute-phase.md" 2>/dev/null || echo 0)
P0_PLAN=$(grep -c "does NOT enforce AI-SDLC gates" "${SCRIPT_DIR}/src/shared/commands/plan-phase.md" 2>/dev/null || echo 0)
check "P0: execute-phase has gate bypass warning" "$([ "$P0_EXEC" -ge 1 ] && echo true || echo false)"
check "P0: plan-phase has gate bypass warning" "$([ "$P0_PLAN" -ge 1 ] && echo true || echo false)"

# P1: DDD protocol reference
P1=$(grep -c "ddd-decomposition" "${SCRIPT_DIR}/src/shared/commands/inception.md" 2>/dev/null || echo 0)
check "P1: inception references DDD protocol" "$([ "$P1" -ge 1 ] && echo true || echo false)"

# P2: Audit trail in agents
P2_EXEC=$(grep -c "Audit Trail" "${SCRIPT_DIR}/src/agents/sdlc-executor.md" 2>/dev/null || echo 0)
P2_VER=$(grep -c "Audit Trail" "${SCRIPT_DIR}/src/agents/sdlc-verifier.md" 2>/dev/null || echo 0)
P2_PLAN=$(grep -c "Audit Trail" "${SCRIPT_DIR}/src/agents/sdlc-planner.md" 2>/dev/null || echo 0)
check "P2: executor has audit trail" "$([ "$P2_EXEC" -ge 1 ] && echo true || echo false)"
check "P2: verifier has audit trail" "$([ "$P2_VER" -ge 1 ] && echo true || echo false)"
check "P2: planner has audit trail" "$([ "$P2_PLAN" -ge 1 ] && echo true || echo false)"

# P3: Golden thread
P3=$(grep -c "traces_to" "${SCRIPT_DIR}/src/agents/sdlc-planner.md" 2>/dev/null || echo 0)
check "P3: planner requires traces_to" "$([ "$P3" -ge 1 ] && echo true || echo false)"

# P4: Mob rituals
P4_INC=$(grep -c "Mob Elaboration" "${SCRIPT_DIR}/src/shared/commands/inception.md" 2>/dev/null || echo 0)
P4_BOLT=$(grep -c "Mob Construction" "${SCRIPT_DIR}/src/shared/commands/bolt.md" 2>/dev/null || echo 0)
check "P4: inception suggests Mob Elaboration" "$([ "$P4_INC" -ge 1 ] && echo true || echo false)"
check "P4: bolt suggests Mob Construction" "$([ "$P4_BOLT" -ge 1 ] && echo true || echo false)"

# P5: Role-specific gates
P5_PO=$(grep -c "Product Owner" "${SCRIPT_DIR}/src/shared/commands/inception.md" 2>/dev/null || echo 0)
P5_TL=$(grep -c "Tech Lead" "${SCRIPT_DIR}/src/shared/commands/bolt.md" 2>/dev/null || echo 0)
check "P5: inception gate has PO role" "$([ "$P5_PO" -ge 1 ] && echo true || echo false)"
check "P5: bolt gate has Tech Lead role" "$([ "$P5_TL" -ge 1 ] && echo true || echo false)"

# P6: Adaptive depth consumption
P6_EXEC=$(grep -c "Adaptive Depth" "${SCRIPT_DIR}/src/agents/sdlc-executor.md" 2>/dev/null || echo 0)
P6_VER=$(grep -c "Adaptive Depth" "${SCRIPT_DIR}/src/agents/sdlc-verifier.md" 2>/dev/null || echo 0)
P6_PLAN=$(grep -c "Adaptive Depth" "${SCRIPT_DIR}/src/agents/sdlc-planner.md" 2>/dev/null || echo 0)
P6_RES=$(grep -c "Adaptive Depth" "${SCRIPT_DIR}/src/agents/sdlc-phase-researcher.md" 2>/dev/null || echo 0)
check "P6: executor reads adaptive depth" "$([ "$P6_EXEC" -ge 1 ] && echo true || echo false)"
check "P6: verifier reads adaptive depth" "$([ "$P6_VER" -ge 1 ] && echo true || echo false)"
check "P6: planner reads adaptive depth" "$([ "$P6_PLAN" -ge 1 ] && echo true || echo false)"
check "P6: researcher reads adaptive depth" "$([ "$P6_RES" -ge 1 ] && echo true || echo false)"

# P6 in commands
P6_BOLT_CMD=$(grep -c "adaptive_depth" "${SCRIPT_DIR}/src/shared/commands/bolt.md" 2>/dev/null || echo 0)
P6_EXEC_CMD=$(grep -c "adaptive_depth" "${SCRIPT_DIR}/src/shared/commands/execute-phase.md" 2>/dev/null || echo 0)
check "P6: bolt command has adaptive depth section" "$([ "$P6_BOLT_CMD" -ge 1 ] && echo true || echo false)"
check "P6: execute-phase has adaptive depth section" "$([ "$P6_EXEC_CMD" -ge 1 ] && echo true || echo false)"

echo ""

# ----- Test 4: Dry Run Install -----
echo -e "${YELLOW}Test 4: Dry Run Install${NC}"

DRYRUN_OUTPUT=$(bash "${SCRIPT_DIR}/install.sh" --claude --dry-run 2>&1 || true)
check "Dry run --claude completes" "$(echo "$DRYRUN_OUTPUT" | grep -q "dry-run\|installed successfully" && echo true || echo false)"

DRYRUN_CURSOR=$(bash "${SCRIPT_DIR}/install.sh" --cursor --dry-run 2>&1 || true)
check "Dry run --cursor completes" "$(echo "$DRYRUN_CURSOR" | grep -q "dry-run\|installed successfully" && echo true || echo false)"

echo ""

# ----- Summary -----
echo "=========================================="
TOTAL=$((PASS + FAIL))
echo -e " Results: ${GREEN}${PASS} passed${NC} / ${RED}${FAIL} failed${NC} / ${TOTAL} total"
echo "=========================================="

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Failures:${NC}"
    for err in "${ERRORS[@]}"; do
        echo "  - $err"
    done
fi

echo ""
exit $FAIL
