---
title: Course Factory — Chapter Text (Document) Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: GreatTextSpec.md
implements: GreatCourseSpec_v2.md §8.1 (Chapter Document schema), §7.3
            (cognitive load), §7.4 (Mayer pre-training, modality), §7.5
            (retrieval), §7.6 (spacing), §7.7 (worked → completion →
            independent), §7.10 (failure-first), §7.11 (metacognition),
            §7.15 (coherence across artifacts), §10 (personalization),
            §12.3 (documentation), §13 (accessibility & localization),
            §15 (style guide), §16 (quality gates)
skill_target: ChapterTextGeneratorSkill
scope: |
  Defines the contract for the per-chapter Text artifact — the canonical
  chapter document the learner reads. The chapter text is the PRIMARY
  artifact for self-taught learners and the SEED for every other per-chapter
  artifact (exercises, slides, quiz, podcast); the orchestrator generates
  the text first and passes its outline, running example, glossary delta,
  and pitfalls list to the downstream artifact generators.
conformance_language: RFC 2119
canonical_term_note: |
  "Text", "chapter doc", "chapter document", and "chapter markdown/docx"
  all refer to this artifact. The canonical term is **Chapter Text**;
  the filename uses the `--doc` artifact suffix per master §5.2.
---

# Chapter Text Specification (v2)

## 1. Purpose

Generate one Chapter Text per chapter
(`{course_slug}--ch{NN}--{chapter_slug}--doc.md` or `.docx`) that:

- Carries the chapter's full conceptual content and worked example.
- Is sufficient on its own for self-taught learners (master §1, mode
  `self_taught`).
- Provides the seed material (outline, running example, glossary delta,
  pitfalls, retrieval checkpoints) every downstream per-chapter generator
  reads.

The Chapter Text is the **first** artifact generated per chapter; all
other chapter artifacts (exercise pack, slide deck, quiz, podcast,
companion files) are produced from it (master §19.3).

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§8.1 (Chapter Document)** plus the
  cross-cutting pedagogy and quality sections listed in the front-matter.
- On any conflict with the master spec, the master wins.

## 3. Input Contract

The ChapterTextGeneratorSkill receives the common envelope defined in
master §19.2 plus text-specific inputs:

```yaml
common_inputs:
  course_slug, chapter, learning_outcomes[], problem_spec,
  student_context, personalization_plan, canonical_references[],
  mode_targets, numeric_overrides, output_paths,
  quality_gates_to_satisfy[]

text_specific_inputs:
  prior_chapter_summary:     <2-sentence digest of chapter N-1 — drives the §7.6 recap>
  prior_chapter_glossary:    <cumulative glossary state — what terms the learner already owns>
  course_running_arc:        <how this chapter's running example fits the course-wide architecture evolution>
  forbidden_examples:        <Problem-Spec scenarios reserved for the capstone (master §19.4 unseen-scenario invariant)>
  brand_assets:              <optional: typography tokens, color palette, template>
```

The ChapterTextGeneratorSkill MUST NOT consume any
`representative_scenarios[]` entry listed in `forbidden_examples`; doing
so would burn the capstone's unseen scenario (master §9.4).

## 4. Output Contract

```
chapters/ch{NN}-{chapter_slug}/
  {course_slug}--ch{NN}--{chapter_slug}--doc.md           # primary
  {course_slug}--ch{NN}--{chapter_slug}--doc.docx         # OPTIONAL parallel export
  {course_slug}--ch{NN}--{chapter_slug}--doc.handoff.json # see §5
  {course_slug}--ch{NN}--{chapter_slug}--diagrams/
    <name>.mmd   |   <name>.drawio       # diagram source (master §12.2)
    <name>.svg                            # exported visual
```

### 4.1 Format

- The canonical format is **Markdown** (`.md`) with YAML front-matter.
- A `.docx` export MAY be emitted in parallel when the
  Orchestration Spec sets `output.docx_parallel = true`; the two MUST be
  semantically identical.
- All diagrams MUST ship as **source + SVG** (master §12.2). Diagrams
  embedded in the doc MUST reference the SVG, never a rasterized image.

### 4.2 Naming

Filenames MUST follow master §5.2: `{course_slug}--ch{NN}--{chapter_slug}--doc.{ext}`.

## 5. Handoff Manifest (`*--doc.handoff.json`)

The ChapterTextGeneratorSkill MUST emit a sibling JSON file that
downstream generators consume. This handoff is the explicit interface
the orchestrator uses to enforce master §19.4's single-running-example
invariant.

```yaml
chapter:               { number, slug, title, est_minutes }
learning_outcome_refs: [LO-{NN}.{n}, ...]
section_outline:                # ordered, matches §6 below
  - id: "1"   ; heading ; bloom_tag ; est_minutes
  - id: "2.1" ; heading ; bloom_tag ; est_minutes
  - ...
running_example:                # the chapter's canonical scenario
  scenario_ref: problem_spec.representative_scenarios[<i>]
  entities:    [<from personalization-plan>]
  artifacts:   [<files/data the example touches>]
worked_example_seed:             # the doc's §7 worked example, in extractable form
  problem_statement, given_state, solution_steps[], final_state, decision_points[]
glossary_delta:                  # terms first defined in this chapter
  - term, definition, locale_translations{}
chapter_pitfalls:                # misconceptions surfaced in §10 of the doc
  - misconception, why_wrong, correction
retrieval_checkpoints:           # ≥3 prompts embedded in the doc
  - section_id, prompt, target_lo_ref
reflection_prompts:              # the 3 end-of-chapter prompts (§7.11)
  - prompt
diagrams:
  - name, source_path, svg_path, alt_text, type: c4 | sequence | er | other
quiz_seed:                       # surfacing material the QuizGenerator uses
  candidate_misconceptions[]:    # feed §9.8 distractor rules
  candidate_scenarios[]:         # for scenario_mcq stems
reading_metrics:
  word_count: <int>
  flesch_kincaid_grade: <float>
```

## 6. Required Body Structure (REQUIRED, in this order)

The Chapter Text MUST contain these 15 sections in order. This
mirrors master §8.1; the present spec adds operational rules.

```
0.  Front-matter (yaml)               # see §7
1.  Prior-Chapter Recap               # §8.1
2.  Learning Outcomes                 # §8.2
3.  Prerequisites                     # §8.3
4.  Vocabulary & Mental Model         # §8.4 (pre-training, master §7.4)
5.  Concept Sections                  # §8.5 (one or more)
6.  Worked Example                    # §8.6 (from Problem Spec)
7.  Completion Problem Lead-in        # §8.7 (pointer into exercise pack)
8.  Independent Exercise(s) Pointer   # §8.8 (pointer into exercise pack)
9.  Common Pitfalls                   # §8.9 (failure-first, master §7.10)
10. Cheat Sheet (preview)             # §8.10
11. Retrieval Checkpoints (recap)     # §8.11 (the in-flow ones live inside concept sections)
12. Reflection Prompts                # §8.12 (master §7.11)
13. Glossary Delta                    # §8.13
14. Further Reading                   # §8.14
```

## 7. Front-Matter (REQUIRED)

```yaml
---
course_slug:           <string>
chapter:               { number, slug, title }
version:               <semver>
edition_date:          <YYYY-MM-DD>
locale:                <BCP-47>
target_level:          intro | intermediate | advanced
target_track:          novice | practiced | universal      # master §7.8
est_minutes:           <int ≤ 60>                          # master §6
hands_on_minutes:      <int ≥ 0.6 * est_minutes>           # master §7.14
word_count_target:     2500..4500                          # master §8.1
flesch_kincaid_cap:    <8 | 10 | 12>                       # per master §11 by age
learning_outcome_refs: [LO-{NN}.{n}, ...]
prerequisites:         { prior_chapters: [...], topics: [...] }
running_example_ref:   problem_spec.representative_scenarios[<i>]
tool_versions:         { <tool>: <pinned version> }
last_validated:        <YYYY-MM-DD>
license:               <SPDX id>
---
```

## 8. Section-by-Section Rules

### 8.1 Prior-Chapter Recap
- REQUIRED for every chapter except ch01.
- 60–120 words.
- MUST be framed as a **retrieval cue**, not a summary (master §7.5):
  pose 2 questions or fill-in-the-blank prompts, then reveal the answers.

### 8.2 Learning Outcomes
- Each outcome MUST start with a Bloom verb from master §9.1.
- Each outcome MUST carry an `LO-{NN}.{n}` ID.
- Each outcome MUST be observable (no "understand", no "appreciate").

### 8.3 Prerequisites
- Lists chapters and topics; MUST link to the prereq diagnostic
  (master §9.5) when relevant.

### 8.4 Vocabulary & Mental Model (Pre-Training, master §7.4)
- REQUIRED at the start of every chapter.
- Introduces every new term that appears in §5–§9 of the body.
- ≤ 7 new terms per chapter; if more, the chapter MUST be split (master §6).
- Each term MUST link to `glossary_delta`.
- Includes one **mental-model figure** (C4 / sequence / ER per master §12.2)
  showing how the new components relate. Alt text REQUIRED.

### 8.5 Concept Sections
- Each section presents **one core concept**.
- A single concept section MUST NOT introduce more than **4 novel
  elements** at once (master §7.3); beyond 4, split into adjacent
  sub-sections.
- Each concept section MUST embed **≥ 1 self-explanation prompt**
  (master §7.11) and accumulate to **≥ 3 retrieval checkpoints** across
  the chapter (master §7.5). Each prompt MUST list `target_lo_ref`.
- Each section MUST be tagged with its dominant Bloom tier in the
  source (HTML comment or front-matter cross-reference).

### 8.6 Worked Example (master §7.7)
- Drawn from the chapter's `running_example` (single instance, used in
  doc + slides + exercises + quiz + podcast — master §7.15).
- Fully solved end-to-end.
- MUST surface **at least 3 decision points** ("here we chose X over Y
  because…").
- MUST show inputs, outputs, and **one failure mode** (master §14.2 for
  code samples; master §7.10 for narrative).

### 8.7 Completion Problem Lead-in
- A 1-paragraph hand-off that points at the completion-stage exercise in
  the chapter's exercise pack.
- MUST NOT duplicate the full exercise content (lives in the pack per
  `GreatModuleExercise_v2 §6.1`).

### 8.8 Independent Exercise(s) Pointer
- Lists the independent exercises by filename + 1-line summary.
- The doc MUST cue but MUST NOT inline the independent solution.

### 8.9 Common Pitfalls (Failure-First, master §7.10)
- ≥ 2 documented pitfalls per chapter.
- Each pitfall MUST contain: the misconception, why it's wrong, the
  correct frame, and a 1-line diagnostic the learner can run.
- These pitfalls feed `chapter_pitfalls` in the handoff and serve as raw
  material for QuizGenerator distractors (master §9.8).

### 8.10 Cheat Sheet (Preview)
- 5–10 line distilled reference: commands, signatures, decision rules.
- The full cheat sheet is a sibling artifact owned by CourseGeneratorSkill
  (master §8.6); this section is the inline preview.

### 8.11 Retrieval Checkpoints (Recap)
- A final 60–120 word retrieval block restating the chapter's key
  questions.
- This is **distinct from** the in-flow checkpoints embedded in §8.5;
  both are required (master §7.5 demands ≥ 3 total).

### 8.12 Reflection Prompts (master §7.11)
- Exactly 3 prompts:
  1. What was hardest?
  2. Where did your mental model change?
  3. What would you do differently next time?
- Open-ended; not graded.

### 8.13 Glossary Delta
- Lists terms first defined this chapter with their definitions.
- Locale translations REQUIRED when `student_context.primary_language ≠ en`
  (master §11).

### 8.14 Further Reading
- 2–5 citations drawn from `canonical_references[]` in the Subject Spec.
- Citation format `Author (Year). Title. URL.` (master §15.5).

## 9. Pedagogy Operationalized

| Master Principle | Text-Level Rule |
|---|---|
| §7.3 Cognitive load | ≤ 7 new terms / chapter; ≤ 4 novel elements per concept section; chunk beyond. |
| §7.4 Mayer pre-training | §8.4 Vocabulary & Mental Model is REQUIRED before any concept section. |
| §7.4 Mayer redundancy | Doc prose MUST NOT be duplicated verbatim by slides or podcast (master §17). |
| §7.5 Retrieval practice | ≥ 3 retrieval checkpoints (in-flow + final), each with `target_lo_ref`. |
| §7.6 Spacing | §8.1 Prior-Chapter Recap is REQUIRED (ch ≥ 2). |
| §7.7 Worked → completion → independent | §8.6 hosts the worked example; §8.7–§8.8 cue the other two stages in the exercise pack. |
| §7.10 Failure-first | §8.9 ≥ 2 documented pitfalls. |
| §7.11 Metacognition | Self-explanation prompt in every concept section + 3 reflection prompts at end. |
| §7.15 Coherence | Single running example, traced via `running_example` in the handoff. |
| §10 Personalization | All examples, scenarios, and vocabulary drawn from `personalization-plan.json`. |
| §12.3 Documentation | Consistent terminology (glossary is single source); beginner / advanced separated via collapsibles, never interleaved inline. |

## 10. Personalization (master §10)

- The worked example, common-pitfalls scenarios, and any in-flow code
  samples MUST instantiate one `problem_spec.representative_scenarios[]`
  entry through `personalization-plan.json`.
- Generic placeholders ("a user", "an item") MUST be replaced with the
  domain terms from `vocabulary_substitutions`.
- The chapter MUST NOT consume any scenario listed in
  `forbidden_examples` (the orchestrator's capstone reserve, master §19.4).
- At most **one** clearly-labeled "out-of-domain illustration" is allowed
  per chapter (master §10.2). It MUST NOT replace the in-domain worked
  example.

## 11. Audience Adaptation (master §11)

- Flesch-Kincaid cap chosen per `age_range` in front-matter
  (8 / 10 / 12).
- Glossary delta translated when `primary_language ≠ en`.
- When `accessibility_needs[dyslexia]` is set, the text MUST use a
  sans-serif body, ≥ 1.5 line height, left-aligned paragraphs.
- When `target_track ∈ {novice, practiced}`, the text emits both
  branches via collapsible "Practiced track" sidebars; the novice
  reading is the default flow.

## 12. Visual & Information Design (master §12.3)

- Consistent terminology — every defined term used identically across
  the chapter and matching the course glossary.
- Use of headings: `#` for chapter title (single, h1), `##` for body
  sections (§1–§14), `###` for sub-sections within a concept.
- Code blocks fenced with language identifier; runnable as-is per
  master §14.2.
- Tables for comparisons and decision matrices; not for layout.
- Diagrams embedded as SVG; source committed alongside; alt text
  REQUIRED on every figure.
- Lists capped at 7 items; longer lists MUST become tables or split.

## 13. Accessibility (master §13.1)

- All artifacts conform to WCAG 2.2 AA.
- Every figure ships with alt text describing both shapes and
  relationships.
- Code samples are plain text, never images.
- No information MUST be conveyed by color alone.
- Body MUST be readable at 100 % zoom in a 1024-wide viewport without
  horizontal scrolling.
- Headings form a valid outline (no skipped levels).

## 14. Mode Adaptation

- **Self-taught:** The Chapter Text is the canonical artifact.
  Sentences MUST be unambiguous; references to "I" or "we" MUST be
  avoided; second-person ("you") is the default voice (master §15.2).
  The text MUST be sufficient without the slide deck or instructor
  guide.
- **Cohort:** The text serves as the take-home reference. Speaker-notes
  in the slide deck and the instructor guide carry the cohort-only
  content; the text MUST NOT contain trainer-only material.

## 15. Quality Gates

The Chapter Text MUST pass every MUST gate before shipping; on failure
the generator regenerates and logs the reason in `CHANGELOG.md`.

### MUST gates
- [ ] Word count ∈ [2,500, 4,500] (master §8.1).
- [ ] All 14 body sections (§6) present in the required order.
- [ ] Front-matter contains all fields listed in §7.
- [ ] Every learning outcome uses a Bloom verb from master §9.1 and
      carries an LO-ID.
- [ ] ≥ 3 retrieval checkpoints (in-flow + recap) with `target_lo_ref`.
- [ ] Vocabulary & Mental Model section appears before any concept
      section and introduces every new term used downstream.
- [ ] ≤ 7 new terms introduced; if more, chapter is split (master §6).
- [ ] No concept section introduces > 4 novel elements at once.
- [ ] §8.6 Worked Example exposes ≥ 3 decision points and shows ≥ 1
      failure mode.
- [ ] §8.9 Common Pitfalls lists ≥ 2 misconceptions with the four
      required fields (misconception, why wrong, correct frame,
      diagnostic).
- [ ] Exactly 3 reflection prompts at end (§8.12).
- [ ] Glossary delta entries include locale translation when
      `primary_language ≠ en`.
- [ ] All examples and scenarios trace to `personalization-plan.json`;
      no `forbidden_examples` scenario is used.
- [ ] Every diagram ships with source + SVG + alt text and ≥ 4.5:1
      contrast.
- [ ] WCAG 2.2 AA: alt text, color-independence, code-as-text, valid
      heading outline.
- [ ] Filename and folder layout match master §5.2.
- [ ] `*--doc.handoff.json` exists and is internally consistent with the
      doc body.
- [ ] Reading level ≤ `flesch_kincaid_cap`.
- [ ] Doc prose is NOT a verbatim copy of any slide-deck or podcast text
      from this chapter (master §17 anti-pattern, checked against the
      sibling artifacts after they are generated).

### SHOULD gates
- [ ] Hands-on cues in §8.7 / §8.8 point at exercises that satisfy
      master §7.14 (≥ 60 % hands-on share).
- [ ] Sections are time-boxed in the section outline and sum to
      `est_minutes`.

## 16. Anti-Patterns (FORBIDDEN)

- A chapter with no Prior-Chapter Recap (ch ≥ 2).
- A chapter that skips the Vocabulary & Mental Model section and
  introduces terms in context only.
- Concept sections that present more than 4 novel elements at once
  without chunking or progressive disclosure.
- Worked examples that show only the happy path (no failure mode).
- Pitfalls written as "tips" instead of named misconceptions.
- "Critical thinking" or "creativity" claimed without a corresponding
  reflection prompt or open-ended exercise pointer.
- Doc prose duplicated verbatim by the slide deck or podcast (master
  §17, §7.4 redundancy).
- Using a Problem-Spec scenario listed in `forbidden_examples`
  (defeats the capstone's unseen-scenario invariant, master §19.4).
- Diagrams embedded as raster images, or diagrams without alt text.
- Decorative imagery, mascots, or off-topic anecdotes (master §17,
  Mayer coherence).
- Sections out of order or missing.
- Mixing trainer-only content (timing markers, "ask the room…") into
  the text — that lives in the slide notes / instructor guide.

