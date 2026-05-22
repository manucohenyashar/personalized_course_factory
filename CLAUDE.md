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

## Quick Start

**One-command generation:**
```
@course-factory-agent

Create a personalized course for [describe your students and domain].
```

The factory agent handles the complete pipeline. Two human-review halts occur during
planning (normalization diff + plan review). Everything else runs automatically.

**Step-by-step (manual control):**
1. Fill in `inputs/problem.yaml` and `inputs/students.yaml`
2. Invoke `@planner-agent` (two mandatory human-review halts)
3. Invoke `@environment-scaffold-generator` (once)
4. Invoke `@chapter-supervisor-agent chapter_number: N` for each chapter
5. Invoke `@evaluator-agent` after all chapters
6. Invoke `@lab-generator` for the capstone

All outputs land in `outputs/` under the course slug.

---

## Agent Pipeline Overview

```
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
  │    ├─ chapter-text-generator → chapter-text-evaluator
  │    ├─ exercise-generator     → exercise-evaluator
  │    ├─ presentation-generator → presentation-evaluator  (parallel)
  │    ├─ quiz-generator         → quiz-evaluator          (parallel)
  │    ├─ podcast-generator      → podcast-evaluator
  │    ├─ companion-generator    → companion-evaluator
  │    └─ glossary-aggregator (incremental, after each chapter)
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
    _plan/
      course-plan.yaml
      personalization-plan.json
      reserved-scenarios.json
      PLAN_REVIEW.md
      CHANGELOG.md
    glossary.md
    prereq-diagnostic.md
    chapters/
      ch{NN}-{chapter_slug}/
        {course_slug}--ch{NN}--{chapter_slug}--doc.md
        {course_slug}--ch{NN}--{chapter_slug}--doc.handoff.json
        {course_slug}--ch{NN}--{chapter_slug}--slides.pptx
        {course_slug}--ch{NN}--{chapter_slug}--slides-notes.md
        {course_slug}--ch{NN}--{chapter_slug}--quiz.json
        {course_slug}--ch{NN}--{chapter_slug}--quiz-formB.json
        {course_slug}--ch{NN}--{chapter_slug}--podcast-script.md
        {course_slug}--ch{NN}--{chapter_slug}--cheatsheet.md
        {course_slug}--ch{NN}--{chapter_slug}--instructor-guide.md
        {course_slug}--ch{NN}--{chapter_slug}--exercises/
          manifest.json
          README.md
          worked-example/
          exercise-02/
          exercise-NN/
          debrief.md
    capstone/
      {course_slug}--capstone-lab.md
      {course_slug}--capstone-lab-rubric.json
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
Student Context > Problem Spec > Subject Spec > Orchestration Spec > Master Spec defaults
```

The master spec's MUST gates cannot be overridden by any spec. Numeric defaults (item counts,
word budgets, time allocations) may be adjusted via `inputs/orchestration.yaml`
`numeric_overrides` block; all overrides MUST be logged in `_plan/CHANGELOG.md`.

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

---

## Available Anthropic Skills

- **`anthropic-skills:pptx`** — generates `.pptx` slide decks; invoked by
  `presentation-generator` via the `Skill` tool
- **`anthropic-skills:docx`** — generates `.docx` documents; invoked by `companion-generator`
  for instructor guides when `.docx` output is needed

Both skills are available globally; no installation required.

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
| `doc/MainSubjectSpec-Practical-Cowork-Automation.md` | Default subject spec (18-chapter Cowork Automation course) |
