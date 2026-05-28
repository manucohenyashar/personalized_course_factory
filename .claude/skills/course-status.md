---
name: course-status
description: Print a quick, lightweight progress report for the active course by reading only PIPELINE_STATE.md (and chapter.manifest.json summaries). Cheap to run, loads no artifact content, and is the fastest way to see what is done, what is pending, what failed, and what to run next — ideal right after a /compact or when resuming a session.
---

# Course Status — Lightweight Progress Readout

A read-only, low-context status check. It never loads chapter docs, slides, quizzes,
or other artifacts — only the durable state files. Run it anytime, especially after
`/compact` or when picking up a previous session.

## Step 1 — Find the active course

Locate the `outputs/*/` directory containing `_plan/PIPELINE_STATE.md`.
If none exists, report: `"No pipeline run found. Start with @course-factory-agent."`
and stop. If multiple exist, prefer the one with `Status: in_progress`; otherwise
list the slugs and ask which one.

## Step 2 — Read state only

Read `_plan/PIPELINE_STATE.md`. Optionally read each completed chapter's
`chapter.manifest.json` **only** to pull the headline numbers (word count, attempts).
Read nothing else.

## Step 3 — Report

```markdown
## {course_title} — Status: {overall_status}

| Phase        | Status |
|--------------|--------|
| planning     | {status} |
| environment  | {status} |
| chapters     | {N_complete}/{N_total} complete |
| evaluation   | {status} |
| capstone     | {status} |

**Chapters**
{compact list: "✓ 1 Intro · ✓ 2 Mindset · ▶ 3 Prompting (in progress) · 4-8 pending"}

**Failed:** {list of FAILED ⚠ chapters, or "none"}

**Next action:** {derive from first incomplete phase, e.g.
  "Run `/next-chapter` (or `/loop /next-chapter`) — 5 chapters remain",
  "Run @evaluator-agent — all chapters done",
  "Run @lab-generator — evaluation passed"}
```

Keep it to one screen. Do not propose regenerating anything unless the user asks.
