---
title: Course Factory — Chapter Quiz Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: GreatQuizSpec.md
implements: GreatCourseSpec_v2.md §9 (Assessment Framework)
skill_target: QuizGeneratorSkill
scope: |
  Defines the contract for the per-chapter Quiz artifact (`*--quiz.json`).
  This document is subordinate to GreatCourseSpec_v2.md (the master).
  On any conflict, the master spec wins; numeric defaults may be overridden
  only via the Orchestration Spec's `numeric_overrides.quiz` block, which MUST
  be logged in `CHANGELOG.md`.
conformance_language: RFC 2119
---

# Chapter Quiz Specification (v2)

## 1. Purpose

Generate one chapter quiz per chapter (`{course_slug}--ch{NN}--{chapter_slug}--quiz.json`)
that:

- Verifies the chapter's learning outcomes through retrieval and transfer.
- Embeds spaced retrieval by including carry-forward items from prior chapters.
- Ships with answer keys, rationales, and remediation links so it teaches as
  well as assesses.

Quizzes implement the assessment design in **GreatCourseSpec_v2.md §9** and
embody the retrieval-practice principle (Roediger & Karpicke) operationalized
in master §7.5.

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§9**. On any conflict, master wins.
- Numeric defaults below MAY be overridden only through the Orchestration
  Spec's `numeric_overrides.quiz` block. Overrides MUST be logged in
  `CHANGELOG.md`.

## 3. Input Contract

The QuizGeneratorSkill receives the common envelope defined in master §19.2
plus quiz-specific inputs:

```yaml
common_inputs:
  course_slug: <string>
  chapter:        { number, slug, title, est_minutes, prerequisites[] }
  learning_outcomes[]: [ { id: LO-NN.n, verb, object, criterion, bloom_level } ]
  problem_spec:        <full master §3.2 object>
  student_context:     <full master §3.3 object>
  personalization_plan: <master §10 object>
  mode_targets:        [self_taught, cohort]
  output_paths:        { primary, sidecars[] }
  quality_gates_to_satisfy[]: <subset of master §16>
  numeric_overrides:   <optional, see §5 below>

quiz_specific_inputs:
  chapter_doc_outline:        <list of section IDs + Bloom tags>
  chapter_pitfalls:           <list of misconceptions surfaced in the chapter doc>
  prior_chapter_quiz_items:   <items from chapter N-1 and one earlier chapter
                               for carry-forward sourcing per §6.2>
  bloom_distribution_target:  <map per §6.1; defaults to master §9.2>
  item_count_target:          <int; default 10 + 2 carry-forward>
  passing_threshold:          <float; default 0.80>
```

If `prior_chapter_quiz_items` is empty (chapter 1), the generator MUST emit
the **graded items only** (no carry-forward), and the Form-A/Form-B
requirement (§6.4) still applies.

## 4. Output Contract

The skill MUST emit **two parallel forms per chapter**:

```
chapters/ch{NN}-{slug}/
  {course_slug}--ch{NN}--{slug}--quiz.json       # Form A (default form)
  {course_slug}--ch{NN}--{slug}--quiz-formB.json # Form B (used by retry policy, §9.3 master)
```

The two forms MUST:

- Target the **same Learning Outcomes** in the same Bloom distribution.
- Contain **different items** (no item ID overlap; no semantic clone where
  the stem differs by surface wording only).
- Be **independently passable** at the §6.3 threshold without seeing Form A.

## 5. Numeric Defaults (Overridable)

| Setting | Default | Override key |
|---|---|---|
| Graded items per quiz | 10 | `numeric_overrides.quiz.items` |
| Carry-forward items per quiz | 2 | `numeric_overrides.quiz.carryforward` |
| Passing threshold | 0.80 | `numeric_overrides.quiz.pass` |
| Item difficulty target (p-value) | 0.40–0.95 | `numeric_overrides.quiz.difficulty_band` |
| Max correct-option position concentration | 35 % | `numeric_overrides.quiz.position_cap` |
| Forms per chapter | 2 (A, B) | `numeric_overrides.quiz.forms` |

For long-form courses (e.g. ≥ 20 chapters, like the Cowork Automation
example), the Orchestration Spec MAY reduce graded items to as few as 4 while
keeping carry-forward at 2; in that case the Bloom distribution scales to
the table in §6.1 row "compact".

## 6. Item Composition Rules

### 6.1 Bloom Distribution

Default (10 graded items):

| Bloom level | Count |
|---|---|
| Remember | 2 |
| Understand | 2 |
| Apply | 3 |
| Analyze | 2 |
| Evaluate / Create | 1 |

Compact override (4 graded items, used when chapters > 20):

| Bloom level | Count |
|---|---|
| Understand | 1 |
| Apply | 2 |
| Analyze | 1 |
| Evaluate / Create | 0–1 (interleaved across the course) |

In the compact form, the **Remember** tier MUST be carried by the in-flow
retrieval checkpoints in the chapter doc (master §7.5), not the quiz.

### 6.2 Carry-Forward Items (§7.5 master)

Every quiz (except ch01) MUST include exactly the configured number of
carry-forward items (default 2):

- **1 item** from chapter N − 1.
- **1 item** from a chapter ≤ N − 3 (longer spacing).
- Each carry-forward item MUST set `assessment_mode: carryforward` and
  `carryforward_from: <chapter_index>`.

### 6.3 Item-Type Mix

Allowed `item_type` values: `mcq`, `multi_select`, `tf_justified`,
`short_answer`, `scenario_mcq`, `error_spotting`, `code_review`.

Rules:
- Every chapter quiz MUST include **at least one `scenario_mcq`** anchored in
  a `problem_spec.representative_scenarios[]` instance.
- Across the **whole course**, the generator MUST emit **≥ 1 item of each of
  the 7 types**.
- MCQs MUST have exactly one correct option; multi-select MUST have ≥ 2.
- True/false items MUST be `tf_justified` (the learner supplies a one-sentence
  justification). Bare true/false items are FORBIDDEN.

### 6.4 Parallel Forms

Form A and Form B MUST be generated together. Form B MUST:
- Re-use the LO IDs and Bloom tags of Form A.
- Replace stems with paraphrased or alternate-scenario versions.
- Re-shuffle options independently.

### 6.5 Distractor Rules (master §9.8)

Every distractor MUST encode one of:

1. A **named misconception** drawn from `chapter_pitfalls` or general domain
   misconceptions documented in the chapter doc's "Common Pitfalls" section
   (master §8.1).
2. An **off-by-one / scope confusion** (wrong but neighboring boundary).
3. A **surface-pattern match** (looks right because it shares keywords).
4. A **previously-correct-but-now-wrong** rule (a rule the learner just
   replaced this chapter).

Throwaway distractors are FORBIDDEN. "All of the above" and "None of the
above" are FORBIDDEN.

### 6.6 Answer-Option Layout

- Option IDs are stable letters: `A`, `B`, `C`, `D` (and `E` only if needed).
- Option **order** MUST be randomized.
- Across a single chapter quiz, the position of the correct option MUST be
  balanced: no single position holds **> 35 %** of correct answers.

## 7. Difficulty Calibration

The generator MUST compute `estimated_difficulty` for every item using the
deterministic heuristic in master §9.10 and MUST flag for rewrite any item
whose computed value falls outside **0.40 – 0.95**.

## 8. Item Schema (REQUIRED — implements master §9.7)

```yaml
quiz_id: <course_slug>--ch{NN}--quiz                # or quiz-formB
form: A | B
chapter: <int>
items:
  - item_id: ch{NN}-q{NN}
    chapter: <int>
    section_ref: "<N.N>"                            # REQUIRED, non-null
    learning_outcome_ref: LO-{NN}.{n}               # REQUIRED, MUST exist in chapter
    bloom_level: Remember|Understand|Apply|Analyze|Evaluate|Create
    item_type: mcq|multi_select|tf_justified|short_answer|scenario_mcq|error_spotting|code_review
    assessment_mode: summative | carryforward
    carryforward_from: <int|null>                   # REQUIRED when mode=carryforward
    stem: "<problem-spec-grounded stem>"
    code_block:                                     # optional, for code_review / error_spotting
      language: <string>
      content:  <string>
    options:                                        # required for mcq, multi_select, scenario_mcq
      - id: A
        text: "..."
        correct: false
        misconception: "named-misconception|off-by-one|surface-pattern|previously-correct"
        rationale:    "Wrong because ..."
      - id: B
        text: "..."
        correct: true
        rationale: "Correct because ..."
    expected_answer: "<text>"                       # required for short_answer / tf_justified
    grading_rubric_ref: "<rubric.json#criterion>"   # required for short_answer
    estimated_difficulty: <0.40..0.95>              # via master §9.10 heuristic
    time_seconds: <int, typically 30..120>
    remediation_link: "<doc anchor>"                # e.g. ch{NN}--doc.md#sec-3.2
    accessibility:
      alt_text_for_figures: "<string|null>"
      screen_reader_safe: true
parallel_form_ref: <filename of the sibling form>
```

## 9. Passing & Retry

- Passing threshold = **0.80** (default; overridable per §5).
- A learner who fails MUST receive **one retry on Form B** (master §9.3).
- The retry MUST sample from the **same LO IDs the learner missed**,
  weighted toward those LOs.

## 10. Personalization (master §10)

- Every `scenario_mcq` stem MUST instantiate a
  `problem_spec.representative_scenarios[]` entry through the
  `personalization-plan.json` substitution table.
- The quiz MUST NOT introduce a new domain that does not appear elsewhere in
  the chapter (master §7.15 Coherence Across Artifacts).
- All terminology in stems and options MUST match the course glossary
  (master §5.1 `glossary.md`).

## 11. Accessibility (master §13.1)

- Every figure embedded in an item MUST ship with `alt_text_for_figures`.
- No item MUST convey meaning through color alone.
- Code blocks MUST be plain text, never images.
- Stems and options MUST be screen-reader-safe (no positional cues such as
  "the option on the right").

## 12. Pre-Assessment / Diagnostic (out of scope, but related)

The course-level **pre-assessment** (master §9.5) is generated by a separate
invocation of the QuizGeneratorSkill with `assessment_mode: diagnostic` and
an explicit `target_topics[]` (one per declared prerequisite). It is NOT a
chapter quiz; it lives at `<course_root>/prereq-diagnostic.md` and uses 8
items by default.

## 13. Quality Gates (run before shipping a quiz)

The quiz MUST pass every MUST gate; the generator MUST regenerate the quiz
on any MUST failure and log the failure in `CHANGELOG.md`.

### MUST gates
- [ ] Item count matches `item_count_target` + `carryforward` (§5).
- [ ] Bloom counts match the configured distribution (§6.1).
- [ ] Exactly `carryforward` items have `assessment_mode: carryforward` with
      a valid `carryforward_from`.
- [ ] Every item declares `learning_outcome_ref`, `section_ref`,
      `bloom_level`, `estimated_difficulty`, `time_seconds`,
      `remediation_link`.
- [ ] Every `learning_outcome_ref` exists in the chapter front-matter.
- [ ] At least one `scenario_mcq` is present and uses a Problem-Spec
      scenario (§6.3, §10).
- [ ] Every distractor has a valid `misconception` tag (§6.5).
- [ ] No item uses "All of the above" or "None of the above" (§6.5).
- [ ] `estimated_difficulty` ∈ [0.40, 0.95] for every item (§7).
- [ ] No position holds > 35 % of correct answers (§6.6).
- [ ] Form B exists, is independently passable, and shares no item IDs with
      Form A (§6.4).
- [ ] Every figure has alt text; no color-only signaling (§11).

### SHOULD gates
- [ ] Across the course's quizzes, every item type from §6.3 appears at
      least once.
- [ ] Per-item time-on-task totals within ±20 % of `chapter.est_minutes ×
      0.10` (quiz is ~10 % of chapter time).

## 14. Anti-Patterns (FORBIDDEN)

- Recognition-only quizzes that never reach Apply or above.
- Distractors that are obviously wrong, joke options, or unrelated to the
  stem.
- Quizzes whose only feedback is a score (no rationale, no remediation
  link).
- Carry-forward items that re-use the exact stem from the prior chapter
  (always paraphrase).
- Items whose correct answer is signaled by length, grammar, or position.
- Quizzes that introduce a new domain example not present in the chapter.
- Single-form quizzes (no parallel Form B).

