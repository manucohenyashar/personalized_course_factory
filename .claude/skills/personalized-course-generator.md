---
name: personalized-course-generator
description: Master orchestration skill for the complete course generation pipeline. Accepts student specifications inline or from pre-filled input files. Writes/validates inputs, runs the planner with mandatory human-review halts, then executes the full chapter generation loop, course evaluator, and capstone lab. Tracks pipeline state so generation can be resumed after interruption. Invoked by course-factory-agent or directly by the user.
---

# Personalized Course Generator — Master Orchestration

This skill drives the complete pipeline from raw specification to finished course.
Follow every phase in order. Do not skip phases. Do not proceed past a HALT without
explicit user approval.

---

## PHASE 0 — Spec Intake

**Goal:** Ensure all four input files are complete and correct before touching the planner.

### 0.1 — Detect the invocation mode

Check which of these three situations applies:

**Mode A — Inline specs** (user provided specs in their message):
The user's message contains domain, student, or subject information that hasn't been
written to `inputs/` yet. Signs: the message includes phrases like "the students are...",
"the domain is...", "the subject is...", or pastes YAML/JSON content.

**Mode B — Pre-filled files** (user already filled the input files):
`inputs/problem.yaml` and `inputs/students.yaml` exist with no `REPLACE_ME` tokens.
Skip to step 0.4 (validation).

**Mode C — Resume** (pipeline was previously started):
`outputs/` contains a directory with a `_plan/course-plan.yaml` and a
`_plan/PIPELINE_STATE.md`. Skip to Phase 5 (Resume Protocol).

---

### 0.2 — Parse inline specs (Mode A only)

If the user provided specs inline, extract the following from their message:

```
From the user's message, derive:

DOMAIN SPEC (→ inputs/problem.yaml):
  problem_id:       short slug, e.g. "warehouse-automation-01"
  summary:          what problem the course solves (1–3 sentences)
  domain:           industry / technical domain name
  domain_vocabulary: list of 3–7 domain-specific terms the user mentions
  representative_scenarios: at least 4 concrete scenarios; for each:
    - id, title, description, entities (people/systems), artifacts (files/outputs)
  success_criteria: 2–5 measurable outcomes of solving the problem

STUDENT SPEC (→ inputs/students.yaml):
  cohort_id:        short slug
  age_range:        min / max
  locale:           IETF tag (default "en-US" if not mentioned)
  primary_language: default "English"
  reading_level_target: Flesch-Kincaid grade (infer from professional_context if not stated:
    blue-collar field → 8, office/knowledge worker → 10, technical/engineering → 12, academic → 14)
  prior_knowledge:  skills, tools, or domains the user says the students already know
  professional_context: their job/industry (what the user describes as their background)
  mode_preference:  "self_taught" | "cohort" | "both" (default "both")
  accessibility_needs: anything the user mentions; default []
  preferred_modalities: infer from context (default ["text", "hands-on"])

SUBJECT SPEC (→ inputs/subject.md):
  The subject spec is the curriculum contract — it defines what topics MUST be taught.
  If the user provides a subject outline, chapter list, or topic list, write it to inputs/subject.md.
  If the user explicitly says "use default" or doesn't provide a curriculum, keep the existing
  inputs/subject.md and state clearly which curriculum will be used (e.g., "Using the default
  18-chapter Cowork Automation curriculum").
  If neither applies — no subject spec provided and no clear default confirmation — ask the user
  to provide one before writing any other file (see course-factory-agent.md for the prompt).

ORCHESTRATION SPEC (→ inputs/orchestration.yaml):
  Keep existing defaults unless the user specifies overrides.

GLOBAL REQUIREMENTS (→ inputs/general-requirements.yaml):
  Scan the user's message for any of these signals and extract them:

  | Signal in message | Field to set |
  |-------------------|-------------|
  | "X hours", "X-hour course", "max X hours" | total_hours_max: X |
  | "at least X hours", "minimum X hours" | total_hours_min: X |
  | "X chapters", "N modules" | chapter_count: X |
  | "X minutes per chapter", "X-minute chapters" | chapter_duration_minutes: X |
  | "focus on X", "emphasize X", "prioritize X" | focus_areas: [X, ...] |
  | "skip X", "exclude X", "no X", "without X" | exclude_topics: [X, ...] |
  | "beginner", "intro level", "entry level" | difficulty_target: beginner |
  | "intermediate", "mid-level" | difficulty_target: intermediate |
  | "advanced", "expert level" | difficulty_target: advanced |
  | "no slides", "no podcast", "no quiz", etc. | artifact_types: [all except named] |
  | "self-paced", "instructor-led", "blended" | delivery_format: <value> |
  | Any specific constraint not captured above | custom_instructions: "<verbatim>" |

  If the user mentions any of these, write them to `inputs/general-requirements.yaml`.
  If none are mentioned, leave the file at its defaults (all fields commented out).
```

After extracting, write draft YAML to the input files. Then present a summary to the user:

```markdown
## Spec Summary — Please Review

**Curriculum (subject spec):** {subject title from subject.md}
  {N} chapters/topics defined — e.g., "Ch 1 — Introduction, Ch 2 — Automation Mindset, …"
  _(This is the curriculum contract. Every topic listed here MUST be covered in the generated course.)_
**Problem domain:** {domain}
**Problem being solved:** {summary}
**Scenarios provided:** {N} ({list titles})
**Cohort:** {cohort_id} — {professional_context}
**Reading level target:** FK grade {N}
**Prior knowledge assumed:** {list}
**Mode:** {mode_preference}

### Global Requirements Applied:
{If any general-requirements fields were set, list them here as:}
- Total time: {min}–{max} h  (or "default")
- Chapters: {count} (or "from subject spec")
- Chapter duration: {N} min (or "45–90 min default")
- Focus areas: {list} (or "none")
- Excluded topics: {list} (or "none")
- Difficulty: {target} (or "from subject spec")
- Artifacts: {list} (or "all six")
- Delivery format: {format} (or "blended")
- Custom instructions: {yes/no}
{If no requirements set: "None — all pipeline defaults apply."}

### Potential gaps I noticed:
{List any missing required fields or scenarios that seem thin. If none: "None — all required fields present."}

> Type **"confirmed"** to proceed with these specs, or tell me what to adjust.
```

**HALT — Wait for user confirmation before writing any input file.**

After confirmation, write all four input files. Tell the user: "Input files written. Starting the planner."

---

### 0.3 — Verify no REPLACE_ME tokens remain (Mode A after writing)

Scan all four input files. If any `REPLACE_ME` token remains, list them and ask the user to supply the missing values before continuing.

---

### 0.4 — Validate inputs (all modes)

Run the input validation checklist from `/plan-course` Step 1:

```
problem.yaml:
  ✓ problem_id present (no REPLACE_ME)
  ✓ summary present
  ✓ domain_vocabulary has ≥ 3 terms
  ✓ representative_scenarios[] has ≥ 4 entries
  ✓ Each scenario has: id, title, description, entities[], artifacts[]
  ✓ success_criteria[] has ≥ 2 entries

students.yaml:
  ✓ cohort_id present
  ✓ reading_level_target present (FK grade 6–16)
  ✓ prior_knowledge[] has ≥ 1 entry
  ✓ professional_context present
  ✓ mode_preference is one of: self_taught, cohort, both

subject.md:
  ✓ Course title present
  ✓ Chapter list with ≥ 3 chapters

orchestration.yaml:
  ✓ output_root present
  ✓ quality_gates_to_run present

general-requirements.yaml (OPTIONAL — skip validation if file absent):
  ✓ total_hours_min < total_hours_max (if both set)
  ✓ chapter_count is integer ≥ 3 and ≤ 30 (if set)
  ✓ chapter_duration_minutes is integer ≥ 30 and ≤ 180 (if set)
  ✓ difficulty_target is one of: beginner | intermediate | advanced (if set)
  ✓ artifact_types contains at least: doc, exercises (if set — these two are non-negotiable)
  ✓ delivery_format is one of: self_paced | instructor_led | blended (if set)
```

If validation fails, list exactly which fields are missing and ask the user to supply them.
Do NOT proceed with missing required fields.

---

## PHASE 1 — Planning

**Goal:** Produce `_plan/course-plan.yaml`, `personalization-plan.json`,
`reserved-scenarios.json`, and `PLAN_REVIEW.md`. Requires two human-review halts.

### 1.1 — Invoke the planner

Invoke `@planner-agent`.

The planner will:
- Run the 12-step planning algorithm
- **HALT at Step 2** (normalization diff) → the planner will show you the diff and ask for approval
- **HALT at Step 12** (PLAN_REVIEW.md) → the planner will show you the review and ask for approval

Both halts require explicit user approval ("approved" or equivalent). Do not continue until
the user has approved at each halt.

After both approvals and planner completion, verify these files now exist:
- `outputs/{course_slug}/_plan/course-plan.yaml`
- `outputs/{course_slug}/_plan/personalization-plan.json`
- `outputs/{course_slug}/_plan/reserved-scenarios.json`
- `outputs/{course_slug}/_plan/PLAN_REVIEW.md`

If any file is missing, re-invoke `@planner-agent`.

---

### 1.2 — Initialize pipeline state

After the planner succeeds, read `course-plan.yaml` to get the chapter list. Write:
`outputs/{course_slug}/_plan/PIPELINE_STATE.md`

```markdown
# Pipeline State — {course_slug}

**Generated:** {ISO datetime}
**Course:** {course_title}
**Total chapters:** {N}
**Status:** in_progress

---

## Phase Progress

| Phase | Status | Completed At |
|-------|--------|-------------|
| spec_intake | complete | {datetime} |
| planning | complete | {datetime} |
| environment | pending | |
| chapters | pending | |
| evaluation | pending | |
| capstone | pending | |

---

## Chapter Progress

| # | Slug | Status | Doc | Ex | Slides | Quiz | Podcast | Companion |
|---|------|--------|-----|-----|--------|------|---------|-----------|
{for each chapter:}
| {N} | {slug} | pending | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
```

Tell the user:
> "Plan approved and pipeline initialized. **{N} chapters** to generate.
> Starting environment setup now."

---

## PHASE 2 — Environment Setup

**Goal:** Generate the shared lab environment that all exercise generators and the capstone lab use.

Invoke `@environment-scaffold-generator` with:
- `course_slug`: from course-plan.yaml
- `subject_spec_path`: `inputs/subject.md`
- `orchestration_path`: `inputs/orchestration.yaml`
- `student_context_path`: `inputs/students.yaml`

After completion, verify these files exist:
- `outputs/{course_slug}/environment/devcontainer.json`
- `outputs/{course_slug}/environment/preflight.sh`
- `outputs/{course_slug}/environment/lab-environment.json`

Update `PIPELINE_STATE.md`: set `environment` → `complete`.

Tell the user: "Environment scaffold generated. Starting chapter generation."

---

## PHASE 3 — Chapter Generation Loop

**Goal:** Generate all chapters sequentially. Each chapter produces 6 artifact types,
all evaluated and verified before moving to the next.

### 3.1 — For each chapter N from 1 to total_chapters:

```
1. Check PIPELINE_STATE.md — if chapter N shows status "complete", skip it.
2. Update PIPELINE_STATE.md: chapter N → "in_progress"
3. Announce: "Generating Chapter {N}/{total}: {title}…"
4. Invoke @chapter-supervisor-agent with: chapter_number: N
5. The supervisor handles the full feedback loop for all 6 artifact types.
6. When the supervisor reports completion:
   - Read chapter.manifest.json for chapter N
   - If status = "verified": update PIPELINE_STATE.md chapter N → "complete ✓"
   - If status = "failed":
       Update PIPELINE_STATE.md chapter N → "FAILED ⚠"
       HALT — show the user the failure details from chapter.manifest.json
       Tell the user: "Chapter {N} failed all 3 attempts. Review the failures below
       and tell me how to proceed: (1) retry this chapter, (2) skip and continue,
       or (3) halt the pipeline."
       Wait for user decision before continuing.
7. Report chapter status to the user after each chapter completes.
```

### 3.2 — Chapter completion report (after each chapter)

After each chapter completes successfully:

```markdown
✓ **Chapter {N} — {title}** complete
  - Doc: {word_count} words (FK {fk_grade})
  - Exercises: {N} exercises, {total_minutes} min
  - Slides: {slide_count} slides
  - Quiz: {item_count} items (Forms A + B)
  - Podcast: {word_count} words (~{audio_minutes} min)
  - Companion: cheatsheet + instructor guide
  - Attempts used: {list per artifact}

  **Progress: {complete_count}/{total_chapters} chapters done.**
  {If not the last chapter: "Generating Chapter {N+1}..."}
```

### 3.3 — After all chapters complete

Update `PIPELINE_STATE.md`: set `chapters` → `complete`.

Tell the user:
> "All {N} chapters generated and verified. Moving to course-wide evaluation."

---

## PHASE 4 — Course Evaluation

**Goal:** Validate cross-chapter LO coverage, running-example coherence, glossary completeness,
and capstone eligibility. This is the final check before the capstone lab.

Invoke `@evaluator-agent` with:
- `course_slug`: from course-plan.yaml
- `outputs_dir`: `outputs/{course_slug}/`
- `course_plan`: `_plan/course-plan.yaml`
- `personalization_plan`: `_plan/personalization-plan.json`
- `reserved_scenarios`: `_plan/reserved-scenarios.json`
- `subject_spec_path`: `inputs/subject.md`
- `subject_coverage_index`: `_plan/subject-coverage-index.json`

After completion, read `COURSE_VERDICT.md`. Check `overall_status`:

**If `pass`:**
Update `PIPELINE_STATE.md`: set `evaluation` → `complete`.
Tell the user: "Course evaluation passed. Generating the capstone lab."

**If `fail`:**
Update `PIPELINE_STATE.md`: set `evaluation` → `FAILED ⚠`.
HALT — show the user the failures from `COURSE_VERDICT.md`.

Ask the user:
> "The course evaluation found the following issues:
> {list failures}
>
> Options:
> 1. Re-generate specific chapters (tell me which chapter numbers to redo)
> 2. Accept the issues and proceed to the capstone anyway (not recommended)
> 3. Halt here for manual review
>
> What would you like to do?"

Wait for user decision. If they choose option 1, return to Phase 3 for the specified chapters,
then re-run Phase 4.

---

## PHASE 5 — Capstone Lab

**Goal:** Generate the capstone lab that implements the student's problem (from `problem.yaml`)
using the reserved scenario.

Invoke `@lab-generator` with:
- `course_slug`: from course-plan.yaml
- `course_plan`: `_plan/course-plan.yaml`
- `problem_spec`: full `inputs/problem.yaml` content
- `personalization_plan`: `_plan/personalization-plan.json`
- `reserved_scenarios`: `_plan/reserved-scenarios.json`
- `all_chapter_handoffs[]`: all `*--doc.handoff.json` files from `outputs/{course_slug}/chapters/`
- `lab_environment_manifest`: `outputs/{course_slug}/environment/lab-environment.json`

After completion, read the lab-evaluator verdict. If the lab fails evaluation:
- The lab-generator will retry automatically (up to 3 attempts)
- If all 3 attempts fail: HALT and show the user the lab evaluation failures

After the lab passes, update `PIPELINE_STATE.md`: set `capstone` → `complete`.

---

## PHASE 6 — Completion Report

**Goal:** Deliver a clear, scannable summary of everything that was generated.

Update `PIPELINE_STATE.md`: set overall `Status` → `complete`.

Present the following completion report to the user:

```markdown
# Course Generation Complete ✓

**Course:** {course_title}
**Slug:** {course_slug}
**Domain:** {problem_spec.domain}
**Cohort:** {cohort_id}
**Generated:** {ISO datetime}

---

## What Was Built

### {N} Chapters
| # | Title | Time | Artifacts |
|---|-------|------|-----------|
| 1 | {title} | {est_minutes} min | doc · exercises · slides · quiz · podcast · companion |
...

**Total learning time:** ~{sum_est_minutes / 60:.1f} hours across {N} chapters

### Capstone Lab
- **Scenario:** {reserved_scenario_title}
- **Duration:** {est_minutes} min
- **Problem solved:** {problem_spec.summary (1 sentence)}
- **Acceptance criteria:** {N} criteria, all implemented and verified

### Supporting Artifacts
- Course glossary: `outputs/{course_slug}/glossary.docx` ({term_count} terms)
- Prerequisite diagnostic: `outputs/{course_slug}/prereq-diagnostic.md`
- Lab environment: `outputs/{course_slug}/environment/`
- Course verdict: `outputs/{course_slug}/COURSE_VERDICT.md`

---

## Output Directory
All files are in: `outputs/{course_slug}/`

---

## Quality Summary
| Gate | Status |
|------|--------|
| Subject spec coverage | ✓ N/N curriculum topics addressed |
| §16.1 Coverage | ✓ all chapters |
| §16.2 Pedagogy | ✓ all chapters |
| §16.3 Personalization | ✓ all chapters |
| §16.4 Format | ✓ all chapters |
| §16.5 Technical | ✓ all chapters |
| §16.6 Accessibility | ✓ all chapters |
| §16.7 Calibration | ✓ all chapters |
| Capstone problem fidelity | ✓ all success_criteria implemented |

---

## Next Steps
1. **Review** `outputs/{course_slug}/_plan/PLAN_REVIEW.md` for the course structure overview
2. **Run preflight** on the environment: `bash outputs/{course_slug}/environment/preflight.sh`
3. **Try the capstone**: open `outputs/{course_slug}/capstone/README.md`
4. **Distribute** chapter content from `outputs/{course_slug}/chapters/`
```

---

## PHASE 5 (RESUME) — Resume Protocol

If `PIPELINE_STATE.md` exists, read it and offer to resume:

```markdown
## Resume Available

A previous pipeline run was found for course **{course_slug}**:

| Phase | Status |
|-------|--------|
| planning | {status} |
| environment | {status} |
| chapters | {N_complete}/{N_total} complete |
| evaluation | {status} |
| capstone | {status} |

**Failed chapters (if any):** {list or "none"}

> Options:
> 1. **Resume** from where it left off (skip completed phases)
> 2. **Restart** specific chapters: tell me which chapter numbers to redo
> 3. **Start fresh** (warning: this will overwrite the existing outputs)
>
> What would you like to do?
```

After user responds:
- **Resume**: jump to the first incomplete phase; for chapters, skip all with status "complete"
- **Restart chapters**: re-run specified chapters in Phase 3, then continue from Phase 4
- **Start fresh**: delete `PIPELINE_STATE.md`, clear `outputs/{course_slug}/`, restart from Phase 0

---

## Error Reference

| Situation | Action |
|-----------|--------|
| < 4 scenarios in problem.yaml | HALT Phase 0; ask user to add scenarios |
| Planner MUST gate fails | HALT Phase 1; show failing gates; ask user to fix inputs |
| Chapter fails 3 attempts | HALT Phase 3; show failures; ask for user decision |
| Course evaluation fails | HALT Phase 4; show failures; offer re-generation options |
| Lab fails 3 attempts | HALT Phase 5; show lab failures; ask for user decision |
| No reserved scenario available | HALT Phase 5; ask user to add a scenario to problem.yaml and re-plan |
| User says "stop" or "pause" | Write current state to PIPELINE_STATE.md; confirm state is saved |

---

## Inline Spec Examples

When a user invokes the generator with inline specs, they might say any of these:

> "Create a course for warehouse logistics supervisors learning to use AI for exception
> triage in SAP WMS. They have SQL experience but no ML background. The course should
> cover prompt engineering, context injection, and batch automation."

> "Using the personalized course generator, build a course on Kubernetes for platform
> engineers at a fintech company. They know Docker well. Focus on: pod scheduling,
> network policies, and GitOps workflows. Success criteria: they can deploy and debug
> a multi-service application independently."

> "Generate a training course. Domain: insurance claims processing. Students are
> claims adjusters with 3+ years experience. Subject: using LLMs to accelerate
> coverage analysis and draft settlement summaries."

In all cases: extract domain, students, subject, success criteria → write input files →
validate → proceed with the pipeline. If anything critical is missing (fewer than 4 scenarios,
no professional context), ask the user to fill in the gap before proceeding.
