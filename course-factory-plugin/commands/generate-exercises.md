---
name: generate-exercises
description: Detailed composition rules for the per-chapter exercise pack including worked-example narration, completion-exercise TODO contract format, independent-exercise brief structure, rubric.json schema, verify/ script patterns, failure-modes.md format, and manifest.json template. Invoked by exercise-generator.
---

# Generate Exercises — Detailed Instructions

---

## PERSONALIZATION PROTOCOL — DO THIS BEFORE WRITING ANY EXERCISE

Exercises are where learners first put their hands on the material. If the scenario feels
artificial — generic inputs, made-up companies, placeholder names — the learner disengages.
Every exercise must feel like a task they could be assigned at work tomorrow.

### Before writing the first exercise, pin this context:

```
protagonist      = personalization_plan.running_example_per_chapter[chapter_slug].protagonist
protagonist_role = personalization_plan.running_example_per_chapter[chapter_slug].protagonist_role
domain_context   = personalization_plan.running_example_per_chapter[chapter_slug].domain_context
vocab            = personalization_plan.vocabulary_substitutions
scenario         = problem_spec.representative_scenarios[scenario_assignments[chapter_slug]]
fk_target        = personalization_plan.reading_register.fk_grade_target
```

### Personalization rules for exercises:

1. **The worked example uses the exact scenario from `scenario_assignments[chapter_slug]`.**
   Every entity name, artifact name, system name, and constraint comes from that scenario.
   No invented data — use `worked_example_seed.given_state` as the starting state.

2. **The completion exercise uses the same scenario with different parameter values.**
   Same protagonist, same domain system, different specific inputs/thresholds/dates.
   This creates meaningful variation without cognitive-load switching costs.

3. **The independent exercise escalates complexity within the same domain.**
   Do NOT switch to a different domain or introduce a new protagonist. The learner
   should feel: "this is harder version of what I just practiced."

4. **Code variable names use domain vocabulary**, not generic names:
   - BAD: `data`, `result`, `item_list`, `process_input`
   - GOOD: `shipment_exceptions`, `claim_priority_score`, `escalation_queue`

5. **Exercise briefs are written from the protagonist's perspective:**
   - BAD: "Implement a function that filters a list based on a condition."
   - GOOD: "Sara needs to filter the exception queue to surface only OVER_RECEIVE items
             with a deviation > 5%. Implement the `triage_exceptions()` function."

6. **Failure modes use domain failure names**, not generic error descriptions:
   - BAD: "The function returns the wrong output."
   - GOOD: "The triage function marks all items as CLEARED regardless of deviation threshold —
             this is the 'silent pass-through' failure mode common in filter implementations."

7. **Rubric descriptors reference the domain**, so instructors can assess domain-appropriate work:
   - BAD: "Solution produces correct output for all test cases."
   - GOOD: "All 47 shipment exceptions are correctly classified; OVER_RECEIVE items
             with deviation > 5% are flagged; no valid exceptions are cleared prematurely."

### Domain placeholder substitution checklist (run before submitting):

Scan every file in the exercise pack. Replace:
- "a user" → `protagonist` + `protagonist_role`
- "the system" → `vocab.system`
- "an item" / "the record" → `vocab.item`
- "the process" → `vocab.process`
- function inputs named `data`, `input`, `items` → domain-named equivalents
- exercise titles like "Exercise: Filter Implementation" → "Exercise: {domain action} for {domain_context}"

---

## Worked Example — Walkthrough.md Format

```markdown
# Worked Example Walkthrough — {chapter title}

**Scenario:** {exact scenario title from scenario_assignments[chapter_slug]}
**Protagonist:** {protagonist} — {protagonist_role}
**Domain context:** {domain_context — 1 sentence describing their work situation}
**Goal:** {what the protagonist needs to accomplish, in domain terms}
**Estimated time to read:** {N} minutes

---

## The Problem

{2–3 sentences grounded in the protagonist's work situation.
Use domain system names, domain object names, and real constraints from the scenario.
Example: "Sara has 47 uncleared shipment exceptions in SAP WMS. The dock closes at 17:00
and each manual classification takes 4 minutes — she needs an automated triage solution."}

## Starting State

{Describe the exact state of the domain system before any action is taken.}
{Use domain-specific values, not placeholder values like "sample_data" or 42.}

```{language}
# Variable names follow domain vocabulary from personalization_plan.vocabulary_substitutions
{e.g. exceptions = wms.fetch_exceptions(dock_id="DOCK-7", status="UNCLEARED")}
```

Or: describe the {vocab.system} state in prose if no code is involved.

## Step 1: {imperative action using domain verb}

> **Why this step:** {decision rationale tied to the scenario's constraints — not generic reasoning.
> Reference the protagonist's goal and the domain constraints.}

```{language}
# Code uses domain variable names and domain API/library names
{syntactically valid, domain-grounded code}
```

**Expected output in {vocab.system}:**
```
{what the protagonist sees — domain-specific output, not "True" or "OK"}
```

> **Decision Point:** {protagonist} considered {domain-grounded alternative}.
> We chose {our approach} because {reason tied to scenario constraints}.
> *In a different {domain context} — e.g., when {condition} — {alternative} would be better.*

## Step 2: {imperative action}

...

## Final State

```{language}
{final domain system state — name the system, describe the observable outcome}
```

**You know this worked when:** {domain-specific success criterion — not "the test passes" but
"the {vocab.system} dashboard shows all {vocab.item}s as {domain status}"}

---

## Key Decisions Summary

| Step | Decision | Reason |
|------|---------|--------|
| 1 | {domain-grounded decision} | {domain-grounded reason} |

## What to Watch For

- **{misconception from chapter_pitfalls[0].misconception}:** In this {domain_context},
  it manifests as {domain-specific symptom}. Fix: {domain-specific correction}.
- **{misconception from chapter_pitfalls[1].misconception}:** {how it appears here, with domain details}
```

---

## Completion Exercise — Starter/ TODO Contract Format

Every `# TODO` line must follow this contract format:

```python
# TODO: {imperative verb phrase} — {acceptance criterion}
# e.g.:
# TODO: implement the filter function — given a list of records, return only those
#       where record["status"] == "active" and record["priority"] >= priority_threshold
result = None  # replace this
```

Rules for TODO placement:
- ≥ 30 % of non-comment lines in starter/ must be TODO-replaced (not blank)
- Every TODO must have a complete contract specifying input, expected output/behavior, and constraints
- Leave valid import statements and type annotations — only replace implementation

---

## Independent Exercise — Brief Format

```markdown
# Exercise {N}: {domain-action title — e.g. "Triage Escalation Queue by Priority Score"}

## Brief

{protagonist}, {protagonist_role}, needs to {business goal using domain vocabulary and
specific domain system names}. This must be completed before {domain deadline/constraint
from scenario}.

Given:
- {input 1: domain name, type, format, domain-specific constraints}
  e.g. "A batch of {vocab.item}s exported from {vocab.system} as CSV, each with {field names}"
- {input 2: domain name and constraints}

Produce:
- {output 1: domain name, format, domain-specific constraints}
  e.g. "A filtered list with only {domain condition}; sorted by {domain field} descending"
- {output 2}

Constraints:
- {domain constraint from scenario — e.g. "must process before {vocab.system} batch window closes"}
- {technical constraint — e.g. "must handle up to {N} {vocab.item}s without timeout"}
- No use of {domain antipattern from chapter_pitfalls} — this is the most common mistake.

## Files

- `starter/{domain_named_file}`: {domain-specific description of the scaffold provided}
- `verify/`: run `{verify command}` to validate against {vocab.system}-compatible expected outputs
```

---

## failure-modes.md Format

Every exercise must have exactly ≥ 2 failure modes documented. Failure modes MUST be named
after the domain misconception they represent (from `chapter_pitfalls[]`), not after the
error message or exception type. A learner should recognize the failure mode from their
domain experience, not from their Python traceback.

```markdown
# Failure Modes — {exercise_id}

## Failure Mode 1: "{chapter_pitfalls[N].misconception}" in {domain_context}

**What this looks like in {vocab.system}:**
{Describe the domain-observable broken state — what the protagonist sees in their system,
not just what the code does. E.g., "All {vocab.item}s appear as CLEARED in {vocab.system}
even though {condition} should have flagged 23 of them."}

**Expected error or domain symptom:**
```
{The error message OR the wrong domain output — e.g., wrong count, wrong status, wrong field value}
```

**What the learner's code looks like when this occurs:**
```{language}
{Code snippet showing the common mistake — derived from chapter_pitfalls[N].why_wrong}
```

**Diagnosis steps:**
1. Check {domain-specific thing to inspect first — e.g., "verify the threshold value being used"}
2. Compare {vocab.system} output against {expected domain state}
3. {Next debugging step in domain context}

**Fix:** {Correction grounded in chapter_pitfalls[N].correction — domain-specific and concrete}
```{language}
{corrected code snippet}
```

---

## Failure Mode 2: "{chapter_pitfalls[M].misconception}" in {domain_context}

...
```

---

## rubric.json Schema

Every exercise (except worked-example) must have a `rubric.json`:

```json
{
  "exercise_id": "ch{NN}-ex{MM}",
  "chapter": <int>,
  "passing_average": 3.0,
  "criteria": [
    {
      "id": "correctness",
      "weight": 0.40,
      "descriptors": {
        "1": "Solution does not produce the correct output for any test case.",
        "2": "Solution produces correct output for ≥ 50% of test cases but fails edge cases.",
        "3": "Solution produces correct output for all standard cases; 1 edge case fails.",
        "4": "Solution produces correct output for all test cases including edge cases."
      }
    },
    {
      "id": "approach",
      "weight": 0.20,
      "descriptors": {
        "1": "Approach is fundamentally incorrect or uses a completely inappropriate technique.",
        "2": "Approach is valid but inefficient or over-complicated for the problem.",
        "3": "Approach is appropriate and mostly efficient; minor improvements possible.",
        "4": "Approach is optimal, well-reasoned, and matches the chapter's taught technique."
      }
    },
    {
      "id": "code_quality",
      "weight": 0.25,
      "descriptors": {
        "1": "Code is unreadable: no naming conventions, no structure, no comments where needed.",
        "2": "Code is readable but has significant style issues or inconsistent naming.",
        "3": "Code is clean and readable; minor naming or structure issues.",
        "4": "Code is exemplary: clear names, consistent style, appropriate comments on non-obvious logic."
      }
    },
    {
      "id": "communication",
      "weight": 0.15,
      "descriptors": {
        "1": "No explanation or reflection provided.",
        "2": "Explanation describes what the code does but not why decisions were made.",
        "3": "Explanation addresses both what and why; minor gaps.",
        "4": "Explanation is clear, complete, and explicitly connects the solution to the chapter's LOs."
      }
    }
  ]
}
```

Weight sum check: 0.40 + 0.20 + 0.25 + 0.15 = 1.00 ✓

---

## verify/ Script Pattern

### Python example (verify.py)

```python
#!/usr/bin/env python3
"""Verify script for exercise {exercise_id}. Run against solution/ to confirm it passes."""
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'solution'))

# Import the learner's implementation
from solution_module import target_function

def test_basic_case():
    result = target_function(standard_input)
    assert result == expected_output, f"Expected {expected_output}, got {result}"

def test_edge_case():
    result = target_function(edge_input)
    assert result == edge_expected, f"Edge case failed: {result}"

if __name__ == "__main__":
    test_basic_case()
    test_edge_case()
    print("All checks passed.")
```

### Shell example (verify.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../solution"

# Run the solution and capture output
actual=$(./run.sh 2>&1)
expected="expected output string"

if [ "$actual" != "$expected" ]; then
  echo "FAIL: Expected '$expected', got '$actual'"
  exit 1
fi

echo "All checks passed."
```

Rules:
- verify/ references `../solution/` (not `../starter/`)
- Must contain ≥ 1 assertion
- Must exit with non-zero code on failure
- Must not hardcode absolute paths

---

## manifest.json Template

```json
{
  "pack_id": "ch{NN}-exercises",
  "chapter": <int>,
  "total_time_box_minutes": <sum>,
  "target_track": "both",
  "exercises": [
    {
      "exercise_id": "ch{NN}-ex01",
      "stage": "worked_example",
      "difficulty": "not_applicable",
      "bloom_level": "Apply",
      "time_box_minutes": 10,
      "learning_outcome_refs": ["LO-NN.1"],
      "skill_pattern": "whole_task",
      "path": "worked-example/"
    },
    {
      "exercise_id": "ch{NN}-ex02",
      "stage": "completion",
      "difficulty": "easy",
      "bloom_level": "Apply",
      "time_box_minutes": 15,
      "learning_outcome_refs": ["LO-NN.2"],
      "skill_pattern": "one_skill",
      "path": "exercise-02/"
    },
    {
      "exercise_id": "ch{NN}-ex03",
      "stage": "independent",
      "difficulty": "medium",
      "bloom_level": "Analyze",
      "time_box_minutes": 15,
      "learning_outcome_refs": ["LO-NN.3"],
      "skill_pattern": "whole_task",
      "path": "exercise-03/"
    }
  ],
  "bloom_distribution": {
    "Remember": 0, "Understand": 0, "Apply": 2, "Analyze": 1, "Evaluate": 0, "Create": 0
  },
  "debrief_path": "debrief.md"
}
```
