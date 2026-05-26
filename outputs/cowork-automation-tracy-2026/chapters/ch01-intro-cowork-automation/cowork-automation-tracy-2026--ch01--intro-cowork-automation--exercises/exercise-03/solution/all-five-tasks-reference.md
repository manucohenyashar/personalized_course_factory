# Reference Analyses — All Five Candidate Tasks (Solution)

This file contains reference RSTRM analyses for all five tasks listed in Exercise 03.
Compare your analysis of your chosen task to the corresponding reference below.
There is no single correct answer — the rubric evaluates reasoning quality, not answer matching.

---

## Task 1: DragonBoat Roadmap Update Sync

**Overall verdict:** Strong automation candidate

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | Every two weeks on a fixed sprint schedule; approximately 26 cycles per year |
| Structured | Strong | DragonBoat roadmap fields (milestone name, status, risk) are fixed; Jira sprint summary and Confluence risk log follow consistent formats |
| Time-consuming | Strong | 45–60 min/cycle × 26 cycles = ~21 hours/year; both programs combined = ~42 hours/year |
| Rules-based | Strong | Rules are articulable: "If Jira ticket is Closed and tagged to milestone X, mark milestone X as Completed in DragonBoat." "If Confluence risk log has a new entry, add to DragonBoat risk section." |
| Multi-step | Strong | Read Jira sprint summary → Read Confluence risk log → Update DragonBoat milestones → Update DragonBoat risks → Save (2 sources in, 1 system out) |

**Tool-type verdict:** Agent — requires reading from two source systems (Jira plugin, Confluence plugin) and writing to one output system (DragonBoat plugin). A skill alone cannot execute cross-system reads and writes.

**Design constraint:** DragonBoat may not have a supported Claude Cowork plugin in Chapter 1. This is the primary risk — the automation requires DragonBoat write access via an MCP tool that may not exist until Chapter 8 or 10 (Zapier integration). Short-term workaround: the automation drafts the updates as a structured text document; Tracy applies them manually in DragonBoat until the plugin is available.

**Checkpoint:** Required before DragonBoat is updated. Tracy reviews the proposed milestone changes and risk additions before the write operations execute.

---

## Task 2: ServiceNow Ticket Status Briefing

**Overall verdict:** Strong automation candidate

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | Every Friday, fixed schedule, ~52 cycles/year |
| Structured | Strong | ServiceNow ticket fields (ticket number, priority, status, assignee, description) are machine-structured; output briefing is a fixed two-paragraph format |
| Time-consuming | Strong | 30 min/week × 52 weeks = 26 hours/year |
| Rules-based | Strong | "Pull all open tickets for Program-Alpha and Program-Beta keys. Classify by priority (P1, P2, P3). For P1 tickets: include in the escalation paragraph. For P2/P3: include in the status paragraph." |
| Multi-step | Partial | Two steps: (1) Query ServiceNow by program key and status. (2) Synthesize into two-paragraph briefing. This is simple enough for a skill calling a single plugin — agent orchestration may be over-engineering for this workflow. |

**Tool-type verdict:** Skill (calling ServiceNow plugin) — two steps, single source system, no cross-system retrieval. Multi-step is Partial; the workflow does not require agent coordination.

**Design constraint:** The two-paragraph briefing format must be defined explicitly (what goes in the escalation paragraph vs. the status paragraph, what Tracy's word-count and tone requirements are) before encoding it in the skill. An underspecified output format will produce inconsistent briefings that Tracy must rewrite.

**Checkpoint:** Required before the briefing is included in the Monday leadership review materials. Tracy reviews the draft, especially the escalation paragraph, before use.

---

## Task 3: Meeting Follow-up Action Item Distribution

**Overall verdict:** Partial automation candidate — depends on input source quality

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | Two leadership reviews per month; consistent trigger |
| Structured | Partial | Output structure is fixed (action item, owner, due date, context sentence). Input is Tracy's meeting notes — quality and format vary by meeting. If notes are typed in a consistent template, S = Strong. If handwritten or unstructured, extraction reliability drops significantly. |
| Time-consuming | Partial | 20–30 min per meeting × 2 meetings/month = 40–60 min/month (~8–10 hours/year). Meaningful but below the "highly time-consuming" threshold. |
| Rules-based | Partial | Action item extraction follows recognizable linguistic patterns ("X will Y by Z date"). However, implicit action items — where an outcome was decided but no explicit owner was named — require judgment based on meeting context and organizational knowledge. |
| Multi-step | Strong | Read notes document → parse action items → match items to owners → generate personalized emails → send to each owner (requires reading and sending across multiple operations) |

**Tool-type verdict:** Agent — requires reading a document (Drive or Notes plugin), parsing, and sending emails to multiple recipients (Gmail plugin with `sendMessage`). A skill alone cannot send email; an agent coordinating a document-reading plugin and the Gmail plugin is required.

**Design constraint:** The quality of the automation output is directly dependent on the quality of Tracy's meeting notes. If Tracy types notes in a consistent template (action item / owner / due date / context), extraction is reliable. If notes are prose summaries, the automation must infer action items — with lower reliability. Tracy would need to adopt a consistent note-taking format as a prerequisite to building this automation.

**Checkpoint:** Required before emails are sent. Tracy reviews the drafted emails for each owner to confirm accuracy before distribution.

---

## Task 4: Sprint Retrospective Tagging

**Overall verdict:** Partial automation candidate

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | One retrospective per sprint (two-week sprints = ~26 retros/year per program) |
| Structured | Partial | Retrospective notes in Confluence follow a general "what went well / what didn't / action items" format, but the free-text content varies by facilitator and team. Tagging themes (velocity, blockers, communication gaps) requires pattern-matching that may have meaningful variance across sprints. |
| Time-consuming | Partial | 30–45 min/retrospective × 26 retrospectives/year × 2 programs = ~26–39 hours/year. Meaningful but concentrated — Tracy only does this once per sprint, not weekly. |
| Rules-based | Partial | Theme tags (velocity, blocker, communication) can be seeded with keyword patterns. But tagging accuracy depends on whether the retrospective notes use consistent language. Novel concerns that do not match existing keywords will be missed or mis-tagged. |
| Multi-step | Partial | Read Confluence retrospective page → extract themes → apply tags → update trend tracker. Two to three steps but from a single source system — a skill with Confluence plugin may be sufficient. |

**Tool-type verdict:** Skill (calling Confluence plugin) — single source system, limited step count. An agent is not required unless the trend tracker lives in a separate system.

**Design constraint:** The tag vocabulary must be defined explicitly and maintained over time. As new recurring themes emerge across sprints, new tags must be added. An automation built with a static tag list will systematically miss novel retrospective themes — potentially masking emerging team problems. Tracy should plan for quarterly tag-list review as part of the automation's maintenance routine.

**Checkpoint:** Required before the trend tracker is updated. Tracy reviews the proposed tags for each retrospective item to catch mis-classifications before they compound over multiple sprints.

---

## Task 5: Vendor Status Update Parsing

**Overall verdict:** Strong automation candidate

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | Weekly, from three vendors on a consistent schedule; approximately 52 cycles/year per vendor |
| Structured | Strong | Even though each vendor email uses a different HTML structure, the three extraction targets (timeline status, open risks, next deliverable date) are consistent across all three vendors. Extraction rules are vendor-specific but articulable. |
| Time-consuming | Strong | 20–30 min/week across three vendors × 52 weeks = 17–26 hours/year |
| Rules-based | Strong | Per-vendor rules: "For Vendor A: timeline status is in paragraph 2, third sentence. For Vendor B: look for 'current status:' label. For Vendor C: look for the table row labeled 'Phase.'" Vendor-specific but explicit and stable. |
| Multi-step | Partial | Read three vendor emails (Gmail plugin) → parse per vendor rules (skill) → write to consolidated tracker (Drive or Sheets). Two to three steps; a skill calling the Gmail plugin is likely sufficient, with a Sheets/Drive plugin for the tracker update. |

**Tool-type verdict:** Skill (calling Gmail plugin + Google Sheets plugin for tracker) or Agent if the tracker update is time-sensitive and needs to be sequenced with a review step. Given the low risk of the output (internal tracker, not distributed), a skill is appropriate.

**Design constraint:** The per-vendor extraction rules are stable only as long as vendors do not change their email format. A vendor that changes its update template will break its extraction rule silently — the automation will parse incorrect data into the tracker with no error. Tracy should add a "format change detector" step: if extracted fields are empty or unexpected, surface the raw email for manual review rather than writing empty rows to the tracker.

**Checkpoint:** Optional — the consolidated tracker is an internal document, not distributed. Tracy may choose to review weekly before sharing the tracker in a leadership review, but the risk of an un-reviewed update is lower than for the status report or email triage workflows.
