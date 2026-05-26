# Chapter 1 Exercise Pack — Debrief

## Purpose

This debrief maps what you completed across the three exercises to the chapter's learning outcomes. Take 5 minutes with this before moving to Chapter 2. Do not skip it — the reflection questions in this section consolidate what the exercises practiced.

---

## What You Did

| Exercise | Task | Primary scenario | LOs Addressed |
|---|---|---|---|
| Worked example (Exercise 01) | Read a full RSTRM analysis of Tracy's weekly status report workflow, including all decision points and the final design verdict | scenario-01: weekly project status report | LO-01.1, LO-01.3 |
| Completion (Exercise 02) | Filled in a partially scaffolded RSTRM analysis of Tracy's email inbox triage workflow; specified the human-in-the-loop checkpoint and required Gmail plugin tools | scenario-04: email inbox triage | LO-01.1, LO-01.2, LO-01.3 |
| Independent (Exercise 03) | Chose one of five real PM recurring tasks; completed an independent RSTRM analysis and tool-type verdict with no scaffold | scenario-01 context, five candidate tasks | LO-01.1, LO-01.2, LO-01.3 |

---

## LO Mapping

**LO-01.1 — Identify what Claude Cowork can and cannot automate:**
You applied this across all three exercises. The consistent finding: tasks that fail RSTRM — specifically, tasks where the Rules-based criterion is Weak across most sub-steps — require human judgment at a level that automation cannot reliably replicate. Tasks that pass RSTRM are not judgment-free; they contain judgment sub-steps that are handled by explicit human-in-the-loop checkpoints rather than by removing Tracy from the loop.

**LO-01.2 — Distinguish skills, plugins, and agents:**
Exercise 02 required you to specify the plugin and MCP tools. Exercise 03 required you to select the tool type and justify it. The core rule you have now applied twice: a skill alone cannot access external systems; that requires a plugin. Multi-source, multi-step workflows that need to evaluate intermediate results and pause for review require an agent coordinating skills and plugins. If you are still uncertain about these boundaries, re-read Section 5 of the Chapter 1 doc before starting Chapter 2.

**LO-01.3 — Recognize the RSTRM framework:**
By the end of Exercise 03, you should be able to write out R-S-T-R-M (Repetitive, Structured, Time-consuming, Rules-based, Multi-step) from memory, state what each criterion evaluates, and apply it to a workflow you have not analyzed before. If you needed to look up the criteria during Exercise 03, that is a signal to re-read Section 6 before Chapter 2. The RSTRM framework is referenced in every chapter from Chapter 2 onward; retrieval fluency matters.

---

## Full Reflection Question Set

Take 3–5 minutes per question. Writing full sentences matters — the habit of articulating reasoning is part of what this course builds.

**1. RSTRM criterion variability across workflows:**
Across the three workflows you analyzed in Exercises 01, 02, and 03 (status report, email triage, and your chosen task), which RSTRM criterion showed the most variability? Why does that criterion tend to be the borderline one for knowledge-work automations?

**2. The human-in-the-loop checkpoint as a design element:**
Before reading this chapter, how would you have described the relationship between automation and human review? Has that description changed? What one insight from the worked example or Exercise 02 caused the change — or reinforced what you already believed?

**3. Skill vs. plugin vs. agent in practice:**
In Exercise 03, you had to select a tool type based on a workflow you chose. After making that choice and justifying it: are you confident in the distinction between a skill and a plugin? If not, write out your best current understanding of the difference in one sentence — and note what is still unclear. Bring that question to Chapter 2.

**4. Your highest-value automation candidate:**
Based on the five tasks in Exercise 03 (DragonBoat roadmap sync, ServiceNow briefing, action item distribution, retrospective tagging, and vendor status parsing), which task would you recommend Tracy build first — and why? Does your answer change if you weight the difficulty of building the automation, or only the time savings?

**5. The task you did NOT choose:**
Look at the task on the Exercise 03 list that you did not analyze. Based on the task description alone — without applying RSTRM formally — what is your initial guess about its RSTRM verdict? After Chapter 2, revisit this chapter's Exercise 03 solution and check whether your intuition was right.

---

## What Comes Next

Chapter 2 introduces the automation mindset — the shift from thinking "I should do this task" to thinking "I should design a system that does this task and check its output." The scenario is Tracy's Google Meet transcript-to-summary workflow (scenario-03), which she currently does manually for 3–5 meetings per week. You will apply a workflow decomposition tool to map the current-state manual process before redesigning it for automation. The RSTRM analysis from Exercise 03 is direct preparation for Chapter 2's decomposition exercise.
