---
title: Course Factory — Planner Agent Specification
version: 2.0.0
status: draft
last_updated: 2026-05-16
supersedes: PlannerSpec.md
implements: GreatCourseSpec_v2.md §3 (input contracts), §3.5 (precedence),
            §3.1 (narrative normalization), §6 (chapter partition), §9.5
            (prereq diagnostic), §10 (personalization plan), §14 (lab
            environment), §19 (skill orchestration)
governs:    GreatTextSpec_v2.md, GreatModuleExercise_v2.md,
            GreatPresentationSpec_v2.md, GreatQuizSpec_v2.md,
            GreatLabSpec_v2.md
agent_target: PlannerAgent (Claude Code agent)
scope: |
  Specifies the **PlannerAgent** — a Claude Code agent that reads the
  four sibling input specs, normalizes narrative inputs, resolves
  precedence conflicts, produces the course-wide Plan, and halts for
  human review before any artifact is generated. The Plan is the
  authoritative contract every downstream agent executes against.
conformance_language: RFC 2119
---

# Planner Agent Specification (v2)

## 1. Purpose

The PlannerAgent is the **first** agent in the Course Factory pipeline.
It does not generate any learner-facing artifact. It produces one
deliverable: **the Plan** (`course-plan.yaml`), an immutable, human-
approved contract that every downstream agent executes against.

The Plan exists because course generation is a multi-agent, multi-artifact
process and the artifacts MUST be consistent (master §7.15: single running
example; §10: shared personalization; §19.4: unseen-scenario invariant for
the capstone). Without a planning phase, downstream agents would each
make independent decisions and drift apart. With it, every agent receives
a pre-resolved, machine-readable assignment.

## 2. Conformance and Precedence

- All MUST/SHOULD language follows RFC 2119.
- This spec implements master **§3, §3.1, §3.5, §6, §9.5, §10, §14, §19**.
- On any conflict with the master spec, the master wins. The Plan MUST
  be regenerated whenever any input spec changes.
- The Plan is **read-only** for downstream agents (master §19.4 extends
  to all plan-derived artifacts).

## 3. Inputs

The PlannerAgent reads the four sibling specifications declared in
master §3:

1. **Subject Spec** — `subject.yaml` *or* `subject.md` (narrative form;
   see §6 for normalization).
2. **Problem Spec** — `problem.yaml`.
3. **Student Context Spec** — `students.yaml`.
4. **Orchestration Spec** — `orchestration.yaml`.

Each input MUST declare a `schema_version`. Missing required fields halt
the Planner with a structured error; the Planner MUST NOT fabricate
missing inputs (master §3).

## 4. Output: the Plan

The PlannerAgent emits the following artifacts under `<output_root>/_plan/`:

```
_plan/
  course-plan.yaml                  # THE Plan (see §9 schema)
  personalization-plan.json         # master §10, embedded by reference in the Plan
  subject.normalized.yaml           # only if Subject Spec was narrative (§6)
  subject.normalized.diff.md        # side-by-side diff for human review
  precedence-log.md                 # resolved conflicts (§7)
  chapter-partition-rationale.md    # human-readable explanation of partition decisions
  reserved-scenarios.json           # scenarios held back for capstone (master §19.4)
  dependency-graph.svg              # rendered DAG of agent dispatches
  PLAN_REVIEW.md                    # the human-review packet (§10)
```

`course-plan.yaml` is the **authoritative** contract; the other files are
either embedded by reference or serve human review.

## 5. The Planning Algorithm

The PlannerAgent MUST execute these steps in order. Each step has a halt
condition; the agent does NOT proceed past a halt without explicit
human approval logged in `PLAN_REVIEW.md`.

```
Step 1.  INPUT VALIDATION
   1.1 Load all four input specs; check schema_version.
   1.2 Validate required fields per master §3.1–§3.4.
   HALT if any MUST field is missing.

Step 2.  NARRATIVE NORMALIZATION  (master §3.1)
   2.1 If Subject Spec is narrative (.md), run the Narrative Subject
       Spec normalization pre-step:
         - extract subject_id, title, domain_taxonomy, target_level,
           prerequisites[], currency_stamp;
         - rewrite course objectives as learning_outcomes[] triples
           {verb, object, criterion} using master §9.1 Bloom verbs;
         - convert each narrative chapter heading to
           chapter_partitioning[] with title, scope, est_minutes,
           prerequisites[];
         - emit subject.normalized.yaml + subject.normalized.diff.md.
   2.2 HALT for human review of the diff before any further work
       (master §3.1).

Step 3.  PRECEDENCE RESOLUTION
   3.1 Walk every spec field that appears in more than one spec.
   3.2 Apply master §3.5 precedence:
         Student Context > Problem > Subject > Orchestration.
   3.3 Log each conflict and resolution in precedence-log.md.
   3.4 Apply numeric_overrides from orchestration_spec.numeric_overrides
       (master §2).

Step 4.  CHAPTER PARTITION  (master §6)
   4.1 Start from the (normalized) Subject Spec's chapter_partitioning[].
   4.2 Compute estimated time per chapter via master §6 formula.
   4.3 If a chapter exceeds 60 min, split into sub-chapters ≤ 45 min.
   4.4 If chapter_partitioning is empty, propose a partition and
       HALT for human review (master §3.1).
   4.5 Verify ≥ 60 % hands-on share (master §7.14) is achievable in each
       chapter given est_minutes; if not, redistribute scope.
   4.6 Auto-activate compact-mode quiz when chapter_count ≥ 25
       (master §9.2).
   4.7 Emit chapter-partition-rationale.md.

Step 5.  TRACK & AUDIENCE DETERMINATION
   5.1 Resolve target_track per chapter:
         - if subject_spec.target_level == intro:           universal
         - if subject_spec.target_level ∈ {intermediate, advanced}: both
           (master §7.8 expertise-reversal)
   5.2 Apply master §11 audience-adaptation rules (FK grade cap,
       glossary translation, accessibility, modality preference,
       time budget cap).

Step 6.  PERSONALIZATION PLAN  (master §10)
   6.1 Walk problem_spec.representative_scenarios[].
   6.2 Allocate scenarios to chapters; reserve at least ONE unseen
       scenario for the capstone (master §19.4 invariant).
   6.3 Build vocabulary_substitutions from problem_spec.domain_vocabulary
       and student_context.cultural_norms.example_substitutions.
   6.4 Set voice_register from student_context (formal | conversational |
       technical).
   6.5 Emit personalization-plan.json and reserved-scenarios.json.

Step 7.  COURSE-WIDE PRE-WORK ASSIGNMENTS
   7.1 Diagnostic (master §9.5): one QuizGenerator invocation in
       `diagnostic` mode with 8 items routing to fast-track / standard /
       with-prerequisites.
   7.2 Course-wide environment (master §14): EnvironmentScaffold work
       item.
   7.3 Glossary skeleton: GlossaryAggregator's initial-state work item.
   7.4 Reference architecture seed: ReferenceArchitecture initial diagram.

Step 8.  PER-CHAPTER WORK ASSIGNMENTS
   For each chapter, the Plan declares a ChapterAssignment containing
   the full deliverable list (Text → Exercise → Presentation → Quiz →
   Podcast → Companion → chapter Evaluator), with dependencies and
   quality gates. See §9 for the schema.

Step 9.  CAPSTONE ASSIGNMENT
   9.1 LabGenerator invocation with chapters_to_interleave[] covering
       ≥ 60 % of chapters (master §9.4) and the reserved unseen
       scenario.
   9.2 Capstone duration 60–180 min (default 120) (master §9.4).
   9.3 6-criterion rubric per master §9.4 / GreatLabSpec_v2 §8.

Step 10. EVALUATOR ASSIGNMENT
   10.1 Per-chapter Evaluator pass at end of every chapter.
   10.2 Course-wide Evaluator pass after capstone.
   10.3 Quality gate set = master §16 ∩ orchestration_spec.quality_gates_to_run.

Step 11. DEPENDENCY GRAPH
   11.1 Build the dependency DAG (§9.6).
   11.2 Verify there is exactly one source (Stage 0 inputs) and one sink
       (the final Evaluator pass).
   11.3 Render dependency-graph.svg.

Step 12. HUMAN REVIEW PACKET
   12.1 Assemble PLAN_REVIEW.md (§10).
   12.2 HALT for human approval before any artifact is generated.
```

## 6. Narrative-to-Structured Normalization

When `subject.md` (narrative) is the input, the PlannerAgent MUST:

1. Extract every chapter heading and treat it as a candidate chapter
   title.
2. Map each "Objectives" bullet to a learning outcome triple; reject
   any objective that lacks an observable verb (master §9.1).
3. Extract `target_level` from explicit cues in the narrative (e.g.,
   "Audience: Knowledge workers, Business professionals, Technical
   professionals" → infer `intermediate` and flag for human confirmation).
4. Compute `est_minutes` per chapter; if the narrative declares a range
   (e.g., "45–60 minutes per chapter") use the upper bound.
5. Translate any "Pedagogical Structure" or "Demonstration Strategy"
   sections in the narrative into orchestration-spec hints (e.g., a
   single shared scenario across chapters → confirm Problem Spec
   provides one unified domain).
6. Surface unresolved decisions as **explicit questions** in
   `PLAN_REVIEW.md` (e.g., "The narrative implies a single capstone
   integrating Parts 1–9. Confirm chapters_to_interleave = all 36?").

The Planner MUST NOT proceed past Step 2 without human approval of
`subject.normalized.diff.md`.

## 7. Conflict Resolution

The Planner enforces master §3.5 precedence. Common conflict patterns
the Planner MUST resolve and log:

| Conflict | Resolution rule |
|---|---|
| Subject Spec declares "optional exercises" or "5–15 min hands-on", but master §7.14 demands ≥ 60 % hands-on | Master wins (pedagogical floor is non-overridable). Log and keep ≥ 60 % rule. |
| Subject Spec chapter time exceeds master §6 cap | Split into ≤ 45 min sub-chapters; halt for human review of the proposed split. |
| Orchestration Spec sets `numeric_overrides.quiz.items` outside [4, 10] | Reject — log the override as invalid; use default. |
| Student Context's `time_budget_per_week` is less than estimated total chapter time × 0.25 | Surface in PLAN_REVIEW.md as a learner-load warning; do not silently shorten the course. |
| Problem Spec lacks enough scenarios for one-per-chapter + unseen-capstone | Halt; request more scenarios. Do not invent. |
| Subject Spec inferred `target_level` disagrees with Student Context's `prior_knowledge` | Surface for human confirmation; do not auto-resolve. |

## 8. Agent Roster (executed downstream of the Plan)

The Plan dispatches to the following agents. The PlannerAgent is itself
the upstream node; it does not generate learner-facing artifacts.

| Agent | Cardinality | Sub-spec | Owns |
|---|---|---|---|
| **PlannerAgent** | 1 per course | `PlannerSpec_v2.md` (this) | The Plan |
| **ChapterSupervisorAgent** | 1 per chapter | (this spec §11) | Per-chapter dispatch + intra-chapter dependency enforcement |
| **ChapterTextGenerator** | 1 per chapter | `GreatTextSpec_v2.md` | Chapter doc + `*--doc.handoff.json` |
| **ExerciseGenerator** | 1 per chapter | `GreatModuleExercise_v2.md` | Exercise pack |
| **PresentationGenerator** | 1 per chapter | `GreatPresentationSpec_v2.md` | Slide deck + notes |
| **QuizGenerator** | 1 per chapter + 1 diagnostic | `GreatQuizSpec_v2.md` | Quiz Form A + Form B + prereq diagnostic |
| **PodcastGenerator** | 1 per chapter | *(future PodcastSpec — currently produced under master §8.4 by an inlined PodcastGenerator role)* | Podcast script |
| **CompanionGenerator** | 1 per chapter | *(currently master §8.6)* | Cheatsheet, instructor guide, troubleshooting |
| **LabGenerator** | 1 per course | `GreatLabSpec_v2.md` | Capstone Lab |
| **EvaluatorAgent** | 1 per chapter + 1 course-wide + 1 capstone | (this spec §12) | Quality-gate execution + diagnostic reports |
| **GlossaryAggregator** | 1 per course (incremental) | *(currently master §8.7)* | `glossary.md` |
| **ReferenceArchitectureGenerator** | 1 per course (incremental) | *(currently master §8.7)* | `reference-architecture.svg` + source |
| **EnvironmentScaffoldGenerator** | 1 per course | *(currently master §14)* | `environment/` |

The original PlannerSpec did not list a QuizGenerator; it is added here
to align with master §9 and the chapter artifact list in §1.

## 9. `course-plan.yaml` Schema (REQUIRED)

```yaml
# 0. Identity
plan_id:        <uuid>
plan_version:   <semver>
created_at:     <ISO-8601>
authored_by:    PlannerAgent vX.Y.Z
master_spec_ref: GreatCourseSpec_v2.md@<git-sha>

# 1. Input fingerprints (immutable from this point)
inputs:
  subject_spec:         { path, schema_version, content_hash, normalized_from_narrative: bool }
  problem_spec:         { path, schema_version, content_hash }
  student_context_spec: { path, schema_version, content_hash }
  orchestration_spec:   { path, schema_version, content_hash }

# 2. Normalization artifacts (only if narrative)
normalization:
  subject_normalized_path: <path|null>
  diff_path:               <path|null>
  approved_by:             <name|null>
  approved_at:             <ISO-8601|null>

# 3. Resolved precedence
precedence_log_path:       <path>

# 4. Numeric overrides applied
numeric_overrides:
  source: orchestration_spec | planner_default | human_override
  values: { ... }                # any subset of §2 / §9.2 / §16.7 / etc.

# 5. Personalization plan
personalization_plan_path:  <path to personalization-plan.json>
reserved_scenarios_path:    <path to reserved-scenarios.json>

# 6. Chapter partition
chapter_partition:
  - number:              <int>
    slug:                <kebab-case>
    title:               <string>
    scope:               <one-paragraph>
    est_minutes:         <int 30..60>
    hands_on_minutes:    <int ≥ 0.6 × est_minutes>
    target_track:        novice | practiced | universal | both
    learning_outcomes:   [ { id: LO-NN.n, verb, object, criterion, bloom_level } ]
    prerequisites:
      prior_chapters:    [<int>, ...]
      topics:            [<string>, ...]
    running_example_ref: problem_spec.representative_scenarios[<i>]
    tool_versions:       { <tool>: <pinned> }

# 7. Per-chapter work assignments
per_chapter_assignments:
  - chapter: <int>
    supervisor: ChapterSupervisorAgent
    deliverables:
      - agent:           ChapterTextGenerator
        sub_spec:        GreatTextSpec_v2.md
        envelope:        <common §19.2 envelope + text-specific inputs>
        output_paths:    [...]
        depends_on:      []                # text is the seed
        quality_gates:   [<subset of master §16>]
      - agent:           ExerciseGenerator
        sub_spec:        GreatModuleExercise_v2.md
        envelope:        <... + handoff_path: chN--doc.handoff.json>
        depends_on:      [ChapterTextGenerator]
        quality_gates:   [...]
      - agent:           PresentationGenerator
        sub_spec:        GreatPresentationSpec_v2.md
        envelope:        <... + exercise_manifest_path>
        depends_on:      [ChapterTextGenerator, ExerciseGenerator]
        quality_gates:   [...]
      - agent:           QuizGenerator
        sub_spec:        GreatQuizSpec_v2.md
        envelope:        <... + prior_chapter_quiz_items: [ch{N-1}, ch{N-3}]>
        depends_on:      [ChapterTextGenerator]
        quality_gates:   [...]
      - agent:           PodcastGenerator
        envelope:        <... + handoff_path + exercise_manifest_path>
        depends_on:      [ChapterTextGenerator, ExerciseGenerator]
        quality_gates:   [...]
      - agent:           CompanionGenerator
        envelope:        <...>
        depends_on:      [ChapterTextGenerator]
        quality_gates:   [...]
      - agent:           EvaluatorAgent (chapter pass)
        envelope:        <chapter manifest>
        depends_on:      [<all prior chapter deliverables>]
        quality_gates:   <master §16.1–§16.7 for this chapter>

# 8. Course-wide assignments
course_assignments:
  - agent: EnvironmentScaffoldGenerator
    depends_on: []
  - agent: PersonalizationPlanGenerator   # done by Planner itself; present for traceability
    depends_on: []
  - agent: QuizGenerator (diagnostic mode)
    depends_on: [PersonalizationPlanGenerator]
  - agent: GlossaryAggregator             # incremental, after every chapter
  - agent: ReferenceArchitectureGenerator # incremental
  - agent: LabGenerator
    depends_on: [<every chapter EvaluatorAgent pass>]
    envelope:
      unseen_scenario: <from reserved-scenarios.json>
      chapters_to_interleave: [<≥ 60 % of chapter numbers>]
      duration_target_minutes: 120
  - agent: EvaluatorAgent (course-wide)
    depends_on: [LabGenerator]
    quality_gates: <course-wide subset of master §16>

# 9. Reserved scenarios
reserved_scenarios:
  capstone: <ref into problem_spec.representative_scenarios>
  notes: "ChapterTextGenerator and ExerciseGenerator MUST NOT consume this entry."

# 10. Dependency graph
dependency_graph:
  edges: [ { from: <agent+chapter>, to: <agent+chapter> } ]
  rendered_path: <path to dependency-graph.svg>

# 11. Human review checkpoints
human_review_points:
  - step: subject_normalization
    status: required | approved | skipped
    approved_by: <name|null>
    approved_at: <ISO-8601|null>
  - step: chapter_partition
    status: required | approved | skipped
  - step: personalization_plan
    status: optional | approved
  - step: pre_lab_generation
    status: optional | approved

# 12. Quality gate selection
quality_gates:
  per_chapter: [<gate IDs from master §16.1–§16.7>]
  course_wide: [<gate IDs from master §16>]
  enforcement: MUST | SHOULD

# 13. Regeneration policy (from orchestration_spec)
regeneration_policy:
  scope: full | chapter | section
  on_failure: regenerate_until_pass | halt_and_report | mark_partial

# 14. Mode targets
mode_targets: [self_taught, cohort]

# 15. Telemetry hooks (optional)
telemetry:
  evaluator_report_path: <path>
  per_chapter_metrics_path: <path>
```

## 10. Human Review Packet (`PLAN_REVIEW.md`)

Before any artifact is generated, the PlannerAgent MUST emit a
`PLAN_REVIEW.md` containing:

- A 1-page **executive summary** (audience, total duration, chapter
  count, capstone scope, estimated total artifacts, estimated weeks
  of generator runtime).
- The chapter partition table with proposed splits/merges highlighted.
- The personalization plan — substitution table preview.
- The reserved capstone scenario.
- The precedence log (every conflict and its resolution).
- The list of explicit decisions still requiring human confirmation
  (each as a checkbox).
- A "Plan ready to execute" signature block (name + date).

The pipeline MUST NOT proceed past this packet without an explicit
human approval recorded in the Plan's `human_review_points`.

## 11. ChapterSupervisorAgent (subordinate to Planner)

The ChapterSupervisorAgent is dispatched once per chapter. Its
responsibilities are narrow:

- Read the chapter's `per_chapter_assignments` entry.
- Dispatch deliverables in dependency order (Text → Exercise →
  Presentation; Quiz in parallel with Presentation; Podcast after
  Text + Exercise; Companion after Text).
- Pass `*--doc.handoff.json` to every downstream agent.
- On any downstream agent failure, retry once with the failure detail;
  on second failure, halt and surface to the EvaluatorAgent + human.
- Emit a `chapter.manifest.json` with paths, checksums, and the
  Evaluator's per-chapter verdict.

The ChapterSupervisor does NOT make creative or pedagogical decisions —
those are baked into the Plan by the PlannerAgent.

## 12. EvaluatorAgent (subordinate to Planner)

The EvaluatorAgent runs the quality gates declared in the Plan:

- **Per-chapter pass**: master §16.1–§16.7 against the chapter
  manifest.
- **Course-wide pass**: master §16 cross-artifact gates (single
  running example, glossary consistency, prereq coverage,
  cross-chapter retrieval health).
- **Capstone pass**: GreatLabSpec_v2 §14 gates.

On any MUST failure the EvaluatorAgent triggers regeneration per the
Plan's `regeneration_policy.on_failure`. The EvaluatorAgent MUST log
every gate result and produce a structured report (`evaluator-report.md`)
the orchestrator and humans can read.

## 13. Quality Gates on the Plan Itself

Before the PlannerAgent emits the Plan it MUST verify:

### MUST gates
- [ ] All four input specs validated; `schema_version` recorded.
- [ ] If Subject Spec was narrative, normalization is complete and
      diff approved.
- [ ] Precedence log covers every multi-spec field with a winner.
- [ ] Every chapter has `est_minutes ≤ 60` and `hands_on_minutes ≥ 0.6
      × est_minutes`.
- [ ] No chapter consumes a scenario reserved for the capstone.
- [ ] Capstone covers ≥ 60 % of chapters (master §9.4).
- [ ] Capstone has an unseen scenario reserved.
- [ ] When `chapter_count ≥ 25`, compact-mode quiz is auto-activated
      (master §9.2).
- [ ] Every Learning Outcome uses a Bloom verb from master §9.1.
- [ ] Every per-chapter assignment names its sub-spec and quality gates.
- [ ] The dependency graph is acyclic and has a single sink.
- [ ] `PLAN_REVIEW.md` exists and contains every required section
      (§10).

### SHOULD gates
- [ ] Course total time × 0.25 ≤ student_context.time_budget_per_week
      × course_weeks (load warning).
- [ ] Each chapter is in the typical 45–60 min band (warn if outside).
- [ ] The number of in-flight chapters at any wall-clock step does
      not exceed the orchestrator's parallelism cap.

## 14. Anti-Patterns (FORBIDDEN)

- Generating any chapter artifact before `PLAN_REVIEW.md` is approved.
- Inventing missing input fields, scenarios, or LOs.
- Silently weakening a master §16 MUST gate during planning.
- Allocating the unseen-capstone scenario to a chapter.
- Producing a chapter assignment without a fully-specified envelope
  (every required field from master §19.2 + the relevant sub-spec).
- A Plan with a cycle in the dependency graph (e.g., Quiz depending on
  Podcast which depends on Quiz).
- Splitting a chapter without halting for human review when the split
  was forced by master §6.
- Suppressing a precedence conflict (every conflict MUST appear in
  `precedence-log.md`).
- Auto-approving the Plan (every checkpoint MUST be human-approved
  before the Plan is consumed by downstream agents).
- Skipping the diagnostic quiz (master §9.5) when the Subject Spec
  declares any prerequisites.

