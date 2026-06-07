---
title: Course Factory — Capstone Lab Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: GreatLabSpec.md
implements: GreatCourseSpec_v2.md §9.4 (Capstone), §7.6 (interleaving), §7.7
            (worked → completion → independent), §7.10 (failure-first),
            §7.11 (reflection), §14 (lab environment), §16 (quality gates)
skill_target: LabGeneratorSkill   # course-level
scope: |
  Defines the contract for the **Capstone Lab** — the single course-level,
  integrative practical that ships once per course. The Capstone Lab is
  distinct from the per-chapter Exercise Pack defined in
  GreatModuleExercise_v2.md (which carries each chapter's hands-on share).
  Where the original "GreatLabSpec.md" was ambiguous about scope, this v2
  fixes it as the course-level capstone (1–3 hours, integrates ≥ 60 % of
  chapters, ungraded scenario unseen by the learner).
conformance_language: RFC 2119
canonical_term_note: |
  In this spec, "Lab" = "Capstone Lab" (course-level). Per-chapter
  hands-on units are called **Exercises** and are governed by
  GreatModuleExercise_v2.md. The two artifacts share an environment,
  diverge on duration, rubric, and integration scope.
---

# Capstone Lab Specification (v2)

## 1. Purpose

Generate the course-level Capstone Lab: a 1–3 hour integrative practical
that asks the learner to solve a previously-unseen scenario from the
Problem Spec, drawing on outcomes from **≥ 60 % of the course's chapters**.

The Capstone Lab is the primary site where learners reach **Bloom's Apply
and Create tiers** (master §9.4) and where transfer is demonstrated, not
just within-chapter mastery.

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§9.4 (Capstone rubric), §7.6 (interleaving),
  §7.7 (worked → completion → independent), §7.10 (failure-first), §7.11
  (reflection), §7.14 (hands-on ratio), §10 (personalization), §13
  (accessibility), §14 (lab environment), §16 (quality gates)**.
- On any conflict with the master spec, the master wins.

## 3. Input Contract

```yaml
common_inputs:
  course_slug, learning_outcomes[], problem_spec, student_context,
  personalization_plan, mode_targets, output_paths,
  quality_gates_to_satisfy[], numeric_overrides

capstone_specific_inputs:
  chapter_index:              <ordered list of all chapters with LO IDs, titles, slugs>
  chapters_to_interleave[]:   <subset, MUST cover ≥ 60 % of chapters>
  unseen_scenario:            <one entry from problem_spec.representative_scenarios[]
                               that has NOT been used in any per-chapter exercise>
  lab_environment_manifest:   <master §14 object, course-wide>
  duration_minutes_target:    <int, 60..180; default 120>
  capstone_rubric_schema:     <master §9.4 reference>
```

The unseen-scenario invariant is REQUIRED: the orchestrator MUST track
which scenarios have been used per-chapter and reserve at least one for the
capstone. If no unseen scenario remains, the orchestrator MUST request the
Problem Spec be expanded before the capstone is generated.

## 4. Output Contract

```
capstone/
  README.md                        # entry point + nav
  capstone-brief.md                # §6 below
  capstone-rubric.json             # 6-criterion rubric, §9.4 schema
  capstone-starter/                # TODO-marked scaffold
  capstone-solution/               # instructor-only canonical solution
  capstone-verify/                 # public + hidden tests + expected outputs
  capstone-failure-modes.md        # ≥ 3 documented failure modes
  capstone-instructor-guide.md     # timing, demo notes, common mistakes
  capstone-debrief.md              # reflection prompts + self-scoring sheet
  capstone-environment/            # delta from course environment, if any
    preflight.sh / preflight.ps1
    reset.sh
```

### 4.1 Naming
All filenames MUST follow master §5.2:
`capstone-{artifact}.{ext}`.

## 5. Time Budget

- Total time MUST be **60–180 minutes**, computed as the sum of section
  `time_box_minutes`.
- Each section MUST be **≤ 30 min** to keep the lab interruptible.
- Time spent on `preflight.sh` MUST NOT be counted in the lab's time
  budget (it is environment setup).
- Optional stretch goals MUST be time-boxed separately and MUST NOT count
  toward the 60–180 min total.

## 6. Required Structure of `capstone-brief.md`

```
1.  Front-matter (yaml)
        course_slug, version, edition_date, locale, est_minutes,
        learning_outcome_refs[], chapters_covered[], tool_versions
2.  Business Motivation
        Drawn from problem_spec.summary; explains why this matters in the
        learner's domain.
3.  Learning Outcomes
        Explicit LO IDs from ≥ 60 % of chapters (master §7.6 interleaving).
        Each LO labeled with its source chapter and Bloom tier.
4.  Prerequisites & Preflight
        Required prior chapters, preflight check, environment activation
        command.
5.  Environment & Pinned Tools
        Reference to master §14 environment; any delta declared here.
6.  Scenario
        The unseen Problem-Spec scenario. Includes inputs, constraints,
        and acceptance criteria (drawn from problem_spec.success_criteria).
7.  Architecture Overview
        Diagram (C4 / sequence / ER per master §12.2) + alt text +
        Mermaid/drawio source committed alongside.
8.  Section-by-Section Plan
        Sections labeled S1..SN, each with:
        - title
        - time_box_minutes
        - stage: worked_example | completion | independent
        - LO references
        - acceptance criterion
        - link into capstone-verify/
9.  Steps
        Each step contains:
        - imperative action verb
        - command or code block (idiomatic, linted, pinned versions)
        - expected output
        - verification command
        - LO reference
        Step language MUST be unambiguous and complete (no "the learner
        should attempt to…").
10. Failure Modes & Debugging
        ≥ 3 documented failure modes per master §7.10 (capstone scope is
        stricter than chapter exercises' ≥ 2). Each entry includes broken
        state, expected error message, diagnostic procedure, fix.
11. Validation
        How capstone-verify/ runs end-to-end; pass/fail criteria.
12. Rubric Self-Score Sheet
        Mirrors capstone-rubric.json so the learner can self-assess
        before submitting.
13. Debrief
        3 reflection prompts (master §7.11) and a "what would you do
        differently in production?" prompt for transfer.
14. Stretch Goals
        Optional, time-boxed separately.
```

## 7. Pedagogy Operationalized

### 7.1 Interleaving (master §7.6)
The capstone MUST integrate **≥ 60 %** of chapters. Each section in
`capstone-brief.md §8` MUST declare which chapter's LOs it exercises; the
orchestrator MUST validate the union of those references covers ≥ 60 %
of the chapter index.

### 7.2 Worked → Completion → Independent (master §7.7)
Across the capstone's section sequence, the **first section** SHOULD be a
narrated worked-example showing the architectural shape of the solution;
**intermediate sections** SHOULD be completion problems (`starter/`
scaffolds with TODO blocks); **final sections** MUST be independent
(brief + tests only).

### 7.3 Failure-First (master §7.10)
The capstone MUST document **≥ 3 failure modes**, distributed across
sections — not all clustered at the end.

### 7.4 Reflection / Metacognition (master §7.11)
`capstone-debrief.md` MUST contain:
- 3 reflection prompts.
- 1 transfer prompt ("how would you adapt this for a different
  scale / regulatory regime / team size?").
- The 6-criterion rubric self-score sheet.

### 7.5 Bloom Reach (master §9.4)
The capstone MUST contain explicit tasks at:
- **Apply** (use, implement, configure)
- **Analyze** (debug, attribute, organize)
- **Create** (compose, design, build)

A capstone that never reaches **Create** does not satisfy master §9.4.

## 8. Capstone Rubric (`capstone-rubric.json`)

The rubric MUST match master §9.4 exactly. Each criterion is scored
1–4 with descriptors; passing average is **≥ 3.0**.

```json
{
  "criteria": [
    { "id": "correctness",   "weight": 0.25, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "approach",      "weight": 0.20, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "code_quality",  "weight": 0.20, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "communication", "weight": 0.15, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "domain_fit",    "weight": 0.10, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "reflection",    "weight": 0.10, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } }
  ],
  "passing_average": 3.0
}
```

## 9. Lab Environment (master §14)

- The Capstone Lab MUST run inside the course-wide environment. Any
  capstone-specific tooling deltas MUST live under
  `capstone-environment/` and MUST not break per-chapter exercises.
- `preflight.sh` / `preflight.ps1` MUST verify tool versions, network,
  and credentials; it MUST pass before Section 1.
- `reset.sh` MUST restore a clean state without manual cleanup.
- `capstone-verify/` MUST pass when run against `capstone-solution/`
  (master §16.5).
- All code MUST be pinned to validated versions and pass the canonical
  formatter + linter at defaults (master §14.2).

## 10. Personalization (master §10)

- The capstone scenario MUST instantiate an **unseen**
  `problem_spec.representative_scenarios[]` entry via
  `personalization-plan.json` substitutions.
- All terminology MUST match the course glossary
  (`<course_root>/glossary.md`, master §5.1).
- The capstone MUST NOT introduce a new domain not represented in the
  Problem Spec.

## 11. Audience Adaptation (master §11)

- When `target_level ∈ {intermediate, advanced}`, the capstone MUST emit
  novice and practiced tracks (master §7.8). The practiced track removes
  worked-example sections and tightens scaffolding.
- Accessibility needs in the Student Context Spec MUST be honored
  (see §13).

## 12. Mode Adaptation

- **Self-taught**: `capstone-brief.md` is the canonical artifact and MUST
  be sufficient for a learner to complete the lab without an instructor.
  `capstone-verify/` provides the only feedback signal, supplemented by
  `capstone-debrief.md`'s self-scoring sheet.
- **Cohort**: `capstone-instructor-guide.md` MUST include section
  timings, common-mistakes notes, discussion prompts, and a
  demo-walkthrough script. `capstone-solution/` is instructor-only.

## 13. Accessibility (master §13.1)

- All artifacts MUST conform to WCAG 2.2 AA.
- Every diagram MUST have alt text; code MUST be plain text not images;
  no information MUST be conveyed by color alone.
- Step lists MUST be screen-reader-safe.

## 14. Quality Gates

The capstone MUST pass every MUST gate; on failure the generator
regenerates and logs the reason in `CHANGELOG.md`.

### MUST gates
- [ ] Total time `∈ [60, 180]` min; every section `≤ 30` min.
- [ ] Scenario is an unseen `problem_spec.representative_scenarios[]`
      entry.
- [ ] Integrates ≥ 60 % of chapters; section LO refs cover that set.
- [ ] Explicit tasks at Apply, Analyze, and Create tiers (§7.5).
- [ ] Worked → completion → independent progression (§7.2).
- [ ] ≥ 3 documented failure modes distributed across sections (§7.3).
- [ ] Every step declares action, command, expected output, verification,
      LO reference.
- [ ] `capstone-rubric.json` matches the 6-criterion schema in §8 exactly.
- [ ] `capstone-debrief.md` contains 3 reflection prompts + 1 transfer
      prompt + the rubric self-score sheet (§7.4).
- [ ] `capstone-verify/` passes against `capstone-solution/`.
- [ ] `preflight.sh` succeeds against the lab environment.
- [ ] Code passes canonical formatter and linter at defaults.
- [ ] All scenarios, terms, and visuals trace to
      `personalization-plan.json` and the course glossary.
- [ ] WCAG 2.2 AA: alt text, color-independence, code-as-text.
- [ ] Filenames match master §5.2.

### SHOULD gates
- [ ] Capstone reading level matches §15.3 master target for the cohort.
- [ ] Capstone fits inside the learner's `time_budget_per_week` over a
      single sitting or two.

## 15. Anti-Patterns (FORBIDDEN)

- A "lab" that is really a long lecture with a single hands-on at the end.
- Capstones that only re-test the final chapter rather than interleaving
  (violates master §7.6 and §9.4).
- Step instructions in passive voice or hedged language.
- Happy-path-only execution (no failure modes).
- Capstones whose only output is "your code works" with no rubric
  scoring.
- A 6-criterion rubric whose weights do not sum to 1.0.
- Use of a scenario the learner has already seen in a chapter exercise
  (defeats transfer assessment).
- Stretch goals counted inside the 60–180 min budget.
- Single-track capstones for an intermediate/advanced course (expertise-
  reversal violation, master §7.8).

