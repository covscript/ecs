#!/usr/bin/env bash
# Formatter correctness tests for ECS compiler
#
# Each test formats a poorly-formatted ECS source via `ecs -n` (dry-run)
# and verifies that the output is properly formatted and idempotent.
#
# Usage:
#   ./format_tests/run.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TMPDIR="${TMPDIR:-/tmp}/ecs_format_test_$$"
PASS=0
FAIL=0

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT
mkdir -p "$TMPDIR"

run_test() {
  local name="$1"
  local src="$2"
  shift 2

  local expects=()
  local forbids=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --expect) expects+=("$2"); shift 2 ;;
      --forbid) forbids+=("$2"); shift 2 ;;
      *) echo "INTERNAL ERROR: unknown flag $1"; exit 1 ;;
    esac
  done

  echo -n "  ${name} ... "

  local fmt_out
  fmt_out=$(cs -i "$ROOT_DIR/imports" "$ROOT_DIR/ecs" -i "$ROOT_DIR/imports" -n "$src" 2>&1) || true

  if echo "$fmt_out" | grep -qE 'Compilation Error|Fatal Error|Error:'; then
    echo "FAIL (format error)"
    echo "$fmt_out" | sed 's/^/      /'
    ((FAIL++))
    return 1
  fi

  if [ -z "$fmt_out" ]; then
    echo "FAIL (empty output)"
    ((FAIL++))
    return 1
  fi

  local test_failed=0

  for pattern in "${expects[@]}"; do
    if ! echo "$fmt_out" | grep -q "$pattern"; then
      if [ "$test_failed" -eq 0 ]; then
        echo "FAIL"
      fi
      echo "    missing: ${pattern}"
      test_failed=1
    fi
  done

  for pattern in "${forbids[@]}"; do
    if echo "$fmt_out" | grep -q "$pattern"; then
      if [ "$test_failed" -eq 0 ]; then
        echo "FAIL"
      fi
      echo "    found forbidden: ${pattern}"
      test_failed=1
    fi
  done

  # Idempotency: format the formatted output again, result must be identical
  if [ "$test_failed" -eq 0 ]; then
    local fmt_file="$TMPDIR/${name// /_}_fmt.ecs"
    echo "$fmt_out" > "$fmt_file"
    local fmt_out2
    fmt_out2=$(cs -i "$ROOT_DIR/imports" "$ROOT_DIR/ecs" -i "$ROOT_DIR/imports" -n "$fmt_file" 2>&1) || true
    if [ "$fmt_out" != "$fmt_out2" ]; then
      if [ "$test_failed" -eq 0 ]; then
        echo "FAIL"
      fi
      echo "    not idempotent (second format differs)"
      test_failed=1
    fi
  fi

  if [ "$test_failed" -eq 0 ]; then
    echo "OK"
    ((PASS++))
  else
    ((FAIL++))
  fi
}

# ================================================================
# Test definitions
# ================================================================

echo "=== Formatter Correctness Tests ==="
echo ""

run_test "basic formatting" \
  "$SCRIPT_DIR/fmt_basic.ecs" \
  --expect 'function badly_formatted(x, y)' \
  --expect '    var result = x + y' \
  --expect '    if result > 10' \
  --expect '        return result' \
  --forbid 'function   badly_formatted'

# ================================================================
# Summary
# ================================================================
echo ""
echo "=== Formatter results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && exit 1
exit 0
