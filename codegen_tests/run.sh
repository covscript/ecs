#!/usr/bin/env bash
# Code generation correctness tests for ECS compiler
#
# Each test compiles a minimal ECS source and verifies that the generated
# CovScript (.csc) output contains (or excludes) expected patterns.
#
# Usage:
#   ./codegen_tests/run.sh           # run all tests
#   ./codegen_tests/run.sh --verbose # run with generated code dump on failure

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TMPDIR="${TMPDIR:-/tmp}/ecs_codegen_test_$$"
PASS=0
FAIL=0
VERBOSE=false

[ "$1" = "--verbose" ] && VERBOSE=true

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT
mkdir -p "$TMPDIR"

# Compile an ECS file, return 0 on success (no compile errors in output)
ecs_compile() {
  local src="$1"
  local outdir="$2"
  cs -i "$ROOT_DIR/imports" "$ROOT_DIR/ecs" -i "$ROOT_DIR/imports" -o "$outdir" "$src" 2>&1
}

# Run a single test case
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

  local base="${src##*/}"
  local basename="${base%.ecs}"
  local csc="$TMPDIR/${basename}.csc"

  echo -n "  ${name} ... "

  # Compile
  local compile_out
  compile_out=$(ecs_compile "$src" "$TMPDIR") || true

  # Check for compilation errors in output
  if echo "$compile_out" | grep -qE 'Compilation Error|Fatal Error|Error:'; then
    echo "FAIL (compile error)"
    echo "$compile_out" | sed 's/^/      /'
    ((FAIL++))
    return 1
  fi

  if [ ! -f "$csc" ]; then
    echo "FAIL (no output file)"
    ((FAIL++))
    return 1
  fi

  local test_failed=0

  # Check expected patterns
  for pattern in "${expects[@]}"; do
    if ! grep -q "$pattern" "$csc"; then
      if [ "$test_failed" -eq 0 ]; then
        echo "FAIL"
      fi
      echo "    missing: ${pattern}"
      test_failed=1
    fi
  done

  # Check forbidden patterns
  for pattern in "${forbids[@]}"; do
    if grep -q "$pattern" "$csc"; then
      if [ "$test_failed" -eq 0 ]; then
        echo "FAIL"
      fi
      echo "    found forbidden: ${pattern}"
      test_failed=1
    fi
  done

  if [ "$test_failed" -eq 0 ]; then
    echo "OK"
    ((PASS++))
  else
    ((FAIL++))
    if $VERBOSE; then
      echo "    --- generated code ($csc) ---"
      cat "$csc" | sed 's/^/      /'
      echo "    --- end ---"
    fi
  fi
}

# ================================================================
# Test definitions
# ================================================================

echo "=== Codegen Correctness Tests ==="
echo ""

# ---- [::] full-slice syntax ----
run_test "[::] full-slice on array" \
  "$SCRIPT_DIR/cg_slice_full.ecs" \
  --expect '\.ecs_slice_ext(null, null, null)'

# ---- catch clause FIFO ordering ----
run_test "catch typed-before-generic order" \
  "$SCRIPT_DIR/cg_catch_order.ecs" \
  --expect 'typeid __impl_ecs\.current_except == typeid(ErrorA)' \
  --expect 'typeid __impl_ecs\.current_except == typeid(ErrorB)'

# ---- lambda capture: value vs reference ----
run_test "lambda capture-by-value (=x)" \
  "$SCRIPT_DIR/cg_lambda_capture_val.ecs" \
  --expect 'this\.counter = _counter'

run_test "lambda capture-by-reference [x]" \
  "$SCRIPT_DIR/cg_lambda_capture_ref.ecs" \
  --expect 'this\.counter := _counter'

# ---- type conversion: internal vs user type ----
run_test "type conversion as internal" \
  "$SCRIPT_DIR/cg_conv_internal.ecs" \
  --expect 'type_constructor\.__integer'

run_test "type conversion as user type" \
  "$SCRIPT_DIR/cg_conv_user.ecs" \
  --expect 'param_new('

# ---- new/gcnew: internal vs user type ----
run_test "new internal type with args" \
  "$SCRIPT_DIR/cg_new_internal.ecs" \
  --expect 'type_constructor\.__integer'

run_test "new user type with args" \
  "$SCRIPT_DIR/cg_new_user.ecs" \
  --expect 'param_new('

run_test "gcnew with args" \
  "$SCRIPT_DIR/cg_gcnew.ecs" \
  --expect 'param_gcnew('

# ---- for loop separators ----
run_test "for loop semicolon separator" \
  "$SCRIPT_DIR/cg_for_semi.ecs" \
  --expect 'for '

run_test "for loop comma separator (legacy)" \
  "$SCRIPT_DIR/cg_for_comma.ecs" \
  --expect 'for '

# ---- continue and break ----
run_test "continue statement generation" \
  "$SCRIPT_DIR/cg_continue.ecs" \
  --expect 'continue' \
  --expect 'break'

# ---- block statement ----
run_test "block statement generation" \
  "$SCRIPT_DIR/cg_block.ecs" \
  --expect 'block '

# ---- nested namespace ----
run_test "nested namespace generation" \
  "$SCRIPT_DIR/cg_nested_ns.ecs" \
  --expect 'namespace outer\b' \
  --expect 'namespace inner\b'

# ---- using statement ----
run_test "using statement generation" \
  "$SCRIPT_DIR/cg_using.ecs" \
  --expect 'using Lib'

# ---- if/elif/else chain ----
run_test "if/elif/else end count" \
  "$SCRIPT_DIR/cg_if_elif.ecs" \
  --expect 'if ' \
  --expect 'else'

# ---- throw / rethrow ----
run_test "throw with expression" \
  "$SCRIPT_DIR/cg_throw.ecs" \
  --expect 'throw_exception('

run_test "throw without expression (rethrow)" \
  "$SCRIPT_DIR/cg_rethrow.ecs" \
  --expect 'rethrow_exception('

# ---- function type annotation / pass-by-value ----
run_test "function arg special-type check" \
  "$SCRIPT_DIR/cg_func_typecheck.ecs" \
  --expect 'check_type_s\b' \
  --expect 'type_validator\.__integer'

run_test "function arg user-type check" \
  "$SCRIPT_DIR/cg_func_typecheck_user.ecs" \
  --expect 'check_type('

run_test "function arg pass-by-value" \
  "$SCRIPT_DIR/cg_func_passbyval.ecs" \
  --expect 'unlink_var'

# ---- switch statement ----
run_test "switch statement generation" \
  "$SCRIPT_DIR/cg_switch.ecs" \
  --expect 'switch ' \
  --expect 'case ' \
  --expect 'default'

# ================================================================
# Summary
# ================================================================
echo ""
echo "=== Codegen results: ${PASS} passed, ${FAIL} failed ==="
[ "$FAIL" -gt 0 ] && exit 1
exit 0
