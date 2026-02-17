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
check "Claude commands generated (>=23): ${CLAUDE_COUNT}" "$([ "$CLAUDE_COUNT" -ge 23 ] && echo true || echo false)"
check "Cursor commands generated (>=23): ${CURSOR_COUNT}" "$([ "$CURSOR_COUNT" -ge 23 ] && echo true || echo false)"

# Check no raw placeholders in generated files
RAW_PLACEHOLDERS=$(grep -rl '__[A-Z_]*__' "${SCRIPT_DIR}/src/claude/commands/" "${SCRIPT_DIR}/src/cursor/commands/" 2>/dev/null | wc -l | tr -d ' ')
check "No raw placeholders in generated commands: ${RAW_PLACEHOLDERS}" "$([ "$RAW_PLACEHOLDERS" -eq 0 ] && echo true || echo false)"

# Check Claude commands have $ARGUMENTS
CLAUDE_ARGS=$(grep -l '\$ARGUMENTS' "${SCRIPT_DIR}/src/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Claude commands use \$ARGUMENTS (>10): ${CLAUDE_ARGS}" "$([ "$CLAUDE_ARGS" -ge 10 ] && echo true || echo false)"

# Check Cursor commands DON'T have $ARGUMENTS
CURSOR_ARGS=$(grep -l '\$ARGUMENTS' "${SCRIPT_DIR}/src/cursor/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Cursor commands don't use \$ARGUMENTS: ${CURSOR_ARGS}" "$([ "$CURSOR_ARGS" -eq 0 ] && echo true || echo false)"

# Check operations.md generated (not deploy.md)
check "operations.md generated (not deploy)" "$([ -f "${SCRIPT_DIR}/src/claude/commands/operations.md" ] && [ ! -f "${SCRIPT_DIR}/src/claude/commands/deploy.md" ] && echo true || echo false)"

# Check status.md generated (not progress.md)
check "status.md generated (not progress)" "$([ -f "${SCRIPT_DIR}/src/claude/commands/status.md" ] && [ ! -f "${SCRIPT_DIR}/src/claude/commands/progress.md" ] && echo true || echo false)"

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
check "Shared commands have placeholders (>=15): ${SHARED_PLACEHOLDER}" "$([ "$SHARED_PLACEHOLDER" -ge 15 ] && echo true || echo false)"

# Check agents are path-agnostic (no __SDLC_HOME__)
AGENT_OLD_PATHS=$(grep -rl '__SDLC_HOME__\|__CLAUDE_HOME__' "${SCRIPT_DIR}/src/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Agents have no old path placeholders: ${AGENT_OLD_PATHS}" "$([ "$AGENT_OLD_PATHS" -eq 0 ] && echo true || echo false)"

# Check all 11 shared agents exist
AGENT_COUNT=$(ls "${SCRIPT_DIR}/src/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
check "Shared agents count (11): ${AGENT_COUNT}" "$([ "$AGENT_COUNT" -eq 11 ] && echo true || echo false)"

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

# ----- Test 3: V2 Agent/Command Structure -----
echo -e "${YELLOW}Test 3: V2 Agent/Command Structure${NC}"

# New agents exist with expected content
BOLT_PLANNER_TRACES=$(grep -c "traces_to" "${SCRIPT_DIR}/src/agents/sdlc-bolt-planner.md" 2>/dev/null || echo 0)
check "sdlc-bolt-planner exists and has golden thread (traces_to)" "$([ "$BOLT_PLANNER_TRACES" -ge 1 ] && echo true || echo false)"

BOLT_EXEC_AUDIT=$(grep -c "Audit Trail" "${SCRIPT_DIR}/src/agents/sdlc-bolt-executor.md" 2>/dev/null || echo 0)
check "sdlc-bolt-executor exists and has Audit Trail" "$([ "$BOLT_EXEC_AUDIT" -ge 1 ] && echo true || echo false)"

UNIT_VER_AUDIT=$(grep -c "Audit Trail" "${SCRIPT_DIR}/src/agents/sdlc-unit-verifier.md" 2>/dev/null || echo 0)
check "sdlc-unit-verifier exists and has Audit Trail" "$([ "$UNIT_VER_AUDIT" -ge 1 ] && echo true || echo false)"

INCEPTION_DECOMP=$(grep -c "decompos" "${SCRIPT_DIR}/src/agents/sdlc-inception.md" 2>/dev/null || echo 0)
check "sdlc-inception exists and has unit decomposition" "$([ "$INCEPTION_DECOMP" -ge 1 ] && echo true || echo false)"

check "sdlc-gate-checker exists" "$([ -f "${SCRIPT_DIR}/src/agents/sdlc-gate-checker.md" ] && echo true || echo false)"

# New commands exist with expected agent references
ELABORATE_REF=$(grep -c "sdlc-inception" "${SCRIPT_DIR}/src/shared/commands/elaborate.md" 2>/dev/null || echo 0)
check "elaborate.md exists and references sdlc-inception" "$([ "$ELABORATE_REF" -ge 1 ] && echo true || echo false)"

PLAN_UNIT_REF=$(grep -c "sdlc-bolt-planner" "${SCRIPT_DIR}/src/shared/commands/plan-unit.md" 2>/dev/null || echo 0)
check "plan-unit.md exists and references sdlc-bolt-planner" "$([ "$PLAN_UNIT_REF" -ge 1 ] && echo true || echo false)"

BUILD_UNIT_REF=$(grep -c "sdlc-bolt-executor" "${SCRIPT_DIR}/src/shared/commands/build-unit.md" 2>/dev/null || echo 0)
check "build-unit.md exists and references sdlc-bolt-executor" "$([ "$BUILD_UNIT_REF" -ge 1 ] && echo true || echo false)"

check "verify-unit.md exists" "$([ -f "${SCRIPT_DIR}/src/shared/commands/verify-unit.md" ] && echo true || echo false)"

APPROVE_INC_REF=$(grep -c "sdlc-gate-checker" "${SCRIPT_DIR}/src/shared/commands/approve-inception.md" 2>/dev/null || echo 0)
check "approve-inception.md exists and references sdlc-gate-checker" "$([ "$APPROVE_INC_REF" -ge 1 ] && echo true || echo false)"

APPROVE_UNIT_REF=$(grep -c "sdlc-gate-checker" "${SCRIPT_DIR}/src/shared/commands/approve-unit.md" 2>/dev/null || echo 0)
check "approve-unit.md exists and references sdlc-gate-checker" "$([ "$APPROVE_UNIT_REF" -ge 1 ] && echo true || echo false)"

check "approve-release.md exists" "$([ -f "${SCRIPT_DIR}/src/shared/commands/approve-release.md" ] && echo true || echo false)"

# operations command exists (not deploy)
check "operations.md exists (not deploy)" "$([ -f "${SCRIPT_DIR}/src/shared/commands/operations.md" ] && [ ! -f "${SCRIPT_DIR}/src/shared/commands/deploy.md" ] && echo true || echo false)"

# status command exists (not progress)
check "status.md exists (not progress)" "$([ -f "${SCRIPT_DIR}/src/shared/commands/status.md" ] && [ ! -f "${SCRIPT_DIR}/src/shared/commands/progress.md" ] && echo true || echo false)"

# guardrails template exists
check "guardrails.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/guardrails.md" ] && echo true || echo false)"

# inception/units/ path referenced (not root units/)
INCEPTION_UNITS=$(grep -rl 'inception/units/' "${SCRIPT_DIR}/src/shared/" 2>/dev/null | wc -l | tr -d ' ')
check "inception/units/ path referenced (>=3): ${INCEPTION_UNITS}" "$([ "$INCEPTION_UNITS" -ge 3 ] && echo true || echo false)"

# operations/ subdirectory referenced
OPS_SUBDIR=$(grep -rl 'operations/' "${SCRIPT_DIR}/src/shared/commands/operations.md" 2>/dev/null | wc -l | tr -d ' ')
check "operations/ subdirectory in operations command" "$([ "$OPS_SUBDIR" -ge 1 ] && echo true || echo false)"

# All 5 gates in gate-checker
GATE_COUNT=$(grep -c 'Gate [1-5]' "${SCRIPT_DIR}/src/agents/sdlc-gate-checker.md" 2>/dev/null || echo 0)
check "All 5 gates in gate-checker (>=5): ${GATE_COUNT}" "$([ "$GATE_COUNT" -ge 5 ] && echo true || echo false)"

# Security in gate checker
SECURITY_GATES=$(grep -c 'security\|Security' "${SCRIPT_DIR}/src/agents/sdlc-gate-checker.md" 2>/dev/null || echo 0)
check "Security touchpoints in gate-checker (>=3): ${SECURITY_GATES}" "$([ "$SECURITY_GATES" -ge 3 ] && echo true || echo false)"

# NFR template
check "nfr.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/nfr.md" ] && echo true || echo false)"

# User stories template
check "user-stories.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/user-stories.md" ] && echo true || echo false)"

# Application design template
check "application-design.md template exists" "$([ -f "${SCRIPT_DIR}/src/shared/templates/application-design.md" ] && echo true || echo false)"

# No hidden Unicode (excluding expected emoji in certain files)
UNICODE_FILES=$(grep -rPl '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F\x80-\x9F\x200B-\x200F\x2028-\x202F\xFEFF]' "${SCRIPT_DIR}/src/" 2>/dev/null | wc -l | tr -d ' ')
check "No hidden Unicode characters: ${UNICODE_FILES}" "$([ "$UNICODE_FILES" -eq 0 ] && echo true || echo false)"

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
