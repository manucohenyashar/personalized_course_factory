---
exercise_id: ch01-ex02
chapter: 1
stage: completion
difficulty: easy
bloom_level: Apply
skill_pattern: whole_task
learning_outcome_refs:
  - LO-01.1
  - LO-01.2
  - LO-01.3
time_box_minutes: 15
prerequisites:
  prior_exercises: ["ch01-ex01"]
  chapter_sections: ["5", "6", "7"]
domain_scenario_ref: "problem_spec.representative_scenarios[3]"
deliverables:
  - "exercise-02/starter/email-triage-rstrm.md (complete the TODOs)"
success_criteria: |
  Your completed RSTRM scorecard correctly scores all 5 criteria for Tracy's
  email inbox triage workflow. Your human-in-the-loop checkpoint specification
  includes all three required fields: trigger, review format, and approval action.
  Your plugin specification names at least one Gmail plugin tool. The verify
  script exits 0.
failure_modes_documented: 2
estimated_completion_rate: 0.82
accessibility:
  alt_text_present: true
  color_independent: true
  code_as_text: true
track: novice
---

# Exercise 02 — Completion: RSTRM Analysis for Email Inbox Triage

## Motivation

You have seen the RSTRM framework applied in full to Tracy's weekly status report workflow. Now apply it yourself to a second task from her workweek: email inbox triage. This is a completion exercise — the scaffold and question structure are provided; you supply the reasoning for each criterion.

## Learning Outcomes

- **LO-01.1:** Classify Tracy's email triage workflow as a strong, partial, or non-automation candidate based on the RSTRM scorecard.
- **LO-01.2:** Identify the plugin type and specific MCP tools required to execute the triage skill.
- **LO-01.3:** Apply the RSTRM framework step-by-step to a workflow you have not previously analyzed.

## Prerequisites

- Completed worked example (Exercise 01 — status report RSTRM analysis).
- Chapter 1, Sections 5, 6, and 7.

## Scenario

Tracy's Gmail inbox contains approximately 4,200 messages, many of them unread. Each Monday she manually reviews the past week's messages to identify which require direct action (reply, escalate, or create a Jira ticket), which can be archived, and which can be bulk-labeled by project. This currently takes 45 minutes every Monday and is error-prone: the volume makes it easy to miss a time-sensitive message from a leadership stakeholder.

This is **scenario-04** from the Problem Spec: *Email inbox triage and categorization*.

## Your Task

Open `starter/email-triage-rstrm.md`. It contains a partially completed RSTRM scorecard and a checkpoint specification template with `# TODO:` markers. Replace every `# TODO:` block with your own analysis.

Use the worked example (status report analysis in Exercise 01) as the benchmark for expected detail. Each scoring field should have:
- A score (YES / NO / PARTIAL)
- 1–3 sentences of reasoning
- For PARTIAL scores: name the specific sub-step that is the exception

**Do not open `solution/` until you have attempted every TODO.**

## Self-Check

Run the verify script after completing the starter file:

```bash
bash verify/verify.sh starter/email-triage-rstrm.md
```

The script confirms:
- All five RSTRM fields have scores and non-empty reasoning
- The checkpoint specification contains all three required fields (trigger, review format, approval action)
- The RSTRM verdict is present

It does not evaluate the quality of your reasoning — that is what the rubric is for.

## Failure Modes

See `failure-modes.md` for full diagnosis steps. Summary:

1. **"Structured = No because email body text is unstructured."**
   Scoring Structured as No because individual email bodies vary will disqualify this workflow incorrectly. Classification rules applied to sender, subject line, and pattern-matching keywords are what makes the task Structured — not uniform message formatting. Before scoring S, write down at least three classification rules that could be expressed as "if X, then Y."

2. **"Checkpoint specification is complete if it says Tracy reviews the triage report."**
   A checkpoint that names the review but omits the approval action is incomplete. The verify script will catch this and exit 1. The approval action must be specific: what does Tracy do, in what interface, to signal the automation to proceed with bulk actions?

## Stretch (optional, not counted in time budget)

Tracy has roughly 4,200 unread messages in her inbox. Before building the triage skill, she would need to do a one-time inbox cleanup to establish a baseline. Estimate: if the triage skill processes 150 messages per week and Tracy's inbox grows by 80 messages per week net, how many weeks until the inbox is at zero backlog? At that point, does the weekly maintenance triage still make sense as a recurring automation, or does the use case change?

## Connect-back

Email triage and weekly status reporting share the same RSTRM profile: repetitive, structured by rule rather than by format, time-consuming in aggregate, rule-describable with a judgment exception, and multi-step. The key design difference is that email triage operates on a single system (Gmail) rather than four systems — which means it may be implemented as a skill calling a single plugin rather than an agent coordinating multiple plugins. Your plugin specification in the TODO will capture this distinction.

## Reflection Prompt

Which of the five RSTRM criteria was most difficult to score for email triage, and what made it harder than the same criterion was for the weekly status report?
