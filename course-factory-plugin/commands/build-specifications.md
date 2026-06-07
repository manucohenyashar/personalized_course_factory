---
name: build-specifications
description: Interactive specification builder that accepts unstructured user documents (problem descriptions, team backgrounds, business cases), extracts structured information, validates scope (lab complexity, course length, subject relevance, personalization richness), works with the user via AskUserQuestion to fill gaps, and produces validated inputs/problem.yaml and inputs/students.yaml. Invoked by spec-builder-agent.
---

# Build Specifications — Detailed Instructions

This skill turns unstructured user documents into validated course input files.
Follow every phase in order. Do not write files until Phase 9.

---

## PHASE 1 — Document Intake & Initial Extraction

### 1.1 — Read everything the user provided

Accept whatever the user has given: business case documents, emails, job descriptions,
team wikis, slide decks in text form, or a plain paragraph description. There is no
required format. Read all of it.

### 1.2 — Extract a raw understanding

From the user's documents, extract your best understanding of these fields.
Mark each as `[FOUND]`, `[INFERRED]`, or `[MISSING]`.

**Problem fields:**
```
domain:              [FOUND|INFERRED|MISSING] — the industry or technical domain
problem_summary:     [FOUND|INFERRED|MISSING] — the core problem being solved
success_criteria:    [FOUND|INFERRED|MISSING] — what success looks like (list items)
domain_vocabulary:   [FOUND|INFERRED|MISSING] — domain-specific terms mentioned
scenarios_raw:       [FOUND|INFERRED|MISSING] — concrete use cases or examples mentioned
```

**Student fields:**
```
role_or_job_title:   [FOUND|INFERRED|MISSING]
industry:            [FOUND|INFERRED|MISSING]
daily_tasks:         [FOUND|INFERRED|MISSING] — what they actually do at work
team_size_context:   [FOUND|INFERRED|MISSING] — solo, small team, enterprise
prior_knowledge:     [FOUND|INFERRED|MISSING] — skills/tools they already know
experience_level:    [FOUND|INFERRED|MISSING] — years of experience, seniority
language_locale:     [FOUND|INFERRED|MISSING]
learning_mode:       [FOUND|INFERRED|MISSING] — self-study, instructor-led, or both
```

### 1.3 — Read the subject spec

Read `inputs/subject.md`. Extract:
- Course title and goals
- Intended audience
- Major topics covered
- Prerequisites listed
- Estimated scope (if stated)

This is the lens against which you will validate the problem domain and student profile.

---

## PHASE 2 — Subject Relevance Validation

### 2.1 — Alignment check

Compare the extracted domain and problem summary against `inputs/subject.md`.

Score alignment on a 0–3 scale:

| Score | Meaning |
|-------|---------|
| 3 | Domain directly matches the subject's target audience and topic |
| 2 | Domain is adjacent — the subject applies to this domain but wasn't written for it |
| 1 | Weak alignment — the subject could technically apply, but major adaptation is needed |
| 0 | No alignment — the problem is in a completely different domain than the subject |

**Score = 3 or 2:** proceed.

**Score = 1:** note the gap. In Phase 3, when asking the user questions, surface this:
> "The course subject is designed for {subject_audience}. Your team is {user_description}.
> The material will need significant adaptation. Should we proceed, or would you like to use
> a different subject specification for `inputs/subject.md`?"

**Score = 0:** flag immediately using `AskUserQuestion` before proceeding further:

```
Question: "The course subject ({subject_title}) appears to be in a very different domain from
your problem ({user_domain}). This mismatch will make personalization difficult.
How would you like to proceed?"
Options:
  - "Replace inputs/subject.md with a new subject spec (I'll describe it)"
  - "Keep the current subject — it's close enough with adaptation"
  - "Help me understand why these are compatible"
```

### 2.2 — Vocabulary overlap check

List domain vocabulary from the user's documents. Compare against subject spec terminology.
Overlap of < 25% on domain vocabulary is a relevance warning — note it for Phase 3 questions.

---

## PHASE 3 — Course Complexity Validation

**Goal:** Validate that the subject can be taught in 3–8 total hours across 3–10 chapters.

### 3.1 — Topic count estimation

From the subject spec and the user's problem description, estimate how many distinct
learnable topics the course would cover. A "learnable topic" = something that requires
its own chapter (45–90 min) to explain and practice.

Use this heuristic:
- Count major concepts the user mentions that the students must learn
- Count major skills required to solve the problem
- Each distinct concept/skill that requires practice = 1 chapter candidate

**Well-scoped range:** 3–10 topics (fits in 3–8 hours).

### 3.2 — Complexity signals

**Signs the subject is TOO BROAD (flag for user):**
- The user mentions "everything about X" or "full stack" or "end-to-end"
- The topic list spans multiple disciplines (e.g., ML theory + DevOps + security)
- Solving the problem would require skills that take months to develop
- The subject spec covers > 15 chapter-level topics

**Signs the subject is TOO NARROW (flag for user):**
- Only 1–2 learnable concepts
- The entire course could be delivered in a single 2-hour workshop
- The user's problem is solved by learning one specific command or API call
- The subject spec covers < 3 chapter-level topics

### 3.3 — Scope adjustment offer

If too broad or too narrow, note the specific issue. You will ask about this in the
Phase 6 questions batch. Frame it constructively:

> TOO BROAD: "Your problem covers {N} distinct skill areas. A 3–8 hour course can realistically
> teach 3–10 of these well. Which {M} are most critical for your team right now?"

> TOO NARROW: "The core problem seems learnable in about {estimated_hours} hours, which might
> feel thin for a full course. Should we expand the scope to include {adjacent_topics}?"

---

## PHASE 4 — Lab Scope Validation

**Goal:** Validate that the problem's implementation fits in a 60–180 minute capstone lab.

The capstone lab is where students implement the student's actual problem
(`problem_spec.success_criteria[]`). If the problem is too large, the lab cannot
implement it faithfully. If too small, the lab lacks depth.

### 4.1 — Implementation complexity estimation

From the problem summary and success criteria, estimate the implementation size:

**Ask these questions internally:**
1. How many distinct systems does the solution integrate? (each integration = +30 min)
2. How many distinct algorithms or logic components? (each component = +20–30 min)
3. Does it require production-grade concerns (auth, error handling, scaling)? (+60 min)
4. Is there a clear starting point (input data, API, file) → clear ending point (output)?
5. Could a student who just completed the course build this in one focused session?

**Complexity estimate buckets:**

| Bucket | Estimated implementation time | Assessment |
|--------|------------------------------|------------|
| Simple | < 30 min | TOO SIMPLE — lab would feel like a chapter exercise |
| Target | 60–180 min | WELL-SCOPED — keep as-is |
| Large | 180–360 min | TOO COMPLEX — needs scoping down |
| Very large | > 360 min | FAR TOO COMPLEX — fundamental rethinking needed |

### 4.2 — Success criteria count check

- **< 2 success criteria**: too simple or under-specified → ask user for more criteria
- **2–5 success criteria**: ideal range
- **> 5 success criteria**: likely too complex for 180 min → help user consolidate

### 4.3 — Complexity reduction patterns

If the problem is too complex, identify which of these applies and prepare a suggestion:

| Pattern | Reduction approach |
|---------|-------------------|
| Too many integrations | "Focus on one system integration for the lab; treat others as stub inputs" |
| Production concerns | "Scope to a working prototype: skip auth, hardcode config, focus on core logic" |
| Too many success criteria | "Pick the 3 most impactful criteria; make the rest stretch goals" |
| Multi-phase workflow | "Implement one phase end-to-end; make other phases a sketch/design exercise" |
| Real-time requirement | "Simulate with batch processing for the lab; note where real-time would differ" |

---

## PHASE 5 — Personalization Richness Validation

**Goal:** Validate that the student context is rich enough for meaningful personalization
across all 7 artifact types (doc, exercises, slides, quiz, podcast, companion, lab).

### 5.1 — Minimum richness checklist

| Field | Why it matters | Status |
|-------|---------------|--------|
| `professional_context` | Grounds every example — protagonist's job, industry, daily tasks | [FOUND/MISSING] |
| `prior_knowledge[]` | Determines what to introduce vs. what to reference as known | [FOUND/MISSING] |
| `domain_vocabulary` | Gives names to the protagonist, systems, objects, processes | [FOUND/MISSING] |
| `reading_level_target` | Controls sentence length and vocabulary complexity | [FOUND/INFERRED/MISSING] |
| `mode_preference` | Determines which artifacts are primary (slides for cohort; doc for self-study) | [FOUND/MISSING] |

### 5.2 — Richness signals

**Sufficient personalization context:**
- You can name the protagonist (specific role, not "a user")
- You can name the domain system (specific software, not "the system")
- You can name the domain object (specific artifact, not "data" or "item")
- You know 3+ things the students already know (for "assumed" references)
- You know 2+ things they do NOT know (for scaffolded introduction)

**Insufficient context (flag):**
- All examples would have to use "a user" and "the system"
- No information about what tools/software they use daily
- No information about their technical background level
- Reading level cannot even be inferred from professional context

---

## PHASE 6 — Interactive Refinement via AskUserQuestion

Run this phase in at most **3 rounds** of questions. Batch related questions into each round.
Never ask more than 4 questions per round.

### 6.1 — Build the question queue

From Phases 1–5, collect all MISSING and flagged items. Prioritize by impact:

**Priority 1 — Blockers** (must resolve before continuing):
- Problem summary is absent or too vague to extract success criteria
- No professional context at all (can't personalize anything)
- Subject relevance score = 0
- Fewer than 2 success criteria

**Priority 2 — Critical gaps** (without these, output quality will be poor):
- Fewer than 4 scenarios (required minimum)
- No prior knowledge information
- Problem scope is too complex or too simple (needs user decision)

**Priority 3 — Enrichment** (improves quality but has fallbacks):
- Exact reading level (can be inferred from professional context)
- Accessibility needs (default to none)
- Mode preference (default to "both")
- Exact age range (default to working age 22–55)

### 6.2 — Round 1: Core clarifications

Use `AskUserQuestion` for Priority 1 blockers only.

**Example question batch for missing problem core:**
```
AskUserQuestion:
  Q1: "What is the specific problem your team needs to solve? In 1–3 sentences, what do
      people on your team currently do manually or inefficiently that this course will fix?"
  options: [
    "I'll type a description",     (triggers free-text via "Other")
    "Here's an example situation: ...",
    "The problem is best described by this success metric: ..."
  ]

  Q2: "What does a successful outcome look like? After completing this course, what
      should your team be able to do that they can't do today?"
  multi-select: true
  options: [
    "Complete a specific workflow automatically (describe below)",
    "Use a specific tool or system confidently",
    "Reduce time spent on a specific task",
    "Make better decisions using data or AI",
    "Build and deploy a specific type of automation"
  ]
```

**Example question batch for missing student context:**
```
AskUserQuestion:
  Q1: "What is your team's main job? Pick the closest description."
  options: [
    "Operations / logistics / field work",
    "Office / knowledge work / analysis",
    "Technical / engineering / development",
    "Management / leadership / strategy",
    "Research / academia / data science"
  ]

  Q2: "What tools or technologies do your team members use every day?"
  options: [
    "Mostly standard office tools (Word, Excel, email, Slack)",
    "Specialized industry software (ERP, CRM, WMS, etc.) — I'll name it",
    "Programming and developer tools",
    "Data and analytics tools (SQL, BI dashboards, Jupyter, etc.)",
    "A mix — I'll describe it"
  ]
```

### 6.3 — Round 2: Scope decisions and scenario development

After Round 1, re-assess scope flags. Present scope findings to the user clearly:

```markdown
## Scope Assessment

**Lab scope:** {WELL-SCOPED | TOO COMPLEX | TOO SIMPLE}
{If issue: specific description of the problem + suggested solution}

**Course length:** {WELL-SCOPED | TOO BROAD | TOO NARROW}
{If issue: specific description of the problem + suggested solution}

**Subject relevance:** {ALIGNED | MARGINAL | MISALIGNED}
{If issue: description}
```

If lab is TOO COMPLEX, use `AskUserQuestion`:
```
AskUserQuestion:
  Q: "The problem as described would take {estimated_hours} hours to implement —
      larger than the 60–180 minute lab target. Which approach works best for you?"
  options: [
    "Scope to the most impactful piece: {specific_suggestion_A}",
    "Scope to a working prototype: {specific_suggestion_B}",
    "Keep the full scope and split it into 2 labs (advanced option)",
    "I'll redefine the problem — here's the adjusted scope: ..."
  ]
```

If lab is TOO SIMPLE, use `AskUserQuestion`:
```
AskUserQuestion:
  Q: "The problem as described is quite focused and might feel thin as a lab.
      Should we expand the scope?"
  options: [
    "Add {adjacent_challenge} as an additional requirement",
    "Add an error-handling and debugging dimension",
    "Add an optimization or monitoring dimension",
    "Keep it focused — a well-scoped lab is better than an inflated one"
  ]
```

### 6.4 — Round 3: Scenario development

Scenarios are often the weakest part of user-provided specs. Help build them interactively.

**Step 1**: Present the scenarios you've been able to extract from their documents:
```markdown
## Scenarios I Found in Your Documents

{For each extracted scenario:}
**Scenario {N}:** {title}
- Protagonist: {who}
- Situation: {what they're doing}
- Challenge: {what's hard or manual}
- Domain objects: {what they're working with}
- Outcome: {what they want to achieve}

{If < 4 scenarios found:}
I need at least {4 - found} more scenarios. Scenarios are concrete situations where your
team would apply the skills from this course. They are used to ground every example,
exercise, and quiz throughout the course — so the more specific, the better.
```

**Step 2**: Ask for missing scenarios via `AskUserQuestion`:
```
AskUserQuestion:
  Q: "Can you describe {N} more real situations from your team's work?
     For each one: who is involved, what are they trying to do, and what makes it challenging?"
  options: [
    "Here are {N} more situations: ... (type below)",
    "Use variations of the scenarios already identified",
    "Generate {N} plausible scenarios based on the domain and role — I'll review them"
  ]
```

If the user asks you to generate scenarios, produce them based on the domain + role + problem.
Present them for approval before locking them in.

**Step 3**: For each scenario, validate richness:
- Does it have a named protagonist (or role name)?
- Does it name the domain system being used?
- Does it name the domain object being acted on?
- Is there a clear challenge and a clear desired outcome?

Any scenario that answers NO to 2+ of these questions needs enrichment.

---

## PHASE 7 — Success Criteria Derivation

Help the user articulate what a successful implementation looks like.
These become the capstone lab's acceptance criteria.

### 7.1 — Extract from what you have

From the problem summary, scenarios, and user's stated goals, derive 2–5 success criteria
in this format:

```
A learner who completes this course can:
1. {specific action} {domain object} {in/using domain system} {to achieve domain outcome}
2. ...
```

### 7.2 — Validate each criterion

Each criterion must be:
- **Implementable** in the lab (one coding/configuration task, not "build a full system")
- **Testable** with a verify script (observable output, not "understands X")
- **Domain-specific** (names the system, object, and outcome)
- **Bloom Apply or above** (not just "knows" or "explains")

If any criterion fails these checks, rewrite it:
- Non-implementable → "given {input}, produce {output} using {technique}"
- Non-testable → add an observable output ("the function returns...", "the file contains...", "the dashboard shows...")
- Generic → add domain names
- Below Apply → replace with an action verb (implement, build, configure, analyze, debug)

### 7.3 — Present for confirmation

```markdown
## Proposed Success Criteria

After completing this course, a learner can:

1. {criterion 1}
2. {criterion 2}
3. {criterion 3}

These will become the capstone lab's acceptance criteria — your team will be able to
demonstrate each of these when they finish the lab.
```

Use `AskUserQuestion`:
```
Q: "Do these success criteria match what you want your team to achieve?"
options: [
  "Yes, these are right",
  "Yes, but I want to add one more: ...",
  "Replace criterion {N} with: ...",
  "These are too ambitious — let's reduce",
  "These are too modest — let's expand"
]
```

---

## PHASE 8 — Reading Level & Register Inference

Infer `reading_level_target` and `tone` from what you know about the students.
Only ask if genuinely uncertain.

### 8.1 — Reading level heuristic

```
professional_context → FK grade target:

  Field / manual operations worker    → 8
  Office / coordinator / analyst      → 10
  Business professional / manager     → 11
  Technical staff / specialist        → 12
  Engineer / developer                → 12–13
  Data scientist / researcher         → 13–14
  Academic / domain expert            → 14+
```

### 8.2 — Register heuristic

```
professional_context → tone:

  Field / manual worker               → conversational (short sentences, everyday words)
  Office / coordinator                → professional (clear, structured, outcome-focused)
  Technical / engineer                → technical (precise, code-heavy, performance-aware)
  Manager / executive                 → professional (outcome-focused, light on implementation)
  Researcher / academic               → academic (formal, citation-friendly, theory-grounded)
```

### 8.3 — Ask only if ambiguous

If the professional context leaves reading level genuinely ambiguous, ask:
```
AskUserQuestion:
  Q: "What's the typical educational and technical background of the learners?"
  options: [
    "Mostly non-technical — they use tools but don't code",
    "Mixed — some technical, some not",
    "Technical — they work with code, data, or systems regularly",
    "Highly technical — engineers, data scientists, or developers"
  ]
```

---

## PHASE 9 — Spec Drafting

Build complete drafts of both YAML files.

### 9.1 — Draft problem.yaml

Compose the full YAML. All REPLACE_ME tokens must be filled.
Every scenario must have:
- `id`, `title`, `description` (2–4 sentences, specific to the domain)
- `entities`: list of named people/roles/systems involved
- `artifacts`: list of files, APIs, databases, or data objects used

```yaml
# Auto-generated by spec-builder-agent — {ISO datetime}
# Review carefully before running the course factory.

problem_id: {domain-slug}-{year}
summary: |
  {2–3 sentences. Describes the core professional problem. Specific to domain + role.
   Written from the learner's perspective, not the course designer's perspective.}

domain: {domain name}

domain_vocabulary:
  - term: {term 1}
    definition: {concise definition in domain language}
  # ... all terms extracted from user's documents + scenarios

representative_scenarios:
  - id: scenario-01
    title: {specific title — not generic}
    description: |
      {2–4 sentences. Names: who (role), what system, what object, what challenge,
       what desired outcome. No generic "a user" language.}
    entities:
      - {role name, e.g. "Logistics Supervisor (Sara)"}
      - {system name, e.g. "SAP WMS"}
    artifacts:
      - {artifact name, e.g. "Exception report CSV"}
      - {artifact name, e.g. "WMS exception queue API"}
  # ... all 4+ scenarios

success_criteria:
  - "{specific, implementable, testable criterion 1}"
  - "{criterion 2}"
  # ... 2–5 criteria
```

### 9.2 — Draft students.yaml

```yaml
# Auto-generated by spec-builder-agent — {ISO datetime}

cohort_id: {role-slug}-{year}

age_range:
  min: {inferred or stated}
  max: {inferred or stated}

locale: {IETF tag}
primary_language: {language}

reading_level_target: {FK grade — from Phase 8 inference}

prior_knowledge:
  - domain: {skill/tool/domain they already know}
    level: {beginner|intermediate|advanced}
  # ... all prior knowledge extracted from user's documents

professional_context: |
  {3–5 sentences. Describes: job title, industry, daily tasks, team context,
   tools used daily. Specific enough that a generator can name the protagonist
   and their work situation without inventing details.}

mode_preference: {self_taught|cohort|both}

accessibility_needs:
  - screen_reader: {true|false}
  - dyslexia: {true|false}
  - low_vision: {true|false}

preferred_modalities:
  - read: {true|false}
  - watch: {true|false}
  - do: {true|false}

motivation_profile: {intrinsic|extrinsic|mixed}
```

### 9.3 — Draft review presentation

Present the drafts to the user in a readable summary (not raw YAML). Use this format:

```markdown
## Specification Draft — Please Review

### Problem Specification

**Problem ID:** {problem_id}
**Domain:** {domain}
**Summary:** {summary}

**Success criteria (these become your capstone lab acceptance criteria):**
1. {criterion 1}
2. {criterion 2}
3. {criterion 3}

**Domain vocabulary ({N} terms):** {term1}, {term2}, {term3}, …

**Scenarios ({N} total):**
| # | Title | Protagonist | System | Challenge |
|---|-------|-------------|--------|-----------|
| 1 | {title} | {entity} | {system} | {brief} |
| 2 | ... |
| 3 | ... |
| 4 | ... (reserved for capstone lab — students won't see this during chapters) |

---

### Student Specification

**Cohort:** {cohort_id}
**Role:** {professional_context — first sentence}
**Reading level:** FK grade {N} ({descriptor})
**Mode:** {mode_preference}
**Prior knowledge assumed:** {list}
**Prior knowledge NOT assumed (will be taught):** {list of gaps}

---

### Scope Assessment

| Check | Result | Notes |
|-------|--------|-------|
| Subject relevance | {✓ Aligned / ⚠ Marginal / ✗ Misaligned} | {note} |
| Course complexity | {✓ Well-scoped / ⚠ Too broad / ⚠ Too narrow} | {note} |
| Lab scope | {✓ Well-scoped / ⚠ Too complex / ⚠ Too simple} | {note} |
| Personalization richness | {✓ Sufficient / ⚠ Thin} | {note} |
| Scenario count | {✓ N scenarios / ⚠ Need more} | {note} |
```

Then use `AskUserQuestion`:
```
Q: "Does this specification match what you had in mind?"
options: [
  "Yes — write the files and start the course factory",
  "Almost — I have a few small adjustments (tell me what to change)",
  "The problem scope needs adjustment (I'll describe the change)",
  "The student profile needs adjustment (I'll describe the change)",
  "Start over — I'll provide clearer documents"
]
```

---

## PHASE 10 — File Writing

After the user approves the specification:

1. Write `inputs/problem.yaml` — full YAML, no REPLACE_ME tokens.
2. Write `inputs/students.yaml` — full YAML, no REPLACE_ME tokens.
3. Do NOT write `inputs/subject.md` unless the user asked you to replace it.
4. Leave `inputs/orchestration.yaml` unchanged.

Confirm after writing:

```markdown
## Specification Files Written ✓

- `inputs/problem.yaml` — {N} scenarios, {M} success criteria
- `inputs/students.yaml` — {cohort_id}, FK grade {N}, {mode_preference} mode

**Ready to generate your course.** Run:

```
@course-factory-agent
The input files are ready in inputs/. Generate the course.
```

Or, if you want to review or adjust the subject specification first:
- Open `inputs/subject.md` and modify it
- Then invoke `@course-factory-agent`
```

---

## Validation Checklists (run before writing files)

### problem.yaml final check:
- [ ] `problem_id` has no REPLACE_ME, is a valid slug
- [ ] `summary` is specific to the domain (names the role, system, and problem)
- [ ] `domain` is a single clear domain identifier
- [ ] `domain_vocabulary` has ≥ 3 terms with definitions
- [ ] `representative_scenarios` has ≥ 4 entries
- [ ] Each scenario has: id, title, description (2–4 sentences), entities (≥ 1), artifacts (≥ 1)
- [ ] Each scenario names specific systems/tools, not generic "the system" or "a user"
- [ ] `success_criteria` has 2–5 entries
- [ ] Each criterion is implementable, testable, and uses domain vocabulary
- [ ] Lab scope: criteria can collectively be implemented in 60–180 min ✓

### students.yaml final check:
- [ ] `cohort_id` has no REPLACE_ME, is a valid slug
- [ ] `reading_level_target` is a number in [6, 16]
- [ ] `prior_knowledge` has ≥ 1 entry with specific domain/skill name
- [ ] `professional_context` names: role, industry, daily tasks, tools used
- [ ] `mode_preference` is one of: self_taught, cohort, both
- [ ] Personalization richness: can name protagonist, system, object without inventing ✓

### Scope checks (all must pass before writing):
- [ ] Subject relevance ≥ 2 (aligned or marginal with user acknowledgment)
- [ ] Course complexity: 3–10 chapter-level topics (or user has acknowledged and accepted)
- [ ] Lab scope: 60–180 min estimated implementation (or user has scoped it appropriately)
