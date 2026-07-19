# Course Factory — Execution Cost & Time Optimization Plan

**Scope:** reduce wall-clock time and token cost of a full course generation run **without
changing the architecture** — same set of agents and skills, same output format and quality bar.
Every recommendation changes only *how* the pipeline runs, and each traces to a Phase 1 finding.

---

## Executive Summary

A single course run is dominated by one number: the **evaluation fan-out**. Every artifact is
checked by an evaluator that spawns **all 7 quality-gate sub-agents in parallel, passing each the
full artifact text**. That is 8 model calls per artifact-evaluation, and it repeats for 6 artifact
types per chapter, up to 3 times per artifact via the feedback loop.

For an 18-chapter course the pipeline issues roughly **1,000–1,600 sub-agent model calls**, of
which **~42 gate calls per chapter (≈760 per course at one attempt, ≈1,200 with retries)** are the
single largest line item. Three structural inefficiencies inflate this further:

1. **Guaranteed no-op gate calls** — several `(artifact × gate)` combinations run a gate that has
   *no checks defined* for that artifact type (e.g. calibration on slides/podcast/companion). ~20%
   of gate calls do no real work.
2. **Contradictory three-layer instructions** — every generator loads an agent file **plus** a
   skill **plus** a spec that re-encode the same contract, and in four of five cases the copies have
   **drifted into direct contradiction**. Contradictions make generators fail gates and burn extra
   feedback-loop attempts — each avoidable attempt costs a full 9-call cycle.
3. **Redundant instruction payload** — each generator call carries ~39 KB of `CLAUDE.md` plus
   33–48 KB of overlapping agent+skill+spec text before it reads any input data (~23 K tokens of
   instructions per call), most of it repeated across the three layers and across chapters.

The recommendations below are ordered by ROI. The top three quick wins are low-risk, need only
edits to existing files (no new agents, no architecture change), and together should cut
**token cost by an estimated 35–55%** and **wall-clock by 25–40%**. None of them relaxes a MUST
gate or changes an artifact's format.

**Decided structural change (R2):** collapse the three instruction layers to two — make the
agent + skill self-contained and **stop reading the `doc/` specs at runtime**, keeping the doc files
only as design history. Reconciliation follows three chosen rules: **docs win** where an agent/skill
contradicts its spec (re-sync the agent/skill *and* the coupled gate to the spec value); **CLAUDE.md
hard rules still win over any spec** (Rule 1/2/3 + §17 — e.g. Bloom badges stay hidden on slides
despite GreatPresentationSpec); and **DocxDesignSpec stays on the hot path** (all other in-scope
specs leave it). See R2 for the full conflict-resolution table and execution sequence.

> **Cost model (18-chapter course, all 6 artifact types active).** Per chapter at one attempt:
> 7 generator calls + 6 evaluator calls + 42 gate calls = **55 sub-agent calls**; **42 of the 55
> are gate calls**. With an assumed average of ~1.6 feedback attempts on the six evaluated
> artifacts, that rises to **~87 calls/chapter ≈ 1,570 calls/course**, plus planning, environment,
> course evaluation, lab, and README. Gate calls alone are on the order of **10–18 M input tokens**
> because each carries `CLAUDE.md` + the gate file + the full artifact payload.

---

## Phase 1 — Findings

### Execution flow (as actually wired)

```
course-factory-agent (opus-4-7)  ──runs skill──▶  /personalized-course-generator
  Phase 0 spec intake ─ Phase 1 planner ─ Phase 2 environment ─ Phase 3 chapters
  ─ Phase 4 course eval ─ Phase 5 capstone ─ Phase 6 podcasts ─ Phase 7 README ─ Phase 8 report

planner-agent (opus-4-7)  ── /plan-course + doc/PlannerSpec.md ──▶ _plan/*.yaml|json  (2 human halts)

PER CHAPTER  ── chapter-supervisor-agent (sonnet-4-6) ──
  Step 1 (sequential):  chapter-text-generator ─▶ chapter-text-evaluator ─▶ 7 gates
  Step 2 (parallel):    exercise|quiz|podcast generators ─▶ 3 evaluators ─▶ 3×7 gates
  Step 3 (parallel):    presentation|companion generators + glossary ─▶ 2 evaluators ─▶ 2×7 gates
  each generator↔evaluator pair runs the 3-attempt feedback loop

evaluator-agent (opus-4-7)  ─ course-wide re-read of every chapter doc/handoff/glossary
lab-generator ─▶ lab-evaluator ─▶ 7 gates      generate-course-podcasts (external NotebookLM)
```

The context-isolation design is already sound: supervisors and generators run as sub-agents, state
lives in `PIPELINE_STATE.md`, and `/next-chapter` bounds each chapter to a fresh window
(`.claude/skills/next-chapter.md`). **The problem is not context management — it is call count,
redundant payload, and avoidable retries.**

---

### F1 — Every evaluator spawns all 7 gates unconditionally, and passes each the full artifact
**Severity: highest (dominant cost).**
All 7 artifact evaluators spawn all 7 gate sub-agents with no artifact-type conditioning:
`chapter-text-evaluator.md:30`, `exercise-evaluator.md:36`, `quiz-evaluator.md:40`,
`presentation-evaluator.md:37`, `podcast-evaluator.md:36`, `companion-evaluator.md:39`,
`lab-evaluator.md:71`. `chapter-text-evaluator.md:37-83` literally repeats
`artifact_content: <full doc text>` in all 7 gate blocks; every gate file's Inputs section also
mandates `artifact_content: full artifact` (`coverage-gate-evaluator.md:13`, etc.). The same
payload is transmitted **7× per attempt, up to 21× per artifact** across the feedback loop.
`inputs/orchestration.yaml` sets `quality_gates_to_run: all`, so nothing narrows this at runtime.

### F2 — Several `(artifact × gate)` combinations are guaranteed no-ops
**Severity: high (pure waste, ~20% of gate calls).**
Reading only what the gate files actually check:
- **calibration-gate** defines MUST checks *only* for quiz, exercises, and doc
  (`calibration-gate-evaluator.md`) → **no-op for slides, podcast, companion, lab**.
- **pedagogy-gate** defines checks *only* for doc, exercises, slides, quiz
  (`pedagogy-gate-evaluator.md:22-41`) → **no-op for podcast, companion, lab**.
- **technical-gate** checks 1–3 require code blocks; 4–6 are exercises-only; 7–8 lab-only
  (`technical-gate-evaluator.md:23-52`) → **guaranteed empty for podcast**, near-empty for slides,
  quiz, and no-code chapter docs.
- **accessibility-gate** figure/code checks are vacuous for the audio-only podcast script.

Per chapter that is ~6 fully wasted + ~3 near-empty gate calls out of 42 (~20%), each still paying
full instruction + payload tokens.

### F3 — Three-layer instruction duplication that has drifted into contradictions
**Severity: high (wastes tokens *and* causes retries).**
Every generator loads an agent **and** a skill **and** a spec (agent files explicitly say to read
both — e.g. `chapter-text-generator.md:7-9`). Loaded instruction per artifact is **33–48 KB**
(`chapter-text` 40 KB, `exercises` 37 KB, `quiz` 33 KB, `presentation` 38 KB, `lab` 48 KB), 45–65%
of which restates another layer. Worse, the copies now **contradict**:
- **Chapter text:** agent+skill define a **15-section** structure (`chapter-text-generator.md:65-152`,
  `generate-chapter-text.md:285-306`); spec defines a **different 14-section** structure
  (`GreatTutorialSpec.md:143-164`). Word budget: agent/skill **3,500–6,000**
  (`generate-chapter-text.md:304-306`) vs spec **2,500–4,500** (`GreatTutorialSpec.md:360`).
- **Slides:** spec **requires** Bloom badges + LO-IDs visible on slides
  (`GreatPresentationSpec.md:82,129-134,224`); the agent **forbids** them
  (`presentation-generator.md:42,64`); the skill **contradicts itself** (`generate-presentation.md:169,208`
  show badges, `:376` forbids them). This directly violates CLAUDE.md Rule 1 and is a personalization/
  format gate failure waiting to happen.
- **Exercises:** README-vs-`brief.docx` as the student file, and a 40-min cap vs a 60% floor
  (`GreatModuleExercise.md:225` vs `exercise-generator.md:162`).
- **Lab:** `.md` vs `.docx` deliverable filenames (`GreatLabSpec.md:71-91` vs `lab-generator.md:103-114`).

Contradictions are read as ambiguity by the generator → higher chance of failing an evaluator →
extra feedback-loop attempts, each a full generator+evaluator+7-gate cycle.

### F4 — Redundant `CLAUDE.md` + spec payload on every call
**Severity: high.**
`CLAUDE.md` is 39 KB (~10 K tokens) and is loaded into every agent context. The
Personalization Protocol (Steps P1–P4), the Handoff JSON schema, the file-naming convention, and
the "no em dashes / Arial / no LO-IDs" rule set are **restated again** inside the skills and inside
3 of 5 generator agents (`chapter-text-generator.md:169-178`, `quiz-generator.md:179-182`,
`lab-generator.md:116-124`) — so a docx generator sees those formatting prohibitions up to three
times. The Handoff JSON template alone is ~2.9 KB and appears in CLAUDE.md, the skill
(`generate-chapter-text.md:205-281`), and the spec.

### F5 — Feedback loop re-runs the entire 8-call evaluation on every attempt
**Severity: medium-high.**
`chapter-supervisor-agent.md:53-78` re-invokes the generator and then a **fresh full evaluation
(evaluator + all 7 gates)** on each of up to 3 attempts, even when only one gate failed. A single
failed gate on attempt 1 costs 8 calls to re-check all 7 gates on attempt 2. CLAUDE.md even labels a
first-attempt personalization failure a "process failure," implying retries are common.

### F6 — Chapters run strictly sequentially though they are largely independent
**Severity: medium (wall-clock, not tokens).**
Phase 3 (`personalized-course-generator.md:335-354`) and `/next-chapter` process one chapter at a
time. Each chapter is seeded only by its own handoff JSON. The only cross-chapter couplings are the
incremental `glossary-aggregator` (writes one shared `glossary.docx`) and quiz **carry-forward**
(reads items from chapters N-1 and N-3, `chapter-supervisor-agent.md:126`). Wall-clock is therefore
~linear in chapter count with no concurrency between independent chapters.

### F7 — All evaluation runs on one Sonnet tier regardless of task nature
**Severity: medium.**
All 7 evaluators and all 7 gates are `claude-sonnet-4-6`. Mechanical, rule-driven gates
(format = word/slide counts, filenames, DXA table widths; coverage = LO/Bloom presence scan;
technical = syntax/verify; accessibility = alt-text presence) do checklist matching that a cheaper
tier handles well, while only the judgment gates (pedagogy, personalization, calibration) need
Sonnet-level reasoning. Everything pays the Sonnet rate.

### F8 — Course-wide evaluator partly repeats per-chapter checks
**Severity: low-medium.**
`evaluator-agent.md` (opus-4-7) re-reads every chapter doc + handoff and re-checks LO coverage
(Steps 2–3) that the per-chapter coverage-gate already verified. Some overlap is legitimate
(cross-chapter scope), but the per-artifact re-reads are heavy on the most expensive model.

### F9 — Input-file naming discrepancy can force a HALT / re-plan
**Severity: medium (correctness + wasted run).**
Planner, factory agent, and skills require `inputs/course-skeleton.md`
(`planner-agent.md:14`, `personalized-course-generator.md:66`), but the repo actually contains
`inputs/subject.md` and **no** `inputs/course-skeleton.md`. A rename is mid-flight (git shows 46
files churning). A run that halts on the missing file, or plans against the wrong file, wastes the
whole planning pass (two human halts included).

### F10 — Duplicated `.claude/` vs `course-factory-plugin/` trees (maintenance, not runtime)
**Severity: low for runtime; medium for correctness/drift.**
The pipeline exists twice: the active `.claude/` tree and the distribution `course-factory-plugin/`
tree (30 agents + 12 skills/commands + doc specs each). Only `.claude/` runs locally. The copies
have already drifted: the plugin still ships `GreatTextSpec.md` while its own agent points at the
renamed `GreatTutorialSpec.md` (a **broken reference**), and retains stale "Subject" terminology.
This does not cost runtime tokens but multiplies the effort of every fix below (each edit must be
mirrored) and is a live source of contradiction.

---

## Phase 2 — Prioritized Recommendations

Impact bands are estimates for an 18-chapter course. "Tokens" = generation-run token cost.

### Quick wins (low effort, low risk, do first)

#### R1 — Invoke only the applicable gates per artifact type *(fixes F2, dampens F1)*
Add a small **gate-applicability matrix** to each artifact evaluator so it spawns only the gates
that actually have checks for that artifact type. Keep all 7 gate agents defined (architecture
unchanged) — just stop invoking the no-ops. Starting matrix, straight from the gate files:

| Artifact | coverage | pedagogy | personalization | format | technical | accessibility | calibration |
|----------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| doc | ✓ | ✓ | ✓ | ✓ | code-only | ✓ | ✓ |
| exercises | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| slides | ✓ | ✓ | ✓ | ✓ | — | ✓ | — |
| quiz | ✓ | ✓ | ✓ | ✓ | code-item-only | ✓ | ✓ |
| podcast | ✓ | — | ✓ | ✓ | — | reduced | — |
| companion | ✓ | — | ✓ | ✓ | code-only | ✓ | — |
| lab | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

- **Impact:** removes ~6 guaranteed no-op + ~3 near-empty gate calls per chapter (~20% of gate
  calls). **≈250–400 fewer gate calls/course; ~10–18% token cut; proportional wall-clock cut** on
  the parallel gate stage.
- **Effort:** low — edit the 7 evaluator files (Step 2 spawn list) + document the matrix in
  `orchestration.yaml`. **Risk:** minimal — every removed call is a gate the file itself defines no
  checks for; MUST coverage is unchanged.

#### R2 — Collapse the runtime spec layer: make agents+skills self-contained and stop reading `doc/` *(fixes F3, F4; dampens F5)*
**This is the decided approach (user direction).** Today every generator loads **three** layers
that re-encode the same contract — the agent, the skill, and a `doc/*Spec.md` — and they have
drifted into contradiction (F3). Collapse this to **two** layers: the agent + skill become the
single, self-contained source of truth, and the `doc/` specs are **no longer read at runtime**.
The specs were the origin material the agents/skills were built from; they stay in the repo as
design history but leave the hot path.

Three decisions govern the reconciliation:

- **Reconciliation direction — docs win.** Where an agent/skill contradicts its spec, re-sync the
  agent/skill (and any coupled gate) to the **spec** value, because the specs are treated as the
  corrected/authoritative version. Apply this to the concrete conflicts from F3:

  | Conflict | Resolve to (spec value) | Also update |
  |----------|------------------------|-------------|
  | Chapter section structure (15 vs 14) | GreatTutorialSpec section list/count | format-gate section-order check |
  | Chapter word budget (6,000 vs 4,500) | GreatTutorialSpec range | format-gate word-count check; course-factory-agent blurb |
  | Chapter front-matter schema | GreatTutorialSpec field set | format-gate front-matter check |
  | Exercise student file (README vs brief.docx) | GreatModuleExercise value | format-gate + exercise-evaluator |
  | Exercise pack time (40-min cap vs 60% floor) | GreatModuleExercise value | pedagogy-gate hands-on check |
  | Lab deliverable filenames (.md vs .docx) | GreatLabSpec value | format-gate + §5.2 naming |

- **Guardrail — CLAUDE.md hard rules still win over any spec.** Per CLAUDE.md §3.5, the MUST gates
  and Rule 1/2/3 + §17 anti-patterns cannot be overridden by any spec. The known collision is
  **Bloom badges / LO-IDs visible on slides**: GreatPresentationSpec *requires* them visible, but
  CLAUDE.md Rule 1 forbids student-visible pipeline metadata. Here the **agent's "hidden, notes-only"
  value stays** — it is the one documented exception to "docs win," and it must be called out so the
  reconciler does not "fix" it back to the spec. (Any other spec value that would print LO-IDs,
  Bloom labels, §-numbers, or non-Office deliverables to students is likewise capped by CLAUDE.md.)

- **Scope & file handling.** In scope: the 5 generator specs (`GreatTutorialSpec`,
  `GreatModuleExercise`, `GreatQuizSpec`, `GreatPresentationSpec`, `GreatLabSpec`), plus
  `PlannerSpec` and `GreatCourseSpec`. **`DocxDesignSpec.md` stays on the hot path** — generators and
  the format-gate genuinely read it for typography/DXA table detail, so it remains the single home
  for those rules (keep its references). `doc/` files are **kept in place**; only the runtime *reads*
  and the in-scope §-citations are removed.

Execution sequence (staged, reviewable):
1. **Reconcile** each generator agent + skill to its current **local** spec (docs win, minus the
   CLAUDE.md guardrail); fold in any authoritative content the spec alone held so nothing is lost.
2. **Propagate coupled numbers** to the evaluators/gates (per the table above) so generator ↔ gate
   agree — otherwise the newly-consistent generator just fails a stale gate and triggers retries.
3. **Fold `GreatCourseSpec` sub-specs** (§8.4 podcast, §8.6 companion, §8.7 glossary, §14
   environment) into the podcast/companion/glossary/environment agents, which have no Great*Spec of
   their own and currently reach these via §-citation; reconcile `PlannerSpec` into planner-agent +
   `/plan-course` the same way.
4. **Drop the reads:** remove every "read/follow `doc/<Spec>.md`" instruction and every in-scope
   §-citation (keep `DocxDesignSpec` refs). Verify with a grep that no in-scope `doc/` file is read
   at runtime.
- **Impact:** removes the ~12–19 KB spec re-read from **every** generator call (~15–25 K tokens/
  chapter across 6 generators) **and** eliminates the contradiction-driven retries — each avoided
  attempt saves a full ~9-call cycle (~0.3 attempts/artifact ≈ **~290 fewer calls/course**).
  Combined token + retry saving is the largest structural win after R1.
- **Effort:** medium-high — reconciliation + coupled-gate propagation across ~20 agent/skill/gate
  files, purely edits, no new agents. **Risk:** medium — the failure mode is an *incomplete* fold
  (a spec-only rule dropped) or a generator/gate number left out of sync; mitigate by doing one
  triplet end-to-end first (chapter-text), verifying generator and its gates agree, then replicating.
  Mirror the same edits into `course-factory-plugin/` or adopt R9 so the copy does not re-drift.

#### R3 — Fix the `course-skeleton.md` / `subject.md` naming discrepancy *(fixes F9)*
Either rename `inputs/subject.md` → `inputs/course-skeleton.md`, or update the three references
back to `subject.md` — pick one and make the repo self-consistent. Add a one-line existence check to
Phase 0 validation that names the exact file.
- **Impact:** prevents an entire wasted planning pass (with two human halts) or a plan built against
  the wrong curriculum. **Effort:** trivial. **Risk:** none.

#### R4 — Remove the residual CLAUDE.md restatements (finish what R2 starts) *(fixes F4)*
R2 removes the spec re-read; this cleans up what remains. `CLAUDE.md` is loaded into every agent
context already, yet three generator agents re-list its rules inline
(`chapter-text-generator.md:169-178`, `quiz-generator.md:179-182`, `lab-generator.md:116-124`) and
the Handoff JSON template is duplicated in the skill (`generate-chapter-text.md:205-281`) on top of
CLAUDE.md. Replace each with a one-line pointer to the single canonical location.
- **Impact:** a few extra KB saved per generator call on top of R2 (the big spec-read saving is
  already counted under R2 — do not double-count). **Effort:** low. **Risk:** low — nothing is lost,
  only de-duplicated; `DocxDesignSpec` stays the single home for typography detail.

### Medium wins (more effort or moderate risk)

#### R5 — Make the feedback loop re-check only the failed gates *(fixes F5)*
On a retry, `chapter-supervisor-agent` already has the failing `gate_id`s in `feedback_failures[]`.
Re-invoke the evaluator in a "targeted" mode that spawns **only the gates that failed** on the prior
attempt, not all 7. All gates still exist and still run in full on attempt 1.
- **Impact:** a typical retry drops from 8 calls to 2–3. Across the retries in a course this is
  **~150–300 fewer gate calls**. **Effort:** medium — add a `gates_to_recheck[]` parameter threaded
  from the supervisor into the evaluator. **Risk:** low-medium — a fix for gate X could regress gate
  Y; mitigate by always re-running the cheap format+coverage gates alongside the targeted set.

#### R6 — Tier the gate models: mechanical gates on Haiku, judgment gates on Sonnet *(fixes F7)*
Move the rule-driven gates — **format, coverage, technical, accessibility** — to `claude-haiku-4-5`;
keep **pedagogy, personalization, calibration** on Sonnet. These are checklist/pattern checks
returning fixed JSON, exactly Haiku's strength.
- **Impact:** ~4 of 7 gate calls per evaluation shift to a much cheaper tier → **large token-cost cut
  on the biggest line item** with negligible latency change (gates run in parallel). **Effort:** low
  (frontmatter `model:` change) but **validate quality first**: run a chapter both ways and diff the
  verdicts. **Risk:** medium — if Haiku misses a format/coverage edge case, quality could slip; gate
  on a verification run before adopting, and keep any gate that regresses on Sonnet.

#### R7 — Run independent chapters in bounded parallel waves *(fixes F6)*
Chapters are independent except glossary and quiz carry-forward (F6). Process them in **waves of
2–3 concurrent `chapter-supervisor-agent` sub-agents**, with two guards: (a) **defer glossary
aggregation** — have each chapter emit its `glossary_delta` and run `glossary-aggregator` **once at
the end** over all deltas instead of incrementally, removing the shared-file write race; (b) respect
carry-forward by scheduling so a chapter's wave never precedes the chapters it reads (N-1, N-3) —
e.g. waves `{1,2,3}`→`{4,5,6}`→… keep the -1/-3 sources already complete.
- **Impact:** **~2–3× wall-clock reduction** on Phase 3 (the bulk of the run). Token cost roughly
  unchanged (same work, concurrent). **Effort:** medium — orchestrator scheduling change plus the
  glossary-deferral tweak; both are "how it runs," not new agents. **Risk:** medium — concurrency and
  the carry-forward ordering must be correct; keep the sequential `/next-chapter` path as the
  fallback for low-context environments.

### Lower priority

#### R8 — Narrow the course-wide evaluator to cross-chapter concerns *(fixes F8)*
Have `evaluator-agent` trust the per-chapter `chapter.manifest.json` gate results for
already-verified per-artifact checks and re-do **only** genuinely cross-chapter work (curriculum
coverage index, running-example coherence, glossary conflicts, Bloom staircase, capstone
eligibility) rather than re-reading every chapter doc.
- **Impact:** meaningfully cheaper single Opus pass at end of run. **Effort:** low-medium.
  **Risk:** low — the per-chapter gates already enforce the per-artifact checks being skipped.

#### R9 — Collapse the duplicated plugin tree to a build step *(fixes F10)*
Stop hand-maintaining `course-factory-plugin/` as a parallel copy. Generate it from `.claude/` +
`doc/` + `CLAUDE.md` via the existing `tools/build_plugin.py` (path/`CLAUDE.md`→`course-factory-guide.md`
rewrites applied mechanically), so there is a single source of truth.
- **Impact:** no direct runtime saving, but eliminates a whole class of drift/contradiction (the
  broken `GreatTextSpec.md` reference, stale "Subject" terminology) and **halves the edit cost of
  every recommendation above**. **Effort:** medium. **Risk:** low.

#### R10 — Consider prompt-cache-friendly ordering of stable instructions *(supports F1/F4)*
Where the harness supports it, keep the large stable prefix (CLAUDE.md + the canonical spec/skill)
at the front of each sub-agent context and the variable per-chapter inputs last, so repeated
sub-agent calls within the run benefit from prompt caching. Confirm cache behavior first; treat as a
tuning pass after R1–R6 land.
- **Impact:** potentially large on the many near-identical gate calls, but harness-dependent —
  measure before relying on it. **Effort:** low-medium. **Risk:** low.

---

## Suggested sequencing

1. **R3, R1** — trivial-to-low effort, immediate token cut, no quality risk. *(F9, F2/F1)*
2. **R2** — the decided structural change: reconcile (docs win, CLAUDE.md guardrail) → self-contain →
   drop the `doc/` reads. Do the chapter-text triplet end-to-end first, verify generator ↔ gate
   agree, then replicate to the other four. Removes the biggest instruction payload and the
   contradiction-driven retries. **R4 falls out of this** as a cleanup pass. *(F3, F4, F5)*
3. **R6, R5** — validate on one chapter, then adopt for the big gate-cost cut. *(F7, F5)*
4. **R7** — wall-clock win once the per-chapter cost is down. *(F6)*
5. **R8, R9, R10** — cleanup and tuning. *(F8, F10, F1/F4)*

**Combined estimate (R1–R6):** on the order of **35–55% lower token cost** and, with R7,
**25–40% lower wall-clock**, with the quality bar preserved — no MUST gate relaxed, no artifact
format changed, and the full set of agents and skills intact.

---

## Traceability matrix

| Rec | Addresses | Type | Effort | Quality risk |
|-----|-----------|------|--------|--------------|
| R1 | F2, F1 | tokens + time | Low | Minimal |
| R2 | F3, F4, F5 | tokens + quality | Medium-High | Medium |
| R3 | F9 | wasted run | Trivial | None |
| R4 | F4 | tokens | Low | Low |
| R5 | F5 | tokens + time | Medium | Low-Med |
| R6 | F7 | tokens | Low (test first) | Medium |
| R7 | F6 | wall-clock | Medium | Medium |
| R8 | F8 | tokens | Low-Med | Low |
| R9 | F10 | maintenance | Medium | Low |
| R10 | F1, F4 | tokens | Low-Med | Low |
