---
exercise_id: ch01-ex03
chapter: 1
stage: independent
difficulty: medium
bloom_level: Analyze
skill_pattern: whole_task
learning_outcome_refs:
  - LO-01.1
  - LO-01.2
  - LO-01.3
time_box_minutes: 8
prerequisites:
  prior_exercises: ["ch01-ex01", "ch01-ex02"]
  chapter_sections: ["4", "5", "6", "10"]
domain_scenario_ref: "problem_spec.representative_scenarios[0]"
deliverables:
  - "exercise-03/starter/my-task-analysis.md (your RSTRM analysis and tool-type verdict)"
success_criteria: |
  Your completed analysis correctly applies all 5 RSTRM criteria to one of
  Tracy's five candidate recurring tasks. Your tool-type verdict (skill, plugin,
  or agent) is explicitly supported by the Multi-step and Rules-based scores.
  Your analysis identifies at least one reason the task might NOT be a strong
  automation candidate or flags at least one design constraint Tracy would need
  to address before building the automation. The verify script exits 0.
failure_modes_documented: 2
estimated_completion_rate: 0.65
accessibility:
  alt_text_present: true
  color_independent: true
  code_as_text: true
track: novice
---

# Exercise 03 — Independent: Choose a Task and Complete Your Own RSTRM Analysis

## Motivation

You have read a fully solved RSTRM analysis (Exercise 01) and completed a scaffolded one (Exercise 02). Now apply the framework entirely on your own — to a task you have not analyzed before, with no pre-filled fields and no step-by-step prompts. This is the exercise that builds the habit: choosing a task from your real workload, systematically evaluating it, and producing a verdict you could use as a design brief in Chapter 6.

## Learning Outcomes

- **LO-01.1:** Independently identify whether a PM workflow is a strong, partial, or non-automation candidate.
- **LO-01.2:** Select the appropriate tool type (skill, plugin, or agent) based on the workflow's characteristics.
- **LO-01.3:** Apply the RSTRM framework independently, without a scaffold, to a previously unanalyzed workflow.

## Prerequisites

- Exercise 01 (status report RSTRM walkthrough) and Exercise 02 (email triage RSTRM completion) completed.
- Chapter 1, Sections 4, 5, 6, and 10.

## Scenario

Tracy has five recurring tasks in her weekly and monthly PM workload that she has not yet analyzed for automation potential. She will choose one, apply the RSTRM framework, select the appropriate tool type, and note any design constraints she would need to resolve before building.

**The five candidate tasks are:**

1. **DragonBoat roadmap update sync** — Every two weeks, Tracy manually updates her two programs' DragonBoat roadmap entries to reflect completed milestones and new risks surfaced during sprint reviews. Current cost: 45–60 minutes per cycle. Sources: Jira sprint summary, Confluence risk log.

2. **ServiceNow ticket status briefing** — Every Friday afternoon, Tracy reviews open ServiceNow tickets for her programs and drafts a two-paragraph status briefing for the Monday leadership review. Current cost: 30 minutes per week. Sources: ServiceNow ticket queue, filtered by her two program keys.

3. **Meeting follow-up action item distribution** — After each leadership review meeting (two per month), Tracy manually transcribes action items from her notes and emails each owner their specific items with due dates. Current cost: 20–30 minutes per meeting. Sources: Tracy's handwritten or typed meeting notes.

4. **Sprint retrospective tagging** — After each sprint retrospective, Tracy reviews the retrospective notes and tags recurring themes (velocity, blockers, communication gaps) to build a trend report across sprints. Current cost: 30–45 minutes per retrospective. Sources: Confluence retrospective page for each sprint.

5. **Vendor status update parsing** — Three vendors submit weekly status update emails in different formats. Tracy reads each and extracts: timeline status, open risks, and next deliverable date into a consolidated tracker. Current cost: 20–30 minutes per week. Sources: Gmail inbox (vendor emails, labeled by vendor name).

## Your Task

Open `starter/my-task-analysis.md`. It contains an analysis template with no pre-filled content — only section headers and a brief prompt for each section. Choose **one** of the five tasks above and complete a full RSTRM analysis. The starter file contains the section structure; the content is entirely yours.

Your analysis must include:
- Your chosen task (by name)
- RSTRM scorecard with a rating (Strong / Partial / Weak) and 1–3 sentence justification for each criterion
- Overall verdict (Strong, Partial, or Non-candidate) with supporting explanation
- Tool-type verdict (skill, plugin, or agent) with a one-sentence justification linking it to the Multi-step and Rules-based scores
- At least one design constraint or risk that Tracy would need to address before building the automation
- Required plugin(s) or tool types needed

**Do not look at `solution/` until you have written your complete analysis.**

The solution directory contains a reference analysis for each of the five tasks. After you complete your own analysis, compare it to the reference for your chosen task and note any significant differences in your reasoning.

## Self-Check

Run the verify script after completing the starter file:

```bash
bash verify/verify.sh starter/my-task-analysis.md
```

The script confirms all sections are non-empty and the required components (task choice, verdict, tool-type verdict, design constraint) are present. It does not evaluate the quality of your reasoning.

## Failure Modes

See `failure-modes.md` for full diagnosis steps. Summary:

1. **"Vendor status update is not automatable because email formats vary."**
   Applying the Structured criterion as "uniform input format required" disqualifies one of the clearest automation candidates on the list. The five vendor emails may have different HTML structures, but the extraction targets (timeline status, open risks, next deliverable date) are consistent across all five. Structured applies to the extraction rules, not to the input format. The verify script will not catch this error — the rubric evaluates it.

2. **"A skill is sufficient for the action item distribution task."**
   If you choose task 3 (meeting follow-up action item distribution) and specify "skill" as the tool type, you are likely under-specifying the architecture. Distributing action items requires reading a document (plugin or file access), parsing content (skill), and sending emails to multiple owners (Gmail plugin with `sendMessage`). A skill alone cannot send email — it requires a plugin. A workflow that reads, transforms, and distributes requires an agent coordinating at minimum two operations. Re-examine the Multi-step score and let it drive the tool-type verdict.

## Stretch (optional, not counted in time budget)

After completing your analysis: if you chose the task with the lowest RSTRM score on the list (the weakest automation candidate), what would Tracy need to change about the task — how it is triggered, what data it draws from, or what its output format is — to raise the weakest criterion to Strong? This is a design exercise, not a score-inflating exercise: the goal is to identify what structural change to the workflow itself would make it more automatable.

## Connect-back

The five tasks on this list represent a typical PM's recurring workload. Not every task on the list is a strong automation candidate — which is exactly what the RSTRM framework is designed to surface before you invest time building. Your analysis in this exercise is the same analytical step Tracy will take at the start of Chapter 6, when she chooses which automation to build first.

## Reflection Prompt

Based on your analysis: which of the five tasks is the strongest automation candidate, and which is the weakest? What is the single criterion that most often separates the strong candidates from the weak ones across this list?
