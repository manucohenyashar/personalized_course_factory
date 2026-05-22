# Personalized Course Factory

A multi-agent Claude Code pipeline that generates complete, personalized technical training
courses from a subject specification, a problem domain, and a learner cohort description.

---

## What It Produces

For each chapter, the pipeline generates six artifacts:

| Artifact | File | Purpose |
|----------|------|---------|
| Chapter doc | `*--doc.md` | 3,500–6,000 word structured learning text |
| Exercise pack | `*--exercises/` | Worked example + completion + independent exercises |
| Slide deck | `*--slides.pptx` | 12–25 slide instructor deck + speaker notes |
| Quiz | `*--quiz.json` + `*--quiz-formB.json` | 10-item assessment (Form A + Form B) |
| Podcast script | `*--podcast-script.md` | 1,200–2,300 word audio narration |
| Companion | `*--cheatsheet.md` + `*--instructor-guide.md` | Quick reference + facilitation guide |

Plus course-level artifacts: capstone lab, master glossary, prerequisite diagnostic, and
lab environment scaffold.

All content is grounded in evidence-based learning science: Bloom's Taxonomy, retrieval
practice (Roediger & Karpicke), cognitive load theory (Sweller), Mayer's multimedia
principles, and the 4C/ID model.

---

## Quick Start

### Option A — One command (recommended)

Describe your course to Claude Code in plain language:

```
@course-factory-agent

Create a personalized course for warehouse logistics supervisors learning to use AI
for exception triage in SAP WMS. They have SQL experience but no ML background.
The course should cover prompt engineering, context injection, and batch automation.
Success criteria: students can build an automated triage pipeline and deploy it to
their WMS environment independently.
```

The factory agent will:
1. Parse your specifications and write the input files
2. Show you a **spec summary** for review → requires your approval
3. Run the planner and show a **normalization diff** → requires your approval
4. Show the **course plan** (chapters, LOs, scenarios) → requires your approval
5. Generate the environment, all chapters, evaluator, and capstone lab automatically
6. Deliver a completion report with links to all outputs

Two mandatory human-review halts occur during planning. All chapter generation runs
automatically after your approvals.

---

### Option B — Pre-fill the input files, then run

If you prefer to edit the input files yourself:

```
inputs/
  problem.yaml   ← REQUIRED: fill in problem domain + ≥ 4 representative scenarios
  students.yaml  ← REQUIRED: fill in cohort profile
  subject.md     ← optional: replace with your subject spec (default: Cowork Automation)
  orchestration.yaml  ← optional: adjust pipeline settings
```

Open each file and replace all `REPLACE_ME` values. Then:

```
@course-factory-agent
The input files are ready in inputs/. Generate the course.
```

---

### Option C — Step by step (advanced / manual control)

Run each agent individually for full control:

```
@planner-agent                              ← Step 1: plan (two human-review halts)
@environment-scaffold-generator             ← Step 2: environment (once)
@chapter-supervisor-agent chapter_number: 1 ← Step 3: repeat for each chapter
@evaluator-agent                            ← Step 4: course-wide evaluation
@lab-generator                              ← Step 5: capstone lab
```

### Resuming after interruption

If generation was interrupted, re-invoke `@course-factory-agent`. It will detect the
saved pipeline state and offer to resume from where it left off — no need to restart
from scratch.

---

## Pipeline Architecture

```
planner-agent (opus)
  └─ two human-review halts: Step 2 (normalization) + Step 12 (PLAN_REVIEW.md)
  └─ outputs: _plan/course-plan.yaml, personalization-plan.json, reserved-scenarios.json

environment-scaffold-generator (sonnet)  [run once]

chapter-supervisor-agent (sonnet)  [per chapter, max 3 retries per artifact]
  ├─ chapter-text-generator    → chapter-text-evaluator    [sequential]
  ├─ exercise-generator        → exercise-evaluator        [sequential]
  ├─ presentation-generator ─┐ → presentation-evaluator ─┐ [parallel]
  ├─ quiz-generator         ─┘ → quiz-evaluator          ─┘
  ├─ podcast-generator         → podcast-evaluator        [sequential]
  ├─ companion-generator       → companion-evaluator      [sequential]
  └─ glossary-aggregator                                  [after all pass]

evaluator-agent (opus)  [after all chapters]

lab-generator (sonnet)   → lab-evaluator (opus)
```

Every evaluator spawns all 7 quality gate sub-agents in parallel.

---

## Quality Gates

Every artifact must pass 7 quality gates before shipping:

| Gate | Checks |
|------|--------|
| §16.1 Coverage | Every LO in ≥ 1 assessment; all Bloom tiers present |
| §16.2 Pedagogy | Retrieval checkpoints, worked examples, ≥ 60% hands-on time |
| §16.3 Personalization | All examples from personalization plan; no forbidden scenarios |
| §16.4 Format | Word count, slide count, section order, file naming |
| §16.5 Technical | Code compiles, verify/ passes, preflight succeeds |
| §16.6 Accessibility | WCAG 2.2 AA: alt text, contrast, no color-only info |
| §16.7 Calibration | Difficulty heuristic, rubric schema, FK reading grade |

On any gate failure, the generator is re-invoked with the specific failures as feedback
(up to 3 attempts). On 3rd failure, the pipeline halts and asks for human intervention.

---

## Changing the Subject

To generate a course on a different topic:
1. Replace `inputs/subject.md` with your subject specification
2. Fill in `inputs/problem.yaml` and `inputs/students.yaml` for your domain
3. Run `@planner-agent`

The default subject (`inputs/subject.md`) is an 18-chapter course on Claude-based workflow
automation for knowledge workers (Cowork Automation).

---

## Repository Structure

```
.claude/
  agents/           ← 26 agent files (generators, evaluators, gate sub-agents)
  skills/           ← 5 skill files (detailed generation instructions)
  settings.json     ← project permissions

doc/                ← specification documents (read-only)
  GreatCourseSpec.md         ← master spec
  PlannerSpec.md
  GreatTextSpec.md
  GreatModuleExercise.md
  GreatPresentationSpec.md
  GreatQuizSpec.md
  GreatLabSpec.md
  MainSubjectSpec-Practical-Cowork-Automation.md

inputs/             ← user-supplied configuration (edit these)
  subject.md        ← subject specification
  problem.yaml      ← problem domain + scenarios (REQUIRED)
  students.yaml     ← cohort profile (REQUIRED)
  orchestration.yaml ← pipeline settings

outputs/            ← generated course content (created at runtime)
  {course_slug}/
    _plan/
    chapters/
    capstone/
    environment/
    glossary.md
    COURSE_VERDICT.md

CLAUDE.md           ← project guide + shared schemas (always loaded by Claude Code)
```

---

## Spec Precedence

When specifications conflict on pedagogical numerics:

```
Student Context > Problem Spec > Subject Spec > Orchestration Spec > Master Spec defaults
```

The master spec's MUST gates cannot be overridden. Numeric defaults (word counts, slide
counts, quiz item counts) can be adjusted in `inputs/orchestration.yaml`.

---

## Requirements

- Claude Code (latest)
- Node.js (for `npx mmdc` — Mermaid diagram export)
- Lab environment tools as declared in your subject spec (Python, etc.)
- The `anthropic-skills:pptx` and `anthropic-skills:docx` skills (available globally in Claude Code)
