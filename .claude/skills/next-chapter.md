---
name: next-chapter
description: Generate exactly ONE chapter — the next pending chapter in PIPELINE_STATE.md — then halt at a clean context boundary. Loop-friendly and compaction-friendly. Use this to drive multi-chapter generation one chapter at a time (optionally via `/loop /next-chapter`) so each chapter runs in a fresh context window. Reads durable state, dispatches @chapter-supervisor-agent, updates state, reports, and stops.
---

# Next Chapter — Single-Chapter, Checkpoint-Bounded Generation

This skill generates **one** chapter and then stops. It exists so that long
multi-chapter courses can be produced **one chapter per context window**, which
keeps the working context small and makes `/compact` safe to run between chapters.

It does the same per-chapter work as Phase 3 of `/personalized-course-generator`,
but for a single chapter, and it never advances past one chapter on its own.

---

## Step 1 — Locate the course and load durable state

1. Find the active course: the `outputs/*/` directory containing
   `_plan/PIPELINE_STATE.md`. If more than one exists, pick the one whose
   `Status` is `in_progress`; if still ambiguous, ask the user which `course_slug`.
2. If no `PIPELINE_STATE.md` exists, tell the user the pipeline has not been
   planned yet and to run `@course-factory-agent` (or `/personalized-course-generator`)
   first. Stop.
3. Read **only** `_plan/PIPELINE_STATE.md` and `_plan/course-plan.yaml`.
   Do NOT read prior chapters' artifact content — state is the source of truth.

## Step 2 — Verify prerequisites

- `planning` must be `complete`. If not, stop and tell the user to finish planning.
- `environment` must be `complete`. If not, run `@environment-scaffold-generator`
  first (Phase 2 of the master skill), then continue.

## Step 3 — Pick the next pending chapter

From the Chapter Progress table, select the **lowest-numbered** chapter whose
status is `pending` or `in_progress` (not `complete ✓`).

- If every chapter is `complete ✓`: report
  `"All N chapters complete — nothing to generate. Run @evaluator-agent next."`
  and **stop** (this is also the signal for `/loop` to end).
- If a chapter is marked `FAILED ⚠`: do not silently skip it. Report the failure
  and ask the user whether to retry it, skip it, or halt.

## Step 4 — Generate exactly that chapter

1. Set the chosen chapter → `in_progress` in `PIPELINE_STATE.md`.
2. Announce: `"Generating Chapter {N}/{total}: {title}…"`
3. Invoke `@chapter-supervisor-agent` with `chapter_number: N` **as a subagent**
   so all generator/evaluator context stays isolated from this window.
4. When it returns, read **only** `chapter.manifest.json` for chapter N
   (status, attempt counts, word/slide/item counts) — never the full artifacts.
5. Update `PIPELINE_STATE.md`:
   - `verified` → mark chapter `complete ✓`
   - `failed` → mark chapter `FAILED ⚠`, surface the failure, ask the user how to proceed.

## Step 5 — Report and STOP at the checkpoint

Print the standard chapter completion report (see master skill §3.2), then a
one-line "what's next" footer:

```
✓ Chapter {N}/{total} complete and state saved.
{If chapters remain:}  {remaining} chapter(s) left. This is a clean checkpoint —
  run `/compact` then `/next-chapter` (or `/loop /next-chapter`) to continue.
{If none remain:}      All chapters done. Run @evaluator-agent for course-wide checks.
```

**Do not start the next chapter.** Stop here. State is durable, so the next
invocation (in a fresh or compacted context) resumes correctly from `PIPELINE_STATE.md`.

---

## Why this is the recommended large-course flow

- **Bounded context:** one chapter's supervisor subagent runs and is reclaimed each
  iteration; this window holds only state-file summaries.
- **Clean compaction boundary:** because state is fully flushed before stopping,
  `/compact` (or auto-compaction) between iterations never loses progress and never
  fires mid-chapter.
- **Loopable:** `/loop /next-chapter` self-paces through all chapters; it ends
  naturally when Step 3 reports "all complete".
- **Resumable:** identical to the master skill's resume protocol — re-invoking
  always continues from the lowest incomplete chapter.
