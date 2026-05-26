#!/usr/bin/env bash
# verify/verify.sh — Exercise 03 completeness check
#
# Confirms that the learner has completed all required sections of the
# independent RSTRM analysis starter file.
#
# Usage: bash verify/verify.sh <path-to-completed-starter-file>
#        bash verify/verify.sh starter/my-task-analysis.md
#
# Exit 0: all required sections present and non-empty; tool-type verdict and
#         design constraint fields present.
# Exit 1: one or more checks fail.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_FILE="${1:-$EXERCISE_DIR/starter/my-task-analysis.md}"

if [ ! -f "$TARGET_FILE" ]; then
  echo "FAIL: File not found: $TARGET_FILE"
  echo "Usage: bash verify/verify.sh starter/my-task-analysis.md"
  exit 1
fi

FAIL=0
PASS=0

echo "=== Exercise 03 — Completeness Check ==="
echo "Checking: $TARGET_FILE"
echo ""

# Helper: check that a section header exists and has non-empty content following it
check_section() {
  local header="$1"
  local label="$2"
  if ! grep -qF "$header" "$TARGET_FILE"; then
    echo "FAIL: Section header not found — $label"
    FAIL=$((FAIL + 1))
    return
  fi
  # Find line number of header, then check next 10 lines for content
  local header_line
  header_line=$(grep -nF "$header" "$TARGET_FILE" | head -1 | cut -d: -f1)
  local content_found=0
  if [ -n "$header_line" ]; then
    local end_line=$((header_line + 10))
    local total_lines
    total_lines=$(wc -l < "$TARGET_FILE")
    [ "$end_line" -gt "$total_lines" ] && end_line=$total_lines
    while IFS= read -r line; do
      trimmed="${line#"${line%%[![:space:]]*}"}"
      if [ -n "$trimmed" ] && [[ "$trimmed" != "##"* ]] && [[ "$trimmed" != "---" ]]; then
        content_found=1
        break
      fi
    done < <(tail -n +"$((header_line + 1))" "$TARGET_FILE" | head -10)
  fi
  if [ "$content_found" -eq 1 ]; then
    echo "PASS: Section present and non-empty — $label"
    PASS=$((PASS + 1))
  else
    echo "FAIL: Section found but appears empty — $label"
    FAIL=$((FAIL + 1))
  fi
}

# Task selection
check_section "My chosen task:" "Task Selection — chosen task"
check_section "Why I chose it:" "Task Selection — rationale"

# RSTRM criteria
check_section "### R — Repetitive" "RSTRM — Repetitive"
check_section "### S — Structured" "RSTRM — Structured"
check_section "### T — Time-consuming" "RSTRM — Time-consuming"
check_section "### R — Rules-based" "RSTRM — Rules-based"
check_section "### M — Multi-step" "RSTRM — Multi-step"

# Verdict sections
check_section "## Overall RSTRM Verdict" "Overall RSTRM Verdict"
check_section "## Tool-Type Verdict" "Tool-Type Verdict"
check_section "## Design Constraint or Risk" "Design Constraint or Risk"
check_section "## Required Plugins or Tools" "Required Plugins or Tools"

# Check that the file has a tool-type selection (skill / plugin / agent)
TOOL_TYPE_LINE=$(grep -i "My verdict:" "$TARGET_FILE" || true)
if [ -n "$TOOL_TYPE_LINE" ]; then
  TOOL_VALUE=$(echo "$TOOL_TYPE_LINE" | sed 's/My verdict://' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
  if [ -n "$TOOL_VALUE" ]; then
    echo "PASS: Tool-type verdict is present"
    PASS=$((PASS + 1))
  else
    echo "FAIL: Tool-type verdict label found but value is empty"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL: 'My verdict:' label not found in Tool-Type Verdict section"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  echo "FAIL: Analysis is incomplete. Address the failures above, then re-run."
  echo "Note: This script checks structure and completeness only. Reasoning quality is assessed by rubric."
  exit 1
fi

echo "PASS: All required sections present and non-empty."
echo "Note: This script checks structure and completeness only. Reasoning quality is assessed by rubric."
exit 0
