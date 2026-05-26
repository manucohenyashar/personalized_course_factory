# RSTRM Analysis — My Chosen Task (Solution Reference)

This file is a completed reference analysis using Task 2: ServiceNow Ticket Status Briefing.
It uses the same template structure as the starter file, so the verify script passes against it.
For reference analyses of all five tasks, see `all-five-tasks-reference.md`.

---

## Task Selection

Which task did you choose? (Write the task name from the list in the exercise README.)

My chosen task: ServiceNow Ticket Status Briefing

Why this task? (1–2 sentences on why you selected it — curiosity, highest time cost, most representative of your work, or another reason.)

Why I chose it: ServiceNow is a system Tracy uses daily for ITSM ticket tracking, and the briefing task has a clear, bounded output format (a two-paragraph status update), which makes it a clean test of the RSTRM framework. It is also a lower-stakes candidate than the status report — useful for a first independent analysis.

---

## RSTRM Scorecard

For each criterion, provide:
- Rating: Strong / Partial / Weak
- Reasoning: 1–3 sentences
- If Partial or Weak: name the specific sub-step or characteristic that limits the rating

### R — Repetitive

Rating: Strong

Reasoning: Tracy performs the ServiceNow ticket status briefing every Friday afternoon on a fixed weekly schedule, approximately 52 times per year. The trigger is calendar-based and does not depend on project events or her discretion.

---

### S — Structured

Rating: Strong

Reasoning: ServiceNow ticket fields (ticket number, priority, status, assignee, description, last-updated timestamp) are machine-structured with consistent field names. The output briefing is a fixed two-paragraph format: one escalation paragraph for P1 tickets and one status paragraph for P2/P3 tickets. Both input structure and output structure can be fully specified before building the skill.

If Partial or Weak — describe the exception: N/A

---

### T — Time-consuming

Rating: Strong

Reasoning: 30 minutes per week × 52 weeks = 26 hours per year spent on a task that could be automated. This is meaningful time, though lower in absolute value than the status report workflow. The primary value driver is predictability — a consistent 30-minute block is recoverable even at a lower annual total.

---

### R — Rules-based

Rating: Strong

Reasoning: Classification rules are fully articulable: "If ticket priority = P1 and status = Open, include in the escalation paragraph." "If ticket priority = P2 or P3 and status = Open, include in the status paragraph with the most recent update." "If ticket is Resolved within the past 7 days, include a one-line resolved note." No ambiguous judgment is required — ServiceNow priority is already a structured classification.

If Partial or Weak — name the sub-step(s) requiring judgment: N/A

---

### M — Multi-step

Rating: Partial

Reasoning: The workflow has two steps: (1) query ServiceNow for open and recently resolved tickets by program key; (2) format the results into the two-paragraph briefing. This is a skill-level workflow — single source system, two sequential steps with no intermediate evaluation required. An agent is not needed.

---

## Overall RSTRM Verdict

Verdict: Strong automation candidate

Supporting explanation: All five RSTRM criteria pass, with Multi-step rated Partial only because the workflow is intentionally simple — a two-step, single-source process. This simplicity is a feature, not a limitation: it makes this a good first automation for Tracy to build and validates before moving to more complex workflows. The appropriate architecture is a skill calling the ServiceNow plugin, with a checkpoint before the briefing is used in the Monday leadership review.

---

## Tool-Type Verdict

Which tool type is most appropriate for this workflow?
Choose one: **skill** / **plugin** / **agent**

My verdict: skill

Justification: Multi-step is Partial (2 steps, single source system), and Rules-based is Strong (no judgment sub-steps requiring escalation). A skill calling the ServiceNow plugin is the simplest architecture that accomplishes the task. An agent would be over-engineering for a two-step, single-source workflow.

---

## Design Constraint or Risk

Identify at least one design constraint or risk Tracy would need to address before building this automation.

Design constraint or risk: The two-paragraph output format must be defined precisely — including tone, maximum word count per paragraph, and what information goes in each paragraph — before encoding it in the skill. An underspecified format will produce briefings that differ in length and emphasis across weeks, requiring Tracy to rewrite them before use and defeating the purpose of the automation.

How would Tracy address it? Before building the skill, Tracy writes out a completed example briefing using last week's ServiceNow data — one that she would be comfortable including in the Monday leadership review without editing. That example becomes the output template encoded in the skill definition.

---

## Required Plugins or Tools

Which plugin(s) or tool type(s) does this automation need?

Required plugins: ServiceNow plugin — tools: `queryTickets` (filter by program key, priority, and status), `getTicket` (retrieve full ticket description for P1 escalation items)

---

## Human-in-the-Loop Checkpoint (if applicable)

Is a checkpoint required? Yes

If Yes — checkpoint specification:
- Trigger: After the two-paragraph briefing draft is generated, before it is included in the Monday leadership review materials.
- Review format: Tracy reads the draft briefing — the escalation paragraph (P1 tickets) and status paragraph (P2/P3 tickets) — and verifies that no ticket has been mis-classified in priority and that the escalation language accurately represents the current risk level.
- Approval action: Tracy selects "Approve and use" in the Claude Cowork interface, which marks the briefing as reviewed and ready for inclusion in the Monday review. She may edit the draft inline before approving.
