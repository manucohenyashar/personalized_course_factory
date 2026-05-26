# RSTRM Analysis — Email Inbox Triage (Solution)

---

## RSTRM Scorecard

### R — Repetitive

Score: YES

Reasoning: Tracy performs this triage every Monday morning on a fixed weekly schedule. The trigger is consistent and calendar-based, not dependent on project events. The task recurs approximately 52 times per year.

---

### S — Structured

Score: PARTIAL

Reasoning: The classification logic can be written as explicit if/then rules for most message types. Examples: "If source is a Jira notification digest, then bulk-archive with label Jira-Digest." "If sender domain is @advisor360.com and subject contains a project keyword, then label by project." The output actions (apply label, archive, surface for action) are also a fixed set.

Exception: Classifying messages from external vendors or clients that contain ambiguous language — for example, a message that could be a billing dispute or a general inquiry. These require contextual judgment based on the sender's relationship and message history, which cannot be fully reduced to a rule.

---

### T — Time-consuming

Score: YES

Reasoning: 45 minutes per week × 52 weeks = approximately 39 hours per year spent on triage that could be automated. Additionally, manual triage is error-prone at volume: Tracy estimates she misses one or two time-sensitive messages per month, each requiring recovery effort.

---

### R — Rules-based

Score: PARTIAL

Reasoning: The majority of triage decisions are rule-describable. Classification rules include: "If sender is in the [leadership list], label Action-Required and surface for review." "If message is a Jira notification digest, bulk-archive." "If subject line contains [project keyword], apply the corresponding project label." Most decisions follow these patterns.

Sub-steps requiring judgment: (1) Ambiguous vendor/client messages where urgency depends on relationship context. (2) Messages from internal senders who are not on the leadership list but whose message is time-sensitive for project-specific reasons. These must be surfaced to Tracy for manual review rather than auto-classified.

---

### M — Multi-step

Score: YES

Steps: (1) Read the past 7 days of Gmail messages. (2) Classify each message using the ruleset (Jira digest, Confluence watch, leadership Action-Required, project-labeled, or unclassifiable/surface). (3) Apply Gmail labels to classified messages. (4) Bulk-archive the identified low-value threads. (5) Generate a triage report listing Action-Required items with sender, subject, date, and Gmail thread link. (6) Surface the triage report and the unclassified messages to Tracy for review before executing bulk actions.

---

## Overall RSTRM Verdict

Strong automation candidate with partial judgment exceptions.

The core triage — reading, classifying by rule, labeling, and bulk-archiving — is automatable. Ambiguous messages and vendor/client messages with context-dependent urgency must be surfaced for Tracy's manual review. The human-in-the-loop checkpoint handles this exception cleanly: the automation proposes the full action list; Tracy reviews and approves before bulk actions execute.

---

## Human-in-the-Loop Checkpoint Specification

**Trigger:** After the triage report is generated and the proposed action list (labels, archives) is assembled, before any bulk label or archive action executes in Gmail.

**Review format:** Tracy reads the triage report, which contains: (1) the Action-Required list with sender, subject, date, and Gmail thread link for each item; (2) the proposed bulk-archive list (thread count and a sample of subjects); (3) the unclassified/surfaced messages for her manual decision. She can modify the proposed action list before approving.

**Approval action:** Tracy selects "Approve and Execute" in the Claude Cowork interface (or runs `cowork approve <task-id>` in the CLI), which triggers the bulk label and archive actions in Gmail. She may also select "Edit Actions" to remove items from the bulk list before approving.

---

## Required Plugin(s)

Gmail plugin — tools: `listMessages`, `searchMessages`, `labelThread`, `archiveThread`, `getThread`

Note: The `getThread` tool is needed to retrieve message context for the surfaced/unclassified items so Tracy can read them in the review step without switching to the Gmail interface.
