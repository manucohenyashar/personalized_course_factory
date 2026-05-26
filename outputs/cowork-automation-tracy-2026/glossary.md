---
course_slug: cowork-automation-tracy-2026
last_updated: 2026-05-25
---

# Course Glossary

Terms are listed alphabetically. Each entry shows the chapter where the term was first defined.

---

### agent
*First introduced: Chapter 1 — intro-cowork-automation*

A Claude configuration that autonomously plans and executes a sequence of steps — calling skills, invoking plugins, evaluating intermediate results, and deciding what to do next — until it reaches a defined stopping condition or a human-in-the-loop checkpoint. Appropriate for multi-step workflows; single-step tasks use skills.

---

### Claude plugin
*First introduced: Chapter 1 — intro-cowork-automation*

A connector that gives Claude read or write access to an external business system. Plugins handle authentication, querying, and data formatting, exposing a consistent interface that skills can invoke. Plugins require explicit authorization and can be revoked at any time.

---

### Claude skill
*First introduced: Chapter 1 — intro-cowork-automation*

A saved, reusable instruction set that Claude executes on demand. A skill encodes what inputs to expect, what format to produce, and what constraints to apply — equivalent to a written SOP that Claude reads and executes rather than a human performing manually. Skills do not connect to external systems independently; they call plugins to retrieve live data.

---

### human-in-the-loop checkpoint
*First introduced: Chapter 1 — intro-cowork-automation*

A deliberate pause in an automated workflow where Tracy reviews and approves the automation's output before the next action — such as sending a report, applying a Gmail label, or moving a file. Required for all high-stakes outputs and a non-negotiable design element of every agent workflow in this course.

---

### RSTRM framework
*First introduced: Chapter 1 — intro-cowork-automation*

A five-criterion checklist for evaluating automation candidates: Repetitive, Structured, Time-consuming, Rules-based, Multi-step. A task scoring Strong on all five criteria is a high-confidence automation candidate. Two or more Weak ratings indicate the task scope should be redesigned or deferred.
