---
name: generate-lab
description: Full generation instructions for the course-level Capstone Lab following GreatLabSpec v2. Covers the complete output layout, capstone-brief.md 14-section structure, rubric schema (6 criteria per §9.4), pedagogy operationalization (interleaving ≥60% chapters, worked→completion→independent, failure-first, Bloom Apply+Analyze+Create), environment integration, personalization rules, and quality gates. Invoked by lab-generator.
---

# Generate Lab — Detailed Instructions (GreatLabSpec v2)

---

## 0. The Capstone Lab IS the Student's Problem

Before reading anything else, internalize this:

> **The capstone is not a course review exercise. It is the implementation of the specific
> problem the students came to this course to solve, as declared in `inputs/problem.yaml`.**

The pipeline runs as follows:
1. The students arrive with a real problem (`problem_spec.summary`).
2. The course teaches them the skills to solve it (`learning_outcomes` across chapters).
3. The capstone is where they put those skills together to actually solve their problem.

This means:
- `problem_spec.summary` → the capstone problem statement (Section 1 of the brief)
- `problem_spec.success_criteria[]` → the capstone acceptance criteria (Sections 5 and 7)
- `problem_spec.domain_vocabulary[]` → the vocabulary used throughout every file
- The reserved scenario → the **specific instance** of the problem (concrete data, stakeholders, constraints)

A completed lab is a working solution to the student's problem — not a demonstration that they
can perform course exercises in a new context.

### Problem-to-Lab Mapping (required before writing the section plan)

Read `problem_spec.success_criteria[]`. Build this table:

```
| success_criteria item | Capstone section | Stage | LO refs | Verify check |
|-----------------------|-----------------|-------|---------|--------------|
| {criterion 1}         | S2              | completion | LO-05.1 | s2.sh |
| {criterion 2}         | S3              | completion | LO-07.3 | s3.sh |
| {criterion 3}         | S4              | independent | LO-11.2 | s4.sh |
```

Rules:
- EVERY `success_criteria` item must appear in this table.
- A criterion that cannot be satisfied by available chapter LOs MUST be noted as a stretch goal,
  but its section must still exist in the main lab (with partial implementation scaffolded).
- If multiple criteria map to the same section, that section MUST have a distinct acceptance
  criterion per `success_criteria` item and a separate verify check per criterion.
- The worked-example section (S1) shows the solution architecture; it exercises NO criteria
  directly (the learner observes, not implements). Criteria are exercised in S2 onward.

---

## 1. Critical Invariant — Unseen Scenario

The capstone scenario MUST come from `_plan/reserved-scenarios.json`. Before generating
anything, verify:

1. Read `reserved-scenarios.json.reserved_for_capstone[]` — pick one scenario ID.
2. Read `personalization_plan.running_example_per_chapter` — collect all scenario IDs already
   used across chapters.
3. Confirm your chosen scenario ID does NOT appear in step 2.
4. If no scenario remains unused → **HALT** and tell the user:
   > "No reserved scenario is available. Expand `inputs/problem.yaml` with at least one
   > additional representative scenario, then re-run the planner."

---

## 2. Integration Requirement

The capstone MUST integrate **≥ 60 % of the course's chapters**. Compute:

```
required_chapters = ceil(total_chapters * 0.60)
```

From `all_chapter_handoffs[]`, identify which chapters teach skills that the capstone scenario
requires. The union of `learning_outcome_refs` cited in the capstone's section LO references
MUST cover at least `required_chapters` distinct chapter numbers.

Map this explicitly before writing the brief:

| Section | Chapter(s) exercised | LO-IDs |
|---------|----------------------|---------|
| S1 | ch03, ch05 | LO-03.2, LO-05.1 |
| … | … | … |

---

## 3. Output Layout

All filenames follow `capstone-{artifact}.{ext}` (master §5.2).

```
outputs/{course_slug}/capstone/
  README.md                                         ← entry point + navigation
  capstone-lab.docx                 ← 14-section lab document (Word — student-facing)
  capstone-lab-rubric.json              ← 6-criterion rubric (internal)
  capstone-starter/                 ← TODO-marked scaffold files (code)
  capstone-solution/                ← instructor-only canonical solution (code)
  capstone-verify/                  ← public + hidden tests + expected outputs (code)
  capstone-failure-modes.md         ← ≥ 3 documented failure modes (internal)
  capstone-instructor-guide.docx    ← timing, demo notes, common mistakes (Word — instructor-facing)
  capstone-debrief.docx             ← reflection prompts + self-scoring sheet (Word — student-facing)
  capstone-environment/             ← delta from course environment (if any)
    preflight.sh / preflight.ps1
    reset.sh
```

### README.md (entry point)

```markdown
# {course_slug} — Capstone Lab

**Estimated time:** {N} minutes
**Chapters covered:** ch{NN}, ch{NN}, …

## Files

| File | Purpose |
|------|---------|
| `capstone-lab.docx` | Lab instructions — start here |
| `capstone-lab-rubric.json` | Assessment rubric |
| `capstone-starter/` | Your starting files |
| `capstone-verify/` | Run `verify.sh` to check your work |
| `capstone-debrief.docx` | Reflection + self-scoring |

## Setup

Run `capstone-environment/preflight.sh` before starting.
```

---

## 4. Time Budget Rules

- Total time MUST be **60–180 minutes** (sum of section `time_box_minutes`).
- Each section MUST be **≤ 30 minutes** (keeps the lab interruptible without losing context).
- `preflight.sh` run time MUST NOT count toward the 60–180 minute total.
- Stretch goals MUST be time-boxed separately and MUST NOT count toward the total.

Default target: ~120 minutes for a 10–15 chapter course.

---

## 5. Pedagogy: Worked → Completion → Independent

Structure sections across the capstone in three stages (master §7.7):

| Stage | Position | Description |
|-------|----------|-------------|
| Worked example | First section (S1) | Narrated architectural overview showing the shape of the solution; included in `capstone-brief.md` as step-by-step with rationale |
| Completion | Middle sections (S2–SN-1) | `starter/` scaffold with TODO blocks (≥ 30 % of lines marked); acceptance criteria per section |
| Independent | Final section(s) (SN) | Brief + tests only; no step-by-step guidance |

The capstone MUST NOT provide step-by-step guidance in the independent sections.

### Bloom Tier Coverage (master §9.4)

The capstone MUST include explicit tasks at **all three** of:
- **Apply** — use, implement, configure, execute something the learner was taught
- **Analyze** — debug, investigate, differentiate, examine an unexpected result
- **Create** — design, compose, build, synthesize something not shown in any chapter

A capstone that never reaches **Create** MUST be rewritten.

---

## 6. `capstone-brief.md` — 14-Section Structure

### Front-matter

```yaml
---
course_slug: <string>
version: "1.0.0"
edition_date: <ISO date>
locale: <IETF tag from student_context>
est_minutes: <int 60–180>
learning_outcome_refs:
  - { id: "LO-03.2", chapter: 3, bloom: "Apply" }
  - { id: "LO-05.1", chapter: 5, bloom: "Analyze" }
chapters_covered: [3, 5, 7, 9, 11, 13]
tool_versions:
  - { tool: "<name>", version: "<pinned version>" }
---
```

### Section 1 — Business Motivation (300–500 words)

**This section must be derived directly from `problem_spec.summary` and `problem_spec.success_criteria[]`.**
It is not a generic introduction — it IS the problem the students enrolled to solve.

Write it as:
1. **The situation** (1–2 paragraphs): paraphrase `problem_spec.summary` in the cohort's domain
   register. Name the domain system, the protagonists, and the real cost of the problem existing.
   Use `personalization_plan.vocabulary_substitutions` throughout.

2. **What a good solution looks like** (1 paragraph): enumerate `problem_spec.success_criteria[]`
   in plain language. These are the criteria the student's completed lab MUST satisfy.

3. **Why this course prepared you** (1 short paragraph): connect to the chapter skills used
   without referencing chapter numbers. "You now know how to {verb from LO} — this lab is
   where that skill meets the real problem."

Do NOT reference any specific chapter by number here. Do NOT introduce the scenario yet —
this section is about the problem, not the specific instance being solved.

Example frame (adapt to actual domain):
> "Every afternoon, Sara's logistics team manually reviews 150+ exception records in SAP WMS.
> Each one requires a classification decision. A mis-classification costs the team an average
> of 4 hours of rework. The team has been looking for an automated triage solution for two years.
> This lab is that solution. By the end of this lab, you will have built a system that:
> (1) automatically classifies exceptions by type and severity, (2) routes them to the correct
> resolution workflow, and (3) generates an audit-ready summary for the dock supervisor.
> These are the exact criteria your team defined as success."

### Section 2 — Learning Outcomes

List every LO-ID the capstone exercises, with:
- Source chapter number
- Bloom tier
- One sentence connecting the LO to the capstone scenario

Format:
```markdown
| LO | Chapter | Bloom | Connection to this lab |
|----|---------|-------|----------------------|
| LO-03.2 | 3 | Apply | You'll implement {technique} as part of {capstone deliverable} |
```

### Section 3 — Prerequisites & Preflight

```markdown
## Prerequisites & Preflight

**Required chapters:** {list chapter numbers and titles}

**Environment setup:**
1. Open a terminal in the capstone directory.
2. Run: `bash capstone-environment/preflight.sh`
3. Confirm output: "All checks passed."

**Activate environment:** `{activation command}`
```

### Section 4 — Environment & Pinned Tools

Reference `lab_environment_manifest`. List every tool with its exact pinned version.
Note any capstone-specific additions (delta from course environment):

```markdown
## Environment & Tools

This lab uses the course-wide environment. See `environment/devcontainer.json`.

| Tool | Version | Used for |
|------|---------|---------|
| Python | 3.11.9 | {purpose} |
| … | … | … |

**Capstone-specific additions:** {list or "none"}
```

### Section 5 — Scenario (the specific instance of the problem)

This section presents the reserved scenario as the **concrete instance** of the problem
defined in Section 1. The learner has already seen the abstract problem (Section 1) and
the skills to solve it (the course). Now they meet the specific case they will solve.

Structure:

```markdown
## The Scenario

{1 paragraph}: {Protagonist from reserved scenario} at {organization from scenario.entities}
is facing **the specific instance** of the problem you read about in Section 1.
Here is the situation in detail:

{2–3 paragraphs describing the specific case}:
- Who: {protagonist name and role from scenario.entities[0]}
- What: {the specific domain object/event they are dealing with, from scenario.artifacts[]}
- Context: {business context — volume, deadline, stakeholders, system state}
- Constraints: {technical and domain constraints from the scenario}
- Stakes: {what happens if this is not solved — from problem_spec.success_criteria framing}

### Inputs You Are Given

{List every file/dataset in `starter/` with its domain meaning:}
- `{filename}`: {domain description — what this data represents in the scenario}
  Format: {format}. Content: {N} {vocab.item}s in state {domain state}.
- `{filename 2}`: {domain description}

### Your Acceptance Criteria

**These come directly from `problem_spec.success_criteria[]`.**
Your solution is complete when ALL of the following are true:

{For each success_criteria item, restate it in terms of the scenario's specific entities:}
- [ ] **{criterion 1 restated}**: e.g., "All {N} {vocab.item}s in `{input_file}` are classified
      into one of the {M} types defined in `{config_file}`; no item is left unclassified."
- [ ] **{criterion 2 restated}**: e.g., "The audit summary produced by your solution matches
      `expected-output.json` within the tolerance defined in `verify/s3.sh`."
- [ ] {criterion 3...}

The verify suite (`capstone-verify/all.sh`) checks each criterion programmatically.
```

### Section 6 — Architecture Overview

The architecture diagram shows the complete solution to the student's problem — not a generic
system diagram. Every component in the diagram must correspond to a real part of the solution
that the student will build. Components that are not built in the lab (e.g., downstream systems)
must be clearly labeled as "external / not built here."

The diagram must show:
- **Inputs**: the exact input files/APIs from the scenario (named with domain names)
- **Processing stages**: one component per capstone section (S2, S3, S4…), labeled by
  what it does to the `vocab.item` in the problem
- **Outputs**: the exact deliverables required by `problem_spec.success_criteria[]`
- **Domain system integration**: where the solution connects to `vocab.system`

Generate one diagram (C4 preferred; sequence or ER if more appropriate):

```bash
npx mmdc -i capstone-architecture.mmd -o capstone-architecture.svg
```

Alt text must describe shapes AND relationships — name the domain components, not just
"boxes and arrows."

```markdown
## Architecture Overview

![{alt text: "Diagram showing {input_1} and {input_2} flowing into the {domain_process} pipeline,
   which produces {output_1} (satisfying criterion 1) and {output_2} (satisfying criterion 2).
   The pipeline has three stages: {S2 stage name}, {S3 stage name}, and {S4 stage name}."}]
   (capstone-architecture.svg)

{2–3 sentences}: Your solution takes {input description from scenario} and produces
{output description from success_criteria}. It does this through three stages:
{stage 1 — one sentence}, {stage 2 — one sentence}, {stage 3 — one sentence}.
This architecture applies skills from Chapters {list} to solve the problem end-to-end.
```

### Section 7 — Section-by-Section Plan

Summarize the sections before presenting the steps. Every section must declare:

```markdown
## Lab Sections

| Section | Title | Time | Stage | LOs | Acceptance Criterion |
|---------|-------|------|-------|-----|----------------------|
| S1 | {title} | {N} min | worked_example | LO-03.2 | {verifiable criterion} |
| S2 | {title} | {N} min | completion | LO-05.1 | {criterion} |
| SN | {title} | {N} min | independent | LO-09.3 | {criterion} |
```

Total time sum MUST be 60–180 min. No section MUST exceed 30 min.

### Sections 8 onward — Steps (one subsection per section S1…SN)

For each section, follow this template exactly:

```markdown
## Section S{N}: {title} [{stage}] [{time_box_minutes} min]

**Learning outcomes:** LO-NN.n, LO-MM.m
**Bloom tier:** Apply | Analyze | Create
**Acceptance criterion:** {observable, verifiable}

### Overview
{1–2 sentences explaining what the learner will build in this section}

### Steps

**Step 1: {imperative verb} {object}**

{Why this step — explicit rationale}

```{language}
{syntactically valid, linted, pinned-version code or command}
```

**Expected output:**
```
{exact expected output or description of the correct state}
```

**Verification:** run `bash capstone-verify/s{N}-step1.sh`

> **Failure Mode:** If you see `{error}`, that means {cause}. Fix: {specific fix}.

**Step 2: ...**

### Completion Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}

**Link to verify:** `bash capstone-verify/s{N}.sh`
```

Rules for steps:
- Use **imperative verbs**: "Configure", "Run", "Implement" — never "The learner should…"
- Every code block must be syntactically valid and use only pinned versions
- Every step must have an expected output
- At least one failure mode distributed across sections (total ≥ 3 across all sections)

### Section 9 — Failure Modes & Debugging

(The ≥ 3 failure modes may appear inline per step AND be aggregated here from
`capstone-failure-modes.md`.)

Each entry:
```markdown
## Failure Mode: {descriptive name}

**Broken state:** {what the learner's code or environment looks like}

**Expected error or symptom:**
```
{exact error message or observable wrong behavior}
```

**Diagnostic procedure:**
1. Check {specific thing}
2. Run `{diagnostic command}` and look for `{pattern}`

**Fix:** {specific correction with example}
```

### Section 10 — Validation

```markdown
## Validation

Run the full verify suite:
```bash
bash capstone-verify/all.sh
```

**Pass criteria:** all N checks pass with exit code 0.

**What's checked:**
- {check 1 description}
- {check 2 description}
```

### Section 11 — Rubric Self-Score Sheet

Mirror the rubric for learner self-assessment:

```markdown
## Self-Score Sheet

Before submitting, score yourself honestly.

| Criterion | Weight | 1 | 2 | 3 | 4 | Your score |
|-----------|--------|---|---|---|---|-----------|
| Correctness | 25 % | Does not work | Works for basic cases | Works; 1 edge case fails | Works for all cases | |
| Approach | 20 % | … | … | … | … | |
| Code quality | 20 % | … | … | … | … | |
| Communication | 15 % | … | … | … | … | |
| Domain fit | 10 % | … | … | … | … | |
| Reflection | 10 % | … | … | … | … | |

**Passing average:** 3.0 / 4.0
**Weighted score:** sum(score × weight) / sum(weights)
```

### Section 12 — Debrief (`capstone-debrief.docx`)

Write as a separate file. Must contain:

```markdown
# Capstone Debrief

## Reflection Prompts

All three prompts are anchored to the PROBLEM and the student's real work — not to the course.

1. **Problem-solution fit** (requires integration of ≥ 2 chapter skills):
   "{Before this course, the team spent N hours/week on this problem. Looking at the solution
   you built: which two techniques from the course contributed most to making it work? What
   would the solution look like if you had to remove one of them?}"

2. **Trade-off evaluation** (requires Evaluate-level thinking):
   "{In Section S{N}, you chose {approach} to handle {domain constraint}. Under what conditions
   would {alternative approach} have been the better choice? Name a real scenario in your team's
   work where you'd switch.}"

3. **Transferability** (requires metacognition):
   "{What would you change about this solution before putting it into production in your actual
   {vocab.system}? Name one technical change, one process change, and one thing you would
   validate with a domain expert before going live.}"

## Transfer Prompt

**The problem you solved here is version 1.** How would you redesign your solution if
{one significantly different constraint from the domain — different data volume, different
regulatory requirement, different integration partner, or different team ownership model}?
Specifically:
- What would you keep from your current solution?
- What would you discard or redesign?
- What new skills or techniques would you need (that were NOT covered in this course)?

This question has no right answer — it is about your ability to think beyond the exercise.

## Self-Score Sheet

{Identical to Section 11 — Rubric Self-Score Sheet above}
```

### Section 13 — Stretch Goals (optional)

```markdown
## Stretch Goals *(optional — not included in the {N}-minute budget)*

- **{goal title}** (≈ {N} min): {description}
```

### Section 14 — Instructor Guide (`capstone-instructor-guide.docx`)

```markdown
# Instructor Guide — Capstone Lab

## Overview
- **Estimated total time:** {N} min
- **Chapters integrated:** {list}
- **Scenario:** {scenario title}

## Pre-Session Checklist
- Run preflight.sh on instructor machine
- Confirm capstone-solution/ is NOT distributed to learners
- Pre-load demo with working solution for S1 walkthrough

## Section-by-Section Timings

| Section | Time | Common mistakes | Discussion prompt |
|---------|------|----------------|------------------|
| S1 | {N} min | {mistake 1} | {discussion question} |

## Demo Walkthrough Script (S1 — worked example)
{Narrated step-by-step demo notes for the worked-example section}

## Common Mistakes Across All Sections
{3–5 specific mistakes learners make, with corrections}

## Debrief Facilitation
{How to run the debrief; expected answers to reflection prompts}
```

---

## 7. Rubric — 6 Criteria (GreatLabSpec §8 / master §9.4)

```json
{
  "lab_id": "{course_slug}--capstone",
  "passing_average": 3.0,
  "criteria": [
    {
      "id": "correctness",
      "weight": 0.25,
      "descriptors": {
        "1": "Solution does not pass any verify/ checks; none of problem_spec.success_criteria[] are satisfied.",
        "2": "Solution satisfies fewer than half of problem_spec.success_criteria[]; basic verify/ checks pass but integration checks fail.",
        "3": "Solution satisfies all problem_spec.success_criteria[]; passes all standard verify/ checks; one edge-case check fails.",
        "4": "Solution satisfies all problem_spec.success_criteria[] and all verify/ checks including edge cases and integration tests."
      }
    },
    {
      "id": "approach",
      "weight": 0.20,
      "descriptors": {
        "1": "Approach does not apply the techniques taught in the course.",
        "2": "Approach applies course techniques but misapplies ≥ 1 in a significant way.",
        "3": "Approach correctly applies course techniques; minor sub-optimal choices.",
        "4": "Approach is optimal, well-reasoned, and clearly integrates skills from ≥ 3 chapters."
      }
    },
    {
      "id": "code_quality",
      "weight": 0.20,
      "descriptors": {
        "1": "Code is unreadable; fails linter with errors.",
        "2": "Code is readable but has significant style issues or fails linter with warnings.",
        "3": "Code is clean; passes linter; minor style inconsistencies.",
        "4": "Code is exemplary: clear naming, consistent style, passes linter at defaults, minimal necessary comments."
      }
    },
    {
      "id": "communication",
      "weight": 0.15,
      "descriptors": {
        "1": "No explanation of decisions provided.",
        "2": "Explanation describes what was done but not why decisions were made.",
        "3": "Explanation addresses both what and why; minor gaps in decision rationale.",
        "4": "Explanation is clear, complete, and explicitly connects decisions to course LOs and the capstone scenario's constraints."
      }
    },
    {
      "id": "domain_fit",
      "weight": 0.10,
      "descriptors": {
        "1": "Solution ignores the domain context: uses generic variable names, does not operate on the scenario's actual entities, or misidentifies the problem being solved.",
        "2": "Solution partially addresses the domain: uses some domain vocabulary but ≥ 1 success_criteria item is ignored or misunderstood.",
        "3": "Solution is clearly built for THIS domain and THIS problem; all success_criteria are addressed; minor vocabulary inconsistencies (e.g., a generic variable name in one function).",
        "4": "Solution is indistinguishable from what a domain expert would write: all success_criteria satisfied, all domain vocabulary used correctly throughout every file, the solution could be handed directly to a colleague and they would recognize it as relevant to their work."
      }
    },
    {
      "id": "reflection",
      "weight": 0.10,
      "descriptors": {
        "1": "Debrief left blank or contains fewer than 2 reflection responses.",
        "2": "Debrief answers describe what was done but show no critical thinking.",
        "3": "Debrief shows genuine reflection on trade-offs and one area for improvement.",
        "4": "Debrief demonstrates deep integration insight, explicitly addresses the transfer prompt, and includes a concrete next-action."
      }
    }
  ]
}
```

Weights: 0.25 + 0.20 + 0.20 + 0.15 + 0.10 + 0.10 = 1.00 ✓

---

## 8. Verify Script Pattern

`capstone-verify/all.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Capstone Verify Suite ==="

run_check() {
  local name=$1; local script=$2
  echo -n "  Checking: $name ... "
  if bash "$script" &>/dev/null; then echo "PASS"; else echo "FAIL"; exit 1; fi
}

run_check "Section 1 output" "$(dirname "$0")/s1.sh"
run_check "Section 2 output" "$(dirname "$0")/s2.sh"
# ... one check per section

echo "=== All checks passed ==="
```

Per-section verify scripts reference `../capstone-solution/` (same pattern as exercise verify/).

---

## 9. Track Variants (master §7.8)

When `target_level ∈ {intermediate, advanced}` in `student_context`, emit two parallel tracks:

```
capstone-starter/
  novice-track/      ← more scaffolding: worked-example section is narrated, more TODO contracts
  practiced-track/   ← less scaffolding: worked-example converted to brief, tighter TODO contracts
```

The tracks MUST be meaningfully different — not just cosmetically different instructions.

---

## 10. Personalization Rules

- All entity names, system names, file names, and domain terms MUST come from
  `personalization_plan.vocabulary_substitutions` and the reserved scenario's `entities[]`
  and `artifacts[]`.
- No generic placeholders ("a user", "the system", "an item") permitted.
- All terminology MUST match `outputs/{course_slug}/glossary.docx`.
- The capstone MUST NOT introduce any domain not represented in `problem_spec`.

---

## 11. Starter/ Files

`capstone-starter/` contains:
- All input data files referenced in the scenario
- Skeleton code/config with TODO blocks (≥ 30 % of lines for completion sections)
- The independent section's starter has only imports and function signatures
- A `README.md` pointing to `capstone-brief.md` as the primary instruction source

---

## 12. Quality Gate Self-Check (before writing output)

**Problem fidelity (check these first — they are the most important):**
- [ ] Problem-to-lab mapping table is complete: every `problem_spec.success_criteria[]` item
      maps to at least one capstone section with a verify check
- [ ] Section 1 (Business Motivation) is derived from `problem_spec.summary` — not invented
- [ ] Section 5 acceptance criteria restate `problem_spec.success_criteria[]` in scenario terms
- [ ] The architecture diagram components correspond 1:1 with the solution stages (no phantom components)
- [ ] `capstone-solution/` actually satisfies all `problem_spec.success_criteria[]` (logical check)
- [ ] The transfer prompt in debrief.md names a real domain constraint variation, not a generic hypothetical
- [ ] No acceptance criterion is only tested by a stretch goal — all must be in the main lab

**Structure and pedagogy:**
- [ ] Scenario ID is in reserved-scenarios.json and NOT in any chapter's running_example
- [ ] Section LO refs cover ≥ 60 % of total chapters
- [ ] Explicit tasks at Apply, Analyze, and Create Bloom tiers present
- [ ] Section sequence: worked_example first → completion → independent last
- [ ] Every section ≤ 30 min; total 60–180 min
- [ ] ≥ 3 failure modes distributed across sections (not all at the end)
- [ ] Every step has: imperative verb, code, expected output, verify link, LO ref

**Format and technical:**
- [ ] rubric.json has exactly 6 criteria with correct weights (sum = 1.0)
- [ ] debrief.md has 3 reflection prompts + 1 transfer prompt + self-score sheet
- [ ] capstone-verify/ passes against capstone-solution/ (logical check)
- [ ] All entity names from personalization plan; no generic placeholders
- [ ] All figures have alt text; code is plain text; no color-only information
- [ ] Filenames match capstone-{artifact}.{ext}
