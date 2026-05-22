---
name: generate-quiz
description: Item-by-item generation rules for chapter quizzes including all 7 item types, distractor pattern recipes, the difficulty heuristic formula, answer-position balance tracking, Form B generation from Form A, and the carry-forward paraphrasing protocol. Invoked by quiz-generator.
---

# Generate Quiz — Detailed Instructions

---

## PERSONALIZATION PROTOCOL — DO THIS BEFORE WRITING ANY ITEM

A quiz that uses generic stems ("a user submits a request") is meaningless for a learner whose
daily reality involves specific systems, specific roles, and specific failure modes. Every item —
not just `scenario_mcq` — MUST be grounded in the domain.

### Before writing the first item, pin this context:

```
protagonist      = personalization_plan.running_example_per_chapter[chapter_slug].protagonist
protagonist_role = personalization_plan.running_example_per_chapter[chapter_slug].protagonist_role
domain_context   = personalization_plan.running_example_per_chapter[chapter_slug].domain_context
vocab            = personalization_plan.vocabulary_substitutions
scenario         = problem_spec.representative_scenarios[scenario_assignments[chapter_slug]]
pitfalls         = handoff_json.chapter_pitfalls  ← these are the distractor seeds
```

### Personalization rules for ALL item types:

1. **Every stem names the domain system, domain object, or protagonist's role** — not generic terms.
   - BAD:  "What happens when the system receives an invalid input?"
   - GOOD: "What does {vocab.system} return when a {vocab.item} arrives with a missing {domain field}?"

2. **Distractors are named after domain misconceptions**, not generic error patterns.
   Use `chapter_pitfalls[].misconception` as the distractor labels — these are the exact
   conceptual errors learners in THIS domain make.
   - BAD distractor: "The function returns None" (describes a symptom, not a misconception)
   - GOOD distractor: "'{chapter_pitfalls[0].misconception}' — the learner expects {wrong behavior}"

3. **Short-answer stems ask about domain situations**, not abstract concepts.
   - BAD:  "In 1–3 sentences, explain what context injection does."
   - GOOD: "In 1–3 sentences, explain how {protagonist} would use context injection to give
            {vocab.system} the current {vocab.item} data it needs before running the batch."

4. **Error-spotting code uses domain variable names and domain logic**, not toy examples.
   - BAD:  `result = process(data)` with a generic off-by-one bug
   - GOOD: `cleared_items = triage(exceptions, threshold=5)` with a domain-specific bug from
            `chapter_pitfalls[].misconception`

5. **True/False statements test domain-specific claims**, not textbook definitions.
   - BAD:  "Context injection always produces more accurate outputs than few-shot prompting."
   - GOOD: "When {vocab.system} processes a {vocab.item} batch overnight, context injection
            is always the more reliable approach compared to few-shot prompting."

6. **Multi-select items use domain choices** — the options are things learners actually encounter.
   - BAD:  Options A–D are generic technique names
   - GOOD: Options A–D are approaches the protagonist would realistically consider in their workflow

### Domain substitution checklist for quiz items (run before final output):

Scan every stem and every option text. Replace:
- "a user" / "the user" → `protagonist` + role
- "the system" → `vocab.system`
- "an item" / "a record" → `vocab.item`
- "the process" / "the workflow" → `vocab.process`
- "returns an error" → returns the domain-specific error from scenario or pitfalls
- variable names like `data`, `result`, `items` in code blocks → domain-named equivalents

---

## Item Type Reference

### MCQ (Multiple Choice Question)

The stem MUST name the domain system, domain object, or protagonist's situation. Do NOT use
abstract stems that could belong to any domain.

```json
{
  "item_type": "mcq",
  "stem": "When {protagonist_role} needs to {domain action using vocab} in {vocab.system}, which approach produces {domain-specific expected result} given {domain-specific condition}?",
  "options": [
    { "id": "A", "text": "...", "correct": true,  "rationale": "Correct because {specific reason grounded in domain behavior}." },
    { "id": "B", "text": "...", "correct": false, "misconception": "{chapter_pitfalls[N].misconception}", "rationale": "Wrong because {domain-specific reason — what goes wrong in vocab.system}." },
    { "id": "C", "text": "...", "correct": false, "misconception": "off-by-one", "rationale": "Wrong because {domain-specific boundary error — e.g., wrong threshold for vocab.item}." },
    { "id": "D", "text": "...", "correct": false, "misconception": "surface-pattern", "rationale": "Wrong because this uses the right domain term ({vocab.X}) in the wrong context." }
  ]
}
```

### Multi-Select

```json
{
  "item_type": "multi_select",
  "stem": "Select ALL of the following that {apply/are correct/satisfy the criterion}. (Select {N}.)",
  "options": [
    { "id": "A", "correct": true, ... },
    { "id": "B", "correct": true, ... },
    { "id": "C", "correct": false, ... },
    { "id": "D", "correct": false, ... }
  ]
}
```

Rules: ≥ 2 correct options. The stem MUST state "Select all that apply" or "Select N".

### TF Justified (True/False with Required Justification)

The claim MUST be about a specific domain situation — not a generic principle.
The expected_answer MUST specify when/why the claim fails in the learner's domain context.

```json
{
  "item_type": "tf_justified",
  "stem": "When {protagonist_role} processes a {vocab.item} batch in {vocab.system}, {domain-specific claim that contains a common misconception from chapter_pitfalls}.",
  "options": [
    { "id": "A", "text": "True",  "correct": false, "misconception": "{chapter_pitfalls[N].misconception}", "rationale": "False because {domain-specific reason — what actually happens in vocab.system}." },
    { "id": "B", "text": "False", "correct": true,  "rationale": "Correct — {domain-specific reason, naming the system and the actual behavior}." }
  ],
  "expected_answer": "False. {One sentence justification grounded in the domain — the learner must explain the specific condition in vocab.system under which the claim fails, not just say 'it depends'.}"
}
```

NEVER use bare true/false without `expected_answer`.
The claim in the stem must be one a domain practitioner would plausibly believe (drawn from chapter_pitfalls).

### Short Answer

The stem MUST situate the question in the protagonist's domain context.
The expected_answer MUST use domain vocabulary and name the domain system's behavior.

```json
{
  "item_type": "short_answer",
  "stem": "In 1–3 sentences, explain how {protagonist_role} would {domain action} when {domain-specific condition} occurs in {vocab.system}. What determines the correct outcome?",
  "expected_answer": "{Model answer using domain vocabulary: key points the learner must address, naming vocab.system behavior, vocab.item states, and any domain constraints from the scenario}",
  "grading_rubric_ref": "{rubric.json}#criterion-id"
}
```

### Scenario MCQ

```json
{
  "item_type": "scenario_mcq",
  "stem": "In the scenario where {protagonist from personalization plan} needs to {business goal}, the system {condition}. What should {protagonist} do first?",
  "options": [...]
}
```

MUST: stem must instantiate a `problem_spec.representative_scenarios[]` entry.
MUST: scenario must match `personalization_plan.scenario_assignments[chapter_slug]`.

### Error Spotting

```json
{
  "item_type": "error_spotting",
  "stem": "The following {language} code is intended to {goal}. Identify the error and explain the correct fix.",
  "code_block": {
    "language": "python",
    "content": "{code with one intentional bug from chapter_pitfalls}"
  },
  "expected_answer": "The error is {specific error}. Fix: {correction}."
}
```

The bug MUST come from `handoff_json.chapter_pitfalls`.

### Code Review

```json
{
  "item_type": "code_review",
  "stem": "Review the following implementation. Identify {N} issues and explain how you would address each.",
  "code_block": {
    "language": "python",
    "content": "{code with multiple reviewable issues}"
  },
  "expected_answer": "Issue 1: {issue}. Fix: {fix}. Issue 2: ..."
}
```

---

## Distractor Recipe Guide

Every distractor must encode a real misconception from `chapter_pitfalls[]` OR a domain-specific
boundary error. Distractors that are domain-plausible wrong answers are more diagnostic than
generic wrong answers — they reveal which misconception the learner holds.

| Misconception type | How to write it |
|--------------------|----------------|
| **named-misconception** | Use the exact `chapter_pitfalls[N].misconception` string as the `misconception` field. Write the distractor as what a domain practitioner with that misconception would do in `vocab.system`. E.g., if the misconception is "threshold applies to count not deviation", the distractor option describes the count-based approach. |
| **off-by-one** | Domain boundary error: wrong threshold, wrong field value, wrong cutoff time. E.g., if correct is "deviation > 5%", distractor is "deviation ≥ 5%" or "deviation > 0.5". Use domain values from the scenario. |
| **surface-pattern** | Option uses the correct domain term (`vocab.system`, `vocab.item`, etc.) but applies it in the wrong context. Learners who pattern-match on terminology without understanding would choose this. |
| **previously-correct** | An approach that was valid in an earlier chapter but is superseded or qualified in this chapter. Learners who applied the prior chapter's rule without updating would choose this. Name the prior chapter explicitly in the rationale. |

Domain-specific distractor writing rules:
- Every distractor option text should name at least one domain entity (`vocab.system`, `vocab.item`,
  or a domain action) — not just describe abstract behavior
- The `rationale` field should explain WHY the distractor is wrong in domain terms: what the
  learner would observe in `vocab.system` if they chose this option
- If the item is a code block, the distractor explanation should reference the specific line
  of code that is wrong and describe the domain outcome of that error

Never write a distractor that:
- Is clearly absurd or humorous
- Contains "All of the above" or "None of the above"
- Is grammatically inconsistent with the stem
- Requires knowledge from a chapter not yet covered
- Has no connection to a real domain misconception (i.e., is a "throwaway wrong answer")

---

## Difficulty Heuristic (§9.10)

```python
def compute_difficulty(bloom_level, item_type, stem_word_count):
    p_base = {
        "Remember": 0.90, "Understand": 0.80, "Apply": 0.70,
        "Analyze": 0.60, "Evaluate": 0.50, "Create": 0.45
    }[bloom_level]

    p_adj = 0.0
    if item_type in ["scenario_mcq", "error_spotting", "code_review"]:
        p_adj -= 0.10
    if stem_word_count > 60:
        p_adj -= 0.05
    if item_type == "tf_justified":
        p_adj += 0.05

    return max(0.40, min(0.95, p_base + p_adj))
```

If computed difficulty < 0.40 or > 0.95, rewrite the item (simplify or complicate accordingly).

---

## Answer-Position Balance Tracker

Track correct-answer positions as you generate items. After every 5 items, check:

```
Position counts:  A=N  B=N  C=N  D=N
Max allowed per position = ceil(total_items * 0.35)
```

If any position is at the max, the next correct answer MUST go elsewhere.

---

## Carry-Forward Paraphrasing Protocol

When paraphrasing a carry-forward item from a prior chapter:

1. **Change the stem** — different sentence structure, different specific values
2. **Change the scenario context** — use the current chapter's scenario instead of the prior chapter's
3. **Keep the same LO-ID and bloom_level** — carry-forward tests the same learning outcome
4. **Keep the same distractor types** — but rewrite the distractor text

Example:
- Original: "When calling the API with an empty payload, what happens?"
- Paraphrased: "If {protagonist} sends a request to {domain API} without the required fields, what does {system} return?"

---

## Form B Generation from Form A

For each Form A item:

1. Identify the LO-ID and Bloom level.
2. Write a new stem that:
   - Tests the same LO from a different angle
   - Uses a different specific scenario instance (same scenario type, different inputs/context)
   - Has different option text (not just shuffled)
3. Assign a new item_id: `ch{NN}-qB{NN}` (B prefix).
4. Verify: Form B item would be independently answerable by someone who never saw Form A.

After generating all Form B items:
- Confirm 0 item_id overlap with Form A
- Confirm same Bloom distribution as Form A
- Confirm same LO-IDs covered (every Form A LO has a Form B counterpart)

---

## Time-Seconds Guidelines

| Item type | Typical range |
|-----------|--------------|
| mcq (Remember/Understand) | 30–45 s |
| mcq (Apply/Analyze) | 60–90 s |
| scenario_mcq | 90–120 s |
| multi_select | 60–90 s |
| tf_justified | 60–90 s |
| short_answer | 90–120 s |
| error_spotting | 90–120 s |
| code_review | 90–180 s |

Total time across all items should be within ±20 % of `chapter.est_minutes × 60 × 0.10`
(quiz time target = 10 % of chapter time).
