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
The user provides a path to an existing spec (e.g., `doc/MainSubjectSpec-Practical-Cowork-Automation.md`
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

After running all checks, present findings to the user using `AskUserQuestion`.

### 3.1 — Summary report

Present this report in your text output before asking questions:

```markdown
## Subject Spec Review — {title or "Your Spec"}

**Chapters:** {N}
**Estimated total learning time:** ~{total_hours:.1f} hours
**Per-chapter range:** {min_min}–{max_min} minutes

### Findings

#### ✓ Looks good
{List all OK checks}

#### ⚠ Warnings (may produce a suboptimal course)
{List all WARNING items}

#### ✗ Blocking issues (must be resolved before generation)
{List all CRITICAL items}

#### ℹ Notices (optional improvements)
{List all NOTICE items}
```

If there are no CRITICAL or WARNING issues: "This spec looks compatible with the generator.
You can proceed with minor refinements if you wish, or write it to `inputs/subject.md` now."

### 3.2 — Ask for decisions on blocking issues (if any)

For each CRITICAL issue, use `AskUserQuestion` to present options:

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

### 3.3 — Ask for decisions on warnings

Group warnings by type and present them together if there are multiple:

```
AskUserQuestion (multiSelect: true):
  "The spec has several warnings. Which would you like to address now?"
  Options:
    A. "Chapter duration issues ({N} chapters outside 45–90 min range)"
    B. "Concept density issues ({N} chapters with >7 topics)"
    C. "Low hands-on ratio ({N} chapters that are mostly conceptual)"
    D. "Vague learning objectives"
    E. "Skip all warnings — generate the course as-is"
```

For each selected warning type, present the specific chapters and ask how to resolve them.

### 3.4 — Optional improvements (if user wants)

If no blockers remain, offer optional improvements:

```
AskUserQuestion (multiSelect: true):
  "Would you like help improving any of these?"
  Options:
    A. "Rewrite vague objectives using observable action verbs"
    B. "Add a capstone scenario description to the spec"
    C. "Add explicit prerequisite statements"
    D. "Add a 'topics intentionally excluded' section to guide the planner"
    E. "No further changes — write the spec now"
```

---

## PHASE 4 — Refinement Loop

Max 3 rounds. For each round:

1. Present the specific change to be made (show the current text and proposed new text)
2. Make the change using the `Edit` tool if working on an existing file, or accumulate changes
   in a working draft if building from scratch
3. Re-run the affected checks from Phase 2
4. If new issues arise, surface them before proceeding

If after round 3 there are still unresolved CRITICAL issues, write them to a
`_subject-spec-issues.md` file and tell the user: "These blocking issues remain unresolved.
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
