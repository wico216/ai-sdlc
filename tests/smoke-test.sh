#!/usr/bin/env bash
# Smoke test: verify all expected reference files exist and are non-empty
set -euo pipefail

REFS_DIR="$(cd "$(dirname "$0")/../src/shared/references" && pwd)"
PASS=0
FAIL=0

check_file() {
  local file="$1"
  if [ -f "$REFS_DIR/$file" ] && [ -s "$REFS_DIR/$file" ]; then
    echo "  PASS: $file"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $file (missing or empty)"
    FAIL=$((FAIL + 1))
  fi
}

echo "AI-SDLC Smoke Test"
echo "==================="
echo ""
echo "Checking reference files..."

check_file "phases.md"
check_file "gates.md"
check_file "git-integration.md"
check_file "glossary.md"
check_file "terminology.md"
check_file "verification-patterns.md"
check_file "principles.md"
check_file "roles.md"
check_file "rituals.md"
check_file "depth-levels.md"
check_file "metrics.md"
check_file "context-packaging.md"

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

echo "All checks passed."
