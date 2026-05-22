---
title: Course Factory — Chapter Slide Deck Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: GreatPresentationSpec.md
implements: GreatCourseSpec_v2.md §8.2, §12.1, §12.2, §13.1, §7.3, §7.4, §7.5, §7.11
skill_target: PresentationGeneratorSkill
scope: |
  Defines the contract for the per-chapter Slide Deck artifact
  (`*--slides.pptx`) and its sibling Speaker Notes file
  (`*--slides-notes.md`). The deck serves cohort mode primarily, but MUST
  remain useful as a standalone reference for self-taught learners when
  read alongside the speaker notes.
conformance_language: RFC 2119
canonical_term_note: |
  "Presentation" and "PowerPoint" are colloquial; the canonical artifact
  name is **Slide Deck**.
---

# Chapter Slide Deck Specification (v2)

## 1. Purpose

Generate one Slide Deck per chapter that reinforces the chapter document
without duplicating it. The deck operationalizes Mayer's multimedia
principles (master §7.4) and the visual rules in master §12.1.

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§8.2 (slide deck schema), §12.1 (visual
  design), §12.2 (diagrams), §13.1 (accessibility), §7.3 (cognitive load),
  §7.4 (Mayer), §7.5 (retrieval), §7.11 (metacognition), §10
  (personalization), §16.4 (format gates)**.
- On any conflict with the master spec, the master wins.

## 3. Input Contract

```yaml
common_inputs:
  course_slug, chapter, learning_outcomes[], problem_spec,
  student_context, personalization_plan, mode_targets,
  output_paths, quality_gates_to_satisfy[], numeric_overrides

slide_deck_specific_inputs:
  chapter_doc_outline:       <ordered section IDs + headings + Bloom tags>
  running_example:           <chapter's canonical worked example from doc §7>
  exercise_manifest:         <so the "Try this now" slide can cue a real exercise filename>
  quiz_filename:             <so the closing "Quiz Cue" slide can name the artifact>
  glossary_terms_introduced: <terms first defined in this chapter — power the pre-training slide>
  brand_assets:              <optional: logo, template, color tokens>
```

## 4. Output Contract

Per chapter, the skill MUST emit **two paired artifacts**:

```
chapters/ch{NN}-{slug}/
  {course_slug}--ch{NN}--{slug}--slides.pptx           # the deck
  {course_slug}--ch{NN}--{slug}--slides-notes.md       # speaker notes (master §8.2)
```

Both files are first-class deliverables. Neither MAY be omitted.

## 5. Size and Pacing

- Slide count: **12–25** (master §8.2). Default cadence: **~1 slide per
  3 minutes** of chapter time.
- The deck MUST embed a retrieval or self-explanation prompt slide **every
  5–7 content slides** (master §7.5, §7.11). The Title / LOs / Agenda /
  Recap / Quiz Cue slides do not count toward the 5–7 cadence.

## 6. Required Slide Order

The deck MUST follow this order. Concept slides (S6…N) MAY be expanded or
reordered; all other named slides MUST appear in the position shown.

```
S1   Title                — course title / chapter / 1-line LO summary
S2   Learning Outcomes    — Bloom-verbed LOs with LO-IDs visible
S3   Agenda               — section names with a Bloom-tier badge per section
S4   Prior-Chapter Recap  — retrieval prompt (omit on ch01)
S5   Vocabulary & Mental Model — pre-training (master §7.4)
S6…N Concept Slides       — one idea each (see §7)
S    Worked Example       — visual walkthrough from the Problem Spec
S    "Try this now"       — practice cue → exercise filename
S    Common Pitfalls      — failure-first (≥ 2 documented failure modes)
S    Recap                — retrieval cue (questions, not bullets)
SN+1 Quiz Cue / Next Up   — quiz filename + next-chapter teaser
```

Total: 12–25 slides.

## 7. Per-Slide Rules

### 7.1 One Idea per Slide
Each content slide MUST present **one core idea**. If a slide drafts with
two ideas, split it into two slides.

### 7.2 Word Budget
**≤ 40 words per slide.** Titles MUST be **conclusions, not topics**
("Questions beat answers" not "The role of questions").

### 7.3 Cognitive Load (master §7.3)
A single slide or diagram MUST NOT introduce more than **4 novel
elements** simultaneously. Beyond 4, the deck MUST use **progressive
disclosure** (animated reveals) or split into adjacent slides.

### 7.4 Diagrams (master §12.2)
- **≥ 1 diagram per 3 slides.**
- Use **C4** for architecture, **sequence** for flows, **ER** for data.
- Authored in **Mermaid** or **draw.io**; the source MUST be committed
  alongside the SVG export.
- Every diagram MUST ship with **alt text** describing both shapes and
  relationships.
- Contrast MUST be **≥ 4.5:1**. Information MUST NOT be conveyed by color
  alone.

### 7.5 Typography & Layout (master §13.1)
- Body text: **≥ 24 pt**.
- Titles: **≥ 36 pt**.
- ≤ 2 fonts in the deck.
- ≤ 4-color palette applied with consistent logic.
- One template across the deck; layouts MAY vary per slide *type* but the
  template family MUST be consistent.

### 7.6 Bloom Tag & LO Reference
Every concept slide and every worked-example slide MUST display:
- a **Bloom-tier badge** (small, top-right), and
- a **LO-ID reference** (small, bottom-right) tying the slide to a chapter
  learning outcome.

### 7.7 Lists
Lists with more than 3 items MUST use **progressive disclosure**.

### 7.8 Retrieval / Reflection Cadence
Every 5–7 concept slides, insert a slide whose body is a single retrieval
or self-explanation prompt (no answer on the slide; answer in the speaker
notes).

## 8. Speaker Notes (`*--slides-notes.md`) — REQUIRED

The speaker-notes file MUST contain one section per slide:

```
## Slide S{NN} — {short title}
**Timing:** [demo: 3 min] | [discuss: 2 min] | [click-through: 30 s]
**Bloom:** Apply
**LO ref:** LO-3.2.b

### Cohort sidebar
- Ask the room: "What happens if…"
- Likely misconception: confuses X with Y — correct it with…

### Solo sidebar
- If you're working alone, pause here and try answering the prompt in
  writing before clicking through.

### Speaker script
A short paragraph the trainer can read or paraphrase. MUST NOT duplicate
the slide body verbatim (Mayer redundancy principle).
```

Both `### Cohort sidebar` and `### Solo sidebar` MUST be present so the
deck remains useful to self-taught learners.

## 9. Mayer Principles, Operationalized

| Principle (master §7.4) | Slide-level rule |
|---|---|
| Modality | Slides reinforce speech, never replace it. Body text is a cue, not a script. |
| Redundancy | Slides MUST NOT duplicate the chapter doc's prose verbatim. |
| Signaling | Titles are conclusions; one diagram per 3 slides directs attention. |
| Segmenting | One idea per slide; ≤ 40 words. |
| Coherence | No decorative graphics, no mascots, no off-topic anecdotes (master §17). |
| Pre-training | Slide S5 introduces new terms and mental model before they appear in context. |
| Personalization | Every example, scenario, and diagram comes from `personalization-plan.json` (master §10). |

## 10. Personalization (master §10)

- All examples, diagrams, and worked-example visuals MUST instantiate
  Problem-Spec scenarios via `personalization-plan.json`.
- The deck MUST share the chapter's running example with the chapter doc,
  exercises, podcast, and quiz (master §7.15).
- Generic placeholders ("a user", "an item") MUST be replaced with the
  domain terms from `personalization-plan.json.vocabulary_substitutions`.

## 11. Audience Adaptation (master §11)

The deck adapts visually and lexically to the Student Context Spec:

- `age_range`, `primary_language` → reading-level cap (master §15.3).
- `accessibility_needs[screen-reader]` → alt text on every figure;
  no color-only meaning.
- `accessibility_needs[dyslexia]` → sans-serif body, ≥ 1.5 line height,
  left-aligned.
- `preferred_modalities[watch]` → favor diagrams over text.

## 12. Mode Adaptation

- **Cohort mode** is the primary consumer. The deck is meant to be
  projected; speaker notes carry the bulk of the trainer's content.
- **Self-taught mode**: the deck is consumed alongside speaker notes as a
  visual companion to the chapter doc. The "Solo sidebar" in every
  speaker-notes section MUST give a useful self-study direction.

## 13. Quality Gates

A deck MUST pass every MUST gate before shipping; on failure the generator
regenerates and logs the reason in `CHANGELOG.md`.

### MUST gates
- [ ] Slide count ∈ [12, 25].
- [ ] All named slides from §6 are present in the required positions.
- [ ] ≤ 40 words per slide; titles are conclusions, not topics.
- [ ] ≥ 1 diagram per 3 slides; each diagram has SVG + source +
      alt text + ≥ 4.5:1 contrast.
- [ ] Body ≥ 24 pt; titles ≥ 36 pt; ≤ 2 fonts; ≤ 4 colors.
- [ ] A retrieval/self-explanation prompt slide appears every 5–7 concept
      slides (§7.8).
- [ ] No single slide or diagram introduces > 4 novel elements (§7.3).
- [ ] Every concept slide bears a Bloom badge and LO-ID (§7.6).
- [ ] `*--slides-notes.md` exists; every slide has a notes section with
      `Timing`, `Bloom`, `LO ref`, `Cohort sidebar`, `Solo sidebar`,
      `Speaker script`.
- [ ] All examples and visuals trace to `personalization-plan.json`
      (§10); no out-of-domain examples.
- [ ] No decorative graphics, mascots, or background media (master §17).
- [ ] Slides do NOT duplicate chapter-doc prose verbatim (master §17).
- [ ] Filenames match master §5.2.

### SHOULD gates
- [ ] Cadence approximates 1 slide per 3 minutes of chapter time.
- [ ] Lists with > 3 items use progressive disclosure.

## 14. Anti-Patterns (FORBIDDEN)

- Slides that duplicate the chapter-doc narration verbatim.
- Mascots, decorative imagery, background music, or "fun" stock photos.
- "Death by bullets": > 5 bullets on a slide, all displayed at once.
- Slide titles framed as topics ("Functions in Python") instead of
  conclusions ("Functions hide complexity").
- Body text below 24 pt to fit more content. (Cut content instead.)
- A single deck without speaker notes.
- A deck that introduces an example domain not present in the chapter
  doc.
- A deck with no diagram, or with diagrams sourced as raster images.

