---
name: plan-course
description: Detailed step-by-step instructions for the 12-step course planning algorithm. Invoked by planner-agent. Provides course-plan.yaml templates, normalization logic, LO generation guidance, scenario assignment rules, and the PLAN_REVIEW.md structure.
---

# Plan Course — Detailed Instructions

This skill provides the detailed step-by-step content for each of the 12 planning steps
defined in `planner-agent.md` and `${CLAUDE_PLUGIN_ROOT}/doc/PlannerSpec.md`.

---

## Step 1 Detail — Input Parsing Checklist

Parse and validate:

```
subject.md:
  ✓ Course title present
  ✓ Chapter list with titles (≥ 3 chapters)
  ✓ Each chapter has ≥ 1 intended learning outcome (verb + object)
  ✓ Prerequisites list (may be empty)
  ✓ Estimated chapter times (may be derived from subject spec)

problem.yaml:
  ✓ problem_id present (no REPLACE_ME)
  ✓ summary present
  ✓ domain_vocabulary has ≥ 3 terms
  ✓ representative_scenarios[] has ≥ 4 entries
  ✓ Each scenario has: id, title, description, entities[], artifacts[]
  ✓ success_criteria[] has ≥ 2 entries

students.yaml:
  ✓ cohort_id present
  ✓ age_range.min and age_range.max present
  ✓ locale is a valid IETF tag
  ✓ primary_language present
  ✓ reading_level_target present (Flesch-Kincaid grade, typically 8–14)
  ✓ prior_knowledge[] has ≥ 1 entry
  ✓ mode_preference is one of: self_taught, cohort, both

orchestration.yaml:
  ✓ output_root present
  ✓ mode_targets is a list
  ✓ quality_gates_to_run is "all" or a list of §16.N identifiers
```

---

## Step 2 Detail — Normalization Diff Format

Present to the user as a markdown table:

```markdown
## Normalization Summary — Please Review and Approve

### Chapter Slug Generation
| Subject Spec Title | Generated Slug | Notes |
|--------------------|---------------|-------|
| "Introduction to Prompt Engineering" | intro-to-prompt-engineering | |
| ... | ... | |

### Spec Conflict Resolution (Precedence: Student > Problem > Subject > Orchestration)
| Field | Subject Spec Value | Overriding Spec | Applied Value | Reason |
|-------|--------------------|-----------------|---------------|--------|
| reading_level | Grade 12 | Student Context Grade 10 | Grade 10 | Student wins |
| ... | | | | |

### Scenario-to-Chapter Assignment (Preliminary)
| Chapter | Scenario ID | Scenario Title |
|---------|------------|---------------|
| ch01 | scenario-02 | ... |
| ... | ... | ... |

### Reserved for Capstone (Preliminary)
| Scenario ID | Scenario Title |
|------------|---------------|
| scenario-04 | ... |

> **Action required:** Review the above and confirm, or ask me to adjust any assignment.
> Type "approved" to continue to Step 3.
```

---

## Step 3 Detail — Chapter Partitioning Rules

When partitioning from the subject spec:

1. **Time constraint**: each chapter should be 45–90 minutes. If a subject spec chapter is
   > 90 min worth of content, split it. If < 45 min, merge with the next chapter.

2. **Concept load**: no chapter may introduce > 4 new core concepts. If the subject spec
   chapter has 5+, split it.

3. **Bloom staircase** — assign dominant Bloom tier by course position:
   - Chapters 1–30 %: Remember, Understand
   - Chapters 30–60 %: Understand, Apply
   - Chapters 60–80 %: Apply, Analyze
   - Chapters 80–100 %: Analyze, Evaluate, Create

4. **Compact mode** (chapters > 20): activate `numeric_overrides.quiz.items: 4` and
   note this in CHANGELOG.md.

---

## Step 4 Detail — LO Generation Template

For each chapter, generate 3–7 LOs. Use the Bloom verb taxonomy from ${CLAUDE_PLUGIN_ROOT}/course-factory-guide.md.

Format:
```yaml
learning_outcomes:
  - id: LO-{chapter_number:02d}.1
    verb: "{Bloom verb from taxonomy}"
    object: "{what is learned}"
    criterion: "{measurable, observable criterion}"
    bloom_level: "{Remember|Understand|Apply|Analyze|Evaluate|Create}"
```

Good LO example:
```yaml
- id: LO-03.2
  verb: "implement"
  object: "a multi-step prompt chain using context-injection"
  criterion: "given a business scenario, construct a chain that produces the correct output in ≤ 5 steps"
  bloom_level: "Apply"
```

Bad LO example (too vague):
```yaml
- id: LO-03.2
  verb: "understand"       # ← "understand" alone is not observable
  object: "prompt engineering"  # ← too broad
  criterion: "the learner understands the topic"  # ← not measurable
```

---

## Step 5 Detail — Scenario Assignment Rules

1. Sort scenarios by complexity (simpler → more complex).
2. Assign simpler scenarios to earlier chapters; more complex to later chapters.
3. Reserve the most complex or most "integrative" scenario for the capstone.
4. For courses with 5 scenarios and ≥ 10 chapters, scenarios may repeat across non-adjacent chapters.
5. No chapter may use the same scenario as its immediately preceding chapter.
6. Write `reserved-scenarios.json`:
```json
{
  "reserved_for_capstone": ["scenario-04"],
  "reason": "Most complex scenario; requires integration of skills from chapters 5–10; used exclusively in capstone lab."
}
```

---

## Step 6 Detail — Personalization Plan Generation

The personalization plan is the single most important output of the planner. Every downstream
generator reads it before writing a single word. Generate it with the following process:

### 6.1 — Derive vocabulary substitutions from problem.yaml and students.yaml

Map every generic term to a domain-specific equivalent. These substitutions are applied
EVERYWHERE in all generated artifacts — examples, exercises, quiz stems, slide bodies,
podcast narration, code variables, and comments.

Generic → domain mapping rules:
- `user` → the primary human agent in the domain (e.g. "warehouse supervisor", "claims adjuster")
- `system` → the main software system they use (e.g. "SAP WMS", "Guidewire ClaimCenter")
- `item` → the primary domain object they act on (e.g. "inbound shipment", "insurance claim")
- `process` → the primary workflow they execute (e.g. "receiving workflow", "claims triage")
- `action` → the primary verb they perform (e.g. "scan", "adjudicate")
- `output` → what they produce (e.g. "receiving report", "settlement offer")
- `error` / `failure` → domain failure mode (e.g. "mis-pick", "coverage gap")

Derive these from `problem.yaml.domain_vocabulary[]` and
`problem.yaml.representative_scenarios[].entities[]`.

### 6.2 — Reading level and register calibration

Extract from `students.yaml`:
```
reading_level_target → FK grade (e.g. 11)
professional_context → register descriptor
prior_knowledge[]    → what can be assumed
locale               → language/cultural calibration
```

Compute:
```
reading_register:
  level: <FK grade>
  avg_sentence_target: <15 if ≤8, 20 if ≤10, 25 if ≤12, 30 if >12> words
  vocabulary_constraint: <"common only" | "domain OK" | "expert OK">
  tone: <"conversational" | "professional" | "technical" | "academic">
  cultural_notes: <any locale-specific adaptations>
```

Derive tone from `professional_context`:
- field/operations → "conversational", metric-heavy, tool-focused
- office/knowledge workers → "professional", workflow-focused
- engineers/developers → "technical", code-heavy, precision-first
- researchers/academics → "academic", theory-grounded
- managers/executives → "professional", outcome-focused

### 6.3 — Prior knowledge mapping

From `students.yaml.prior_knowledge[]`, produce two lists:
```
assumed_knowledge: [<topics to reference but never teach>]
gap_topics: [<topics from subject spec NOT in prior_knowledge — these need full scaffolding>]
partial_knowledge: [<topics mentioned in prior_knowledge with caveats — need bridging>]
```

Generators use this to decide: introduce from scratch vs. bridge from prior exposure vs. skip.

### 6.4 — Domain analogy bank

For each of the top 5 most abstract concepts in the course (from subject spec), provide a
domain-grounded analogy the generators can use:

```json
"domain_analogies": [
  {
    "abstract_concept": "<e.g. 'prompt context window'>",
    "domain_analogy": "<e.g. 'like a whiteboard that erases itself — the warehouse supervisor only sees the last N shipments'>",
    "chapter_first_introduced": "<chapter_slug>"
  }
]
```

These analogies MUST use entities from the domain — no generic "imagine a box" analogies.

### 6.5 — Personalization Plan Template

```json
{
  "course_slug": "<course_slug>",
  "generated_at": "<ISO datetime>",
  "locale": "<IETF tag from students.yaml>",
  "vocabulary_substitutions": {
    "user": "<domain protagonist>",
    "system": "<domain system name>",
    "item": "<domain object>",
    "process": "<domain workflow>",
    "action": "<primary domain verb>",
    "output": "<primary domain deliverable>",
    "error": "<domain failure mode>"
  },
  "reading_register": {
    "fk_grade_target": <int>,
    "avg_sentence_words_max": <int>,
    "vocabulary_constraint": "common only | domain OK | expert OK",
    "tone": "conversational | professional | technical | academic",
    "cultural_notes": "<locale-specific adaptations>"
  },
  "prior_knowledge_map": {
    "assumed": ["<topic>"],
    "needs_scaffolding": ["<topic>"],
    "bridge_from_prior": [{ "topic": "<topic>", "prior_context": "<what they know>", "extension": "<what to add>" }]
  },
  "domain_analogies": [
    {
      "abstract_concept": "<concept>",
      "domain_analogy": "<domain-grounded analogy>",
      "chapter_first_introduced": "<chapter_slug>"
    }
  ],
  "scenario_assignments": {
    "<chapter_slug>": "<scenario_id>"
  },
  "running_example_per_chapter": {
    "<chapter_slug>": {
      "scenario_ref": "<scenario_id>",
      "protagonist": "<entity from scenario.entities[0]>",
      "protagonist_role": "<their job title / role>",
      "artifact": "<artifact from scenario.artifacts[0]>",
      "domain_context": "<1-sentence description of their work situation in this chapter>"
    }
  }
}
```

---

## Step 12 Detail — PLAN_REVIEW.md Template

```markdown
# Course Plan Review — {course_slug}

**Generated:** {ISO datetime}
**Subject:** {course_title}
**Problem domain:** {problem_id}
**Cohort:** {cohort_id}

---

## Course Overview

| Field | Value |
|-------|-------|
| Total chapters | N |
| Total estimated hours | N.N |
| Mode targets | self_taught, cohort |
| Numeric overrides active | compact quiz (chapters > 20) |

---

## Chapter Outline

| # | Title | Slug | Est. Min | LO Count | Bloom (dominant) |
|---|-------|------|----------|----------|-----------------|
| 1 | ... | ... | 60 | 4 | Apply |

---

## Scenario Assignments

| Chapter | Scenario ID | Scenario Title |
|---------|------------|---------------|
| ch01 | scenario-02 | ... |

**Reserved for capstone:** scenario-04 — "{title}" (MUST NOT appear in chapter content)

---

## PlannerSpec §13 Quality Gate Checklist

**Course Structure**
- [ ] ≥ 4 representative scenarios provided
- [ ] All LOs have Bloom verbs from the taxonomy
- [ ] Chapter count ≥ 3 and ≤ 30
- [ ] All chapter times in [45, 90] minutes
- [ ] Each chapter has 3–7 LOs
- [ ] Bloom staircase is present across the course
- [ ] ≥ 1 scenario reserved for capstone
- [ ] No chapter uses the reserved scenario
- [ ] personalization-plan.json covers all chapter slugs
- [ ] Locale in students.yaml is a valid IETF tag
- [ ] reading_level_target is in [6, 16]
- [ ] All REPLACE_ME tokens removed from input files
- [ ] Numeric overrides (if any) logged in CHANGELOG.md

**Personalization Quality**
- [ ] vocabulary_substitutions has entries for all 7 generic terms (user, system, item, process, action, output, error)
- [ ] reading_register.fk_grade_target matches students.yaml reading_level_target
- [ ] reading_register.tone is derived from students.yaml.professional_context (not defaulted)
- [ ] prior_knowledge_map.assumed[] lists ≥ 1 entry from students.yaml.prior_knowledge[]
- [ ] prior_knowledge_map.needs_scaffolding[] lists ≥ 1 entry (no course teaches zero new concepts)
- [ ] domain_analogies[] has ≥ 3 entries, each using entities from problem.yaml (no generic analogies)
- [ ] Every running_example_per_chapter entry has protagonist_role and domain_context populated
- [ ] All scenario protagonists are domain-specific (no "User A", "Person", or "Student")

---

## Action Required

**Type "approved" to begin chapter generation, or tell me what to adjust.**
```
