# RSTRM Analysis — Email Inbox Triage (Starter)

Complete every TODO below. Replace each `# TODO:` block with your own analysis.
Keep answers concise — 1–3 sentences per field. Do not delete the section headers.

---

## Task Description

Tracy's Gmail inbox currently contains approximately 4,200 messages.
Each Monday she manually reviews the past 7 days of email to:
- Identify messages requiring direct action (reply, escalate to Jira, or flag for follow-up)
- Bulk-archive low-value threads (Jira notification digests, Confluence page-watch updates, automated system emails)
- Apply Gmail labels by project (Project-Alpha, Project-Beta, ServiceNow, General-Admin)

Current weekly cost: 45 minutes.

---

## RSTRM Scorecard

### R — Repetitive

Question: Does Tracy perform this task on the same schedule or trigger, week after week?

Score:
# TODO: Write YES, NO, or PARTIAL

Reasoning:
# TODO: Write 1–3 sentences explaining your score. If YES: what is the trigger and frequency?

---

### S — Structured

Question: Does the task follow a predictable pattern or template that can be written down?

Score:
# TODO: Write YES, NO, or PARTIAL

Reasoning:
# TODO: Write 1–3 sentences. Can Tracy write classification rules as "if X, then Y" statements?

If PARTIAL — describe the exception:
# TODO: Name the specific sub-step that does not follow a writable rule, or delete this line if N/A

---

### T — Time-consuming

Question: Does the task take meaningful time that could be better spent on judgment-intensive work?

Score:
# TODO: Write YES or NO

Reasoning:
# TODO: Include a weekly time estimate and an annual estimate.

---

### R — Rules-based

Question: Can the decisions within the task be described as rules ("if X, then Y") rather than pure intuition?

Score:
# TODO: Write YES, NO, or PARTIAL

Reasoning:
# TODO: Write 1–3 sentences. Name at least two rules Tracy applies (e.g., "If sender is X, then...").

If PARTIAL — name the sub-step(s) that require judgment:
# TODO: Name the specific classification decision(s) that cannot be reduced to an "if X, then Y" rule

---

### M — Multi-step

Question: Does the task require gathering from more than one source or taking more than one distinct action?

Score:
# TODO: Write YES or NO

Reasoning:
# TODO: List the distinct steps Tracy takes during the triage workflow.

---

## Overall RSTRM Verdict

# TODO: Write your verdict: "Strong automation candidate," "Partial automation candidate," or "Not an automation candidate."
# TODO: Write 1–2 sentences explaining what the scorecard supports.

---

## Human-in-the-Loop Checkpoint Specification

(Required for any automation whose output will trigger actions in Tracy's Gmail inbox.)

**Trigger:**
# TODO: At what point in the triage workflow does the automation pause for Tracy's review?

**Review format:**
# TODO: What exactly does Tracy review at this checkpoint? Be specific — list the elements she sees.

**Approval action:**
# TODO: What specific action does Tracy take to signal the automation should proceed with bulk labeling and archiving?

---

## Required Plugin(s)

# TODO: Which plugin does this skill need? List the specific MCP tools required.
# Format: Plugin name — tools: tool1, tool2, tool3
# Hint: This workflow operates entirely within Gmail.
