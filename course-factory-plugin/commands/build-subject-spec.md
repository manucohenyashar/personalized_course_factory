---
name: build-subject-spec
description: Detailed logic for reviewing, validating, and improving a subject specification (inputs/subject.md) to ensure it is compatible with the Personalized Course Factory generator. Covers scope validation, structural checks, Bloom compatibility, hands-on feasibility, and capstone viability. Used by subject-spec-builder-agent.
---

# Build Subject Spec — Validation & Refinement Logic

This skill validates and improves a subject specification so it produces a coherent,
teachable course when processed by the Personalized Course Factory pipeline.

Follow every phase in order. Use `AskUserQuestion` to present findings and gather decisions.
Complete all phases before writing `inputs/subject.md`.

---

## Generator Compatibility Requirements

These are the hard constraints the generator enforces. A spec that violates them will cause
the pipeline to fail or produce a degraded course:

| Constraint | Minimum | Maximum | Notes |
|------------|---------|---------|-------|
| Chapter count | 3 | 30 | 20+ activates compact quiz mode (4 items) |
| Chapter duration | 30 min | 90 min | Hands-on must be ≥60% of each chapter |
| Total course time | ~1.5 h | ~18 h | Ideal range: 3–8 h for one course run |
| New concepts per chapter | 1 | 7 | >7 forces a chapter split |
| Learning outcomes per chapter | 3 | 7 | <3 = too thin; >7 forces a split |
| Capstone lab duration | 60 min | 180 min | Must integrate ≥3 chapters |
| Topics that can be exercised | ≥60% of chapter time | — | Pure lecture content fails §16.2 |

---

## PHASE 0 — Intake

### 0.1 — Determine the invocation mode

**Mode A — Reviewing an existing file:**
The user provides a path to an existing spec (e.g., `${CLAUDE_PLUGIN_ROOT}/doc/MainSubjectSpec-Practical-Cowork-Automation.md`
or their own file). Read the file using the `Read` tool.

**Mode B — Building from scratch:**
The user describes their course topic but has no structured spec. Ask them to share what
they have — even a rough list of topics, a training manual, or a paragraph description.
Proceed to Phase 1 using whatever they provide.

**Mode C — Reviewing `inputs/subject.md`:**
No file specified; check if `inputs/subject.md` exists and contains non-default content.
If it does, treat as Mode A with that file. If it contains the default Cowork Automation
curriculum, confirm with the user whether to review the default or start fresh.

---

## PHASE 1 — Parse the Specification

Read the spec and extract the following into a working structure:

```
parsed_spec:
  title: <string or null>
  audience: <string or null>
  prerequisites: [<string>]
  course_goal: <string or null>
  total_chapters: <int or null>
  recommended_duration_per_chapter_min: <int or null>
  course_level_outcomes: [<string>]
  chapters:
    - number: <int>
      title: <string>
      objectives: [<string>]
      topics: [<string>]
      sub_topics: [<string>]
      deliverables: [<string>]
      estimated_minutes: <int or null>   # null if not stated
  design_principles: [<string>]    # any stated philosophy / what to avoid
  intentional_simplifications: [<string>]
```

For any field that is absent from the spec, mark it `null` — do not invent values.

Estimate `estimated_minutes` for each chapter that has no stated duration:
- Count topics + sub-topics. Assume ~5 min per topic for reading, ~8 min per hands-on topic.
- Add ~10 min for exercises per chapter.
- Clamp the estimate to [20, 120] min.
- Mark estimates with a `~` prefix (e.g., `~45`) to distinguish them from stated values.

---

## PHASE R — Web Research

Run this phase after parsing the spec and before running validation checks. The goal is to
ground your evaluation in real-world knowledge of the subject: what practitioners actually
need, what similar courses teach, what topics are standard vs. optional, and what is current
vs. outdated. Research findings are used to supplement — not replace — the structural
validation in Phase 2.

### R.1 — Formulate search queries

From `parsed_spec`, derive 4 targeted queries:

```
query_1 (breadth): "{course_topic} course curriculum syllabus {audience_type}"
  → finds: what topics similar courses cover; typical chapter structures

query_2 (depth): "{course_topic} what to learn {audience_type} {level}"
  → finds: learning paths, recommended sequences, depth expectations

query_3 (authority): "{course_topic} certification skills {year} OR industry standard"
  → finds: professional certifications, official skill frameworks, employer expectations

query_4 (recency): "{course_topic} best practices {current_year} new developments"
  → finds: recent updates to the field; topics that have changed or emerged recently
```

If the spec covers a specific tool or platform (e.g., "Kubernetes", "SAP WMS", "Claude Code"),
add a fifth query targeting that tool directly:
```
query_5 (tool): "{tool_name} training topics {audience_type} hands-on"
```

Use the `WebSearch` tool for each query. Also use `WebFetch` to read 2–3 of the most
relevant results (course pages, syllabi, certification frameworks) in full.

### R.2 — Extract research findings

After completing all searches and reading key results, populate this structure:

```
research_findings:
  sources_consulted:
    - title: <page title>
      url: <URL>
      relevance: <why this source matters>

  topics_commonly_covered:
    # Topics that appear across ≥3 similar courses/resources.
    # These are the "expected" topics for this subject.
    - topic: <string>
      found_in: [<source titles>]
      in_spec: true | false    # does the user's spec include this?

  topics_in_spec_rarely_seen_elsewhere:
    # Topics in the user's spec that did NOT appear in similar courses/resources.
    # Flag for discussion — may be niche, outdated, or ahead of the field.
    - topic: <string>
      note: <reason it seems unusual, e.g., "typically only in advanced courses">

  recommended_ordering:
    # How similar courses typically sequence topics. Compare to the user's chapter order.
    description: <string>
    differs_from_spec: true | false
    ordering_notes: <specific differences, if any>

  typical_depth_for_audience:
    # What practitioners at this level are expected to be able to do (not just know).
    description: <string>
    spec_alignment: "well-aligned | too shallow | too deep | mixed"
    depth_notes: <specific mismatches, if any>

  industry_resources:
    # Relevant certifications, official documentation, style guides, or standards.
    - name: <string>
      url: <URL>
      relevance: <how it relates to the course>

  recency_notes:
    # Anything that suggests the spec is outdated or missing recent developments.
    - note: <string>
      source: <title>
```

### R.3 — Prepare research-based suggestions

From `research_findings`, build two lists for Phase 3:

**Suggested additions** — topics `commonly_covered` but missing from the spec (`in_spec: false`):
```
additions:
  - topic: <string>
    rationale: "Found in N similar courses/resources: {source_list}. Typical placement: after {topic X}."
    suggested_chapter: <number or "new chapter">
    priority: high | medium | low   # high = appears in most sources; low = appears in 1–2
```

**Suggested reviews** — topics in the spec that are `rarely_seen_elsewhere`:
```
reviews:
  - topic: <string>
    rationale: <why it may not belong>
    options: ["Keep — this is intentionally included", "Move to advanced sequel",
              "Replace with {alternative}", "Remove"]
```

Only surface suggestions with `priority: high` or `medium` unless the user asks for a full
audit. Low-priority additions are offered as optional improvements in Phase 3.4.

---

## PHASE 2 — Scope Validation

Run the following checks and record results for each:

### 2.1 — Chapter count check

```
chapter_count = len(parsed_spec.chapters)

if chapter_count < 3:
  flag: CRITICAL — "Too few chapters ({N}). The generator requires ≥3 chapters."
  suggestion: "Consider expanding the topic list or breaking broad chapters into smaller ones."

elif chapter_count > 18:
  flag: WARNING — "High chapter count ({N}). Courses with >18 chapters are large;
  consider whether this is one course or should be split into two."
  sub_flag (if > 20): "Compact quiz mode will activate: quizzes will have 4 items instead of 10."

else:
  status: OK
```

### 2.2 — Per-chapter duration check

For each chapter:
```
if estimated_minutes < 30:
  flag: WARNING — "Chapter {N} ({title}) is very short (~{min} min).
  It may be too thin to support a full exercise pack. Consider merging with an adjacent chapter."

elif estimated_minutes > 90:
  flag: CRITICAL — "Chapter {N} ({title}) is too long (~{min} min).
  The generator enforces a 90-minute maximum. This chapter needs to be split."

else:
  status: OK
```

### 2.3 — Total course time check

```
total_minutes = sum(estimated_minutes for each chapter)
total_hours = total_minutes / 60

if total_hours < 1.5:
  flag: WARNING — "Total course time is very short (~{h:.1f} h). This may not constitute
  a full course. Consider adding more content or merging with another topic area."

elif total_hours > 8:
  flag: WARNING — "Total course time is {h:.1f} hours — on the longer side for a single
  course run. Consider whether all content is essential or whether some can be moved to
  an advanced sequel."

else:
  status: OK
```

### 2.4 — Concept density check

For each chapter, count the number of distinct topics + sub-topics:
```
concept_count = len(topics) + len(sub_topics)

if concept_count > 7:
  flag: WARNING — "Chapter {N} ({title}) introduces {N} concepts. The generator enforces
  a maximum of 7 new concepts per chapter (cognitive load limit). Consider splitting this
  chapter or removing the least essential topics."

elif concept_count < 2:
  flag: WARNING — "Chapter {N} ({title}) has very few topics ({N}). It may not sustain
  a 45-minute chapter. Consider merging or adding sub-topics."
```

### 2.5 — Hands-on feasibility check

For each chapter, classify each topic as `practical` or `conceptual`:
- Practical: involves a concrete action, tool usage, workflow step, or creation of an artifact
- Conceptual: explains a concept, defines a term, or describes a principle without doing anything

```
practical_ratio = practical_count / total_topics

if practical_ratio < 0.5:
  flag: WARNING — "Chapter {N} ({title}) appears to be mostly conceptual
  ({practical_ratio:.0%} practical topics). The generator requires ≥60% of chapter time
  to be hands-on. This chapter may fail the pedagogy gate (§16.2) unless practical
  components are added."
```

### 2.6 — Learning objective quality check

For each chapter's objectives:
- Check if objectives use action verbs (any verb, not necessarily Bloom verbs — this is a light check)
- Check if objectives are observable ("understand X" is weak; "demonstrate X by doing Y" is strong)

```
vague_objectives = [obj for obj in objectives if verb is "understand" or "know" or "learn about"]

if any vague_objectives:
  flag: NOTICE — "Chapter {N} has vague objectives: {list}. These should be rewritten with
  observable verbs (e.g., 'demonstrate', 'create', 'evaluate'). The planner will rewrite
  them during planning, but clearer objectives here produce better course plans."
```

### 2.7 — Capstone viability check

Check whether the spec's topics support a 60–180 minute capstone lab that integrates ≥3 chapters:
- Look for topics that combine skills from multiple chapters
- Look for a "final project" or "portfolio" chapter
- Look for a stated deliverable or success criterion that spans the course

```
if no integrative scenario is obvious:
  flag: NOTICE — "The spec does not have an obvious capstone scenario — a problem that
  requires integrating skills from multiple chapters. The planner will propose one, but
  you may want to add a course-level success criterion or final project description."
```

### 2.8 — Prerequisite clarity check

```
if parsed_spec.prerequisites is empty:
  flag: NOTICE — "No prerequisites are stated. The generator creates a prerequisite
  diagnostic quiz from the prerequisites list. If the course truly has no prerequisites,
  that is fine — but consider stating that explicitly."
```

---

## PHASE 3 — Present Findings

After running Phase R (research) and Phase 2 (validation), present all findings to the user.
Present the research findings and the structural validation findings together — they tell a
single story about the spec's quality and completeness. Work through them in this order:
blocking issues → research gaps → structural warnings → optional improvements.

### 3.1 — Summary report

Present this full report in your text output before asking any questions:

```markdown
## Subject Spec Review — {title or "Your Spec"}

**Chapters:** {N}  
**Estimated total learning time:** ~{total_hours:.1f} hours  
**Per-chapter range:** {min_min}–{max_min} minutes  

---

### Research Findings
_Based on reviewing {N} sources including {source_list}_

**Coverage vs. similar courses:**
| Status | Topics |
|--------|--------|
| ✓ In spec and commonly taught | {list} |
| ➕ Commonly taught but missing from spec | {list or "none"} |
| ❓ In spec but rarely seen in similar courses | {list or "none"} |

**Ordering:** {aligned / differs — with specific notes}
**Depth for audience:** {well-aligned / too shallow / too deep / mixed — with notes}
**Industry resources found:** {list relevant certifications or standards, or "none"}
**Recency notes:** {any outdated content or missing recent developments, or "none"}

---

### Structural Validation

#### ✗ Blocking issues (must resolve before generation)
{List CRITICAL items, or "None"}

#### ⚠ Warnings (may produce a suboptimal course)
{List WARNING items, or "None"}

#### ℹ Notices (optional improvements)
{List NOTICE items, or "None"}

#### ✓ Looks good
{List all OK checks}
```

If there are no CRITICAL, WARNING, or research gaps: "This spec looks compatible with the
generator and covers the expected topics for this subject and audience. You can proceed or
make optional refinements."

### 3.2 — Ask for decisions on blocking issues (if any)

For each CRITICAL issue, use `AskUserQuestion` to present options. One question per issue.

**Example — chapter too long:**
```
Question: "Chapter 5 (Skills) is estimated at ~110 minutes, which exceeds the 90-minute maximum.
How would you like to handle this?"
Options:
  A. "Split it into two chapters (e.g., Chapter 5a: Creating Skills / Chapter 5b: Testing Skills)"
  B. "Remove some topics to reduce the chapter scope"
  C. "Keep it as-is — I'll adjust the time estimate manually"
```

**Example — too few chapters:**
```
Question: "The spec has only 2 chapters, which is below the minimum of 3. How would you like to expand it?"
Options:
  A. "Break one of the existing chapters into two"
  B. "Add a new chapter on a related topic"
  C. "Describe your topic in more detail and I will propose additional chapters"
```

### 3.3 — Ask about research-identified gaps (high/medium priority only)

For each `additions` item with `priority: high or medium`, ask the user one at a time:

```
Question: "Based on {N} similar courses I reviewed, '{topic}' is commonly included but not
in your spec. Found in: {source_list}. Typical placement: after '{preceding_topic}'.

Would you like to add it?"
Options:
  A. "Yes — add it to Chapter {suggested_chapter}"
  B. "Yes — create a new chapter for it"
  C. "No — this topic is out of scope for this course"
  D. "No — it's already covered implicitly in {chapter X}"
```

For each `reviews` item (topics in spec rarely seen elsewhere):

```
Question: "'{topic}' is in your spec but doesn't appear in most similar courses I found.
{rationale}. What would you like to do with it?"
Options:
  A. "Keep it — it's deliberately included for this audience"
  B. "Move it to an 'advanced topics' chapter or sequel"
  C. "Replace it with {alternative from research}"
  D. "Remove it"
```

If there are ordering differences (`recommended_ordering.differs_from_spec: true`):

```
Question: "Similar courses for this subject typically sequence topics differently from your spec:
  Your order:    {chapter_sequence}
  Typical order: {recommended_ordering.description}

The difference: {ordering_notes}.

Would you like to adjust the chapter order?"
Options:
  A. "Yes — reorder to match the typical sequence"
  B. "Yes — reorder partially: [I'll describe which chapters to move]"
  C. "No — my ordering is intentional"
```

### 3.4 — Ask about structural warnings

After resolving blocking issues and research gaps, group structural warnings and ask:

```
AskUserQuestion (multiSelect: true):
  "Your spec has some structural warnings. Which would you like to address?"
  Options:
    A. "Chapter duration issues ({N} chapters outside 30–90 min range)"
    B. "Concept density issues ({N} chapters with >7 topics)"
    C. "Low hands-on ratio ({N} chapters that are mostly conceptual)"
    D. "Vague learning objectives"
    E. "Skip all — generate the course as-is"
```

For each selected warning type, present the specific chapters and options to resolve them.

### 3.5 — Optional improvements

If no blockers or high-priority gaps remain, offer:

```
AskUserQuestion (multiSelect: true):
  "Would you like any optional improvements before writing the spec?"
  Options:
    A. "Rewrite vague objectives with observable action verbs"
    B. "Add a capstone scenario description"
    C. "Add explicit prerequisite statements"
    D. "Add a 'topics intentionally excluded' section"
    E. "Review low-priority topics found in research ({N} additional topics)"
    F. "No further changes — write the spec now"
```

If the user selects E (low-priority research topics), present them one at a time with the
same format as step 3.3.

---

## PHASE 4 — Refinement Loop

Max 3 rounds. For each round:

1. Present the specific change to be made — show the current text and proposed new text side
   by side. For research-driven additions, also cite which source(s) the suggestion comes from:
   > "Adding 'Error handling and debugging' to Chapter 6. This topic appeared in 4 of the 5
   > similar courses I reviewed, including the official Kubernetes documentation learning path."

2. Make the change using the `Edit` tool if working on an existing file, or accumulate changes
   in a working draft if building from scratch.

3. Re-run the affected checks from Phase 2. If a research-driven addition creates a concept
   density warning (>7 topics in the receiving chapter), surface that immediately before
   proceeding to the next change.

4. After all approved changes in the round are applied, present a brief "changes made" summary
   before moving to the next round.

**Research-driven additions** — when inserting a topic the user approved from research:
- Add it to the most natural chapter (based on prerequisite order and `recommended_ordering`)
- If no existing chapter can absorb it without exceeding 7 topics, propose creating a new chapter
- Keep the source attribution in a comment or note in the draft so the user can trace where
  each added topic came from

**Ordering changes** — when the user approves a reorder:
- Show the new chapter sequence as a numbered list before applying
- Verify that no chapter now references topics from later chapters (prerequisite order preserved)
- Update any cross-chapter references in objectives/deliverables to reflect the new numbering

If after round 3 there are still unresolved CRITICAL issues, write them to
`_subject-spec-issues.md` and tell the user: "These blocking issues remain unresolved.
The generator can still attempt planning, but will likely halt at Step 1 of the planner.
You can resolve them manually in `inputs/subject.md` before running `@course-factory-agent`."

---

## PHASE 5 — Write `inputs/subject.md`

After all rounds are complete, write the final spec.

**If working from an existing file that was modified:**
Write the updated content to `inputs/subject.md` using the `Write` tool. Preserve all
original content that was not explicitly changed.

**If building from scratch:**
Assemble the full spec from the `parsed_spec` structure plus all user-approved refinements.
Use this template:

```markdown
# {course_title}
## {subtitle if any}

**Version:** 1.0
**Audience:** {audience}

**Prerequisites:**
{prerequisites list}

**Course Goal:**
{course_goal}

**Primary Philosophy:**
This course prioritizes:
{design_principles}

This course intentionally excludes:
{intentional_simplifications}

---

# COURSE STRUCTURE

## Total Chapters
{chapter_count}

## Recommended Delivery
- {chapter_duration_min}–{chapter_duration_max} minutes per chapter
- Hands-on exercises in every chapter
- {delivery notes}

## Course-Level Learning Outcomes

By the end of this course, learners will be able to:
{course_level_outcomes}

---

{for each chapter:}
# Chapter {N} — {title}

## Objectives
{objectives}

## Topics
{topics}

## Deliverable
{deliverable}

---
```

After writing, confirm to the user:

> "`inputs/subject.md` has been written and validated.
>
> **Summary:**
> - {N} chapters
> - ~{total_hours:.1f} hours total learning time
> - {blocking_issues_resolved} blocking issues resolved
> - {warnings_resolved} warnings addressed
>
> **Next steps:**
> - Fill in `inputs/problem.yaml` and `inputs/students.yaml` (or run `@spec-builder-agent`)
> - Then run `@course-factory-agent` to generate the full personalized course"

If invoked by `@course-factory-agent`, return the path and summary without instructing the
user to run the next agent manually — the orchestrator will handle sequencing.
