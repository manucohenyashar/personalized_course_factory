---
title: Course Factory — Great Course Specification
version: 2.2.0
status: draft
last_updated: 2026-05-16
supersedes: GreatCourseSpec.md
scope: |
  Master rubric for the Course Factory generator. Defines the inputs the
  generator consumes, the artifacts it produces, the pedagogy it must follow,
  and the quality gates every chapter must pass before it ships.
audience: |
  AI agents (and the humans configuring them) that auto-generate personalized
  technical training courses.
conformance_language: RFC 2119 (MUST, MUST NOT, SHOULD, SHOULD NOT, MAY)
---

# Course Factory — Great Course Specification

## 0. How to Read This Document

This is a **contract**, not a description of taste. Every sentence containing
MUST, MUST NOT, SHOULD, SHOULD NOT, or MAY is binding on the generator agent.
Adjectives like "engaging" or "professional" appear only when paired with a
measurable rule. When the generator must choose between two options, the
relevant section gives a decision rule; the generator MUST NOT invent its own.

Section ordering matters: inputs (§3) → pipeline (§4) → outputs (§5–§8) →
pedagogy and quality (§9–§17) → reference (§18–§19).

---

## 1. Purpose

Generate **personalized technical training courses** in any subject, where
personalization means the course meets students where they are by speaking in
the vocabulary of, and using examples from, the student's own problem domain.

The core pedagogical assumption is: *when training is anchored in a domain the
learner already cares about, encoding and transfer improve dramatically.*

Courses MUST work in two modes simultaneously:

- **Self-taught mode** — a learner working alone uses the chapter document,
  podcast, exercises, and quiz.
- **Cohort/trainer mode** — an instructor teaches from the slide deck plus
  instructor guide; learners follow the doc and exercises.

By the end of any generated course, learners MUST be assessable across all
six Bloom revised-taxonomy tiers (Remember → Understand → Apply → Analyze →
Evaluate → Create), with the upper tiers carried by exercises and the capstone
rather than by quizzes alone.

---

## 2. Conformance Language

The key words **MUST**, **MUST NOT**, **REQUIRED**, **SHALL**, **SHALL NOT**,
**SHOULD**, **SHOULD NOT**, **RECOMMENDED**, **MAY**, and **OPTIONAL** in this
document are to be interpreted as described in RFC 2119.

Numeric thresholds in this spec are defaults. The Orchestration Spec (§3.4)
MAY override them; if it does, the override MUST be logged in the course's
`CHANGELOG.md`.

---

## 3. Input Contracts

The generator consumes **four sibling specifications**. Each MUST declare a
`schema_version`. Missing required fields halt generation with a clear error;
the generator MUST NOT fabricate missing inputs.

### 3.1 Subject Spec  (`subject.yaml` / `subject.md`)

| Field | Req | Description |
|---|---|---|
| `subject_id` | MUST | Stable kebab-case ID. |
| `title` | MUST | Human-readable course title. |
| `domain_taxonomy` | MUST | `{field, sub_field}` (e.g., `software-engineering / distributed-systems`). |
| `target_level` | MUST | `intro` \| `intermediate` \| `advanced`. |
| `learning_outcomes[]` | MUST | Each: `{verb, object, criterion}` using a Bloom verb. |
| `chapter_partitioning[]` | SHOULD | Ordered list `{title, scope, est_minutes, prerequisites[]}`. |
| `prerequisites[]` | MUST | Topics learners must already know. |
| `canonical_references[]` | SHOULD | `{citation, url}` for further reading. |
| `currency_stamp` | MUST | `last_validated: YYYY-MM-DD` + pinned tool versions. |

If `chapter_partitioning` is omitted, the generator MUST propose a partition
(per §6) and halt for human review before producing artifacts.

**Narrative Subject Spec normalization.** If the Subject Spec is supplied
as a narrative markdown document (such as the bundled
`MainSubjectSpec-Cowork-Automation.md` example) rather than the structured
schema above, the orchestrator MUST run a **normalization pre-step** that
extracts the schema fields from the narrative and emits a derived
`subject.normalized.yaml`. The pre-step MUST:

1. Extract `subject_id`, `title`, `domain_taxonomy`, `target_level`,
   `prerequisites[]`, and a `currency_stamp` (with today's date if absent).
2. Re-express each course-level objective as a `learning_outcomes[]`
   triple `{verb, object, criterion}` using a Bloom verb from §9.1.
3. Convert each narrative chapter heading into a
   `chapter_partitioning[]` entry `{title, scope, est_minutes,
   prerequisites[]}`.
4. Halt for **human review** before any artifact is generated; emit a
   side-by-side diff (`subject.normalized.diff.md`) listing every
   inferred field and its source span in the narrative.

The normalized YAML, once human-approved, becomes the authoritative
Subject Spec for the rest of the pipeline. The narrative original
is retained for traceability in `course.manifest.json`.

### 3.2 Problem Spec  (`problem.yaml` / `problem.md`)

The student's real-world problem domain. This is the single most important
input — it is the source of every example, exercise, scenario, and quiz item.

| Field | Req | Description |
|---|---|---|
| `problem_id` | MUST | Stable ID. |
| `summary` | MUST | One-paragraph description. |
| `domain_vocabulary[]` | MUST | `{term, definition}` — the words the learner already uses. |
| `representative_scenarios[]` | MUST | ≥3 realistic situations the learner faces. |
| `success_criteria` | MUST | What "solved" looks like in their world. |
| `constraints` | SHOULD | Tech stack, regulatory, scale, budget. |
| `artifacts_to_produce` | SHOULD | What the learner will build/ship. |
| `sample_data_or_assets` | SHOULD | Real or redacted data; otherwise an acceptable substitute. |

If the Problem Spec is missing or empty, generation MUST FAIL. The generator
MUST NOT invent a problem domain.

### 3.3 Student Context Spec  (`students.yaml` / `students.md`)

| Field | Req | Description |
|---|---|---|
| `cohort_id` | MUST | Stable ID. |
| `age_range` | MUST | e.g., `25-40`. |
| `locale` | MUST | BCP-47 (e.g., `en-US`, `he-IL`, `es-MX`). |
| `primary_language` | MUST | Language of instruction. |
| `secondary_languages[]` | MAY | For glossary cross-references. |
| `prior_knowledge[]` | MUST | `{topic, level}` per relevant topic. |
| `preferred_modalities[]` | SHOULD | Subset of `{read, watch, listen, do}`. |
| `accessibility_needs[]` | SHOULD | e.g., `screen-reader`, `low-vision`, `dyslexia`. |
| `cultural_norms` | SHOULD | Object — see schema below. |
| `time_budget_per_week` | SHOULD | Hours/week available for the course. |

`cultural_norms` sub-schema:

```yaml
cultural_norms:
  formality: formal | neutral | informal
  taboo_topics: [<string>, ...]               # examples / analogies to avoid
  example_substitutions:                       # generic → culturally-fit term
    - generic: "<placeholder>"
      domain:  "<replacement>"
  preferred_metaphor_sources: [<string>, ...]  # e.g., sports, cooking, music
```

If `locale` is missing, the generator MUST default to `en-US` and log a
warning.

### 3.4 Orchestration Spec  (`orchestration.yaml`)

Defines the pipeline the generator executes.

| Field | Req | Description |
|---|---|---|
| `pipeline_steps[]` | MUST | Ordered steps with model/agent assignments. |
| `regeneration_policy` | MUST | `full` \| `chapter` \| `section`. |
| `quality_gates_to_run[]` | MUST | Subset of §16's gates. |
| `output_root` | MUST | Path template for artifacts. |
| `human_review_points[]` | SHOULD | Where to halt for human approval. |
| `numeric_overrides` | MAY | Overrides to defaults in §6, §8, §9. |

### 3.5 Contradictions Between Specs

When specs disagree, precedence is (highest first):

1. Student Context Spec  (the learner is the ultimate constraint)
2. Problem Spec  (the anchor for personalization)
3. Subject Spec
4. Orchestration Spec

Conflicts MUST be logged in `CHANGELOG.md` with the resolution applied.

---

## 4. Generation Pipeline & Failure Handling

The generator MUST execute, in order:

1. **Validate inputs** against §3. Halt on any MUST violation.
2. **Resolve chapter partition** (§6). Halt for human review if partition was
   auto-generated.
3. **Build a personalization plan** (§10) once, course-wide; reuse across
   chapters.
4. **Generate per chapter** in order: chapter doc → exercises → slide deck →
   quiz → podcast script → companion artifacts.
5. **Run quality gates** (§16) on every chapter. A chapter that fails a MUST
   gate is regenerated, not shipped.
6. **Assemble course-level artifacts**: capstone, glossary, reference
   architecture, CHANGELOG, manifest.
7. **Emit a `course.manifest.json`** listing every artifact path, checksum,
   and version (§5.2).

Atomicity: artifacts for a chapter MUST be written as a unit. Partial writes
MUST be discarded.

---

## 5. Course-Level Output Contract

### 5.1 File Layout (REQUIRED)

```
<output_root>/<course_slug>/
  course.manifest.json
  CHANGELOG.md
  VERSIONS.md
  README.md                       # course overview, outcomes, prereqs, time budget
  prereq-diagnostic.md            # §9.5
  glossary.md                     # accumulating; one source of truth
  reference-architecture.svg      # + source (mermaid/drawio)
  capstone/
    capstone-brief.md
    capstone-rubric.md
    capstone-starter/             # starter assets
  environment/                    # course-wide lab env (§14)
    devcontainer.json | Dockerfile | nix.flake | requirements.txt
    preflight.sh / preflight.ps1
    reset.sh
  chapters/
    ch01-<slug>/
      tutorial.docx                    # chapter doc (§8.1)
      slides.pptx                 # or .gslides
      slides-notes.md
      exercises/
        starter/                  # learner-facing
        solution/                 # answer key
        verify/                   # auto-graders
        rubric.json
      podcast-script.md
      quiz.json                   # §9.7
      cheatsheet.pdf
      instructor-guide.md
      troubleshooting.md
```

### 5.2 Naming Convention (STRICT)

Pattern: `{course_slug}/chapters/ch{NN}-{chapter_slug}/{artifact}.{ext}`

- Chapter-level artifacts are named by **artifact role only**, with NO course-slug
  and NO chapter-slug prefix. They are identified by the chapter folder they live in
  (`chapters/ch{NN}-{chapter_slug}/`). This keeps paths within the Windows 260-char limit.
- `course_slug` and `chapter_slug` are kebab-case ASCII, ≤40 chars (used only for the
  chapter folder name, not the artifact filenames).
- `NN` is zero-padded chapter order (`01`, `02`, …).
- `artifact` ∈ {`doc`, `slides`, `slides-notes`, `exercises`, `podcast-script`,
  `quiz`, `cheatsheet`, `instructor-guide`, `troubleshooting`}.
- Capstone files are named by role only too (`capstone-lab.docx`, `capstone-lab-rubric.json`,
  `capstone-instructor-guide.docx`, `capstone-debrief.docx`, and the `capstone-starter/`,
  `capstone-solution/`, `capstone-verify/` folders), inside `capstone/`, with no `course_slug`
  prefix. Course-root files (`glossary.docx`, `README`, `prereq-diagnostic.md`) are also bare.

### 5.3 Course Metadata (REQUIRED in `README.md` front-matter)

```yaml
course_slug: <slug>
title: <human title>
version: <semver, e.g., 1.0.0>
edition_date: <YYYY-MM-DD>
locale: <BCP-47>
target_level: intro | intermediate | advanced
total_duration_minutes: <int>
prerequisites: [<topic>, ...]
tool_versions_validated: { <tool>: <pinned version> }
last_validated: <YYYY-MM-DD>
license: <SPDX id>
authors: [{ name, role }]
```

### 5.4 Versioning

Course version follows **SemVer**:
- **MAJOR**: outcomes change.
- **MINOR**: a chapter is added/removed or pedagogical structure changes.
- **PATCH**: content fixes, errata, tool-version bumps.

Every regeneration MUST bump at least the PATCH version and append an entry to
`CHANGELOG.md`.

---

## 6. Chapter Partitioning Rules

The generator MUST partition the course such that each chapter:

1. Maps to **one or two** learning outcomes from the Subject Spec.
2. Has an **estimated time ≤ 60 min**, computed as:
   ```
   time = (doc_words / 140 wpm)
        + (slide_count * 1.0 min)
        + sum(exercise_time_box_minutes)
   ```
   The podcast is **not** included in this budget — it is treated as an
   alternative modality for the chapter doc (Mayer modality principle), not
   additional content. Cohort-mode timing equals this same total. The
   `sum(exercise_time_box_minutes)` MUST satisfy the §7.14 hands-on share
   (≥ 60 % of total chapter time); see the Chapter Exercise Pack spec
   (§19 sub-spec roster) for the exercise-pack time band.
3. Stands alone: a learner can complete it without reading another chapter's
   content, given the prereqs.
4. Has at least one exercise drawn from the Problem Spec.

If the provided partition violates (1)–(4), the generator MUST propose a new
partition and halt for human review. If a chapter exceeds 60 min, it MUST be
split into sub-chapters of **≤ 45 min each**.

---

## 7. Pedagogical Principles (with operational rules)

Every chapter MUST embody the following research-backed principles. Each
principle is paired with at least one **checkable rule** the generator and the
quality gates can verify.

### 7.1 Backward Design & Constructive Alignment (Wiggins & McTighe; Biggs)
- **Rule:** Every chapter MUST declare its learning outcomes BEFORE content is
  drafted, and every section, exercise, and quiz item MUST reference at least
  one outcome by ID (`LO-{NN}.{n}`).
- **Rule:** Outcomes MUST start with a Bloom verb (see §9.1) and be observable.

### 7.2 Bloom's Revised Taxonomy (Anderson & Krathwohl)
- **Rule:** Across the course, outcomes MUST span at least four of six tiers,
  with at least one outcome at Apply or higher per chapter, and at least one
  at Evaluate/Create somewhere in the course (usually the capstone).

### 7.3 Cognitive Load Theory (Sweller)
- **Rule:** No slide or diagram introduces more than **4 novel elements**
  simultaneously; beyond 4, the generator MUST chunk or reveal progressively.
- **Rule:** Extraneous load reducers: consistent terminology, no decorative
  imagery, no off-topic anecdotes (see §17).

### 7.4 Multimedia Learning Principles (Mayer)
- **Modality / Redundancy:** Slides and podcasts MUST NOT repeat doc prose
  verbatim. Slides reinforce, they do not replace.
- **Segmenting:** Each slide presents **one core idea** (§8.2).
- **Signaling:** Headings, callouts, and progressive disclosure MUST highlight
  the path of attention.
- **Coherence:** Forbid decorative graphics, mascots, background music.
- **Personalization Principle:** Voice is second-person, conversational
  (§15.2). Examples use the learner's domain vocabulary.
- **Pre-training:** Each chapter MUST open with a "Vocabulary & Mental Model"
  section that introduces new terms and core components before they appear in
  context.

### 7.5 Retrieval Practice & the Testing Effect (Roediger & Karpicke)
- **Rule:** Every chapter MUST contain **≥ 3 in-flow retrieval checkpoints**
  (low-stakes recall prompts), separate from the end-of-chapter quiz.
- **Rule:** Each chapter quiz MUST include **≥ 2 carry-forward items** drawn
  from chapter N−1 and one earlier chapter (spaced retrieval).

### 7.6 Spacing & Interleaving
- **Rule:** Each chapter (except ch01) opens with a 1–2 minute retrieval review
  of the prior chapter's key ideas.
- **Rule:** The capstone MUST interleave problems across **≥ 60%** of chapters.

### 7.7 Worked Examples & Fading (Sweller; Kalyuga)
- **Rule:** For every new skill, the chapter MUST present, in order:
  1. **Worked example** — a fully-solved instance.
  2. **Completion problem** — partial solution with `TODO` blocks.
  3. **Independent problem** — learner solves end-to-end.
  (the "I do / we do / you do" pattern.)

### 7.8 Expertise Reversal & Differentiated Paths (Kalyuga)
- **Rule:** When the Subject Spec's `target_level` is `intermediate` or
  `advanced`, the generator MUST emit two tracks per chapter:
  - **Novice track:** worked-example-heavy.
  - **Practiced track:** problem-heavy, with worked examples linked but not
    inline.

### 7.9 Productive Failure (Kapur)
- **Rule:** At least one chapter per course MUST include a **productive-
  failure segment**: a novel problem posed *before* the corresponding
  instruction, followed by the canonical solution and a debrief on the
  approaches the learner likely tried.

### 7.10 Failure-First Technical Pedagogy
- **Rule:** Every lab MUST include **≥ 2 explicit failure modes**: a broken
  state, the expected error message, and a diagnostic procedure.

### 7.11 Metacognition & Self-Explanation
- **Rule:** Every chapter MUST include **self-explanation prompts**
  ("Why does this work?", "Predict what happens if…", "Where would this
  fail?") at least every 10 minutes of content.
- **Rule:** Every chapter MUST end with **3 reflection prompts**:
  1. What was hardest?
  2. Where did your mental model change?
  3. What would you do differently next time?

### 7.12 4C/ID for Complex Skills (van Merriënboer)
- **Rule:** For complex, non-recurrent skills, exercises MUST be **whole-task
  with variability** — multiple problem surface forms, not isolated subskill
  drills only.

### 7.13 Feedback (Hattie)
- **Rule:** Every quiz item and exercise MUST answer three feedback questions:
  *Where am I going?* (outcome), *How am I going?* (correctness + reasoning),
  *Where to next?* (remediation link).

### 7.14 Active Learning Ratio
- **Rule:** Hands-on practice MUST be **≥ 60%** of chapter time (exercises
  and labs from §6's time formula); explanation (concept sections, slides
  walkthrough, demo) MUST be **≤ 40%**. The two together sum to 100%.

### 7.15 Coherence Across Artifacts
- **Rule:** A chapter's doc, slides, podcast, exercises, and quiz MUST share
  a single running example drawn from the Problem Spec. New domains MUST NOT
  be introduced mid-chapter.

---

## 8. Per-Chapter Artifact Schemas

Each artifact MUST conform to its schema below. The generator emits a chapter
manifest fragment in `course.manifest.json`.

### 8.1 Chapter Document (`tutorial.docx`)

Length: **2,500–4,500 words**. Required sections, in this order:

```
1.  Front-matter (yaml)        # chapter, order, LOs, est_minutes, tool versions
2.  Prior-Chapter Recap        # 1–2 min retrieval, if not ch01
3.  Learning Outcomes          # bullet list, Bloom-verbed, LO IDs
4.  Prerequisites              # links to prior chapters or diagnostic
5.  Vocabulary & Mental Model  # pre-training (§7.4)
6.  Concept Sections           # each ends with a self-explanation prompt (§7.11)
7.  Worked Example             # from Problem Spec
8.  Completion Problem         # partial solution
9.  Independent Exercise(s)    # pointer to /exercises
10. Common Pitfalls            # failure-first content (§7.10)
11. Cheat Sheet (preview)      # link to PDF
12. Retrieval Checkpoints      # ≥3 in-flow recall prompts (§7.5)
13. Reflection Prompts         # 3 metacognition items (§7.11)
14. Glossary Delta             # terms added this chapter
15. Further Reading            # 2–5 citations from Subject Spec
```

The chapter doc MUST embed (or link) all diagrams as both source (Mermaid /
draw.io) and exported SVG.

### 8.2 Slide Deck (`slides.pptx`)

Slide count: **12–25**, ≈1 slide per 3 minutes of chapter time. Required
structure:

```
S1   Title (course / chapter / LOs in one line)
S2   Learning Outcomes
S3   Agenda
S4-N Concept slides (one idea each, ≤ 40 words, ≥1 diagram per 3 slides)
S    Worked Example (visual walkthrough)
S    "Try this now" practice slide (cue exercise)
S    Common Pitfalls (failure-first)
S    Recap (retrieval cue, not summary)
S    Quiz Cue / Next Up
```

Speaker notes (`slides-notes.md`) MUST be emitted alongside, including
demo timing markers (`[demo: 4 min]`) and "if cohort vs. solo" sidebars.

### 8.3 Exercises / Labs (`exercises/`)

Per chapter, **≥ 3 exercises**, difficulty curve: 1 easy → ≥1 medium → ≥1
hard. Each exercise directory contains:

```
exercise-NN/
  README.md          # objective, scenario from Problem Spec, time-box, success criteria
  starter/           # learner-facing scaffold with TODO blocks
  solution/          # canonical answer key (instructor-only artifact)
  verify/            # auto-grader: public + hidden tests, expected outputs
  rubric.json        # §9.6 schema
  failure-modes.md   # ≥2 documented failure modes
```

Every lab MUST be runnable in the course-wide environment (§14) and MUST pass
its own `verify/` suite when run against `solution/`.

### 8.4 Podcast Script (`podcast-script.md`)

Length: **1,200–2,300 words**, ≈ 8–15 min audio. Structure:

```
00:00  Cold open hook (problem-domain framing)
00:30  Prior-chapter recap (retrieval, §7.6)
01:00  Act 1: Concept 1 + analogy
        Act 2: Concept 2 + worked example narration
        Act 3: Concept 3 + pitfall + reframe
        "Try this now" CTA (points at exercise)
        Next-chapter teaser
```

The podcast MUST NOT read the chapter doc verbatim (Mayer redundancy
principle). It MUST stand alone for listen-only learners.

### 8.5 Quiz (`quiz.json`)

See **§9 Assessment Framework** for full schema and rules.

### 8.6 Companion Artifacts (REQUIRED per chapter)

- `cheatsheet.pdf` — one page, A4 portrait, ≥ 4.5:1 contrast.
- `instructor-guide.md` — timing, demo script, common mistakes, discussion
  prompts, answer key references.
- `troubleshooting.md` — known failure modes and fixes.

### 8.7 Course-Wide Artifacts (REQUIRED per course)

- `glossary.md` — accumulating; terms defined on first use are added here.
- `reference-architecture.svg` (+ source) — updated as the course progresses.
- `capstone/` — see §9.4.
- `prereq-diagnostic.md` — see §9.5.

---

## 9. Assessment Framework

### 9.1 Outcome Verb Taxonomy

Outcomes MUST use one of these Bloom verbs:

| Tier | Allowed Verbs |
|---|---|
| Remember | define, list, identify, recall, name |
| Understand | explain, summarize, classify, compare, interpret |
| Apply | use, implement, execute, configure, run |
| Analyze | differentiate, organize, attribute, diagnose, debug |
| Evaluate | critique, justify, judge, defend, select |
| Create | design, build, compose, generate, refactor |

### 9.2 Chapter Quiz Composition (REQUIRED)

10 graded items, distributed:

| Bloom level | Count |
|---|---|
| Remember | 2 |
| Understand | 2 |
| Apply | 3 |
| Analyze | 2 |
| Evaluate / Create | 1 |

Plus **2 carry-forward items** from prior chapters (§7.5).

**Compact-mode override (for long courses).** The orchestrator MUST
auto-activate compact mode when `chapter_count ≥ 25`, setting
`numeric_overrides.quiz.items = 4` (plus 2 carry-forward). For
20 ≤ `chapter_count` < 25 compact mode is RECOMMENDED; below 20 it
is OPTIONAL. The Orchestration Spec MAY override this auto-activation
in either direction; overrides MUST be logged in `CHANGELOG.md`. In
compact mode the Remember tier is dropped from the quiz; it MUST
instead be carried by the in-flow retrieval checkpoints in the chapter
doc (§7.5).

| Bloom level (compact) | Count |
|---|---|
| Understand | 1 |
| Apply | 2 |
| Analyze | 1 |
| Evaluate / Create | 0–1 (interleaved across the course) |

Overrides MUST be logged in `CHANGELOG.md` (§2). The full per-quiz schema
and validators are defined in **GreatQuizSpec_v2.md**.

Item types MUST include at least one of each: MCQ, multi-select,
true/false-with-justification, short answer, scenario-based MCQ (framed in
Problem-Spec scenario), error-spotting or code-review.

### 9.3 Passing & Remediation
- Passing threshold: **80%** on the chapter quiz.
- Below 80%: targeted re-study of the sections tied to missed Bloom tags,
  then **one retry** with a parallel-form quiz drawing from the same outcomes
  but different items.
- The capstone MUST be graded against the rubric in §9.4.

### 9.4 Capstone (REQUIRED per course)

The capstone MUST:
- Have a total duration in **60–180 minutes** (default 120), computed as
  the sum of section time-boxes; each section ≤ 30 min. Stretch goals are
  time-boxed separately and do not count toward this total.
- Integrate **≥ 60%** of chapters (interleaving).
- Sit at Bloom's **Apply + Create** tiers.
- Use a Problem-Spec scenario the learner has not seen.
- Be assessable against a **6-criterion capstone rubric** scored on a 1–4
  scale per criterion, with the weighted average **≥ 3.0** required to pass:

  | Criterion | Weight |
  |---|---|
  | Correctness | 0.25 |
  | Approach / Reasoning | 0.20 |
  | Code/Artifact Quality | 0.20 |
  | Communication | 0.15 |
  | Domain Fit | 0.10 |
  | Reflection | 0.10 |

- Ship with: brief, rubric (`capstone-rubric.json`, same JSON shape as §9.6
  but with 6 criteria and the weights above), starter assets, exemplar
  submission, time budget.

Note: per-exercise rubrics (§9.6) and the capstone rubric (§9.4) are two
distinct rubric schemas by design. Quality gates (§16) check both for
schema validity.

### 9.5 Pre-Assessment / Diagnostic (REQUIRED)

`prereq-diagnostic.md` MUST contain an **8-item diagnostic**, ~2 items per
prerequisite topic, that routes learners to one of:

- **fast-track** — skip chapters whose prereqs are already mastered.
- **standard** — default path.
- **with-prerequisites** — links to remediation before ch01.

### 9.6 Exercise Rubric Template (REQUIRED `rubric.json`)

```json
{
  "criteria": [
    { "id": "correctness",   "weight": 0.4, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "approach",      "weight": 0.2, "descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "code_quality",  "weight": 0.25,"descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } },
    { "id": "communication", "weight": 0.15,"descriptors": { "1": "...", "2": "...", "3": "...", "4": "..." } }
  ],
  "passing_average": 3.0
}
```

### 9.7 Quiz Item Schema (REQUIRED `quiz.json` entries)

```yaml
- item_id: ch03-q07
  chapter: 3
  section_ref: 3.2
  bloom_level: Apply              # Remember|Understand|Apply|Analyze|Evaluate|Create
  item_type: scenario_mcq          # mcq|multi_select|tf_justified|short_answer|scenario_mcq|error_spotting|code_review
  assessment_mode: summative       # formative|summative|carryforward|diagnostic
  carryforward_from: null          # chapter index if mode=carryforward
  learning_outcome_ref: LO-3.2.b
  stem: |
    In <Problem-Spec scenario>, ...
  options:
    - id: A
      text: "..."
      correct: false
      misconception: "confuses X with Y"
      rationale: "Wrong because ..."
    - id: B
      text: "..."
      correct: true
      rationale: "Correct because ..."
  estimated_difficulty: 0.7        # target p-value 0.60–0.85
  time_seconds: 60
  remediation_link: "ch03--tutorial.docx#sec-3.2"
```

### 9.8 Distractor Rules (REQUIRED for MCQs)

Every distractor MUST encode a **named misconception**, **off-by-one / scope
confusion**, **surface-pattern match**, or a **previously-correct-but-now-
wrong rule**. Throwaway distractors are forbidden.

### 9.9 Answer Keys & Feedback

Every item MUST ship with:
- Correct answer.
- One-sentence rationale for the correct choice.
- One-sentence rationale for why each distractor is wrong.
- Bloom tag.
- Remediation link to the section that taught the outcome.

### 9.10 Difficulty Calibration

Until empirical learner-response data exists, the generator MUST estimate
each item's difficulty deterministically using the following heuristic and
record it as `estimated_difficulty` (a proxy p-value, higher = easier):

```
base = { Remember: 0.85, Understand: 0.78, Apply: 0.70,
         Analyze:  0.60, Evaluate:   0.50, Create: 0.45 }[bloom_level]

novelty_penalty   = 0.05  if the item introduces a concept first seen in
                          the current chapter, else 0
distractor_bonus  = 0.05  if all distractors are explicitly tagged with a
                          named misconception (§9.8), else 0
scenario_penalty  = 0.05  if item_type == scenario_mcq
                          and scenario combines ≥2 prior chapters' content

estimated_difficulty = clamp(base − novelty_penalty
                                  + distractor_bonus
                                  − scenario_penalty, 0.10, 0.95)
```

Items whose computed value falls **outside 0.40–0.95** MUST be flagged for
rewrite before shipping. Once real learner response data is available, the
Orchestration Spec MAY override this heuristic with empirical p-values.

### 9.11 Formative vs Summative
- **Formative**: in-flow retrieval checkpoints (§7.5) and self-explanation
  prompts. Not scored.
- **Summative**: chapter quiz, exercises, capstone. Scored against rubric.

---

## 10. Personalization Mechanism

Personalization is not a vibe; it is a **substitution layer** the generator
runs once per course and reuses across all artifacts.

### 10.1 Personalization Plan (generated once per course)

The generator MUST produce a `personalization-plan.json` mapping generic
placeholders to Problem-Spec instances:

```yaml
domain_anchors:
  example_entity:   "<from problem_spec.domain_vocabulary>"
  sample_dataset:   "<from problem_spec.sample_data_or_assets>"
  primary_scenario: "<from problem_spec.representative_scenarios[0]>"
  success_metric:   "<from problem_spec.success_criteria>"
vocabulary_substitutions:
  - generic: "a user"
    domain: "a claims adjuster"          # example
  - generic: "an item"
    domain: "a claim"
voice_register: <formal | conversational | technical>  # from student context
```

### 10.2 Application Rules
- Every worked example, exercise scenario, and scenario-based quiz item MUST
  be drawn from `representative_scenarios[]` (no invented domains).
- Generic placeholders in any artifact MUST be replaced via the substitution
  table; the chapter doc, slides, podcast, and quiz MUST use **identical**
  domain terms.
- If a Problem-Spec scenario does not naturally fit a concept, the generator
  MAY introduce **one** clearly-labeled "out-of-domain illustration" per
  chapter; it MUST NOT replace the in-domain worked example.

---

## 11. Audience Adaptation Rules

The Student Context Spec drives content shape, not just labels.

| Context Field | Effect |
|---|---|
| `age_range < 18` | Reading level ≤ Flesch-Kincaid 8; analogies from school/everyday life. |
| `age_range 18–24` | FK ≤ 10; analogies from common tech/consumer apps. |
| `age_range ≥ 25` | FK ≤ 12; analogies from professional contexts. |
| `prior_knowledge[topic].level = none` | Use novice track (§7.8); fully worked examples. |
| `prior_knowledge[topic].level = high` | Use practiced track; problems first. |
| `primary_language ≠ en` | Glossary MUST include term in primary language alongside English. |
| `accessibility_needs[screen-reader]` | All diagrams MUST have alt text; no info conveyed only by color. |
| `accessibility_needs[dyslexia]` | Use sans-serif body, ≥ 1.5 line height, left-aligned text. |
| `preferred_modalities[listen]` | Podcast is canonical; doc is reference. |
| `time_budget_per_week < 3h` | Estimated total course time MUST ≤ 4 × that figure across all chapters; otherwise warn. |

---

## 12. Visual & Information Design Standards

### 12.1 Slides
- Reinforce speech, not replace it.
- **One core idea per slide.**
- ≤ 40 words per slide.
- ≥ 1 diagram or visual per 3 slides.
- Progressive disclosure for any list > 3 items.
- Consistent template, max 2 fonts, max 4-color palette.
- No decorative imagery, mascots, or background music.

### 12.2 Diagrams
- Use **C4** for architecture, **sequence** for flows, **ER** for data.
- Author in **Mermaid** or **draw.io**; commit source alongside SVG export.
- Consistent shape legend; ≥ 4.5:1 contrast.
- Alt text MUST describe both shapes and relationships.
- Show flows and dependencies explicitly; no implicit arrows.

### 12.3 Documentation
- Consistent terminology (glossary is single source of truth).
- Separate beginner and advanced content via collapsible sections or
  sidebars; never interleave inline.
- Include diagrams.
- Include a troubleshooting section per chapter.

### 12.4 Cheat Sheets
- One page, A4 portrait.
- Distilled to commands, signatures, shapes, decision rules.
- ≥ 4.5:1 contrast; sans-serif body.

---

## 13. Accessibility & Localization

### 13.1 Accessibility (REQUIRED)
- All artifacts MUST conform to **WCAG 2.2 AA**.
- Every image / diagram MUST have alt text describing structure and meaning.
- Code samples MUST be real text (never images).
- No information MUST be conveyed by color alone.
- Podcast MUST ship with a transcript (`podcast-script.md` serves).
- Slide decks MUST have readable fonts at the back of a room: body ≥ 24pt,
  titles ≥ 36pt.

### 13.2 Localization
- All artifacts respect the Student Context Spec's `locale`.
- Units, dates, currency, and number formatting MUST follow locale.
- Examples that depend on cultural norms MUST be substituted using the
  Student Context Spec's `cultural_norms.example_substitutions`.
- The glossary MUST include translated terms where `primary_language ≠ en`.

---

## 14. Code Sample & Lab Environment Standards

### 14.1 Lab Environment (REQUIRED per course)
- Reproducible via container, devcontainer, Nix, or pinned-venv recipe.
- `preflight.sh` / `preflight.ps1` MUST verify tool versions, network, and
  credentials before any lab runs.
- `reset.sh` MUST restore a clean state.
- Environment MUST be tested against `solution/` for every chapter as part of
  the quality gates (§16).

### 14.2 Code Samples
- All code MUST be runnable end-to-end against the pinned environment.
- All code MUST pass the canonical formatter (black / prettier / gofmt /
  rustfmt) and canonical linter (ruff / eslint / golangci-lint / clippy) at
  default settings.
- Idiomatic for the language; typed where the language supports it.
- Every sample shows **inputs**, **outputs**, and **one failure mode**.
- Filename header and license header REQUIRED.
- Tools/SDKs/libraries MUST be pinned. Deprecated APIs MUST NOT be used
  without an explicit migration callout.

### 14.3 Naming & Style
- Files: kebab-case.
- Code identifiers: language-idiomatic (snake_case Python, camelCase JS/TS,
  PascalCase types, SCREAMING_SNAKE env vars).
- Git branches: `chapter/NN-slug`.

### 14.4 Currency
- Every chapter doc front-matter MUST declare `last_validated: YYYY-MM-DD`
  and the tool versions tested.

---

## 15. Style Guide

### 15.1 Tone
- Warm, precise, and direct. Respect the learner; never condescend.
- Technical without jargon-for-jargon's-sake; every new term is introduced in
  the Vocabulary & Mental Model section before use.

### 15.2 Voice
- Second person (*you*), present tense, active voice.
- Conversational register; avoid passive constructions and nominalizations.
- No emoji unless the Student Context Spec opts in.

### 15.3 Reading Level
- Default Flesch–Kincaid grade ≤ 12; adjusted per §11.

### 15.4 Humor & Analogies
- Analogies MUST be from the Problem-Spec domain or culturally-neutral
  everyday life.
- Humor is allowed in moderation; jokes MUST NOT target groups or rely on
  stereotypes.

### 15.5 Citations
- Further-reading citations use a consistent format
  (`Author (Year). Title. URL.`) and link to canonical sources from the
  Subject Spec.

---

## 16. Quality Gates (Self-Check Before Shipping)

A chapter MUST pass every MUST gate; a chapter SHOULD pass every SHOULD gate.

### 16.1 Coverage Gates (MUST)
- [ ] Every LO is addressed by ≥ 1 concept section, ≥ 1 exercise, and ≥ 1 quiz item.
- [ ] Every quiz item, exercise, and section references at least one LO ID.
- [ ] Bloom distribution in the chapter quiz matches §9.2.

### 16.2 Pedagogy Gates (MUST)
- [ ] ≥ 3 in-flow retrieval checkpoints exist in the doc (§7.5).
- [ ] ≥ 1 worked example, ≥ 1 completion problem, ≥ 1 independent exercise (§7.7).
- [ ] ≥ 1 self-explanation prompt every 10 minutes of content (§7.11).
- [ ] 3 reflection prompts at end of chapter (§7.11).
- [ ] ≥ 2 failure modes documented per lab (§7.10).
- [ ] Hands-on share ≥ 60% of chapter time (§7.14).
- [ ] Prior-chapter recap present (chapter > 1) (§7.6).
- [ ] ≥ 2 carry-forward items in quiz (§7.5).

### 16.3 Personalization Gates (MUST)
- [ ] All concept examples, exercise scenarios, and scenario quizzes use
      Problem-Spec vocabulary and scenarios.
- [ ] At most 1 out-of-domain illustration, clearly labeled.
- [ ] Doc, slides, podcast, quiz share the same running example.

### 16.4 Format Gates (MUST)
- [ ] Filename matches §5.2 pattern.
- [ ] Chapter doc length 2,500–4,500 words.
- [ ] Slide count 12–25.
- [ ] Podcast script 1,200–2,300 words.
- [ ] All required sections (§8.1, §8.2) present in order.
- [ ] All diagrams have source + SVG + alt text.

### 16.5 Technical Gates (MUST)
- [ ] All code samples run against the pinned environment.
- [ ] Linter and formatter pass at defaults.
- [ ] `verify/` passes against `solution/` for every exercise.
- [ ] `preflight.sh` succeeds before any lab is run.

### 16.6 Accessibility Gates (MUST)
- [ ] WCAG 2.2 AA contrast on all visuals.
- [ ] Alt text on every image/diagram.
- [ ] No info conveyed by color alone.
- [ ] Slide body ≥ 24pt.

### 16.7 Calibration & Rubric Gates (MUST)
- [ ] No quiz item with `estimated_difficulty` < 0.40 or > 0.95 (§9.10).
- [ ] Every exercise has a `rubric.json` matching the §9.6 schema (4 criteria,
      weights summing to 1.0, `passing_average` = 3.0).
- [ ] The capstone has `capstone-rubric.json` matching the §9.4 schema
      (6 criteria, weights as listed, `passing_average` = 3.0).
- [ ] Reading level within the §15.3 target for the cohort's age bracket.

A chapter that fails a MUST gate MUST be regenerated; the failure MUST be
logged in `CHANGELOG.md`.

---

## 17. Anti-Patterns (FORBIDDEN)

The generator MUST NOT produce:

- End-of-chapter-only assessment with no in-chapter retrieval.
- Strictly linear "simple to complex" content with no revisiting of prior
  material.
- Slides that duplicate the doc narration verbatim.
- Podcasts that read the chapter doc verbatim.
- Decorative graphics, mascots, or background music.
- Quizzes whose only feedback is a score.
- "Critical thinking" claimed without Analyze / Evaluate / Create tasks in
  the exercise set.
- Labs whose only path is the happy path (no failure conditions).
- Identical exercise difficulty for novice and practiced tracks.
- Capstones that re-test only the final chapter.
- Code samples using deprecated APIs without a migration callout.
- Diagrams whose meaning depends on color alone.
- Invented problem domains when the Problem Spec is empty or missing.
- Mid-chapter switching to a new domain example.
- Throwaway MCQ distractors.

---

## 18. Glossary (canonical terms used in this spec)

| Term | Canonical definition |
|---|---|
| **Course** | The full deliverable for one Subject + Problem + Student Context combination. |
| **Chapter** | A single learning unit, ≤ 60 min, mapping to 1–2 outcomes. |
| **Section** | A subdivision within a chapter (concept, example, exercise, etc.). |
| **Subject Spec** | Input spec defining the topic to teach (§3.1). |
| **Problem Spec** | Input spec defining the learner's real-world problem domain (§3.2). |
| **Student Context Spec** | Input spec defining the learner's identity, prior knowledge, locale, and needs (§3.3). |
| **Orchestration Spec** | Input spec defining the pipeline (§3.4). |
| **Artifact** | Any file produced for a chapter or for the course (doc, slides, etc.). |
| **Learning Outcome (LO)** | An observable, Bloom-verbed statement of what the learner will be able to do. |
| **Retrieval Checkpoint** | A low-stakes recall prompt embedded in chapter content. |
| **Worked Example** | A fully-solved instance shown to the learner. |
| **Completion Problem** | A partially-solved problem with `TODO` blocks. |
| **Carry-Forward Item** | A quiz item drawn from a prior chapter (spaced retrieval). |
| **Track** | A differentiated variant of a chapter (novice / practiced). |
| **Personalization Plan** | Course-wide substitution table mapping generic placeholders to Problem-Spec instances. |
| **Quality Gate** | A self-check the generator runs before declaring a chapter done. |

---

## 19. Sub-Specifications and Skill Orchestration

The Course Factory generator is composed of one **orchestrator** skill and
four **artifact-generator** skills. Each artifact-generator skill is
governed by a focused sub-specification that implements the relevant
master-spec sections. On any conflict, this master spec wins.

### 19.1 Skill / Agent Roster and Sub-Spec Cross-Reference

The pipeline executes as a **two-tier agent system**: the **PlannerAgent**
(upstream, one-shot) produces the authoritative Plan; **artifact-generator
agents** (downstream, dispatched per the Plan) produce the learner-facing
artifacts; **ChapterSupervisorAgent** and **EvaluatorAgent** coordinate
per-chapter dispatch and quality-gate enforcement. See §19.7 for the
full hierarchy.

| Skill / Agent | Tier | Owns Artifacts | Sub-Spec | Implements |
|---|---|---|---|---|
| **PlannerAgent** | upstream (1 per course) | `course-plan.yaml`, `personalization-plan.json` (§10), `subject.normalized.yaml` (§3.1, if narrative), `reserved-scenarios.json`, `chapter-partition-rationale.md`, `precedence-log.md`, `dependency-graph.svg`, `PLAN_REVIEW.md` | `PlannerSpec_v2.md` | §3, §3.1, §3.5, §6, §9.5, §10, §14, §19 |
| **ChapterSupervisorAgent** | per-chapter coordinator | `chapter.manifest.json`; dispatches deliverables in dependency order | `PlannerSpec_v2.md §11` | §19.3, §19.4 |
| **EvaluatorAgent** | quality-gate runner | `evaluator-report.md` per chapter + course-wide + capstone | `PlannerSpec_v2.md §12` | §16 |
| **ChapterTextGenerator** | per-chapter | `tutorial.docx`, `tutorial.handoff.json`, `diagrams/` | `GreatTextSpec_v2.md` | §7.3, §7.4, §7.5, §7.6, §7.7, §7.10, §7.11, §7.15, §8.1, §10, §12.3, §13, §15, §16 |
| **QuizGenerator** | per-chapter (+ 1 diagnostic per course) | `quiz.json` (Form A), `quiz-formB.json`, `prereq-diagnostic.md` (in `diagnostic` mode) | `GreatQuizSpec_v2.md` | §9 |
| **ExerciseGenerator** | per-chapter | `exercises/` folder (worked example + completion + ≥ 1 independent), per-exercise `rubric.json`, `verify/`, `failure-modes.md`, `manifest.json`, `debrief.md` | `GreatModuleExercise_v2.md` | §7.7, §7.10, §7.12, §7.14, §8.3, §9.6, §16.2, §16.5 |
| **PresentationGenerator** | per-chapter | `slides.pptx`, `slides-notes.md` | `GreatPresentationSpec_v2.md` | §7.3, §7.4, §7.5, §7.11, §8.2, §10, §12.1, §12.2, §13.1, §16.4 |
| **LabGenerator** | course-level (1 per course) | `capstone/` folder (brief, rubric, starter, solution, verify, failure-modes, instructor guide, debrief, environment delta) | `GreatLabSpec_v2.md` | §7.6, §7.7, §7.10, §7.11, §9.4, §14, §16 |
| **PodcastGenerator** | per-chapter | `podcast-script.md` (and audio when TTS is available) | *(future PodcastSpec; currently inlined under master §8.4)* | §7.4, §7.6, §7.15, §8.4 |
| **CompanionGenerator** | per-chapter | `cheatsheet.pdf`, `instructor-guide.md`, `troubleshooting.md` | *(future CompanionSpec; currently inlined under master §8.6)* | §8.6 |
| **GlossaryAggregator** | course-wide (incremental) | `glossary.md` | *(currently master §5.1, §8.7)* | §5.1, §8.7 |
| **ReferenceArchitectureGenerator** | course-wide (incremental) | `reference-architecture.svg` (+ source) | *(currently master §5.1, §8.7)* | §5.1, §8.7 |
| **EnvironmentScaffoldGenerator** | course-wide (1 per course) | `environment/` (devcontainer / Dockerfile / Nix flake, `preflight.sh`, `reset.sh`) | *(currently master §14)* | §14 |

Future dedicated sub-specs MAY be added for PodcastGenerator,
CompanionGenerator, GlossaryAggregator, ReferenceArchitectureGenerator,
and EnvironmentScaffoldGenerator. Until those exist, their behavior is
governed directly by the master spec section listed in the *Implements*
column.

### 19.2 Common Input Envelope

Every artifact-generator skill receives the same common envelope from the
CourseGeneratorSkill, plus a skill-specific block. Sub-specs reference
this envelope by name (`common_inputs`); they extend it but MUST NOT
redefine its fields.

```yaml
common_inputs:
  course_slug:           <string>
  chapter:               { number: NN, slug, title, scope,
                           est_minutes, prerequisites[] }
  learning_outcomes[]:   [ { id: LO-NN.n, verb, object, criterion,
                             bloom_level } ]
  problem_spec:          <full §3.2 object>
  student_context:       <full §3.3 object>
  personalization_plan:  <§10 object, course-wide>
  canonical_references[]: <from subject_spec.canonical_references>
  mode_targets:          [ self_taught, cohort ]   # which modes this artifact must serve
  numeric_overrides:     <optional, from orchestration_spec>
  output_paths:          { primary: <§5.2 path>, sidecars: [...] }
  quality_gates_to_satisfy[]: <subset of §16>
```

Skill-specific additions are defined inside each sub-spec.

### 19.3 Regeneration Order (dependency graph)

The pipeline MUST execute generation in this order. The PlannerAgent
produces the dependency graph as a deliverable (`dependency-graph.svg`,
see `PlannerSpec_v2 §9`); the text below is the canonical structure that
graph encodes. Steps within the same chapter MUST respect the per-chapter
dependency arrows; ChapterSupervisorAgent enforces them at runtime.

```
Stage 0  — INPUTS (must pre-exist)
0.1  Subject Spec, Problem Spec, Student Context Spec, Orchestration Spec
     (validated per §3; halt on missing required fields)

Stage 1  — PLANNING (PlannerAgent, 1 invocation)
1.1  PlannerAgent → narrative normalization (§3.1, if needed)
                                                   [HALT for human review of diff]
1.2  PlannerAgent → precedence resolution, chapter partition (§6),
                    personalization plan (§10), reserved capstone scenario (§19.4)
1.3  PlannerAgent → per-chapter and course-wide work assignments
1.4  PlannerAgent → PLAN_REVIEW.md                 [HALT for human approval]
1.5  PlannerAgent → course-plan.yaml emitted; downstream agents receive it as read-only input

Stage 2  — COURSE-WIDE PRE-WORK (dispatched by the Plan)
2.1  EnvironmentScaffoldGenerator → `environment/`  (§14)
2.2  QuizGenerator (diagnostic mode) → prereq-diagnostic.md (§9.5)
2.3  GlossaryAggregator → glossary skeleton; ReferenceArchitectureGenerator → seed diagram

Stage 3  — PER CHAPTER (ChapterSupervisorAgent per chapter, in order ch01 → chNN)
3.1  ChapterTextGenerator → chapter doc + handoff (§8.1, GreatTextSpec_v2)
                                                   [seeds 3.2–3.6 via tutorial.handoff.json]
3.2  ExerciseGenerator → exercises pack            [needs 3.1]
3.3  PresentationGenerator → slides + notes        [needs 3.1, 3.2 for "Try this now" slide]
3.4  QuizGenerator → quiz Form A + Form B          [needs 3.1; needs prior chapters' quizzes for carry-forward (§7.5)]
3.5  PodcastGenerator → podcast script             [needs 3.1, 3.2]
3.6  CompanionGenerator → cheatsheet, instructor guide, troubleshooting [needs 3.1]
3.7  GlossaryAggregator → merge chapter delta into course glossary
3.8  EvaluatorAgent (chapter pass) → run master §16 gates;
                                                   [on MUST failure, regenerate from 3.1 for this chapter]

Stage 4  — COURSE-WIDE POST-WORK (after every chapter passes)
4.1  LabGenerator → capstone (§9.4, GreatLabSpec_v2)  [needs all chapters; unseen scenario from reserved-scenarios.json]
4.2  ReferenceArchitectureGenerator → finalize
4.3  PlannerAgent (or orchestrator) → README.md, course.manifest.json, CHANGELOG.md, VERSIONS.md
4.4  EvaluatorAgent (course-wide pass) → master §16 cross-artifact gates;
                                                   [on MUST failure, route to the responsible Stage]
```

### 19.4 Cross-Skill Invariants

- **Single Running Example per Chapter (§7.15).** The ChapterTextGenerator
  seeds the running example in `tutorial.handoff.json`; exercise pack,
  slide deck, quiz, and podcast MUST reuse it via that handoff. The
  orchestrator MUST pass the handoff as an explicit input to every
  downstream per-chapter generator.
- **Unseen Scenario for Capstone (§9.4).** The orchestrator MUST reserve
  at least one `problem_spec.representative_scenarios[]` entry for the
  capstone and pass the index of used scenarios to ExerciseGenerator so
  it does not consume the reserved entry.
- **Carry-Forward Sourcing (§7.5).** QuizGenerator MUST receive
  prior-chapter quiz items as `prior_chapter_quiz_items[]` from the
  orchestrator (chapter N − 1 and at least one chapter ≤ N − 3).
- **Personalization Plan is read-only downstream.** Only
  CourseGeneratorSkill may write `personalization-plan.json`. All
  artifact generators MUST treat it as immutable input.
- **Quality-Gate Authority.** If an artifact-generator skill disagrees
  with the orchestrator's gate decision, the orchestrator wins. Sub-skills
  MUST log dissent in `CHANGELOG.md` rather than override.

### 19.5 Conflict Resolution Among Sub-Specs

When a sub-spec contradicts the master:
1. The master spec wins (§3.5 precedence is unchanged).
2. The sub-spec MUST be updated within the same release cycle.
3. Until updated, the sub-spec's contradicting clause is treated as
   advisory; the master's clause is enforced.

When numeric defaults differ between sub-specs and the Orchestration Spec,
the Orchestration Spec's `numeric_overrides` win (§2). All overrides MUST
be logged in `CHANGELOG.md`.

### 19.6 Orphan-Artifact Ownership

The following artifacts have a designated owner agent in §19.1 but no
dedicated sub-spec yet. Each owner agent produces them by reading the
master-spec section listed below until a dedicated sub-spec is added.

| Artifact | Owner Agent | Master Section |
|---|---|---|
| Podcast Script | PodcastGenerator | §8.4 |
| Cheatsheet | CompanionGenerator | §8.6, §12.4 |
| Instructor Guide | CompanionGenerator | §8.6 |
| Troubleshooting | CompanionGenerator | §8.6 |
| Glossary (course-wide, accumulating) | GlossaryAggregator | §5.1, §8.7 |
| Reference Architecture diagram | ReferenceArchitectureGenerator | §5.1, §8.7 |
| Lab Environment (preflight / reset) | EnvironmentScaffoldGenerator | §14 |
| `course.manifest.json`, `CHANGELOG.md`, `VERSIONS.md`, `README.md` | PlannerAgent (final emission) | §4, §5 |

Personalization Plan and chapter partition are NOT orphans — they are
PlannerAgent deliverables (§19.1, `PlannerSpec_v2.md`). When new dedicated
sub-specs are added for the artifacts above, the master spec section is
updated in the same release.

### 19.7 Agent Hierarchy (multi-agent execution model)

```
PlannerAgent  (1 per course, upstream)
   │  produces:  course-plan.yaml + personalization-plan.json + reserved-scenarios.json
   │
   ├── [Stage 2 course-wide]
   │      EnvironmentScaffoldGenerator
   │      QuizGenerator (diagnostic)
   │      GlossaryAggregator (init)
   │      ReferenceArchitectureGenerator (seed)
   │
   ├── for each chapter:
   │      ChapterSupervisorAgent
   │         ├── ChapterTextGenerator             ─┐ produces tutorial.handoff.json
   │         ├── ExerciseGenerator                 │ consume handoff
   │         ├── PresentationGenerator             │
   │         ├── QuizGenerator (chapter, A+B)      │
   │         ├── PodcastGenerator                  │
   │         └── CompanionGenerator                ─┘
   │      EvaluatorAgent (chapter pass)
   │
   ├── [Stage 4 course-wide]
   │      LabGenerator (capstone, unseen scenario)
   │      ReferenceArchitectureGenerator (finalize)
   │
   └── EvaluatorAgent (course-wide pass)
```

The PlannerAgent is the **only** agent that makes pedagogical or
architectural decisions. ChapterSupervisorAgent and the artifact
generators MUST consume the Plan as read-only input and MUST NOT
override its decisions. EvaluatorAgent MUST trigger regeneration on
gate failures per the Plan's `regeneration_policy`.



