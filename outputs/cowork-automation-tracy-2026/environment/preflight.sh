#!/usr/bin/env bash
# =============================================================================
# Preflight check — cowork-automation-tracy-2026 lab environment
# Run before any exercise verify/ script, or after a fresh devcontainer build.
#
# Usage:
#   bash environment/preflight.sh
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more required tools are missing or at the wrong version
#
# This script is idempotent: safe to run multiple times.
# It does NOT install missing tools — it checks for them and reports clearly.
# =============================================================================

set -euo pipefail

COURSE_SLUG="cowork-automation-tracy-2026"
PASS=0
FAIL=0

# ------------------------------------------------------------------------------
# Helper — check_tool <display_name> <required_version> <version_command> <grep_pattern>
#
# Runs <version_command>, pipes through grep for <grep_pattern>.
# Prints a pass/fail line. Increments PASS or FAIL counter.
# Does NOT exit immediately — collects all failures before reporting.
# ------------------------------------------------------------------------------
check_tool() {
  local display_name="$1"
  local required_version="$2"
  local version_cmd="$3"
  local grep_pattern="$4"

  if eval "$version_cmd" 2>/dev/null | grep -qF "$grep_pattern"; then
    echo "  [PASS] ${display_name} ${required_version}"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] ${display_name} ${required_version} — not found or version mismatch"
    echo "         Run: ${version_cmd}"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "==================================================================="
echo "  ${COURSE_SLUG} — Environment Preflight"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "==================================================================="
echo ""
echo "Checking required tools..."
echo ""

# ------------------------------------------------------------------------------
# Claude CLI — primary interface for all exercises
# Install: https://docs.anthropic.com/claude-code/installation
# ------------------------------------------------------------------------------
check_tool \
  "claude (Claude CLI)" \
  "1.0.58" \
  "claude --version" \
  "1.0.58"

# ------------------------------------------------------------------------------
# Node.js 22.12.0 LTS — required for Playwright MCP (Chapter 9)
# Install: https://nodejs.org/en/download  or  nvm install 22.12.0
# ------------------------------------------------------------------------------
check_tool \
  "node (Node.js LTS)" \
  "22.12.0" \
  "node --version" \
  "v22.12.0"

# ------------------------------------------------------------------------------
# npm 10.9.0 — bundled with Node 22.12.0
# If npm version is wrong, re-install Node 22.12.0.
# ------------------------------------------------------------------------------
check_tool \
  "npm" \
  "10.9.0" \
  "npm --version" \
  "10.9.0"

# ------------------------------------------------------------------------------
# Playwright 1.48.0 — browser automation MCP backend (Chapter 9)
# Install: npm install -g @playwright/test@1.48.0 && npx playwright install chromium
# ------------------------------------------------------------------------------
check_tool \
  "playwright (via npx)" \
  "1.48.0" \
  "npx playwright --version" \
  "1.48.0"

# ------------------------------------------------------------------------------
# Python 3.11.9 — Zapier/API scripting exercises (Chapter 10)
# Install: https://www.python.org/downloads/release/python-3119/
#          or  pyenv install 3.11.9
# On Linux/macOS the binary may be "python3" — both are checked.
# ------------------------------------------------------------------------------
PYTHON_BIN=""
if command -v python3 &>/dev/null && python3 --version 2>/dev/null | grep -qF "3.11.9"; then
  PYTHON_BIN="python3"
elif command -v python &>/dev/null && python --version 2>/dev/null | grep -qF "3.11.9"; then
  PYTHON_BIN="python"
fi

if [ -n "$PYTHON_BIN" ]; then
  echo "  [PASS] python 3.11.9 (found as ${PYTHON_BIN})"
  PASS=$((PASS + 1))
else
  echo "  [FAIL] python 3.11.9 — not found or version mismatch"
  echo "         Install from: https://www.python.org/downloads/release/python-3119/"
  FAIL=$((FAIL + 1))
fi

# ------------------------------------------------------------------------------
# Git 2.44.0 — saving and versioning automation assets
# Install: https://git-scm.com/downloads
# ------------------------------------------------------------------------------
check_tool \
  "git" \
  "2.44.0" \
  "git --version" \
  "2.44.0"

# ------------------------------------------------------------------------------
# curl 8.7.1 — HTTP calls in API exercises and Zapier webhook testing
# Typically pre-installed; update via OS package manager if needed.
# ------------------------------------------------------------------------------
check_tool \
  "curl" \
  "8.7.1" \
  "curl --version" \
  "8.7.1"

# ------------------------------------------------------------------------------
# jq 1.7.1 — JSON parsing in shell automation exercises
# Install: https://jqlang.github.io/jq/download/
# ------------------------------------------------------------------------------
check_tool \
  "jq" \
  "1.7.1" \
  "jq --version" \
  "1.7.1"

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
echo "-------------------------------------------------------------------"
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "-------------------------------------------------------------------"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "  ACTION REQUIRED: Install or update the tools marked [FAIL] above."
  echo "  See the README in environment/ for per-tool install instructions."
  echo ""
  exit 1
fi

echo ""
echo "  All checks passed. Your lab environment is ready."
echo "  Course: ${COURSE_SLUG}"
echo ""
exit 0
