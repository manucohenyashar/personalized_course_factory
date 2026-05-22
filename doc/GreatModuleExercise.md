---
title: Course Factory — Chapter Exercise Pack Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: GreatModuleExercise.md
implements: GreatCourseSpec_v2.md §8.3, §7.7, §9.6, §16.2, §16.5
skill_target: ExerciseGeneratorSkill
scope: |
  Defines the contract for the per-chapter Exercise Pack
  (`*--exercises/` folder). Exercises are the primary hands-on learning
  artifact inside a chapter; they are distinct from the course-level
  Capstone Lab defined in GreatLabSpec_v2.md (which implements master §9.4).
conformance_language: RFC 2119
canonical_term_note: |
  "Module" is a legacy term. The canonical learning unit is **Chapter**.
  This spec produces the **per-chapter exercise pack**.
---

# Chapter Exercise Pack Specification (v2)

## 1. Purpose

Generate the per-chapter exercise pack: the runnable, gradeable, hands-on
component of a chapter that carries the **≥ 60 %** hands-on share required
by master §7.14. Exercises operationalize the chapter's learning outcomes
through the *"I do / we do / you do"* progression (master §7.7).

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§8.3 (Exercises layout), §7.7 (worked →
  completion → independent), §9.6 (exercise rubric), §16.2 / §16.5 (quality
  gates), §7.10 (failure-first), §7.12 (4C/ID whole-task), §7.14 (hands-on
  ratio), §10 (personalization), §13 (accessibility)**.
- On any conflict with the master spec, the master wins.

## 3. Input Contract

```yaml
common_inputs:
  course_slug, chapter, learning_outcomes[], problem_spec,
  student_context, personalization_plan, mode_targets,
  output_paths, quality_gates_to_satisfy[], numeric_overrides

exercise_specific_inputs:
  chapter_doc_outline:        <section IDs + Bloom tags + worked-example seed>
  worked_example_seed:        <chapter's canonical worked example, from doc §7>
  difficulty_curve:           [easy, medium, hard]   # default; overridable
  min_exercises:              3
  lab_environment_manifest:   <master §14 object; pinned versions, preflight ref>
  chapter_pitfalls:           <misconceptions surfaced in the chapter doc>
  target_track:               novice | practiced | both   # master §7.8
```

## 4. Time Budget

- The exercise pack MUST total **at least 60 % of the chapter's computed
  total time** (master §7.14, §6), and SHOULD fall in the **25–40 minute
  band** (which satisfies the 60 % rule for typical 45–60 min chapters).
- Each exercise MUST declare an integer `time_box_minutes` in its
  front-matter; the sum of `time_box_minutes` across the pack MUST satisfy
  both bounds above.
- Time-boxing is part of master §6's chapter-time formula. The exercise
  pack carries the **≥ 60 %** hands-on share (§7.14); explanation
  artifacts (doc + slides) carry the remainder.

If the Subject Spec or Orchestration Spec declares a smaller exercise share
(for example the Cowork Automation Subject Spec example originally said
"5–15 min optional exercises"), the generator MUST log the conflict and
follow master spec precedence (master §3.5: master > Subject Spec on
pedagogical numerics). The Orchestration Spec MAY override the 25–40 min
SHOULD band by setting `numeric_overrides.exercises.pack_minutes`, but the
60 % MUST floor (§7.14) cannot be overridden.

## 5. Required Output Layout

```
chapters/ch{NN}-{slug}/{course_slug}--ch{NN}--{slug}--exercises/
  manifest.json                 # see §9
  README.md                     # pack motivation, LOs, prereqs, total time
  worked-example/               # stage 1 — fully solved
    README.md
    solution/                   # the artifact IS the walkthrough
    walkthrough.md              # narrated, step-by-step
  exercise-02/                  # stage 2 — completion
    README.md
    starter/                    # with TODO blocks (≥30 % of lines)
    solution/
    verify/
    rubric.json
    failure-modes.md
  exercise-03/                  # stage 3 — independent (≥ 1 required)
    README.md
    starter/                    # minimal scaffold only
    solution/
    verify/
    rubric.json
    failure-modes.md
  exercise-NN/                  # additional independent (debug/diagnose preferred)
    [same shape as exercise-03]
  debrief.md                    # reflection prompts + LO mapping
```

### 5.1 Naming

All filenames MUST follow master §5.2. The pack root directory is named
`{course_slug}--ch{NN}--{slug}--exercises/`.

## 6. Composition Rules

### 6.1 Stages (master §7.7)

Every chapter pack MUST contain, in this order:

1. **One worked example** — fully solved, narrated step-by-step, with
   highlighted decisions.
2. **One completion problem** — partial solution with ≥ 30 % of lines
   marked `TODO` and a clear contract for what the learner must fill in.
3. **At least one independent exercise** — only a brief + tests; no
   step-by-step guidance.

The three stages MAY share a running thread (recommended) so the learner
sees the same scenario from different scaffolding levels.

### 6.2 Count

The pack MUST contain **≥ 3** exercises (1 worked + 1 completion + ≥ 1
independent). It SHOULD contain **3–5**; > 5 exercises in a single chapter
SHOULD be split into sub-chapters per master §6.

### 6.3 Difficulty Curve

The independent exercises MUST follow the curve **1 easy → ≥ 1 medium →
≥ 1 hard** when there are three or more independents. The worked example
itself is `not_applicable`. Each exercise MUST declare its
`difficulty: easy | medium | hard` in front-matter.

### 6.4 Bloom Coverage

Across the pack, exercises MUST cover **≥ 3 Bloom tiers**, with:
- **≥ 1 at Apply or higher**, and
- **≥ 1 at Analyze, Evaluate, or Create**.

At least **one independent exercise per chapter MUST be a
debugging/diagnosis task** at Analyze level, operationalizing §7.10
(failure-first technical pedagogy).

### 6.5 One-Skill vs Whole-Task

- **Simple/recurrent skills** (procedural, repeatable): each exercise tests
  exactly one skill. If an exercise tests three, split it into three.
- **Complex/non-recurrent skills** (architecture, evaluation, debugging in
  context): use **whole-task with variability** (master §7.12 / 4C/ID) —
  multiple problem surface forms, not isolated drills.

Choose the path based on the LO's Bloom tier: Remember/Understand/Apply
SHOULD use one-skill; Analyze/Evaluate/Create SHOULD use whole-task.

### 6.6 Track Variants (master §7.8)

When `target_track = both`, the generator MUST emit two parallel branches:

```
exercise-03/
  novice-track/      # worked-example-heavy, more scaffolding
  practiced-track/   # problem-heavy, less scaffolding
```

For `intermediate` or `advanced` Subject Specs, `target_track = both` is
the default.

## 7. Per-Exercise Schema (REQUIRED in each `README.md` front-matter)

```yaml
exercise_id: ch{NN}-ex{MM}
chapter: {NN}
stage: worked_example | completion | independent
difficulty: not_applicable | easy | medium | hard
bloom_level: Remember|Understand|Apply|Analyze|Evaluate|Create
skill_pattern: one_skill | whole_task
learning_outcome_refs: [LO-{NN}.{n}, ...]
time_box_minutes: <int 5..20>
prerequisites:
  prior_exercises: [<exercise_id>, ...]
  chapter_sections: ["<N.N>", ...]
domain_scenario_ref: problem_spec.representative_scenarios[<i>]
deliverables: [<file>, ...]
success_criteria: |
  Observable, learner-verifiable.
failure_modes_documented: <int ≥ 2>
estimated_completion_rate: <0.55..0.85>     # heuristic, see §11
accessibility:
  alt_text_present: true
  color_independent: true
  code_as_text:    true
track: novice | practiced | universal       # if track variants emitted
```

## 8. Required Body Structure for Each `README.md`

```
1.  Front-matter (yaml, schema above)
2.  Motivation — why this exercise matters (1–2 sentences, learner-facing)
3.  Learning Outcomes — explicit LO references
4.  Prerequisites — prior exercises, chapter sections, environment check
5.  Scenario — drawn from Problem-Spec via personalization-plan.json
6.  Steps (worked) or Brief (completion / independent)
        worked       → narrated solution, highlighted decisions
        completion   → TODO contracts + acceptance criteria
        independent  → brief + tests + non-functional constraints
7.  Self-check — how to know it works (link to `verify/`)
8.  Failure Modes — ≥ 2 documented: broken state, expected error, diagnosis
9.  Stretch (optional, time-boxed separately, not counted in pack total)
10. Connect-back — one sentence tying the exercise to the chapter concept
11. Reflection prompts — 1 per exercise (the full set lives in debrief.md)
```

## 9. `manifest.json` Schema

```yaml
pack_id: <course_slug>--ch{NN}--exercises
chapter: <int>
total_time_box_minutes: <int 20..40>
target_track: novice | practiced | both
exercises:
  - exercise_id, stage, difficulty, bloom_level, time_box_minutes,
    learning_outcome_refs[], skill_pattern, path
bloom_distribution:
  Remember: <int>
  Understand: <int>
  Apply: <int>
  Analyze: <int>
  Evaluate: <int>
  Create: <int>
debrief_path: "debrief.md"
```

## 10. `rubric.json` (per exercise — REQUIRED)

Each `exercise-NN/rubric.json` MUST conform to the master §9.6 schema:

```json
{
  "criteria": [
    { "id": "correctness",   "weight": 0.40, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "approach",      "weight": 0.20, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "code_quality",  "weight": 0.25, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "communication", "weight": 0.15, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } }
  ],
  "passing_average": 3.0
}
```

Note: the **capstone-level rubric is 6-criterion** (master §9.4). This
per-exercise rubric stays at 4 criteria.

## 11. Difficulty / Completion-Rate Heuristic

For each independent exercise, the generator MUST estimate
`estimated_completion_rate` deterministically:

```
base = { easy: 0.85, medium: 0.70, hard: 0.55 }[difficulty]
bloom_adj = { Apply: 0, Analyze: -0.05, Evaluate: -0.08, Create: -0.10 }[bloom_level]
scaffold_adj = +0.05 if starter scaffold covers ≥ 70 % of solution lines, else 0
novelty_adj = -0.05 if the skill is first introduced this chapter
estimated_completion_rate = clamp(base + bloom_adj + scaffold_adj + novelty_adj, 0.30, 0.95)
```

Independent exercises with `estimated_completion_rate < 0.40` MUST be
flagged for rewrite (too hard for the position in the curve).

## 12. Personalization (master §10)

- Every exercise scenario MUST instantiate a
  `problem_spec.representative_scenarios[]` entry through the
  `personalization-plan.json` substitution table.
- The pack MUST share the chapter's running example with the chapter doc,
  slide deck, podcast, and quiz (master §7.15).
- At most **one** out-of-domain illustration is allowed across the pack and
  MUST be clearly labeled (master §10.2).

## 13. Lab Environment (master §14)

- Every exercise MUST run inside the course-wide environment declared in
  `lab_environment_manifest`.
- `preflight.sh` / `preflight.ps1` MUST pass before any `verify/` is run.
- `verify/` MUST pass when run against `solution/` (master §16.5).
- Tool versions MUST match the chapter's `validated-against:` block; the
  generator MUST NOT use deprecated APIs without an explicit migration
  callout (master §14.2).

## 14. Accessibility (master §13.1)

- All code samples MUST be plain text; never images.
- Every figure MUST have alt text describing both shapes and relationships.
- No exercise MUST convey information by color alone.
- Step lists MUST be screen-reader-safe (no positional cues like "the
  button on the right").

## 15. Self-Taught vs Cohort Mode

- **Self-taught:** README.md is the canonical artifact; `verify/` provides
  the only feedback loop. Step language MUST be unambiguous and complete.
- **Cohort:** the chapter's instructor guide (master §8.6) MUST link each
  exercise and provide timing, common-mistakes notes, and discussion
  prompts. The `solution/` directory is instructor-only.

## 16. Quality Gates

A pack MUST pass every MUST gate before shipping; on failure the generator
regenerates and logs the reason in `CHANGELOG.md`.

### MUST gates
- [ ] ≥ 3 exercises with one of each of the three stages (§6.1).
- [ ] Pack total `time_box_minutes` ≥ 60 % of chapter total (§4); SHOULD be in [25, 40].
- [ ] Independent difficulty curve 1 easy → ≥ 1 medium → ≥ 1 hard (§6.3).
- [ ] Bloom coverage ≥ 3 tiers, ≥ 1 at Apply+, ≥ 1 at Analyze/Evaluate/Create (§6.4).
- [ ] ≥ 1 debugging/diagnosis exercise at Analyze (§6.4).
- [ ] Every exercise ships `README.md`, `starter/`, `solution/`,
      `verify/`, `rubric.json`, `failure-modes.md` (worked-example uses
      `solution/` + `walkthrough.md` instead of `starter/`).
- [ ] Every exercise documents ≥ 2 failure modes (§7.10).
- [ ] `verify/` passes against `solution/` for every exercise (§16.5 master).
- [ ] `preflight.sh` succeeds against the lab environment (§16.5 master).
- [ ] All scenarios drawn from `personalization-plan.json` (§12).
- [ ] WCAG 2.2 AA: alt text, color-independence, code-as-text (§14, master §13).
- [ ] Every rubric matches master §9.6 (4 criteria, weights = 1.0,
      `passing_average` = 3.0).
- [ ] When `target_track = both`, novice and practiced branches both ship.

### SHOULD gates
- [ ] `estimated_completion_rate` ∈ [0.40, 0.95] for every independent.
- [ ] Pack reading level matches §15.3 master target.

## 17. Anti-Patterns (FORBIDDEN)

- Happy-path-only labs (master §17).
- Worked example placed in an appendix or after the first independent.
- Step instructions in passive voice or hedged language
  ("the learner should attempt to query"). Use plain imperatives ("Query
  the table.").
- Exercises whose only output is "your code works" with no `verify/`.
- Exercises that test three skills at once when the LO is one skill.
- Exercises that introduce a new domain example mid-chapter.
- Stretch goals counted inside the 20–40 min pack budget.
- Identical exercises for novice and practiced tracks (expertise-reversal
  violation, master §7.8).

