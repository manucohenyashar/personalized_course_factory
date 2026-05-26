#!/usr/bin/env bash
# verify/verify.sh — Exercise 02 completeness check
#
# Confirms that the learner has replaced all TODO blocks in the starter file
# and that the human-in-the-loop checkpoint specification is complete.
#
# Usage: bash verify/verify.sh <path-to-completed-starter-file>
#        bash verify/verify.sh starter/email-triage-rstrm.md
#
# Exit 0: all TODOs replaced; checkpoint has all 3 required fields; RSTRM verdict present.
# Exit 1: one or more checks fail.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_FILE="${1:-$EXERCISE_DIR/starter/email-triage-rstrm.md}"

if [ ! -f "$TARGET_FILE" ]; then
  echo "FAIL: File not found: $TARGET_FILE"
  echo "Usage: bash verify/verify.sh starter/email-triage-rstrm.md"
  exit 1
fi

FAIL=0
PASS=0

echo "=== Exercise 02 — Completeness Check ==="
echo "Checking: $TARGET_FILE"
echo ""

# Check 1: No remaining TODO markers
TODO_LINES=$(grep -n "# TODO:" "$TARGET_FILE" || true)
if [ -n "$TODO_LINES" ]; then
  echo "FAIL: The following lines still contain TODO markers:"
  echo "$TODO_LINES" | while IFS= read -r line; do echo "  $line"; done
  FAIL=$((FAIL + 1))
else
  echo "PASS: No TODO markers remaining"
  PASS=$((PASS + 1))
fi

# Check 2: All 5 RSTRM sections have content
RSTRM_CHECKS=("### R — Repetitive" "### S — Structured" "### T — Time-consuming" "### R — Rules-based" "### M — Multi-step")
for section in "${RSTRM_CHECKS[@]}"; do
  if grep -q "$section" "$TARGET_FILE"; then
    echo "PASS: RSTRM section found — $section"
    PASS=$((PASS + 1))
  else
    echo "FAIL: RSTRM section missing — $section"
    FAIL=$((FAIL + 1))
  fi
done

# Check 3: Checkpoint specification contains all 3 required fields
for field in "**Trigger:**" "**Review format:**" "**Approval action:**"; do
  if grep -qF "$field" "$TARGET_FILE"; then
    echo "PASS: Checkpoint field present — $field"
    PASS=$((PASS + 1))
  else
    echo "FAIL: Checkpoint field missing — $field"
    echo "  Each checkpoint must specify: Trigger, Review format, and Approval action."
    FAIL=$((FAIL + 1))
  fi
done

# Check 4: RSTRM Verdict section is present and non-empty
if grep -q "## Overall RSTRM Verdict" "$TARGET_FILE"; then
  VERDICT_LINE=$(grep -A 3 "## Overall RSTRM Verdict" "$TARGET_FILE" | tail -3 | tr -d '[:space:]')
  if [ -n "$VERDICT_LINE" ]; then
    echo "PASS: Overall RSTRM Verdict section is present and non-empty"
    PASS=$((PASS + 1))
  else
    echo "FAIL: Overall RSTRM Verdict section found but appears empty"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL: Overall RSTRM Verdict section not found"
  FAIL=$((FAIL + 1))
fi

# Check 5: Plugin section has content
if grep -q "## Required Plugin" "$TARGET_FILE"; then
  PLUGIN_CONTENT=$(grep -A 5 "## Required Plugin" "$TARGET_FILE" | grep -v "^#" | grep -v "^$" | head -3)
  if [ -n "$PLUGIN_CONTENT" ]; then
    echo "PASS: Required Plugin section is non-empty"
    PASS=$((PASS + 1))
  else
    echo "FAIL: Required Plugin section found but appears empty"
    FAIL=$((FAIL + 1))
  fi
else
  echo "FAIL: Required Plugin(s) section not found"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  echo "FAIL: Starter file is incomplete. Address the failures above, then re-run."
  echo "Note: This script checks completeness only. Quality of reasoning is assessed by rubric."
  exit 1
fi

echo "PASS: All TODO blocks filled. Checkpoint specification complete. RSTRM verdict present."
echo "Note: This script checks completeness only. Quality of reasoning is assessed by rubric."
exit 0
