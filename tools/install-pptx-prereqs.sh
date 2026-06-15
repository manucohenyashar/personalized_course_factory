#!/usr/bin/env bash
#
# install-pptx-prereqs.sh — install the prerequisites the `pptx-generator` slide renderer
# needs to build slide decks.
#
# The course factory renders chapter slide decks with the `pptx-generator` skill, which compiles
# PptxGenJS slide scripts to a .pptx. Those compiled scripts live under
# outputs/<course_slug>/chapters/<ch>/_pptx-build/slides/ and resolve `require('pptxgenjs')` by
# walking UP the directory tree. Installing pptxgenjs into the project root's local node_modules
# (the directory where outputs/ is generated) therefore makes it resolvable from the build dir.
#
# Installs into the target directory:
#   - pptxgenjs                              (REQUIRED — builds the .pptx)
#   - markitdown[pptx]                       (recommended — QA text extraction; unless --skip-markitdown)
#   - react-icons react react-dom sharp      (optional — only with --with-icons)
#
# Run from your project root: the same directory where you launch Claude Code and where
# outputs/ is generated.
#
# Usage:
#   tools/install-pptx-prereqs.sh [TARGET_DIR] [--with-icons] [--skip-markitdown]
#
set -euo pipefail

TARGET_DIR="$PWD"
WITH_ICONS=0
SKIP_MARKITDOWN=0

for arg in "$@"; do
  case "$arg" in
    --with-icons)      WITH_ICONS=1 ;;
    --skip-markitdown) SKIP_MARKITDOWN=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"; exit 0 ;;
    *)                 TARGET_DIR="$arg" ;;
  esac
done

cyan()  { printf '\033[36m==> %s\033[0m\n' "$1"; }
green() { printf '\033[32mOK  %s\033[0m\n' "$1"; }
yellow(){ printf '\033[33m!!  %s\033[0m\n' "$1"; }

cyan "pptx-generator prerequisites -> $TARGET_DIR"

[ -d "$TARGET_DIR" ] || { echo "Target directory does not exist: $TARGET_DIR" >&2; exit 1; }

# --- Node.js / npm (required) ----------------------------------------------
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "Node.js 18+ and npm are required but were not found on PATH." >&2
  echo "Install Node.js from https://nodejs.org and re-run." >&2
  exit 1
fi
green "Node.js $(node --version) / npm $(npm --version)"

(
  cd "$TARGET_DIR"

  # A package.json lets npm record and reproduce the dependency. Create a minimal one only
  # if the project does not already have it (never overwrite an existing manifest).
  if [ ! -f package.json ]; then
    cyan "No package.json found; creating a minimal one (npm init -y)"
    npm init -y >/dev/null
  fi

  cyan "Installing pptxgenjs (required)"
  npm install pptxgenjs
  green "pptxgenjs installed into node_modules"

  if [ "$WITH_ICONS" -eq 1 ]; then
    cyan "Installing optional icon libraries (react-icons react react-dom sharp)"
    npm install react-icons react react-dom sharp
    green "icon libraries installed"
  else
    echo "    (skipping optional icon libraries; pass --with-icons to include them)"
  fi
)

# --- markitdown (recommended QA tool, Python) ------------------------------
if [ "$SKIP_MARKITDOWN" -eq 0 ]; then
  PY=""
  command -v python3 >/dev/null 2>&1 && PY="python3"
  [ -z "$PY" ] && command -v python >/dev/null 2>&1 && PY="python"
  if [ -n "$PY" ]; then
    cyan "Installing markitdown[pptx] (recommended QA tool)"
    if "$PY" -m pip install --user "markitdown[pptx]"; then
      green "markitdown installed"
    else
      yellow "markitdown install failed (optional). Verify pip is available, or re-run with --skip-markitdown."
    fi
  else
    yellow "Python not found; skipping markitdown (optional QA tool). Install Python 3 to enable it."
  fi
else
  echo "    (skipping markitdown; --skip-markitdown set)"
fi

echo
green "Done. Slide rendering prerequisites are installed in: $TARGET_DIR"
cyan "Generate courses from this directory so the compiled slide scripts can resolve pptxgenjs from node_modules."
