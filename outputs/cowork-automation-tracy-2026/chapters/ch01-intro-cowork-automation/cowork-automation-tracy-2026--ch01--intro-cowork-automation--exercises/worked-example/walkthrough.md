# Walkthrough — RSTRM Analysis: Weekly Project Status Report (scenario-01)

This walkthrough narrates the complete RSTRM analysis for Tracy's weekly project status report workflow. Read from top to bottom. Decision callouts explain the reasoning behind each scoring choice.

---

## Context

Tracy is a Senior Program Manager at Advisor360°, a wealth-management SaaS company based in Weston, Massachusetts. She manages two concurrent programs. Each Monday she assembles a weekly project status report from four data sources:

- **Jira board:** closed and in-progress tickets from the past week (filtered by sprint and status)
- **Confluence project page:** recent page edits, the decision log, and the change log
- **Slack project channel:** past week's messages, filtered for blockers, decisions, and risk flags
- **Google Meet stand-up transcripts:** two transcripts per week (Monday and Wednesday stand-ups)

Her output: a five-section executive summary (Accomplishments, Risks, Upcoming Milestones, Decisions Needed, Key Discussions) and a detailed supporting notes document with source citations.

Current time cost: approximately 2.5 hours per report. She runs this process for two programs, so the weekly total is approximately 5 hours.

---

## Step 1 — Score Repetitive

**Question:** Does Tracy perform this task on the same schedule or trigger, week after week?

**Analysis:** Yes. The weekly status report runs every Monday without exception for both programs. The trigger is calendar-based and external — it is not dependent on project milestones or Tracy's discretion. It runs approximately 50 times per year per program.

> **Decision (DP-1):** There are two exceptions per year — skip weeks during sprint transitions — when Tracy deliberately omits the report. This does not disqualify the Repetitive criterion. The correct design is to encode a skip flag in the automation, not to disable the automation entirely during those weeks. The automation runs and self-documents the skip with a one-line note; Tracy does not have to remember to re-enable it.

**Score: R = Strong**

---

## Step 2 — Score Structured

**Question:** Does the task follow a predictable pattern or template that can be written down?

**Analysis:** Yes. All four source systems produce data that follows consistent and describable patterns:

- Jira exports a structured ticket list with fields: ticket ID, title, status, assignee, priority, sprint.
- Confluence pages have a stable layout that has not changed in eight months.
- Slack messages in the project channel follow recognizable decision/blocker patterns: "Decided to…", "Blocker: …", "Risk: …".
- Google Meet transcripts follow the Google Meet format with speaker labels and timestamps.

The output template — the five-section executive summary — is also stable. The same format has been used for eight months.

> **Decision (DP-2):** Slack messages are free-text, which might suggest the workflow is not Structured. However, Structured means "patterns are consistent enough to describe as rules" — not "every source is a database table." The Slack channel messages follow linguistic patterns that are reliable enough to extract with approximate if/then rules. This is sufficient for a Strong rating, provided the extraction rules are written down explicitly before the skill is built. A partial or weak rating would apply if the patterns were unpredictable or changed frequently.

**Score: S = Strong**

---

## Step 3 — Score Time-consuming

**Question:** Does the task take meaningful time that could be better spent on judgment-intensive work?

**Analysis:** Yes. At 2.5 hours per report, for two programs, the annual cost is:

2.5 hours × 2 programs × 50 weeks = **250 hours per year**

Even assuming 60% automation success rate (meaning Tracy still reviews and corrects for 40% of the time), the automation recovers 150 hours per year — approximately 4 working weeks.

> **Decision:** The 60% estimate is conservative. For a workflow this structured, success rates above 80% are common once the extraction rules are refined through two or three iterations. The 250-hour savings estimate used here uses the conservative floor, not the optimistic ceiling, to avoid over-selling the investment.

**Score: T = Strong**

---

## Step 4 — Score Rules-based

**Question:** Can the decisions within the task be described as rules ("if X, then Y") rather than pure intuition?

**Analysis:** Yes, for most sub-steps. Tracy can articulate the decision rules for each source:

- **Jira:** If ticket status = Closed and closed-date is within the past 7 days, classify as Accomplishment. If ticket status = Blocked, classify as Risk.
- **Confluence:** If a page was edited in the past 7 days, include the edit summary. If a decision was logged in the Decision Log, include it in the Decisions Needed section.
- **Slack:** If a message contains "decided to" or "we're going with", extract as Decision. If it contains "blocker", "blocked", or "at risk", extract as Risk. Otherwise, include in Key Discussions if it was sent by a named project stakeholder.
- **Google Meet transcripts:** Apply the same extraction rules as Slack.

The one exception: classifying whether a Slack message about a stakeholder concern is a genuine blocker versus a casual observation. This requires judgment based on the message's context and the sender's role.

> **Decision (DP-3):** The stakeholder-concern classification sub-step stays with Tracy at the human-in-the-loop checkpoint. Claude performs a first-pass classification — it flags any message matching risk patterns — and Tracy reviews the flagged list before the report is finalized. This is not a failure of the Rules-based criterion; it is correct design. The automation handles the rule-describable 90% and surfaces the judgment-required 10% for Tracy to resolve.

**Score: R = Strong**

---

## Step 5 — Score Multi-step

**Question:** Does the task require gathering from more than one source or taking more than one action?

**Analysis:** Yes. The workflow has six discrete steps:

1. Retrieve last week's Jira board data (closed and in-progress tickets).
2. Retrieve the Confluence project page (recent edits, decision log, change log).
3. Retrieve the Slack project channel (past 7 days of messages).
4. Retrieve the two Google Meet stand-up transcripts (from Google Drive).
5. Synthesize the four source artifacts into a draft executive summary and supporting notes.
6. Pause for Tracy's review before the report is shared with leadership.

Six steps, four distinct external systems, and an intermediate synthesis step between retrieval and delivery. A single skill could not execute all of this without calling multiple plugins. The workflow requires agent-level orchestration.

> **Decision (DP-4):** A further sub-step refinement: the Jira retrieval should be scheduled for Tuesday morning rather than Monday morning. Developers at Advisor360° routinely close tickets on Tuesday when they write up their weekend work — Friday ticket data would miss those closures. The automation encodes a report-cutoff-time parameter (Tuesday 9:00 AM ET) that Tracy can adjust if team norms change. This kind of parameter encoding is what distinguishes a robust, maintainable automation from a fragile one-off script.

**Score: M = Strong**

---

## RSTRM Summary Scorecard

| Criterion | Rating | One-line justification |
|---|---|---|
| Repetitive | Strong | Weekly, calendar-triggered, consistent for 50+ weeks/year |
| Structured | Strong | All four sources follow describable patterns; output template stable 8 months |
| Time-consuming | Strong | 250 hours/year at current manual rate; conservative 60% recovery = 150 hrs saved |
| Rules-based | Strong | Extraction rules articulable for all sources; judgment-required sub-step isolated to human-in-the-loop checkpoint |
| Multi-step | Strong | 6 steps across 4 external systems; agent orchestration required |

**Overall verdict: High-confidence automation candidate.**

---

## Design Verdict

**Tool type:** An agent orchestrating one status-report skill and four plugins (Jira plugin, Confluence plugin, Slack plugin, Google Drive/Meet plugin). A skill alone is insufficient — the workflow requires retrieving from four systems, synthesizing, and pausing for approval, which requires agent-level coordination.

**Human-in-the-loop checkpoint position:** After the draft executive summary and supporting notes are generated (Step 5), before the report is shared with leadership (Step 6). Tracy reviews the full draft, including the flagged Slack/transcript items, and explicitly approves before distribution.

**Why here, not earlier?** Inserting a checkpoint after each individual retrieval step (Steps 1–4) would eliminate the time savings — Tracy would spend as much time approving data pulls as she currently spends doing them manually. The synthesis output (Step 5) is the meaningful artifact she can evaluate in one pass.

**Why not later?** The only step after review is distribution to leadership. Distributing an unreviewed report is the failure mode this course is designed to prevent.

---

## Plugins Required

- Jira plugin (tools: `searchTickets`, `getBoard`)
- Confluence plugin (tools: `getPage`, `getPageChildren`)
- Slack plugin (tools: `getChannelMessages`)
- Google Drive plugin (tools: `getDriveFile`) — for transcript access

---

## End of Walkthrough

You have seen how RSTRM produces a structured, documented evaluation — not an intuitive judgment. The final scorecard (`solution/status-report-rstrm-scorecard.md`) is the clean version without narrative, suitable for use as a design artifact in Chapter 6 when Tracy builds the status-report skill.

Next: In Exercise 02, you will apply the same process to Tracy's email inbox triage workflow, but you will fill in the analysis yourself using the partial scaffold provided.
