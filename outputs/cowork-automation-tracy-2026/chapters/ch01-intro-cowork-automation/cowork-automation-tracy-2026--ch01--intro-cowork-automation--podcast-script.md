# Podcast Script — Chapter 1: Introduction to Claude Cowork Automation
## Course: cowork-automation-tracy-2026

---

**Audio-only artifact — no visuals referenced in this script.**
No diagrams, slides, or figures are required to follow this episode.

**Estimated runtime:** 1,980 words / 150 wpm = approximately 13 minutes 12 seconds
**Chapter reference:** Chapter 1 — Introduction to Claude Cowork Automation
**Learning outcomes covered:** LO-01.1, LO-01.2, LO-01.3
**Retrieval prompts embedded:** 3

---

### [0:00–1:30] Hook and context

It's Monday morning at Advisor360°. Tracy opens her Jira board, pulls up the project channel in Slack, navigates to the Confluence project page, and hunts down the two Google Meet transcripts from last week's stand-ups. She's done this forty-something Mondays in a row. Two programs. Two full rounds of this same circuit every week. Somewhere around the two-and-a-half-hour mark, she's assembled enough raw material to start drafting the executive status report — the five-section document that lands in leadership's inbox before end of day.

Two and a half hours. Every week. To move information from four systems she already has open into a template she's been using for eight months.

This chapter is about why that workflow is a near-perfect automation candidate, and more importantly, how to think clearly about which of your workflows are good candidates — and which ones aren't. By the end of this episode, you'll know how to distinguish automatable PM tasks from tasks that genuinely require your professional judgment, you'll understand the three building blocks of Claude Cowork automation — skills, plugins, and agents — and you'll be able to apply the RSTRM framework to score any workflow you're looking at.

This is Chapter 1, so there's no prior episode to connect to. We're starting from scratch. But if you've worked with Jira, Confluence, Slack, and Google Workspace in your day-to-day PM work — which, if you're Tracy or anyone like her, you absolutely have — then everything in this episode will map directly onto tools and workflows you already know.

---

### [1:30–8:00] Concept explanations

Let's start with a distinction that sounds obvious but matters a lot in practice: the difference between tasks that are automatable and tasks that require your professional judgment.

Here's the test. Ask yourself: if I wrote down every step of this task as a set of explicit rules, would those rules produce the same output every time? If yes, the task is automatable. If the answer is "well, it depends on things I can't fully write down" — things like reading the room in a stakeholder meeting, sensing political risk in how a message is phrased, or drawing on five years of institutional knowledge about which risks your leadership team actually worries about — then that's your judgment at work, and automation can't replace it.

This isn't about Claude being limited. It's about being precise about what automation is actually for. It handles the retrieval, the aggregation, the formatting, the synthesis across structured sources. You handle the judgment calls that sit on top of that synthesized information.

So what falls on the automatable side? Calendar-triggered workflows that run the same way every week. Status reports compiled from consistent-format sources. Meeting transcripts transformed into structured summaries. Action items pulled from emails and routed to the right Jira board. These are all information-movement and information-transformation tasks. The inputs are structured, the rules for transforming them are articulable, and the output format is fixed.

**Pause here and think about this before I continue.** What is the single characteristic that separates automatable tasks from judgment-required tasks? Not a list of examples — the underlying characteristic. What's the core difference? Take ten seconds.

Got an answer? Here's what I found when I worked through it carefully: the separator is whether the decision rules can be made explicit. If you can write them down — fully, not just partially — and those written rules produce correct output every time without needing you to fill in the gaps with tacit knowledge, the task is automatable. If the rules require tacit knowledge to work, they can't be fully encoded, and automation will hit a ceiling somewhere.

Now let's talk about the three building blocks, because this is where people get confused when they're first getting started, and getting the vocabulary right early saves a lot of frustration later.

Think of a Claude skill as a saved instruction set — like a detailed SOP you've written for a specific task, except instead of a human reading and following the SOP, Claude reads and executes it. A skill tells Claude what inputs to expect, what transformations to apply, what format to produce, and what constraints to respect. Critically: a skill on its own does not reach out to Jira or Confluence or anywhere else. It operates on whatever information you give it. It's a transformation engine, not a data retrieval engine.

That's where plugins come in. A plugin is a connector — it gives Claude read or write access to an external business system. The Jira plugin knows how to authenticate with your Jira instance, query the board, and hand back a structured list of tickets in a format a skill can work with. The Confluence plugin does the same for project pages. The Slack plugin pulls messages from a channel. The Google Meet plugin can surface transcript content. Plugins handle the credential management, the API calls, and the data formatting. You authorize them explicitly, and you can revoke them at any time.

So if a skill is the instruction set and a plugin is the data connector, what's an agent?

An agent is what you use when the workflow has multiple steps that need to be coordinated — and when the right next step depends on what came back from the previous step. An agent plans and executes a sequence: call the Jira plugin, evaluate the results, call the Confluence plugin, evaluate those results, call the Slack plugin, synthesize everything into a draft report using the status report skill, then pause and wait for Tracy to review before sending. That pause is the human-in-the-loop checkpoint, and it's a non-negotiable design element of every agent workflow we'll build in this course. More on that in a moment.

**Pause here and test yourself before I keep going.** Without looking anything up, describe in one sentence each: what a skill does, what a plugin does, and what an agent does. Three sentences. Then keep listening.

If you found one of the three harder to pin down than the others, you're not alone. Most people mix up skills and agents at first — they think of an agent as a more powerful skill, when actually the distinction is structural. A skill transforms. An agent orchestrates.

Now here's the mental model that ties all three together. Think of it as three layers. The bottom layer is your external systems — Jira, Confluence, Slack, Google Meet — where the actual project data lives. The middle layer is plugins, which act as the bridge between those systems and Claude. The top layer is skills and agents, which do the thinking: they receive data from plugins, apply transformation rules, and produce output. An agent sits above a skill in the same layer — it doesn't just execute one skill, it coordinates the whole sequence and decides what to do next at each step.

This three-layer picture matters because it tells you where to focus when something goes wrong. Bad data coming back from Jira? That's a plugin configuration issue. Poorly formatted output? That's a skill instruction problem. Steps happening in the wrong order, or intermediate results being ignored? That's an agent design issue. The layers keep your troubleshooting organized.

---

### [8:00–11:00] Worked example narration — RSTRM framework applied

Now let's walk through the RSTRM framework — because theory is fine, but watching it applied to a real workflow is where the value actually lands.

RSTRM stands for Repetitive, Structured, Time-consuming, Rules-based, Multi-step. Five criteria. For each one, you rate the workflow as Strong, Partial, or Weak. Two or more Weak ratings are a signal to redesign the workflow scope before automating, or to defer it. All five Strong is a high-confidence automation candidate.

Tracy applies this framework to her weekly status report workflow — the one we opened with, the two-and-a-half-hour Monday process pulling from Jira, Confluence, Slack, and two Google Meet transcripts.

She starts with Repetitive. Does the report run on a fixed schedule without exception? Yes — every Monday, both programs, approximately fifty times a year per program. That's a calendar-triggered workflow with no discretionary skip logic. Strong.

Next: Structured. She asks whether all four source systems produce consistent-format data. Jira exports a structured ticket list — closed tickets, blocked tickets, organized by status. Confluence pages follow a stable layout that hasn't changed in eight months. Slack messages in the project channel follow consistent patterns around decisions and blockers. Google Meet transcripts come in a predictable format. And the output template — the five-section executive summary — has been stable for the same eight months. Every input is consistently formatted, and the output template is fixed. Strong.

Time-consuming. Tracy does the arithmetic: 2.5 hours per report, two programs, fifty weeks per year. That's 250 hours per year recoverable — and even if the automation succeeds sixty percent of the time and she needs to spend time on the remaining forty percent, she still recovers 150 hours annually. That is a material number. Strong.

Rules-based. This is the criterion where Tracy does the most careful work, because she knows from experience that Slack messages are the messiest input. She writes out explicit classification rules for each source: what qualifies as an Accomplishment from the Jira board, what qualifies as a Risk from Confluence's decision log, what gets categorized as a Decision Needed versus an Action Item from the Slack channel. For the Slack channel specifically, she acknowledges the classification decision point: Claude does a first-pass classification using her written rules, but Tracy reviews and validates that classification at the human-in-the-loop checkpoint before the report goes out. Free-text doesn't mean un-classifiable — it means pattern-based classification with human review on the ambiguous cases. Strong.

Multi-step. Tracy maps out the discrete steps: retrieve Jira, retrieve Confluence, retrieve Slack, retrieve the two transcripts, synthesize a draft using the status report skill, pause for Tracy's review, then distribute. That's six steps with intermediate artifacts at each stage. A single skill would be insufficient here — this is exactly the kind of workflow that benefits from agent orchestration. Strong.

All five criteria come in Strong. That's the verdict: Tracy's weekly status report workflow is a high-confidence automation candidate.

Here's where the RSTRM process surfaces something useful that Tracy hadn't written down before. There are two decision points she needs to resolve at design time. First, twice a year during sprint transitions, there are weeks when no report is needed. The natural instinct is to disable the automation for those weeks manually — but that introduces operational risk, because someone has to remember to re-enable it. A better design is to encode a skip flag in the skill itself, so the automation runs, checks for the flag, and self-documents the skip. The automation is always on; it just knows when to stand down.

Second, stale Jira data. Developers at Advisor360° tend to close tickets on Tuesday, not Friday, which means pulling Jira on Monday morning gets last week's data but misses the previous Friday closes. Tracy's fix: shift the automation run to Tuesday morning, with a report cutoff time parameter baked into the skill. Small change, big impact on accuracy.

---

### [11:00–12:30] Pitfalls segment

Three pitfalls come up repeatedly when people start automating their first workflows, and all three of them come from reasonable instincts that lead somewhere wrong.

The first is what I'd call the structure-it-later problem. It's the belief that Claude can impose consistent structure on inconsistent inputs — that if your status report template has been used loosely, with different people filling in sections in different ways, Claude will sort it out. It won't. Claude reflects the patterns in the inputs it receives. Inconsistent templates produce inconsistent drafts. The fix: standardize the output template before you automate the workflow that produces it. Use it manually for two or three cycles until it's stable. Then build the skill around the stable version.

The second pitfall is the send-it-automatically trap. Once the automation is running and the drafts look good three weeks in a row, there's a temptation to remove the human-in-the-loop checkpoint and let the report go straight to leadership. Don't. A status report reaching executives with an error damages your credibility in ways that are hard to repair — and the automation cannot assess its own accuracy against your professional judgment of what leadership actually needs to hear this week. Time savings come from eliminating the data-gathering and synthesis labor, not from removing yourself from the approval chain. The checkpoint stays.

The third pitfall is layer confusion — specifically, assuming an agent is needed whenever you want to connect to an external system. Pulling Jira data is a plugin function. You call the Jira plugin, it returns the data, you're done. An agent isn't needed for a single retrieval step — and building one anyway just gives you something more complex to debug when it breaks. The design principle: start with the simplest combination that accomplishes the goal. Single retrieval uses a plugin. Transformation uses a skill. Multi-step workflows that retrieve, synthesize, and deliver use an agent. Add complexity only when the task structure requires it.

---

### [12:30–13:30] Recap and next steps

You now know how to distinguish the PM tasks that belong in an automation workflow from the ones that genuinely require your judgment — the separator is whether the decision rules can be made fully explicit.

You now understand the three building blocks: a skill is a saved transformation instruction set; a plugin is a data connector to an external business system; and an agent is an orchestrator that coordinates skills and plugins across a multi-step workflow.

You now know the RSTRM framework — Repetitive, Structured, Time-consuming, Rules-based, Multi-step — and you've watched Tracy apply it criterion by criterion to her weekly status report workflow, arriving at a high-confidence automation verdict with two important design decisions surfaced along the way.

In Chapter 2, we go deeper on automation mindset — specifically, how to decompose a complex workflow into steps that automation can handle and steps that need to stay with you. The running example will shift to Tracy's Google Meet transcript-to-summary workflow: a raw transcript goes in, a structured summary with decisions, action items, and risks comes out. If you've ever watched a Google Meet auto-summary miss three critical decisions and attribute an action item to the wrong person, Chapter 2 is for you.

Before you move on: try the exercises in this chapter's pack. Exercise 1 is the RSTRM worked example — Tracy's status report workflow, criterion by criterion, scorecard in hand. Exercise 2 asks you to score a second workflow. Exercise 3 is yours: pick one task from your own Advisor360° work, score it with RSTRM, and bring that scorecard to Chapter 2. That's the one that will matter most.

---

*End of Chapter 1 podcast script.*
*Cowork Automation for Tracy — cowork-automation-tracy-2026*
