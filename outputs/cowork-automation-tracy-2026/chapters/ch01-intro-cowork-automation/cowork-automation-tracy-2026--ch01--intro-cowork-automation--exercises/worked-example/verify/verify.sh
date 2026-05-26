#!/usr/bin/env bash
# verify/verify.sh — Worked Example self-check
#
# Confirms that the worked example solution artifacts are present and non-empty.
# This script does not test learner output (the worked example has no starter file).
# Run from the worked-example/ directory or with the path to worked-example/ as $1.
#
# Exit 0: all artifacts present and non-empty.
# Exit 1: one or more artifacts missing or empty.
#
# Usage:
#   bash verify/verify.sh
#   bash verify/verify.sh /absolute/path/to/worked-example

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXERCISE_DIR="${1:-$(dirname "$SCRIPT_DIR")}"

PASS=0
FAIL=0

check_file() {
  local filepath="$1"
  local label="$2"
  if [ -f "$filepath" ] && [ -s "$filepath" ]; then
    echo "  PASS: $label exists and is non-empty"
    PASS=$((PASS + 1))
  elif [ -f "$filepath" ]; then
    echo "  FAIL: $label exists but is empty"
    FAIL=$((FAIL + 1))
  else
    echo "  FAIL: $label not found at $filepath"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Worked Example — Artifact Check ==="
echo ""

check_file "$EXERCISE_DIR/walkthrough.md" "walkthrough.md"
check_file "$EXERCISE_DIR/solution/status-report-rstrm-scorecard.md" "solution/status-report-rstrm-scorecard.md"

# Confirm walkthrough contains all 5 RSTRM criteria headings
WALKTHROUGH="$EXERCISE_DIR/walkthrough.md"
if [ -f "$WALKTHROUGH" ]; then
  MISSING_CRITERIA=()
  for criterion in "Repetitive" "Structured" "Time-consuming" "Rules-based" "Multi-step"; do
    if ! grep -q "$criterion" "$WALKTHROUGH"; then
      MISSING_CRITERIA+=("$criterion")
    fi
  done
  if [ ${#MISSING_CRITERIA[@]} -eq 0 ]; then
    echo "  PASS: walkthrough.md contains all 5 RSTRM criteria"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: walkthrough.md is missing RSTRM criteria: ${MISSING_CRITERIA[*]}"
    FAIL=$((FAIL + 1))
  fi
fi

# Confirm solution contains scorecard table
SCORECARD="$EXERCISE_DIR/solution/status-report-rstrm-scorecard.md"
if [ -f "$SCORECARD" ]; then
  if grep -q "Design Verdict" "$SCORECARD"; then
    echo "  PASS: solution scorecard contains Design Verdict section"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: solution scorecard is missing Design Verdict section"
    FAIL=$((FAIL + 1))
  fi
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
  echo "FAIL: Worked example artifacts are incomplete. See failures above."
  exit 1
fi

echo "PASS: All worked example artifacts present and structurally valid."
exit 0
