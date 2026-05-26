# Session Handoff — cowork-automation-tracy-2026
# CLI Continuation Guide for Parallel Chapter Orchestration

Generated: 2026-05-25
Purpose: Complete course generation for chapters 2–16, course-wide evaluation, and capstone lab
using Claude Code CLI with parallel agent invocation.

---

## What Is Already Done

| Artifact | Location | Status |
|----------|----------|--------|
| Planning (all 6 plan files) | `outputs/cowork-automation-tracy-2026/_plan/` | ✅ Complete |
| Environment scaffold | `outputs/cowork-automation-tracy-2026/environment/` | ✅ Complete |
| Ch01 chapter doc + handoff JSON | `chapters/ch01-intro-cowork-automation/` | ✅ Complete |
| Ch01 exercise pack | `chapters/ch01-intro-cowork-automation/...-exercises/` | ✅ Complete |
| Ch01 quiz Forms A + B | `chapters/ch01-intro-cowork-automation/` | ✅ Complete |
| Ch01 podcast script | `chapters/ch01-intro-cowork-automation/` | ⏳ Background agent running |
| Ch01 cheatsheet + instructor guide | `chapters/ch01-intro-cowork-automation/` | ⏳ Background agent running |
| Ch01 slides (.pptx + notes) | `chapters/ch01-intro-cowork-automation/` | ⏳ Background agent running |
| Ch01 glossary delta | `outputs/cowork-automation-tracy-2026/glossary.md` | ⬜ Needs glossary-aggregator run |
| Ch01 chapter.manifest.json | `chapters/ch01-intro-cowork-automation/` | ⬜ After all Ch01 artifacts done |
| Ch02 – Ch16 | — | ⬜ Not started |
| Course-wide evaluator | — | ⬜ After all chapters |
| Capstone lab | — | ⬜ After evaluator passes |

---

## How to Resume from CLI

### Option A — Continue this conversation (simplest)

```bash
cd C:\Users\manuc\Documents\projects\personalized_course_factory
claude --continue
```

Claude picks up full context. Say: **"Continue with Ch02 through Ch16. Run chapters in parallel where possible."**

### Option B — Resume by session ID

```bash
claude --resume
# Select this session from the list
```

---

## Parallel Chapter Generation (Recommended CLI Approach)

The key insight: **each chapter is independent once Ch01's handoff JSON exists**. Chapters that
share no prerequisite can run simultaneously. The dependency structure is:

```
Ch01 (complete) ──► Ch02–Ch07 (parallel batch 1 — no inter-dependencies)
                     Ch02–Ch07 complete ──► Ch08–Ch13 (parallel batch 2)
                                            Ch08–Ch13 complete ──► Ch14–Ch16 (parallel batch 3)
                                                                    All 16 done ──► evaluator ──► capstone
```

**Note:** In practice you can run all 15 remaining chapters in parallel. The only true dependency
is that the glossary-aggregator must run in sequence after each chapter completes (not blocking
generation of other chapters).

### Parallel invocation pattern

Each chapter needs its own `claude` process. In PowerShell:

```powershell
# Run chapters 2–7 in parallel (open 6 terminals, or use Start-Job):
$chapters = @(
  @{num=2; slug="ch02-automation-mindset"; scenario="scenario-03"; bloom="Analyze"},
  @{num=3; slug="ch03-claude-workspace-setup"; scenario="scenario-04"; bloom="Apply"},
  @{num=4; slug="ch04-context-management"; scenario="scenario-05"; bloom="Create"},
  @{num=5; slug="ch05-claude-md-business"; scenario="scenario-03"; bloom="Apply"},
  @{num=6; slug="ch06-creating-skills"; scenario="scenario-01"; bloom="Create"},
  @{num=7; slug="ch07-evaluating-skills"; scenario="scenario-03"; bloom="Create"}
)

foreach ($ch in $chapters) {
  Start-Job -ScriptBlock {
    param($c)
    claude -p "You are chapter-supervisor-agent for cowork-automation-tracy-2026. Generate ALL artifacts for chapter $($c.num) ($($c.slug)). Working dir: C:\Users\manuc\Documents\projects\personalized_course_factory. Read outputs/cowork-automation-tracy-2026/_plan/course-plan.yaml and outputs/cowork-automation-tracy-2026/_plan/personalization-plan.json for full context. Run all generators inline (no sub-agent spawning — Task tool unavailable in this env). Scenario: $($c.scenario). Bloom peak: $($c.bloom). Follow doc/GreatTextSpec.md, doc/GreatModuleExercise.md, doc/GreatPresentationSpec.md, doc/GreatQuizSpec.md. All 7 quality gates required. Write chapter.manifest.json when all artifacts pass." -ArgumentList $ch
  } -ArgumentList $ch
}
Get-Job | Wait-Job
```

Or in bash (WSL / Git Bash):

```bash
for ch in "2:ch02-automation-mindset:scenario-03:Analyze" \
          "3:ch03-claude-workspace-setup:scenario-04:Apply" \
          "4:ch04-context-management:scenario-05:Create" \
          "5:ch05-claude-md-business:scenario-03:Apply" \
          "6:ch06-creating-skills:scenario-01:Create" \
          "7:ch07-evaluating-skills:scenario-03:Create"; do
  IFS=: read num slug scenario bloom <<< "$ch"
  claude -p "Generate ch${num} (${slug}) for cowork-automation-tracy-2026. \
    Scenario: ${scenario}. Bloom: ${bloom}. \
    Working dir: /mnt/c/Users/manuc/Documents/projects/personalized_course_factory. \
    Read _plan/course-plan.yaml and _plan/personalization-plan.json. \
    Run all generators inline. All 7 quality gates. Write chapter.manifest.json." &
done
wait
```

---

## Per-Chapter Prompt Template

Use this prompt for each chapter. Substitute `{N}`, `{SLUG}`, `{SCENARIO}`, `{BLOOM}`, `{TITLE}`.

```
You are chapter-supervisor-agent for course cowork-automation-tracy-2026.

Working directory: C:\Users\manuc\Documents\projects\personalized_course_factory

Generate ALL artifacts for Chapter {N} ({SLUG} — "{TITLE}").

IMPORTANT: You do NOT have a Task tool. Run every generator INLINE in your own context.
Do not attempt to spawn child agents.

Read these files for full context before generating anything:
- outputs/cowork-automation-tracy-2026/_plan/course-plan.yaml
- outputs/cowork-automation-tracy-2026/_plan/personalization-plan.json
- outputs/cowork-automation-tracy-2026/_plan/reserved-scenarios.json
- inputs/students.yaml
- inputs/problem.yaml
- outputs/cowork-automation-tracy-2026/environment/lab-environment.json
- outputs/cowork-automation-tracy-2026/chapters/ch01-intro-cowork-automation/cowork-automation-tracy-2026--ch01--intro-cowork-automation--doc.handoff.json
  (for glossary delta baseline and running example coherence)

Chapter details:
  number: {N}
  slug: {SLUG}
  title: {TITLE}
  scenario: {SCENARIO}
  bloom_peak: {BLOOM}
  est_minutes: 50

Personalization (apply before writing anything):
  Protagonist: Tracy, Senior Program Manager at Advisor360°
  FK Grade: 13 (≤ 30 words avg sentence)
  Prior knowledge assumed (never define): Jira, Confluence, ServiceNow, Slack,
    Google Workspace, Agile PM, executive reporting
  Forbidden: "a user" → "Tracy", "the system" → tool name, scenario-02 must NOT appear

Artifacts to generate (in this order):
1. Chapter doc + handoff JSON (doc/GreatTextSpec.md)
2. Exercise pack (doc/GreatModuleExercise.md) — 3 exercises, ≥60% hands-on
3. Quiz Forms A + B (doc/GreatQuizSpec.md) — 10 items each, difficulty 0.40–0.95
4. Podcast script (1,200–2,300 words, conversational, no verbatim doc repetition)
5. Slides (.pptx via anthropic-skills:pptx) + slides-notes.md (doc/GreatPresentationSpec.md)
6. Cheatsheet (≤800 words) + instructor guide (GreatCourseSpec §8.6)

After all 6 artifact types pass all 7 quality gates (§16.1–§16.7), write:
  outputs/cowork-automation-tracy-2026/chapters/{SLUG}/chapter.manifest.json

Output directory:
  outputs/cowork-automation-tracy-2026/chapters/{SLUG}/

File naming: cowork-automation-tracy-2026--ch{NN}--{SLUG}--{artifact}
```

---

## Chapter Roster with Exact Values

| # | Slug | Title | Scenario | Bloom |
|---|------|-------|----------|-------|
| 02 | ch02-automation-mindset | The Automation Mindset | scenario-03 | Analyze |
| 03 | ch03-claude-workspace-setup | Setting Up Claude for Daily Work | scenario-04 | Apply |
| 04 | ch04-context-management | Context Management for Better Results | scenario-05 | Create |
| 05 | ch05-claude-md-business | CLAUDE.MD for Business Users | scenario-03 | Apply |
| 06 | ch06-creating-skills | Creating and Generating Skills | scenario-01 | Create |
| 07 | ch07-evaluating-skills | Evaluating Skills | scenario-03 | Create |
| 08 | ch08-tools-and-imports | Connecting Tools and Importing Skills | scenario-04 | Evaluate |
| 09 | ch09-browser-automation | Playwright MCP & Browser Automation | scenario-05 | Create |
| 10 | ch10-saas-automation | Zapier MCP & SaaS Automation | scenario-04 | Evaluate |
| 11 | ch11-practical-agents | Practical Agents for Knowledge Work | scenario-01 | Create |
| 12 | ch12-orchestrations-scheduling | Orchestrations & Scheduled Work | scenario-01 | Evaluate |
| 13 | ch13-human-in-the-loop | AskUserQuestion & Human-in-the-Loop Automation | scenario-06 | Create |
| 14 | ch14-debugging-automations | Debugging & Improving Automations | scenario-06 | Create |
| 15 | ch15-security-governance | Security, Safety & Governance | scenario-06 | Create |
| 16 | ch16-personal-automation-system | Designing Your Personal Automation System | scenario-01 | Create |

---

## After All 16 Chapters: Course-Wide Evaluator

```bash
claude -p "You are evaluator-agent for cowork-automation-tracy-2026. \
  Working dir: C:\Users\manuc\Documents\projects\personalized_course_factory. \
  Validate cross-chapter LO coverage, running-example coherence across all 16 chapter \
  handoff JSONs, glossary completeness (glossary.md), and capstone lab eligibility. \
  Read all 16 chapter.manifest.json files. Report pass/fail with any blocking failures."
```

## After Evaluator Passes: Capstone Lab

```bash
claude -p "You are lab-generator for cowork-automation-tracy-2026. \
  Working dir: C:\Users\manuc\Documents\projects\personalized_course_factory. \
  Read outputs/cowork-automation-tracy-2026/_plan/reserved-scenarios.json. \
  Use ONLY scenario-02 (cross-project risk & dependency detection — RESERVED). \
  60–180 minutes, 6-criterion rubric, Bloom Apply+Analyze+Create. \
  Integrates ≥60% of course chapters. \
  Output: outputs/cowork-automation-tracy-2026/capstone/"
```

---

## Key File Paths (Quick Reference)

```
Project root:   C:\Users\manuc\Documents\projects\personalized_course_factory\
Plan files:     outputs\cowork-automation-tracy-2026\_plan\
  course-plan.yaml
  personalization-plan.json      ← read this for vocabulary substitutions
  reserved-scenarios.json        ← scenario-02 is CAPSTONE ONLY
Environment:    outputs\cowork-automation-tracy-2026\environment\lab-environment.json
Glossary:       outputs\cowork-automation-tracy-2026\glossary.md
Ch01 handoff:   outputs\cowork-automation-tracy-2026\chapters\ch01-intro-cowork-automation\
                  cowork-automation-tracy-2026--ch01--intro-cowork-automation--doc.handoff.json
Spec docs:      doc\GreatTextSpec.md
                doc\GreatModuleExercise.md
                doc\GreatPresentationSpec.md
                doc\GreatQuizSpec.md
                doc\GreatLabSpec.md
Student ctx:    inputs\students.yaml
Problem spec:   inputs\problem.yaml
```

---

## Glossary Aggregator (run after each chapter, not in parallel)

```bash
claude -p "You are glossary-aggregator for cowork-automation-tracy-2026. \
  Read the glossary_delta from outputs/cowork-automation-tracy-2026/chapters/ch{NN}-{slug}/\
  cowork-automation-tracy-2026--ch{NN}--{slug}--doc.handoff.json and merge it into \
  outputs/cowork-automation-tracy-2026/glossary.md. Deduplicate terms. Add chapter-of-origin \
  reference. Do not alter existing definitions unless there is a direct conflict."
```

Run this after each chapter completes, or in a single pass after all chapters are done.
