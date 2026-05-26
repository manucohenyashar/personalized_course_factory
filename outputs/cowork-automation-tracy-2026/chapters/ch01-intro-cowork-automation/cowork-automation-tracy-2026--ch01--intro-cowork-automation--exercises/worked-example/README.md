---
exercise_id: ch01-ex01
chapter: 1
stage: worked_example
difficulty: not_applicable
bloom_level: Understand
skill_pattern: whole_task
learning_outcome_refs:
  - LO-01.1
  - LO-01.3
time_box_minutes: 12
prerequisites:
  prior_exercises: []
  chapter_sections: ["4", "5", "6"]
domain_scenario_ref: "problem_spec.representative_scenarios[0]"
deliverables:
  - "worked-example/solution/status-report-rstrm-scorecard.md (read-only)"
  - "worked-example/walkthrough.md (narrated analysis)"
success_criteria: |
  After reading this walkthrough, you can reproduce the RSTRM scorecard for
  Tracy's weekly status report workflow from memory, explain each criterion
  rating in one sentence, and state the design verdict (tool type and
  human-in-the-loop checkpoint position).
failure_modes_documented: 2
estimated_completion_rate: 0.90
accessibility:
  alt_text_present: true
  color_independent: true
  code_as_text: true
track: novice
---

# Worked Example — Applying RSTRM to Tracy's Weekly Status Report Workflow

## Motivation

The RSTRM framework is the primary tool you will use throughout this course to evaluate whether a workflow is worth automating. Before you apply it yourself in Exercise 02, read a fully solved analysis of the task that motivated this entire course: Tracy's Monday-morning status report assembly. Seeing the decision logic made explicit — and seeing the design verdict that follows from it — prepares you to apply the same reasoning independently.

## Learning Outcomes

- **LO-01.1:** Identify the characteristics that make a program management workflow a strong automation candidate.
- **LO-01.3:** Apply the RSTRM framework criterion by criterion and derive a design verdict.

## Prerequisites

- Chapter 1, Sections 4, 5, and 6 (suitability criteria, tool building blocks, and RSTRM framework).

## Scenario

Tracy's current process for assembling a weekly project status report takes approximately 2.5 hours every Monday. She pulls data from four systems — Jira, Confluence, Slack, and Google Meet transcripts — organizes it into a five-section executive summary (Accomplishments, Risks, Upcoming Milestones, Decisions Needed, Key Discussions), and writes detailed supporting notes. She runs this process for two concurrent programs, meaning this one task consumes 5 hours of her week — time she would rather spend on strategic roadmap reviews, stakeholder alignment, and risk mitigation.

This is **scenario-01** from the Problem Spec: *Weekly project status report from scattered sources*.

## Walkthrough

Read `walkthrough.md` for the full narrated analysis. The walkthrough applies each RSTRM criterion to Tracy's status report workflow, surfaces four key decision points, and produces a scored evaluation card and a design verdict. Every Decision callout explains *why* a particular scoring choice was made, not just what the choice is.

After reading the walkthrough, open `solution/status-report-rstrm-scorecard.md` — the clean, final scorecard without narrative, which is what you would hand to a colleague or use as a design input for Chapter 6.

## Self-Check

After reading the walkthrough without the solution file open, ask yourself:

1. All five RSTRM criteria are rated Strong for this workflow. Can you explain why each one is Strong — one sentence per criterion — without referring to the text?
2. The verdict recommends an agent, not a skill alone. What is the specific reason?
3. Where exactly does the human-in-the-loop checkpoint sit, and why not earlier or later in the workflow?

Write your answers before opening Exercise 02.

## Failure Modes

1. **"Inconsistent source means Structured = No."**
   Broken state: Tracy notices that Slack messages are free-text and concludes the workflow is not Structured because one of its four sources is not machine-formatted. She scores S = No and stops the RSTRM analysis.
   Expected consequence: The workflow is incorrectly disqualified. Slack messages are free-text but follow consistent linguistic patterns (blocker reports, decision announcements, risk flags) that can be extracted reliably. Structured means the patterns are consistent enough to describe — not that every source is a database table.
   Diagnosis: Before scoring Structured, write down the extraction rule for each source. If you can write an "if X, then Y" rule for a source — even an approximate one — it passes. If you cannot write any rule for a source, that source scores Weak on Structured.

2. **"A 5/5 RSTRM score means the automation can run without Tracy's review."**
   Broken state: Tracy interprets "Strong automation candidate" as "remove Tracy from the loop." She configures the automation to send the executive summary directly to leadership without a review step.
   Expected consequence: A status report with an error reaches the VP of Product. The error damages Tracy's credibility. The automation that was supposed to recover time now requires trust remediation.
   Diagnosis: RSTRM evaluates *whether* to automate. A separate stakes filter determines *how* to automate safely. A Strong RSTRM score is not permission to skip the human-in-the-loop checkpoint; it is permission to build the automation. The checkpoint design is a separate and mandatory step.

## Stretch (optional, not counted in time budget)

The worked example concludes that running the automation Tuesday morning rather than Monday morning reduces stale-Jira-data risk (because developers close tickets on Tuesday, not Friday). Think through the tradeoff: what does a Tuesday delivery cost Tracy's stakeholders compared to a Monday delivery? Under what conditions would Monday delivery at higher stale-data risk be preferable? This is the kind of judgment that stays with Tracy even after the automation is built.

## Connect-back

The status report workflow passes RSTRM because it is the ideal form of program management work to automate: repetitive enough to be reliable, structured enough to be consistent, expensive enough to be worth the investment, rules-based enough to be describable, and complex enough that an agent — not a single skill — is the right architecture. The gap between "I could describe these rules" and "I have actually written them down" is where most first automations fail; the worked example shows what "written down" looks like in practice.

## Reflection Prompt

After reading the walkthrough: which of the four data sources (Jira, Confluence, Slack, Google Meet transcripts) do you think would be hardest to extract reliably, and why? What additional design constraint would you add to the automation to handle that source's edge cases?
