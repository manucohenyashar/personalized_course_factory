# RSTRM Scorecard — Weekly Project Status Report (scenario-01)

This is the canonical solution artifact for the worked example.
See `walkthrough.md` for the narrated version with Decision callouts.

---

## RSTRM Scorecard

| Criterion | Rating | Justification |
|---|---|---|
| Repetitive | Strong | Calendar-triggered every Monday; runs for both programs; ~50 cycles/year/program |
| Structured | Strong | All four sources (Jira, Confluence, Slack, Google Meet transcripts) follow describable patterns; output template stable for 8 months |
| Time-consuming | Strong | 2.5 hr/report × 2 programs × 50 weeks = 250 hr/year; conservative 60% recovery = 150 hr saved annually |
| Rules-based | Strong | Extraction rules articulable for all sources; judgment sub-step (stakeholder-concern classification) isolated to human-in-the-loop checkpoint |
| Multi-step | Strong | 6 steps across 4 external systems; requires agent orchestration |

**Overall verdict: High-confidence automation candidate.**

---

## Design Verdict

- **Architecture:** Agent orchestrating 1 status-report skill + 4 plugins (Jira, Confluence, Slack, Google Drive/Meet)
- **Human-in-the-loop checkpoint:** After draft synthesis, before distribution to leadership
- **Schedule:** Tuesday 9:00 AM ET (not Monday) — avoids stale Jira data from developers who close tickets Tuesday morning
- **Skip-week handling:** Skip flag encoded as a skill parameter; automation runs and self-documents the skip

---

## Key Decision Points

| ID | Decision |
|---|---|
| DP-1 | Encode skip-week flag rather than disabling the automation; automation self-documents skip weeks |
| DP-2 | Slack free-text passes Structured because extraction patterns are consistent and describable |
| DP-3 | Stakeholder-concern classification stays with Tracy at checkpoint; Claude performs first-pass flagging only |
| DP-4 | Tuesday 9:00 AM ET cutoff time encoded as a skill parameter to avoid stale-ticket data |

---

## Required Plugins

| Plugin | Required MCP tools |
|---|---|
| Jira plugin | `searchTickets`, `getBoard` |
| Confluence plugin | `getPage`, `getPageChildren` |
| Slack plugin | `getChannelMessages` |
| Google Drive plugin | `getDriveFile` (for transcript files) |
