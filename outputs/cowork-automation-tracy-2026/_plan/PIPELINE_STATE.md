# Pipeline State — cowork-automation-tracy-2026

This file tracks the current execution state of the course factory pipeline.
Updated by each agent as it completes or halts.

---

## Current State

**Status:** IN PROGRESS — Ch01 artifact generation running (3 artifacts in background)

**Last completed step:** Ch01 partial — doc ✅, exercises ✅, quiz A+B ✅, podcast/companion/slides 🔄

**Next step:** Complete Ch01 → run glossary-aggregator → begin Ch02–Ch16

**Orchestration mode:** Manual (top-level Claude session acts as orchestrator; no Task-tool sub-agent spawning available in Cowork environment — use Claude Code CLI for parallel execution)

---

## Step Completion Log

| Step | Name | Status | Completed At |
|---|---|---|---|
| 1 | Input Validation | COMPLETE | 2026-05-25 |
| 2 | Narrative Normalization + Human Review | COMPLETE (approved by user) | 2026-05-25 |
| 3 | Precedence Resolution | COMPLETE | 2026-05-25 |
| 4 | Chapter Partition | COMPLETE | 2026-05-25 |
| 5 | Track & Audience Determination | COMPLETE | 2026-05-25 |
| 6 | Personalization Plan | COMPLETE | 2026-05-25 |
| 7 | Course-Wide Pre-Work Assignments | COMPLETE | 2026-05-25 |
| 8 | Per-Chapter Work Assignments | COMPLETE | 2026-05-25 |
| 9 | Capstone Assignment | COMPLETE | 2026-05-25 |
| 10 | Evaluator Assignment | COMPLETE | 2026-05-25 |
| 11 | Dependency Graph | COMPLETE | 2026-05-25 |
| 12 | Human Review Packet | HALTED — awaiting approval | — |

---

## Artifacts Produced So Far

| Artifact | Path | Status |
|---|---|---|
| personalization-plan.json | `outputs/cowork-automation-tracy-2026/_plan/personalization-plan.json` | Written |
| reserved-scenarios.json | `outputs/cowork-automation-tracy-2026/_plan/reserved-scenarios.json` | Written |
| course-plan.yaml | `outputs/cowork-automation-tracy-2026/_plan/course-plan.yaml` | Written (pending approval) |
| CHANGELOG.md | `outputs/cowork-automation-tracy-2026/_plan/CHANGELOG.md` | Written |
| PLAN_REVIEW.md | `outputs/cowork-automation-tracy-2026/_plan/PLAN_REVIEW.md` | Written (presented for approval) |
| PIPELINE_STATE.md | `outputs/cowork-automation-tracy-2026/_plan/PIPELINE_STATE.md` | This file |

---

## What Happens After Approval

Once the user approves PLAN_REVIEW.md:

1. `course-plan.yaml` becomes the authoritative contract (approved_by and approved_at fields populated).
2. `@course-factory-agent` (or `@chapter-supervisor-agent chapter_number: 1`) can be invoked.
3. Chapters are generated sequentially: ch01 → ch02 → … → ch16.
4. Each chapter: Text → Exercise → (Presentation ∥ Quiz) → Podcast → Companion → Evaluator.
5. After ch16: LabGenerator (capstone, uses scenario-02) → EvaluatorAgent (course-wide).

---

## Resume Instructions

If the pipeline is interrupted mid-course, resume by invoking:
```
@chapter-supervisor-agent chapter_number: N
```
where N is the first chapter not yet marked COMPLETE in this file.
The chapter-supervisor reads the plan, reconstructs the envelope, and resumes from that chapter.
