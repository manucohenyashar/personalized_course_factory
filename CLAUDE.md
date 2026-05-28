# Personalized Course Factory — Project Guide

## Purpose

This repository generates personalized technical training courses using a multi-agent Claude Code
pipeline. Given a subject specification, a problem domain, and a student cohort description, the
pipeline produces a complete course: chapter documents, slide decks, exercises, quizzes, podcast
scripts, a capstone lab, and supporting artifacts — all grounded in learning-science best practices
and personalized to the learner's domain and context.

---

## Personalization First Principle — READ BEFORE GENERATING ANYTHING

**This is a personalized course factory. Generic content is a defect, not a default.**

Every generator agent MUST internalize the student's world before writing a single word.
Personalization is not a finishing coat applied to generic content — it is the foundation.

### What "personalized" means in this system

| Generic (FORBIDDEN) | Personalized (REQUIRED) |
|---------------------|------------------------|
| "A user submits a request" | "Sara, the operations analyst, submits a ticket escalation" |
| "The system processes the input" | "The Salesforce CRM validates the escalation priority" |
| "Consider this scenario…" | "Recall that in your team's queue management workflow…" |
| "Beginner-level explanation" | FK grade calibrated to `students.yaml.reading_level_target` |
| Abstract principle first | Concrete domain example first, then extract the principle |

### Every generator MUST do this before writing

**Step P1 — Read the student context:**
```
From students.yaml, extract:
  - reading_level_target (FK grade; controls sentence length + vocabulary)
  - prior_knowledge[] (what they already know — do NOT explain these; BUILD on them)
  - professional_context (their job, team, industry — the lens for every example)
  - preferred_modalities (visual / text / hands-on — weight the artifact accordingly)
  - locale + primary_language (affects idioms, units, date formats, cultural references)
```

**Step P2 — Read the personalization plan:**
```
From personalization_plan.json, extract:
  - vocabulary_substitutions{} → replace EVERY generic term before writing
      "user"    → <domain protagonist, e.g. "warehouse supervisor">
      "system"  → <domain system, e.g. "SAP WMS">
      "item"    → <domain object, e.g. "inbound shipment">
      "process" → <domain process, e.g. "receiving workflow">
  - scenario_assignments{chapter_slug} → the exact scenario for THIS chapter
  - running_example_per_chapter{chapter_slug} → the protagonist + artifact for THIS chapter
```

**Step P3 — Build your personalization context before the first sentence:**
Write (internally) this context block and keep it active throughout generation:
```
Protagonist:  <name/role from running_example>
Domain system: <system name>
Domain object: <item name>
Scenario:     <title + 1-line description of THIS chapter's scenario>
Reading level: FK grade <N> — sentences ≤ <20 if ≤10, 25 if ≤12, 30 if >12> words avg
Prior knowledge assumed: <list from students.yaml — these need NO introduction>
Prior knowledge NOT assumed: <gaps — these need scaffolding>
Register: <professional|academic|conversational depending on professional_context>
```

**Step P4 — Verify before submitting:**
- Scan the output: does every example name the protagonist and domain system?
- Does every worked problem use the chapter's scenario entities?
- Is any sentence using "a user", "the system", "an item", or "the process"? → replace
- Does the FK grade match `reading_level_target`? (simplify or complexify accordingly)
- Would a student in this cohort recognize their daily work in every example? If not, revise.

### Reading Level Calibration Rules

| FK Grade Target | Max avg sentence length | Vocabulary rule |
|----------------|------------------------|-----------------|
| ≤ 8 | 15 words | Common words only; define every technical term inline |
| 9–10 | 20 words | Technical terms defined on first use; analogies to everyday objects |
| 11–12 | 25 words | Technical terms may appear without inline definition if in glossary |
| 13–14 | 30 words | Academic prose OK; compound sentences acceptable |
| > 14 | No hard limit | Expert register; may assume professional vocabulary |

### Prior Knowledge Scaffolding Rules

- **Listed in `prior_knowledge[]`**: NEVER introduce or define these. Reference them as known:
  "As you know from your SQL experience…" not "SQL is a query language that…"
- **Not listed**: Scaffold from concrete example → analogy → formal definition (Concrete-Pictorial-Abstract)
- **Partially known** (listed with caveat in students.yaml): acknowledge the prior exposure and
  extend: "You've seen X in context Y. Here it works differently because…"

### Domain Register Rules

Derive the appropriate register from `students.yaml.professional_context`:
- **Blue-collar / field operations**: plain language, tool-focused, metric-heavy, minimal jargon
- **Office / knowledge workers**: professional but accessible, workflow-focused
- **Technical / engineering**: precise terminology, code-heavy, performance-aware
- **Academic / research**: formal, citation-friendly, theory-grounded
- **Managerial / executive**: outcome-focused, business-impact framing, light on implementation detail

---

## Student-Facing Materials — General Rules

These rules apply to ALL artifacts that a student will see or interact with. They take
precedence over any conflicting instruction in individual generator or spec files.

### Rule 1: Student Content Contains ONLY Training Material

**Student-facing content must be concise and include ONLY training material the student
should read to learn. All administrative, pedagogical, and pipeline references MUST NEVER
be presented to the student.**

This is the fundamental principle: if it is not something the student needs to learn from,
it does not belong in student-facing content.

#### Administrative references that are FORBIDDEN in student-facing content

| Category | FORBIDDEN examples | Where they belong instead |
|----------|-------------------|--------------------------|
| **Bloom taxonomy** | `[Apply]`, `[Remember]`, `(Understand)`, "Bloom level", "cognitive level" | Handoff JSON, speaker notes, instructor guide |
| **LO-IDs** | `LO-03.1`, `LO-07.2`, `LO-NN.n` | Handoff JSON, course-plan.yaml, quiz JSON, manifest JSON |
| **Section IDs** | `§ 5`, `3.2`, section numbering in headings | Internal spec references only |
| **Chapter slugs** | `ch02-automation-mindset`, `ch{NN}-{slug}` | File naming (internal), course-plan.yaml |
| **Item/exercise IDs** | `ch03-q01`, `ch03-ex02`, `exercise_id` | Quiz JSON, manifest JSON, rubric JSON |
| **Pipeline terminology** | "quality gate", "evaluator", "handoff", "spec", "feedback loop" | Internal pipeline docs |
| **Pedagogical framework names** | "Bloom's taxonomy", "Concrete-Pictorial-Abstract", "I-do/we-do/you-do" | Instructor guide, specs |
| **Assessment metadata** | `assessment_mode`, `estimated_difficulty`, `time_seconds`, `remediation_link` | Quiz JSON (internal) |
| **File format references** | "see the JSON", "handoff.json", "manifest.json" | Never in student content |
| **Time budgets / admin data** | `est_minutes: 45`, `time_box_minutes: 15` | Instructor guide, manifest |

#### What students SHOULD see

- **Clear, descriptive headings** without numbers, symbols, or codes
- **Learning outcomes** stated naturally: "By the end of this chapter, you will be able to..."
  (no LO-IDs, no Bloom labels)
- **Exercises** with clear titles and instructions (no exercise IDs, no Bloom tags)
- **Quiz questions** with clean numbering (no item IDs, no metadata)
- **Content focused entirely on learning** the subject matter

#### Examples

| Student sees (REQUIRED) | Student NEVER sees (FORBIDDEN) |
|------------------------|-------------------------------|
| By the end of this chapter, you will be able to recall and define... | LO-03.1 (Remember): Recall and define... |
| The Automation Suitability Framework | § 5 The Automation Suitability Framework [Apply] |
| Exercise 2: Build a prompt template | Exercise ch03-ex02 [Apply]: Build a prompt template |
| 1. What is the correct output when... | ch03-q01 [Apply, LO-03.2]: What is the correct output... |
| Key Terms | § 14 Glossary [Remember] |

#### Where administrative metadata IS retained

Bloom levels, LO-IDs, and other pipeline metadata are essential for course quality. They are
retained in **internal pipeline artifacts only**:
- `*--doc.handoff.json` (section Bloom tags, LO refs)
- `*--quiz.json` / `*--quiz-formB.json` (item metadata)
- `manifest.json` (exercise pack metadata)
- `rubric.json` (assessment criteria)
- `course-plan.yaml` (LO definitions)
- Slide speaker notes (LO refs, Bloom levels for instructor reference)
- Instructor guides (may reference LO-IDs and Bloom levels since they are instructor-facing)

### Rule 2: All Student Materials are Office Files

Every artifact delivered to students MUST be a Microsoft Office file (`.docx` or `.pptx`).
No student should ever receive or interact with a `.json`, `.yaml`, `.md`, or raw code file
as a learning deliverable.

**Quiz format change:** Quizzes MUST be delivered as Word documents, not JSON files:

| File | Purpose | Format |
|------|---------|--------|
| `*--quiz-questions.docx` | Student quiz (questions only, no answers) | Word (.docx) |
| `*--quiz-answers.docx` | Answer key with rationales | Word (.docx) |
| `*--quiz-questions-formB.docx` | Form B questions (no answers) | Word (.docx) |
| `*--quiz-answers-formB.docx` | Form B answer key with rationales | Word (.docx) |
| `*--quiz.json` | Internal pipeline data (retained for evaluators) | JSON (internal) |
| `*--quiz-formB.json` | Internal pipeline data (retained for evaluators) | JSON (internal) |

The quiz generator MUST produce both the internal JSON (for pipeline evaluators and gates)
AND the student-facing `.docx` files. The `.docx` quiz files:
- Present questions cleanly formatted with proper numbering
- Include no Bloom labels, LO-IDs, item IDs, or internal metadata
- Use the same design guidelines as all other student-facing docx files
- The questions file contains ONLY the questions (no correct answers, no rationales)
- The answers file contains each question followed by the correct answer and rationale

### Rule 3: Document Design Spec for All Student-Facing Docx

All generators producing student-facing `.docx` files MUST follow `doc/DocxDesignSpec.md`.
This spec defines typography, layout, structure, prose style, and anti-patterns for Word
documents. Key requirements include:

- **No § symbols, LO-IDs, Bloom tags, or chapter slugs** in student text
- **No em dashes** (use periods, commas, or conjunctions instead)
- **Bold-lead bullet pattern** (bold the initial keyword of each bullet point)
- **Clean headings** without leading numbers or symbols
- **Arial font family**, US Letter page size, 1-inch margins
- **Tables with DXA widths** (never percentage), light borders, cell padding
- **Blockquotes** for scenarios, tips, and side information
- **Direct, factual prose** without setup phrasing or unnecessary modifiers

Every generator MUST run the anti-patterns checklist in `doc/DocxDesignSpec.md` §6 before
submitting any student-facing document.

---

## Subject Specification — The Curriculum Contract

`inputs/subject.md` is the **curriculum baseline**. It defines:
- The topics, subjects, and chapters that MUST be taught
- The high-level learning objectives for the course
- The recommended chapter structure and delivery approach

**The subject spec is not optional.** Every course is built by taking the subject spec as a
syllabus and personalizing it — applying learning-science best practices, grounding every example
in the student's domain, and adapting depth and register to the cohort's background. The subject
spec defines *what* to teach; the student context and problem spec define *how* to teach it.

### Relationship between specs and generated content

```
inputs/subject.md          ← WHAT to teach (curriculum contract, topic list, objectives)
inputs/problem.yaml        ← Domain context for examples (scenarios, vocabulary, success criteria)
inputs/students.yaml       ← WHO is being taught (prior knowledge, reading level, register)
inputs/general-requirements.yaml ← User overrides (time, chapter count, difficulty, focus)
                                    ↓
              planner-agent produces a personalized course-plan.yaml
              that MUST cover every topic in subject.md
                                    ↓
              generators produce artifacts grounded in problem.yaml
              and calibrated to students.yaml
                                    ↓
              evaluator-agent verifies ALL subject.md topics are covered
```

### Subject spec coverage is a MUST gate

The `evaluator-agent` checks every topic, chapter objective, and subject area listed in
`inputs/subject.md` against the generated course. Any topic that has no corresponding
chapter section, exercise, or assessment FAILS the coverage gate and blocks course delivery.

This check is in addition to — not instead of — the Bloom LO coverage gate (§16.1).

### Providing a subject specification

When creating a course, the user MUST supply a subject specification. Three ways:
- **Default**: keep `inputs/subject.md` (the 18-chapter Cowork Automation course)
- **Replace**: overwrite `inputs/subject.md` with a custom curriculum outline
- **Inline**: paste chapter titles, topics, and objectives in the message to
  `@course-factory-agent` — the agent writes them to `inputs/subject.md`

If no subject specification is provided and the user's message does not contain a topic list,
`@course-factory-agent` MUST ask the user to supply one before proceeding.

---

## Quick Start

**One-command generation (recommended):**
```
@course-factory-agent

Create a personalized course for [describe your students and domain].
```

The factory agent handles the complete pipeline. Two human-review halts occur during
planning (normalization diff + plan review). Everything else runs automatically.

**If you have unstructured documents** (business cases, job descriptions, team wikis):
```
@spec-builder-agent
```
Share your documents in any format. The agent extracts structure, validates scope, and
produces `inputs/problem.yaml` and `inputs/students.yaml` interactively. Then run
`@course-factory-agent`.

**Step-by-step (manual control):**
1. Fill in `inputs/problem.yaml` and `inputs/students.yaml` (or run `@spec-builder-agent`)
2. Invoke `@planner-agent` (two mandatory human-review halts)
3. Invoke `@environment-scaffold-generator` (once)
4. Invoke `@chapter-supervisor-agent chapter_number: N` for each chapter
5. Invoke `@evaluator-agent` after all chapters
6. Invoke `@lab-generator` for the capstone

All outputs land in `outputs/` under the course slug.

**Large-course / low-context flow (recommended for many chapters):**

Generate one chapter per context window so the working set stays small and compaction
lands on clean boundaries:

```
/next-chapter          ← generates the next pending chapter, updates state, then HALTS
/compact               ← (optional) reset context at the clean checkpoint
/next-chapter          ← continue with the next chapter
```

Or drive it hands-free:

```
/loop /next-chapter    ← self-paces through every remaining chapter; ends when all are done
/course-status         ← lightweight progress readout (reads only PIPELINE_STATE.md)
```

`/next-chapter` and `/course-status` both rely on `_plan/PIPELINE_STATE.md` as the durable
source of truth, so they resume correctly after any compaction or new session.

### Context & Compaction Guidance

The pipeline is built for bounded context: `@chapter-supervisor-agent` and every
generator/evaluator run as **subagents**, so their heavy context is isolated and reclaimed
when they return. The orchestrator holds only state-file summaries. Consequently:

- **You do not need to `/compact` after every chapter.** With subagent isolation, the
  orchestrator window barely grows per chapter. Compact only if a single very long session
  is approaching the limit; the chapter boundary is where it lands cleanly.
- **A chapter is a checkpoint only after `PIPELINE_STATE.md` is written.** State on disk —
  not conversation memory — is authoritative. After any compaction, re-read it before continuing.
- **`/compact` is a user/harness action, not an agent tool.** Agents must not assume they can
  trigger it; they rely on durable state plus subagent isolation instead.
- **Prefer the loop-and-checkpoint pattern over manual compaction** for long runs: it keeps
  context naturally small and is fully resumable.

---

## Agent Pipeline Overview

```
subject-spec-builder-agent  ← optional step 0a: validates/builds inputs/subject.md
  │  Skill: /build-subject-spec
  │  Accepts: existing spec file, pasted outline, or topic description
  │  Validates: chapter count, duration, concept density, hands-on ratio, Bloom compatibility
  │  Produces: inputs/subject.md (validated curriculum contract)
  │  Uses AskUserQuestion to surface issues and gather user decisions

spec-builder-agent  ← optional step 0b: builds problem/student specs from unstructured docs
  │  Skill: /build-specifications
  │  Produces: inputs/problem.yaml, inputs/students.yaml
  │  Uses AskUserQuestion for interactive refinement + scope validation

course-factory-agent  ← top-level entry point (invokes everything below)
  │  Skill: /personalized-course-generator
  │  Manages: spec intake, state tracking, human-review halts, resumability
  │
  ├─ planner-agent
  │    └─ produces: _plan/course-plan.yaml, _plan/personalization-plan.json,
  │                 _plan/reserved-scenarios.json, _plan/PLAN_REVIEW.md
  │    └─ two mandatory human-review halts (Step 2 and Step 12)

  ├─ environment-scaffold-generator  [once, before any chapter]
  │
  ├─ chapter-supervisor-agent  [per chapter, sequential]
  │    ├─ Step 1: chapter-text-generator → chapter-text-evaluator
  │    ├─ Step 2: [PARALLEL] exercise-generator + quiz-generator + podcast-generator
  │    │          → exercise-evaluator + quiz-evaluator + podcast-evaluator
  │    ├─ Step 3: [PARALLEL] presentation-generator + companion-generator + glossary-aggregator
  │    │          → presentation-evaluator + companion-evaluator
  │    └─ Each pair uses the 3-attempt feedback loop; subagent isolation per pair
  │
  ├─ evaluator-agent  [course-wide, after all chapters]
  │    ├─ validates cross-chapter LO coverage
  │    ├─ validates running-example coherence
  │    └─ validates lab against reserved-scenarios.json
  │
  └─ lab-generator → lab-evaluator  [course-level capstone]
```

Each generator-evaluator pair operates under the Feedback Loop Protocol (see below).
Every evaluator spawns all 7 gate sub-agents in parallel.

---

## Feedback Loop Protocol

For each generator-evaluator pair:

```
attempt = 1  (max 3)
while attempt <= 3:
  invoke Generator with feedback_failures=[] (attempt 1) or populated list (retry)
  invoke Evaluator → spawns 7 gate sub-agents in parallel → returns verdict JSON
  if ALL MUST gates PASS → mark artifact verified; break loop
  else → collect all failing gate details → re-invoke Generator with feedback_failures[]
  attempt += 1
if all 3 attempts fail → HALT; surface to human; write failure in chapter.manifest.json
```

`feedback_failures[]` schema:
```json
[
  {
    "gate_id": "16.2",
    "gate_name": "pedagogy",
    "check": "retrieval_checkpoints",
    "actual": "0 checkpoints found",
    "required": "≥ 1 retrieval checkpoint per 3 sections"
  }
]
```

Gate sub-agent output format:
```json
{
  "gate_id": "16.N",
  "gate_name": "<name>",
  "status": "pass | fail",
  "failures": [
    { "check": "<what was checked>", "actual": "<what was found>", "required": "<what is required>" }
  ]
}
```

---

## Model Assignment

| Role | Agent(s) | Model | Rationale |
|------|----------|-------|-----------|
| Master orchestrator | `course-factory-agent` | `claude-opus-4-7` | Complex multi-phase orchestration with human-review halts |
| Planner | `planner-agent` | `claude-opus-4-7` | 12-step planning with curriculum design decisions |
| Course-wide evaluator | `evaluator-agent` | `claude-opus-4-7` | Cross-chapter analysis requiring deep reasoning |
| Chapter supervisor | `chapter-supervisor-agent` | `claude-sonnet-4-6` | Dispatch and feedback-loop management |
| Content generators (9) | `chapter-text-generator`, `exercise-generator`, `presentation-generator`, `quiz-generator`, `podcast-generator`, `companion-generator`, `lab-generator`, `environment-scaffold-generator`, `glossary-aggregator` | `claude-sonnet-4-6` | Content generation; detailed instructions come from skills |
| Artifact evaluators (7) | `chapter-text-evaluator`, `exercise-evaluator`, `presentation-evaluator`, `quiz-evaluator`, `podcast-evaluator`, `companion-evaluator`, `lab-evaluator` | `claude-sonnet-4-6` | Structured gate aggregation |
| Gate sub-agents (7) | `coverage-gate-evaluator`, `pedagogy-gate-evaluator`, `personalization-gate-evaluator`, `format-gate-evaluator`, `technical-gate-evaluator`, `accessibility-gate-evaluator`, `calibration-gate-evaluator` | `claude-sonnet-4-6` | Focused checklist evaluation |
| Spec builders (2) | `spec-builder-agent`, `subject-spec-builder-agent` | `claude-sonnet-4-6` | Interactive spec construction |

---

## Quality Gate Reference (§16)

| Gate | Agent | Checks |
|------|-------|--------|
| §16.1 Coverage | `coverage-gate-evaluator` | Every LO appears in ≥ 1 assessment; all Bloom tiers present |
| §16.2 Pedagogy | `pedagogy-gate-evaluator` | Retrieval checkpoints, worked examples, reflection prompts, ≥ 60 % hands-on |
| §16.3 Personalization | `personalization-gate-evaluator` | All examples from personalization-plan.json; running example consistent across artifacts |
| §16.4 Format | `format-gate-evaluator` | Word count, slide count, section order, file naming §5.2 |
| §16.5 Technical | `technical-gate-evaluator` | Code compiles, verify/ passes against solution/, preflight.sh succeeds |
| §16.6 Accessibility | `accessibility-gate-evaluator` | WCAG 2.2 AA: alt text, ≥ 4.5:1 contrast, no color-only info, font sizes |
| §16.7 Calibration | `calibration-gate-evaluator` | Difficulty heuristic 0.40–0.95, rubric schema, Flesch-Kincaid grade |

---

## Common Input Envelope (§19.2)

Every generator agent receives this envelope. Chapter-supervisor-agent is responsible for
constructing and passing it.

```yaml
common_inputs:
  course_slug:            <string>          # e.g. cowork-automation-01
  chapter:
    number:               <int>
    slug:                 <string>          # e.g. ch03-prompt-engineering
    title:                <string>
    est_minutes:          <int>             # total chapter time budget
    prerequisites:        [<chapter_slug>]
  learning_outcomes:
    - id:                 LO-NN.n
      verb:               <Bloom verb>
      object:             <what is learned>
      criterion:          <measurable criterion>
      bloom_level:        Remember|Understand|Apply|Analyze|Evaluate|Create
  problem_spec:           <full §3.2 object from course-plan.yaml>
  student_context:        <full §3.3 object from inputs/students.yaml>
  personalization_plan:   <path to _plan/personalization-plan.json>
  canonical_references:   [<reference objects>]
  mode_targets:           [self_taught, cohort]   # or subset
  numeric_overrides:      <optional overrides block>
  global_requirements:    <resolved object from inputs/general-requirements.yaml; null if file absent>
  output_paths:
    primary:              <path to primary artifact>
    sidecars:             [<paths>]
  quality_gates_to_satisfy: [16.1, 16.2, 16.3, 16.4, 16.5, 16.6, 16.7]
  feedback_failures:      []   # empty on first attempt; populated on retry
  forbidden_examples:     []   # scenarios reserved for capstone (reserved-scenarios.json)
```

---

## Handoff JSON Schema (`*--doc.handoff.json`)

Produced by `chapter-text-generator`. Passed explicitly to every downstream chapter generator.

```json
{
  "chapter": {
    "number": "<int>",
    "slug": "<string>",
    "title": "<string>",
    "est_minutes": "<int>"
  },
  "learning_outcome_refs": ["LO-NN.n"],
  "section_outline": [
    { "id": "<N.N>", "heading": "<string>", "bloom_tag": "<Bloom level>", "est_minutes": "<int>" }
  ],
  "running_example": {
    "scenario_ref": "<problem_spec.representative_scenarios[i].id>",
    "entities": [],
    "artifacts": []
  },
  "worked_example_seed": {
    "problem_statement": "<string>",
    "given_state": "<string>",
    "solution_steps": [],
    "final_state": "<string>",
    "decision_points": []
  },
  "glossary_delta": [
    { "term": "<string>", "definition": "<string>", "locale_translations": {} }
  ],
  "chapter_pitfalls": [
    { "misconception": "<string>", "why_wrong": "<string>", "correction": "<string>" }
  ],
  "retrieval_checkpoints": [
    { "section_id": "<N.N>", "prompt": "<string>", "target_lo_ref": "LO-NN.n" }
  ],
  "reflection_prompts": [
    { "prompt": "<string>" }
  ],
  "diagrams": [
    {
      "name": "<string>",
      "source_path": "<path to .mmd file>",
      "svg_path": "<path to .svg file>",
      "alt_text": "<string describing shapes and relationships>",
      "type": "C4 | sequence | ER | flowchart"
    }
  ],
  "quiz_seed": {
    "candidate_misconceptions": [],
    "candidate_scenarios": []
  },
  "reading_metrics": {
    "word_count": "<int>",
    "flesch_kincaid_grade": "<float>"
  }
}
```

---

## File Naming Convention (§5.2)

```
outputs/
  {course_slug}/
    _plan/                                                ← internal pipeline files
      course-plan.yaml
      personalization-plan.json
      reserved-scenarios.json
      subject-coverage-index.json
      PLAN_REVIEW.md
      CHANGELOG.md
    glossary.docx                                         ← student-facing reference (Word)
    prereq-diagnostic.md                                  ← internal planning artifact
    chapters/
      ch{NN}-{chapter_slug}/
        {course_slug}--ch{NN}--{chapter_slug}--doc.docx          ← chapter doc (Word)
        {course_slug}--ch{NN}--{chapter_slug}--doc.handoff.json   ← internal handoff
        {course_slug}--ch{NN}--{chapter_slug}--slides.pptx        ← slide deck (PowerPoint)
        {course_slug}--ch{NN}--{chapter_slug}--slides-notes.docx  ← presenter notes (Word)
        {course_slug}--ch{NN}--{chapter_slug}--quiz-questions.docx   ← student quiz questions (Word)
        {course_slug}--ch{NN}--{chapter_slug}--quiz-answers.docx   ← answer key + rationales (Word)
        {course_slug}--ch{NN}--{chapter_slug}--quiz-questions-formB.docx ← Form B questions (Word)
        {course_slug}--ch{NN}--{chapter_slug}--quiz-answers-formB.docx   ← Form B answers (Word)
        {course_slug}--ch{NN}--{chapter_slug}--quiz.json          ← quiz data (internal pipeline)
        {course_slug}--ch{NN}--{chapter_slug}--quiz-formB.json    ← quiz form B (internal pipeline)
        {course_slug}--ch{NN}--{chapter_slug}--podcast-script.md  ← recording script (internal)
        {course_slug}--ch{NN}--{chapter_slug}--cheatsheet.docx    ← cheatsheet (Word)
        {course_slug}--ch{NN}--{chapter_slug}--instructor-guide.docx ← instructor guide (Word)
        {course_slug}--ch{NN}--{chapter_slug}--exercises/
          manifest.json                                   ← pack metadata (internal)
          README.md                                       ← directory index (internal)
          worked-example/
            brief.docx                                    ← worked example instructions (Word)
            solution/                                     ← code files
            walkthrough.docx                              ← narrated solution (Word)
          exercise-02/
            brief.docx                                    ← completion exercise (Word)
            starter/                                      ← code scaffold
            solution/                                     ← code solution
            verify/                                       ← test scripts
            rubric.json                                   ← rubric data (internal)
            failure-modes.md                              ← failure reference (internal)
          exercise-NN/
            brief.docx
            starter/ | solution/ | verify/
            rubric.json | failure-modes.md
          debrief.docx                                    ← pack debrief (Word)
    capstone/
      {course_slug}--capstone-lab.docx                   ← capstone brief (Word)
      {course_slug}--capstone-lab-rubric.json             ← rubric data (internal)
      {course_slug}--capstone-instructor-guide.docx       ← instructor guide (Word)
      {course_slug}--capstone-debrief.docx                ← debrief & reflection (Word)
      capstone-starter/ | capstone-solution/ | capstone-verify/  ← code
    environment/
      devcontainer.json
      preflight.sh
      preflight.ps1
      reset-env.sh
    chapter.manifest.json   [per chapter, written by chapter-supervisor]
```

Naming rules:
- Slugs are lowercase, hyphen-separated, no underscores
- Chapter numbers are zero-padded to 2 digits: `ch01`, `ch02`, …
- All artifact filenames include the `{course_slug}` prefix
- **Student-facing deliverables are `.docx` (Word) or `.pptx` (PowerPoint)**
- Internal pipeline files (JSON, YAML, `.md` plan files, code) stay in their native format
- The podcast script stays `.md` — it is a recording production script, not a student deliverable

---

## Bloom's Taxonomy Verb Reference (§9.1)

| Level | Verbs |
|-------|-------|
| Remember | define, list, recall, identify, name, state, recognize |
| Understand | explain, describe, summarize, interpret, classify, compare |
| Apply | use, implement, execute, demonstrate, solve, apply |
| Analyze | distinguish, examine, break down, differentiate, investigate |
| Evaluate | assess, judge, critique, justify, defend, recommend |
| Create | design, construct, produce, develop, formulate, synthesize |

---

## Input Precedence (§3.5)

When specs conflict on pedagogical numerics:
```
General Requirements > Student Context > Problem Spec > Subject Spec > Orchestration Spec > Master Spec defaults
```

`inputs/general-requirements.yaml` holds explicit user requirements (total time, chapter count,
focus areas, excluded topics, difficulty target, artifact selection, custom instructions).
These take the highest priority. If this file is absent or a field is commented out, the
pipeline falls back to the chain below it.

The master spec's MUST gates cannot be overridden by any spec — not even General Requirements.
Numeric defaults (item counts, word budgets, time allocations) may be adjusted via
`inputs/orchestration.yaml` `numeric_overrides` block; all overrides MUST be logged in
`_plan/CHANGELOG.md`.

---

## Diagram Generation

Generators author diagram source files in **Mermaid** (`.mmd`) format alongside every diagram.
Export to SVG using the Mermaid CLI:

```bash
npx mmdc -i diagram.mmd -o diagram.svg
```

The `.mmd` source and the `.svg` export MUST both be committed. The SVG is the deliverable;
the `.mmd` is the editable source. Every diagram MUST include alt text in the handoff JSON
`diagrams[].alt_text` field describing both shapes and relationships.

---

## Personalization Invariants

- `personalization-plan.json` is produced once by `planner-agent` and is **read-only** for all
  downstream agents.
- `reserved-scenarios.json` lists scenarios reserved exclusively for the capstone lab. Chapter
  generators MUST NEVER consume a scenario listed in `reserved-scenarios.json`. The
  `forbidden_examples` field in the common envelope carries this list at runtime.
- All examples, scenarios, diagrams, and worked examples in every artifact MUST trace back to
  `personalization-plan.json.vocabulary_substitutions` or
  `problem_spec.representative_scenarios[]`.
- The chapter's **running example** must be the same instance across: chapter doc, slide deck,
  exercise pack, quiz, and podcast script (§7.15 Coherence Across Artifacts).
- Every generator MUST execute Steps P1–P4 of the **Personalization First Principle** (see above)
  before producing any content. Failing §16.3 (personalization gate) on first attempt is a process
  failure — not an acceptable retry scenario.
- FK grade is a hard constraint derived from `students.yaml.reading_level_target`. Content that
  exceeds the target grade by more than 1.5 points MUST be rewritten before submission.
- Prior knowledge listed in `students.yaml.prior_knowledge[]` MUST be referenced as assumed, not
  taught. Content that re-teaches declared prior knowledge wastes learner time and signals the
  generator did not read the student context.
- Domain vocabulary from `problem_spec.domain_vocabulary[]` and `vocabulary_substitutions` MUST
  appear in EVERY section of EVERY artifact — including worked examples, failure modes, retrieval
  checkpoints, and quiz distractors. No section is exempt from personalization.

---

## Anti-Patterns (§17) — FORBIDDEN in all artifacts

- Happy-path-only content with no failure modes, pitfalls, or debugging exercises
- Decorative graphics, mascots, background music, stock photos
- Placeholder text ("a user", "an item") not replaced by domain vocabulary
- Quizzes/exercises that introduce a domain not present in the chapter doc
- Distractors that are jokes or obviously wrong
- "All of the above" / "None of the above" options in quizzes
- Bare true/false items (must always be `tf_justified`)
- Single-form quizzes (Form B is always required)
- Chapter docs without retrieval checkpoints or reflection prompts
- Slide titles framed as topics ("Functions in Python") — must be conclusions
  ("Functions hide complexity")
- Worked examples placed after independent exercises
- Lab scenarios drawn from chapter content (capstone must use reserved scenarios only)
- **Bloom labels visible to students** (LO-IDs, `[Apply]` badges, Bloom level names in any
  student-facing text, slide, quiz, or exercise)
- **Em dashes** in any student-facing document (use periods, commas, or conjunctions)
- **§ symbols, section numbers, or internal codes** in student-facing headings or prose
- **Student materials delivered as non-Office formats** (JSON, YAML, MD) instead of `.docx`/`.pptx`

---

## Available Anthropic Skills

- **`anthropic-skills:pptx`** — generates `.pptx` PowerPoint slide decks; invoked by
  `presentation-generator` via the `Skill` tool
- **`anthropic-skills:docx`** — generates `.docx` Word documents; invoked by ALL content
  generators that produce student-facing text artifacts: `chapter-text-generator`,
  `exercise-generator`, `companion-generator`, `lab-generator`, `presentation-generator`
  (for speaker notes), `quiz-generator` (for student-facing quiz documents), and
  `glossary-aggregator`

Both skills are available globally in Claude Code; no installation or configuration required.
Invoke them via the `Skill` tool, passing the document content as input.

### When to use each skill

| Output needed | Skill to invoke | Applies to |
|---------------|----------------|------------|
| Student reads a chapter | `anthropic-skills:docx` | `chapter-text-generator` |
| Student works an exercise | `anthropic-skills:docx` | `exercise-generator` (brief.docx, walkthrough.docx, debrief.docx) |
| Instructor presents slides | `anthropic-skills:pptx` | `presentation-generator` |
| Instructor reads presenter notes | `anthropic-skills:docx` | `presentation-generator` (slides-notes.docx) |
| Student reads cheatsheet | `anthropic-skills:docx` | `companion-generator` |
| Instructor reads guide | `anthropic-skills:docx` | `companion-generator` |
| Student takes a quiz | `anthropic-skills:docx` | `quiz-generator` (quiz-questions.docx, quiz-answers.docx) |
| Student does capstone | `anthropic-skills:docx` | `lab-generator` (capstone-lab.docx, debrief.docx) |
| Student looks up terms | `anthropic-skills:docx` | `glossary-aggregator` |

---

## Spec Reference

| Document | Governs |
|----------|---------|
| `doc/GreatCourseSpec.md` | Master spec; all §N references point here |
| `doc/PlannerSpec.md` | `planner-agent` — 12-step algorithm |
| `doc/GreatTextSpec.md` | `chapter-text-generator` — chapter doc |
| `doc/GreatModuleExercise.md` | `exercise-generator` — exercise pack |
| `doc/GreatPresentationSpec.md` | `presentation-generator` — slide deck |
| `doc/GreatQuizSpec.md` | `quiz-generator` — quiz Forms A & B |
| `doc/GreatLabSpec.md` | `lab-generator` — capstone lab |
| `doc/DocxDesignSpec.md` | Document design + typography for all student-facing `.docx` files |
| `doc/MainSubjectSpec-Practical-Cowork-Automation.md` | Default subject spec (18-chapter Cowork Automation course) |

### Input Files

| File | Role | Required |
|------|------|----------|
| `inputs/subject.md` | **Curriculum contract** — defines topics, objectives, and chapter structure that MUST be taught | REQUIRED |
| `inputs/problem.yaml` | Problem domain — representative scenarios, domain vocabulary, success criteria | REQUIRED |
| `inputs/students.yaml` | Cohort profile — prior knowledge, reading level, professional context | REQUIRED |
| `inputs/orchestration.yaml` | Pipeline settings — quality gates, numeric overrides, output root | REQUIRED |
| `inputs/general-requirements.yaml` | Global user overrides — time, chapter count, difficulty, focus areas | OPTIONAL |
