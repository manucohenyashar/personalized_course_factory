# Plan Review Packet
## Course: Practical Claude Cowork Automation for Knowledge Workers
## Course Slug: `cowork-automation-tracy-2026`
## Prepared by: PlannerAgent v2.0.0 | 2026-05-25

---

> **This is the Step 12 halt.** No learner-facing artifact will be generated until
> you respond with **"approved"**. Review every section below and confirm or request changes.

---

## Executive Summary

| Field | Value |
|---|---|
| **Cohort** | Tracy Zlatkova — Senior Program Manager (AI Program Manager), Advisor360° |
| **Cohort size** | 1 (self-taught, primary; cohort artifacts also produced) |
| **Course title** | Practical Claude Cowork Automation for Knowledge Workers |
| **Total chapters** | 16 |
| **Estimated chapter time** | 50 minutes each |
| **Estimated total learning time** | 800 minutes (13.3 hours) |
| **Capstone lab** | 120 minutes |
| **Grand total time** | ~920 minutes (~15.3 hours) |
| **Reading level** | Flesch-Kincaid Grade 13 (college-level professional prose; ≤ 30 words avg sentence) |
| **Domain** | Program management automation — Advisor360° wealth-management SaaS |
| **Primary systems** | Jira, Confluence, Slack, Google Meet, Gmail, Google Drive, DragonBoat, ServiceNow, Claude Cowork |
| **Capstone scenario** | scenario-02: Cross-project risk and dependency detection (RESERVED — unseen) |
| **Artifacts per chapter** | 7: chapter doc, handoff JSON, exercise pack, slides (PPTX + notes), quiz Forms A & B, podcast script, cheatsheet, instructor guide |
| **Total artifact files** | ~150 (16 chapters × ~9 files + capstone + environment + plan) |
| **Estimated generator runtime** | 8–14 hours wall-clock (sequential chapter generation, 3-attempt retry per artifact) |
| **Quality gates** | All 7 (§16.1 Coverage, §16.2 Pedagogy, §16.3 Personalization, §16.4 Format, §16.5 Technical, §16.6 Accessibility, §16.7 Calibration) |

---

## Chapter Partition

All 16 chapters from `inputs/subject.md` accepted as-is. No splits or merges required
(all chapters fit within the 60-minute cap at 50 minutes estimated each).

| # | Slug | Title | Est. Min | Hands-on Min | Scenario | Bloom Peak |
|---|---|---|---|---|---|---|
| 01 | intro-to-cowork-automation | Introduction to Claude Cowork Automation | 50 | 30 | scenario-01 | Remember |
| 02 | automation-mindset | The Automation Mindset | 50 | 30 | scenario-03 | Analyze |
| 03 | setting-up-claude | Setting Up Claude for Daily Work | 50 | 30 | scenario-04 | Apply |
| 04 | context-management | Context Management for Better Results | 50 | 30 | scenario-05 | Create |
| 05 | claude-md | CLAUDE.MD for Business Users | 50 | 30 | scenario-03 | Apply |
| 06 | creating-skills | Creating and Generating Skills | 50 | 30 | scenario-01 | Create |
| 07 | evaluating-skills | Evaluating Skills | 50 | 30 | scenario-03 | Create |
| 08 | connecting-tools | Connecting Tools and Importing Skills | 50 | 30 | scenario-04 | Evaluate |
| 09 | playwright-browser-automation | Playwright MCP and Browser Automation | 50 | 30 | scenario-05 | Create |
| 10 | zapier-saas-automation | Zapier MCP and SaaS Automation | 50 | 30 | scenario-04 | Evaluate |
| 11 | practical-agents | Practical Agents for Knowledge Work | 50 | 30 | scenario-01 | Create |
| 12 | orchestrations-scheduled-work | Orchestrations and Scheduled Work | 50 | 30 | scenario-01 | Evaluate |
| 13 | ask-user-question | AskUserQuestion and Human-in-the-Loop Automation | 50 | 30 | scenario-06 | Create |
| 14 | debugging-improving-automations | Debugging and Improving Automations | 50 | 30 | scenario-06 | Create |
| 15 | security-safety-governance | Security, Safety, and Governance | 50 | 30 | scenario-06 | Create |
| 16 | personal-automation-system | Designing Your Personal Automation System | 50 | 30 | scenario-01 | Create |
| CAP | capstone-lab | Cross-Project Risk and Dependency Detection (Capstone) | 120 | 120 | **scenario-02** | Create |

**Hands-on check:** Every chapter = 30 min hands-on out of 50 min total = 60% exactly. Gate §16.2 minimum satisfied.

**Bloom coverage check:**
- Remember: ch01
- Understand: ch01, ch02, ch11
- Apply: ch03, ch04, ch05, ch06, ch08, ch09, ch12, ch13, ch14, ch15
- Analyze: ch02, ch07, ch14, ch15
- Evaluate: ch07, ch08, ch10, ch11, ch12, ch13, ch16
- Create: ch04, ch06, ch07, ch09, ch11, ch13, ch14, ch15, ch16, capstone

All six Bloom levels represented. Gate §16.1 satisfied.

---

## Personalization Plan Summary

### Protagonist and Domain

- **Protagonist:** Tracy, Senior Program Manager (AI Program Manager) at Advisor360°
- **Register:** Professional — outcome-focused, workflow-centric, PM-register prose
- **FK Grade:** 13 — compound sentences acceptable, technical terms without inline definition if in glossary
- **Every example** names Tracy by name and references her actual systems (Jira, Confluence, Slack, Google Meet, Gmail, Google Drive, DragonBoat, ServiceNow)

### Vocabulary Substitutions (key entries)

| Generic term (FORBIDDEN) | Domain replacement (REQUIRED) |
|---|---|
| "a user" / "the user" | "Tracy" |
| "the system" | "Claude Cowork" |
| "an item" | "a project artifact" |
| "the process" | "the workflow" |
| "report" | "executive status report or meeting summary" |
| "meeting" | "stand-up, leadership review, or project sync" |
| "file" | "Google Drive file or meeting recording" |
| "ticket" | "ServiceNow ticket or Jira ticket" |
| "dashboard" | "Jira board or DragonBoat roadmap" |
| "team" | "project team or cross-functional team" |

Full substitution table: `_plan/personalization-plan.json` → `vocabulary_substitutions`

### Scenario-to-Chapter Assignments

| Scenario | Used In |
|---|---|
| scenario-01: Weekly status report | ch01, ch06, ch11, ch12, ch16 |
| scenario-03: Meeting transcript → summary | ch02, ch05, ch07 |
| scenario-04: Email inbox triage | ch03, ch08, ch10 |
| scenario-05: Google Drive organization | ch04, ch09 |
| scenario-06: ServiceNow ticket integration | ch13, ch14, ch15 |
| **scenario-02: Cross-project risk (RESERVED)** | **Capstone only** |

### Running Example Anchors (selected highlights)

- **ch06** (Creating Skills): Tracy builds the **Status Report Aggregation skill** — a reusable Claude skill accepting Jira board data, Confluence page content, Slack channel summary, and two transcript excerpts, producing an executive summary and detailed supporting notes.
- **ch12** (Orchestrations): Tracy schedules her weekly report agent to run **every Monday at 7:00 AM ET**, collecting the past week's data and delivering a review-ready draft to her Gmail inbox by 8:00 AM.
- **ch15** (Governance): Tracy formulates a governance policy covering which ServiceNow fields must never appear in prompts and which output categories require human review before distribution.
- **Capstone**: Tracy receives two project data streams (Jira Plans + DragonBoat + transcripts for both programs) and deploys a multi-step Claude agent to surface cross-project blockers and shared milestones for the leadership meeting — a scenario she has never seen in the chapter exercises.

### Prior Knowledge Handling

- **Assumed (no introduction):** Jira, Confluence, ServiceNow, Slack, Google Workspace, Agile PM, executive reporting, vendor management
- **Scaffolded (CPA pattern — Concrete → Analogy → Definition):**
  - Claude Cowork skills, plugins, MCP tools, browser automation (Playwright), Zapier workflows, agent design, CLAUDE.MD, scheduled automations, prompt injection basics, evaluation rubrics

---

## Reserved Capstone Scenario

**scenario-02: Cross-project risk and dependency detection**

Tracy oversees two unrelated projects whose teams occasionally share resources or timelines. The capstone deploys a Claude agent that reviews both projects' Jira Plans and DragonBoat roadmap entries alongside recent meeting transcripts to surface shared blockers, overlapping milestones, and cross-team dependencies — producing a prioritized risk and dependency summary for the next leadership meeting.

**Why this scenario is optimal for the capstone:**
- It requires Tracy to integrate skills from every part of the course: multi-source aggregation (Part 2), reusable skills and evaluation (Part 3), tool connections and browser/SaaS automation (Part 4), agent design and orchestration (Part 5), debugging and governance (Part 6).
- It is the only scenario that spans both concurrent programs simultaneously — no chapter exercise has used it, making it genuinely unseen and integrative.
- The 120-minute duration allows realistic agent development, a human-review checkpoint loop, and written reflection.

**Enforcement:** All 16 chapter common envelopes carry `forbidden_examples: [scenario-02]`. The reserved-scenarios.json file declares this explicitly.

---

## Precedence Log Summary

Full log: `_plan/precedence-log.md` (inline below for review)

| Field | Conflict | Winner | Resolution |
|---|---|---|---|
| mode_targets | students.yaml: self_taught only; orchestration.yaml: [self_taught, cohort] | Student Context | primary=self_taught; cohort artifacts produced in parallel as secondary |
| reading_level / FK grade | students.yaml: FK 13; subject.md: implies intermediate (knowledge workers) | Student Context | FK 13 enforced; ≤ 30 words avg sentence; professional register |
| chapter time | subject.md: 30–50 min range | Subject spec | Upper bound 50 min per chapter (no other spec conflicts) |
| quality gates | orchestration.yaml: all | Orchestration (no conflict) | All gates §16.1–§16.7 active |
| max_attempts | orchestration.yaml: 3 | Orchestration (no conflict) | 3 retry attempts per generator |
| hands-on floor | subject.md: "short hands-on exercises" (vague) vs master §7.14: ≥ 60% | Master spec (non-overridable MUST gate) | 30 min / 50 min = 60% floor enforced; subject.md's vague language yields |
| numeric overrides | orchestration.yaml: all commented out | Planner defaults | All master spec defaults applied; no overrides active |

**No unresolved conflicts.** All decisions are logged.

---

## Course-Wide Quality Gate Configuration

| Gate | Agent | Scope | Active? |
|---|---|---|---|
| §16.1 Coverage | coverage-gate-evaluator | Per chapter + course-wide | Yes |
| §16.2 Pedagogy | pedagogy-gate-evaluator | Per chapter | Yes |
| §16.3 Personalization | personalization-gate-evaluator | Per chapter + course-wide | Yes |
| §16.4 Format | format-gate-evaluator | Per chapter | Yes |
| §16.5 Technical | technical-gate-evaluator | Per chapter (where code present) | Yes |
| §16.6 Accessibility | accessibility-gate-evaluator | Per chapter | Yes |
| §16.7 Calibration | calibration-gate-evaluator | Per chapter | Yes |

All gates enforced as MUST. Regeneration policy: 3 attempts per generator, then halt.

---

## Diagnostic Quiz Configuration

- **Mode:** Prerequisite diagnostic
- **Items:** 8 (covers automation mindset, Claude basics, knowledge of Tracy's systems)
- **Routing:**
  - Score ≥ 87.5% → fast-track (can skip Part 1 Foundations)
  - Score 50–87.4% → standard entry (start at Chapter 1)
  - Score < 50% → with-prerequisites (background reading recommended before Chapter 1)
- **Output:** `outputs/cowork-automation-tracy-2026/prereq-diagnostic.md`

---

## Environment Scaffold

Produced once before any chapter generation:
- `environment/devcontainer.json` — development container configuration
- `environment/preflight.sh` — Unix preflight checks
- `environment/preflight.ps1` — Windows preflight checks
- `environment/reset-env.sh` — environment reset script

---

## Explicit Decisions Requiring Your Confirmation

Please check each item. If you want to change anything, note it before approving.

- [ ] **1. Course slug confirmed:** `cowork-automation-tracy-2026` — this is the directory and file prefix for all artifacts.
- [ ] **2. 16 chapters, 50 minutes each** — no splits or merges; total ~13.3 hours of learning content.
- [ ] **3. Capstone scenario confirmed:** scenario-02 (Cross-project risk and dependency detection) is RESERVED and will not appear in any chapter exercise.
- [ ] **4. Primary mode: self_taught.** Cohort artifacts produced in parallel as secondary. Tracy's mode_preference in students.yaml drives this.
- [ ] **5. FK Grade 13** enforced as the reading level target throughout all artifacts.
- [ ] **6. All quality gates (§16.1–§16.7) active** with MUST enforcement and 3-retry policy.
- [ ] **7. Capstone duration: 120 minutes.** Tracy integrates all 16 chapters' skills in the unseen scenario-02 context.
- [ ] **8. No numeric overrides active.** All master spec defaults apply (10 quiz items, 30 min exercise pack, 12–25 slides, 1,200–2,300 word podcast, 3,000–6,000 word chapter doc).
- [ ] **9. Scenario assignments accepted** as presented in the Chapter Partition table above. Scenario-01 (status report) anchors chapters 01, 06, 11, 12, and 16 as Tracy's flagship automation workflow.
- [ ] **10. Prior knowledge list accepted** — Jira, Confluence, ServiceNow, Slack, and Google Workspace will NOT be introduced or defined; they will be referenced as known tools.

---

## Plan Readiness Self-Check

The PlannerAgent has verified the following MUST gates before presenting this packet:

- [x] All four input specs loaded and validated
- [x] Narrative normalization complete; diff approved by user (Step 2)
- [x] Precedence log covers every multi-spec field
- [x] Every chapter: est_minutes ≤ 60 (= 50); hands_on_minutes ≥ 60% (= 30 of 50)
- [x] No chapter consumes scenario-02 (reserved for capstone)
- [x] Capstone covers 100% of chapters (≥ 60% required; 16/16 = 100% achieved)
- [x] Capstone has an unseen scenario (scenario-02, confirmed reserved)
- [x] Chapter count = 16 < 25; compact-mode quiz NOT activated (correct)
- [x] Every Learning Outcome uses a Bloom verb from master §9.1
- [x] Every per-chapter assignment names its sub-spec and quality gates
- [x] Dependency graph is acyclic; single source (plan inputs) and single sink (course-wide EvaluatorAgent)
- [x] PLAN_REVIEW.md contains every required section

---

## Signature Block

**Prepared by:** PlannerAgent v2.0.0
**Date:** 2026-05-25
**Status:** AWAITING HUMAN APPROVAL

> Respond with **"approved"** to authorize artifact generation.
> To request changes, describe them and the planner will revise the affected plan sections before re-presenting for approval.

---

*After approval, invoke `@chapter-supervisor-agent chapter_number: 1` to begin Chapter 1 generation,
or invoke `@course-factory-agent` to run the full pipeline automatically.*
