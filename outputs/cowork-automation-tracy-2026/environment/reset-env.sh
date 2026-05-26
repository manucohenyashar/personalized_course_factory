#!/usr/bin/env bash
# =============================================================================
# reset-env.sh — cowork-automation-tracy-2026 lab environment reset
#
# Resets the lab to a clean state between exercise attempts or after a session.
#
# WHAT THIS SCRIPT DOES:
#   - Removes all generated submission artifacts from exercise-*/submission/ dirs
#   - Removes scratch files created during exercises (*.scratch.*, *.tmp)
#   - Removes any Claude session state files (.claude-session, *.session.json)
#     that were generated inside the exercise directories
#   - Preserves all starter/ files (the original exercise inputs)
#   - Preserves all solution/ directories (reference implementations)
#   - Preserves all verify/ directories (automated graders)
#   - Preserves the environment/ directory itself
#   - Preserves _plan/, chapters/, capstone/, and glossary files
#
# WHAT THIS SCRIPT DOES NOT DO:
#   - Does not uninstall any tools
#   - Does not delete solution/ directories
#   - Does not modify CLAUDE.MD or persona/context files
#   - Does not touch outputs outside the course directory
#
# Usage (from the repo root):
#   bash environment/reset-env.sh
#
# Options:
#   --dry-run   Print what would be deleted without deleting anything.
#   --chapter N Reset only chapter N (zero-padded, e.g. --chapter 03)
#
# This script is idempotent: running it on an already-clean directory is safe.
# =============================================================================

set -euo pipefail

COURSE_SLUG="cowork-automation-tracy-2026"
COURSE_ROOT="outputs/${COURSE_SLUG}"
DRY_RUN=false
CHAPTER_FILTER=""

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --chapter)
      if [[ -z "${2:-}" ]]; then
        echo "ERROR: --chapter requires a value (e.g. --chapter 03)" >&2
        exit 1
      fi
      CHAPTER_FILTER="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      echo "Usage: bash environment/reset-env.sh [--dry-run] [--chapter NN]" >&2
      exit 1
      ;;
  esac
done

# ------------------------------------------------------------------------------
# Sanity check: must be run from repo root
# ------------------------------------------------------------------------------
if [[ ! -d "$COURSE_ROOT" ]]; then
  echo "ERROR: Directory '${COURSE_ROOT}' not found." >&2
  echo "Run this script from the repository root." >&2
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "=== DRY RUN MODE — nothing will be deleted ==="
fi

echo ""
echo "==================================================================="
echo "  ${COURSE_SLUG} — Environment Reset"
echo "  $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
if [[ -n "$CHAPTER_FILTER" ]]; then
  echo "  Scope: chapter ${CHAPTER_FILTER} only"
else
  echo "  Scope: all chapters"
fi
echo "==================================================================="
echo ""

DELETED_COUNT=0
SKIPPED_COUNT=0

# ------------------------------------------------------------------------------
# delete_if_exists <path> <description>
# ------------------------------------------------------------------------------
delete_if_exists() {
  local target="$1"
  local description="$2"

  if [[ -e "$target" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [DRY RUN] Would delete: ${target}  (${description})"
    else
      rm -rf "$target"
      echo "  [REMOVED] ${target}  (${description})"
    fi
    DELETED_COUNT=$((DELETED_COUNT + 1))
  else
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi
}

# ------------------------------------------------------------------------------
# Determine which chapter directories to process
# ------------------------------------------------------------------------------
CHAPTERS_DIR="${COURSE_ROOT}/chapters"

if [[ ! -d "$CHAPTERS_DIR" ]]; then
  echo "  No chapters directory found at '${CHAPTERS_DIR}'."
  echo "  Nothing to reset."
  echo ""
  exit 0
fi

if [[ -n "$CHAPTER_FILTER" ]]; then
  CHAPTER_DIRS=("${CHAPTERS_DIR}/ch${CHAPTER_FILTER}-"*)
else
  # Glob all chapter directories
  mapfile -t CHAPTER_DIRS < <(find "$CHAPTERS_DIR" -maxdepth 1 -type d -name 'ch[0-9][0-9]-*' | sort)
fi

if [[ ${#CHAPTER_DIRS[@]} -eq 0 ]]; then
  echo "  No chapter directories matched. Nothing to reset."
  echo ""
  exit 0
fi

# ------------------------------------------------------------------------------
# Process each chapter
# ------------------------------------------------------------------------------
for chapter_dir in "${CHAPTER_DIRS[@]}"; do
  [[ -d "$chapter_dir" ]] || continue

  chapter_name="$(basename "$chapter_dir")"
  exercises_dir="${chapter_dir}/${COURSE_SLUG}--${chapter_name}--exercises"

  # Also handle the flat layout without full prefix (generator may vary)
  if [[ ! -d "$exercises_dir" ]]; then
    exercises_dir="${chapter_dir}/exercises"
  fi

  echo "  Processing: ${chapter_name}"

  if [[ ! -d "$exercises_dir" ]]; then
    echo "    No exercises directory found — skipping."
    continue
  fi

  # Iterate over exercise subdirectories
  for exercise_dir in "${exercises_dir}"/exercise-*/; do
    [[ -d "$exercise_dir" ]] || continue

    exercise_name="$(basename "$exercise_dir")"

    # 1. Clear submission/ contents (but keep the directory so git tracks it)
    submission_dir="${exercise_dir}/submission"
    if [[ -d "$submission_dir" ]]; then
      while IFS= read -r -d '' file; do
        delete_if_exists "$file" "submission artifact in ${exercise_name}"
      done < <(find "$submission_dir" -maxdepth 1 -type f -print0)
    fi

    # 2. Remove scratch and temp files anywhere in the exercise directory
    while IFS= read -r -d '' scratch_file; do
      delete_if_exists "$scratch_file" "scratch/temp file in ${exercise_name}"
    done < <(find "$exercise_dir" \( -name '*.scratch.*' -o -name '*.tmp' -o -name '*.temp' \) -type f -print0 2>/dev/null)

    # 3. Remove Claude session state files generated during exercises
    while IFS= read -r -d '' session_file; do
      delete_if_exists "$session_file" "session state file in ${exercise_name}"
    done < <(find "$exercise_dir" \( -name '.claude-session' -o -name '*.session.json' \) -type f -print0 2>/dev/null)

  done

  # 4. Remove any loose temp/scratch files in the chapter root
  while IFS= read -r -d '' chapter_scratch; do
    delete_if_exists "$chapter_scratch" "scratch/temp file in ${chapter_name}"
  done < <(find "$chapter_dir" -maxdepth 1 \( -name '*.scratch.*' -o -name '*.tmp' -o -name '*.temp' \) -type f -print0 2>/dev/null)

done

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
echo ""
echo "-------------------------------------------------------------------"
if [[ "$DRY_RUN" == true ]]; then
  echo "  Dry run complete. ${DELETED_COUNT} item(s) would be removed."
else
  echo "  Reset complete. ${DELETED_COUNT} item(s) removed."
fi
echo "  (${SKIPPED_COUNT} paths were already clean or non-existent.)"
echo "-------------------------------------------------------------------"
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "  Run without --dry-run to apply changes."
else
  echo "  Lab environment reset to clean state."
  echo "  solution/ and verify/ directories were not modified."
fi
echo ""
exit 0
