#!/usr/bin/env bash
# Error recovery tests for ECS compiler
#
# Verifies that the recovering parser reports multiple syntax errors
# in a single pass instead of stopping at the first one.
#
# Usage:
#   ./tests/run_recovery.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0

echo "=== Error Recovery Tests ==="
echo ""

echo -n "  multiple errors reported in one pass ... "
output=$(cs -i "$ROOT_DIR/imports" "$ROOT_DIR/ecs" -i "$ROOT_DIR/imports" -c "$SCRIPT_DIR/test_multi_error.ecs" 2>&1) || true

error_count=$(echo "$output" | grep -c "line [0-9]*:")
if [ "$error_count" -ge 2 ]; then
  echo "OK ($error_count errors reported)"
  ((PASS++))
else
  echo "FAIL (expected >= 2 errors, got $error_count)"
  echo "$output" | sed 's/^/      /'
  ((FAIL++))
fi

echo ""
echo "=== Recovery results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && exit 1
exit 0
