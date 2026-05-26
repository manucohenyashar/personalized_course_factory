# Instructor Guide — Chapter 1: Introduction to Claude Cowork Automation

**INSTRUCTOR-ONLY — Do not distribute to learners.**

---

## Chapter Overview

- **Total time:** 50 minutes (chapter doc) + 35 minutes (exercises) = 85 minutes instructed time
- **Learning Outcomes:**
  - LO-01.1: Identify automation-candidate characteristics in a PM workflow [Bloom: Remember / Understand]
  - LO-01.2: Distinguish skill / plugin / agent and select the right building block [Bloom: Understand]
  - LO-01.3: Apply the RSTRM framework to produce a scored evaluation and design verdict [Bloom: Apply]
- **Prerequisites:** None (Chapter 1 is the entry point)
- **Artifacts:**
  - Chapter doc (`--doc.md`): 50 min estimated read, ~5,400 words, FK grade 12.8
  - Exercises: worked example (12 min), completion (15 min), independent (8 min) = 35 min total
  - Quiz Form A (administer after exercises); Form B available for learners scoring below 80%
  - Slides (`--slides.pptx`): refer to slide notes for timing; slide count per `--slides-notes.md`
  - Cheatsheet (`--cheatsheet.md`): distribute before or during the session; it stands alone

---

## Before the Session

### Concepts instructors must be confident in

1. **The RSTRM framework — criterion by criterion.** You must be able to score any of Tracy's five candidate tasks (DragonBoat sync, ServiceNow briefing, meeting follow-up distribution, sprint retrospective tagging, vendor status update parsing) on all five criteria without referring to notes, and justify each rating in one sentence. If you cannot do this fluently, work through the worked example walkthrough before facilitating.

2. **The three-layer building-block model (skill / plugin / agent) with clear decision boundaries.** Specifically: a skill cannot call an external API without a plugin; a plugin alone cannot follow instructions without a skill; an agent is not required for single-system, single-step workflows. The most common learner confusion lives at the skill/agent boundary — know the Multi-step decision rule cold.

3. **The human-in-the-loop checkpoint as a mandatory design element — not an optional safety feature.** The worked example and both exercises explicitly test whether learners understand that a Strong RSTRM score is not permission to skip the checkpoint. Be prepared to counter the "it's reliable enough" argument with the stakes-based reasoning: the checkpoint exists because the output reaches leadership, not because the automation is unreliable.

### Environment preflight

Run `preflight.sh` (or `preflight.ps1` on Windows) in the `environment/` directory before the session. The preflight script confirms:
- The exercise starter files are in their unmodified state
- The verify scripts are executable
- Node.js is available (required for `exercise-02/verify/check-completeness.js`)

If the preflight fails, do not proceed — learners will hit verify script errors mid-exercise.

### Potential misconceptions to pre-empt (from chapter pitfalls)

State these explicitly in the opening, before the concept introduction:

1. **"Structured means machine-formatted."** Learners with a technical background often interpret Structured as "the input must be a database row or JSON object." Every exercise in this pack tests the opposite: Slack messages, Gmail bodies, and vendor emails are free-text but still satisfy Structured when classification rules are writable. Pre-empt this by stating it directly: "Structured measures your rules, not the input format."

2. **"High RSTRM score = skip the review step."** This misconception produces the most consequential real-world error in Tracy's context — a status report reaching leadership unchecked. Name it before it appears: "RSTRM tells you whether to build the automation. A separate question — who receives this output and what happens if it contains an error — tells you where to put the checkpoint."

3. **"An agent is needed for any multi-source workflow."** Over-engineering first automations is a common first-session mistake. Clarify: a skill calling multiple plugins (in a single skill execution, with manually coordinated steps) is appropriate for simpler workflows before introducing agent orchestration in Chapter 11.

---

## Session Flow

### Opening (5 min)

**Retrieve prior knowledge (no prior chapter; use experience retrieval instead):**

Ask the room: "Think about the most repetitive report or document you produce every week or every month. How long does it take you, and which step in that process do you find most tedious — gathering the data, synthesizing it, or formatting it for the audience?"

Give learners 60 seconds to think, then take two or three answers. You are listening for the data-gathering step — almost universally, it is gathering that dominates. This sets up the chapter's premise: Claude Cowork's primary value in program management is eliminating the data-gathering overhead, not replacing Tracy's synthesis judgment.

Expected wrong framing to correct: if a learner says "the writing" or "formatting," probe gently — "How long does it take to actually write once you have all the information in front of you?" Usually the answer reveals that formatting takes 10–15 minutes while gathering takes 60–90 minutes. This makes the automation opportunity concrete before the framework is introduced.

---

### Concept Introduction (15 min)

**Walk through the worked example setup (doc §7, slide deck section 3).**

The worked example is Tracy's Monday status report workflow. Do not abstract it. Walk it as Tracy's literal Tuesday morning:

> "It's 9 AM on Monday. Tracy has a status report due to leadership by noon. She opens her Jira board — that's step one — finds the closed and blocked tickets from the past sprint, notes them. Then she opens Confluence to check the change log and decision log — step two. Then Slack, to review the past week's messages in the project channel for blockers and decisions she may have missed — step three. Then she opens two Google Meet transcripts from stand-ups she ran last week — step four. At this point she has four browser tabs open, pages of notes, and 90 minutes have passed. Now she writes the executive summary. That's step five. She sends it. That's step six. Repeat next Monday, for both programs."

The six-step enumeration prepares learners to score Multi-step = Strong before they have seen the framework.

**Discussion prompt:** "Before I show you the RSTRM framework, which of those six steps do you think could be replaced by automation today, and which one do you think requires Tracy's professional judgment no matter how good the automation is?"

Take two or three answers. You are listening for "the synthesis step" or "deciding what counts as a blocker" as the judgment-required step. If learners suggest all steps are automatable, probe: "If the automation incorrectly classifies a low-priority Slack message as an escalated blocker — and it reaches the VP of Product without Tracy reviewing it — what happens?" This surfaces the checkpoint design rationale organically.

**Common wrong turn: "Skills are like macros."** Learners familiar with Excel macros or Zapier sometimes frame a skill as "a recorded sequence of clicks." Correct this before it calculates: "A skill is a reusable instruction set — more like a written SOP than a recorded macro. It cannot click or navigate on its own. It processes source information that is supplied to it and produces a report draft. Clicking and navigating is what plugins and browser automation handle — and that comes in later chapters."

---

### Exercise Time (35 min)

#### ch01-ex01: Worked Example — RSTRM Analysis for Tracy's Weekly Status Report (12 min)

- **Time box:** 12 minutes
- **Stage:** worked_example
- **What to watch for:**
  - Learners who skim the decision callouts and treat the scorecard as the deliverable. The decision points (DP-1 through DP-4) contain the reasoning that makes the framework transferable. If learners skip them, they will miss the "Structured = rules, not format" insight before Exercise 02 tests it.
  - Learners who read the walkthrough and conclude "this task is obviously automatable — why bother with the framework?" The value of the framework is producing a defensible verdict before you invest build time. Ask: "Could you have made this same assessment in 5 minutes without the framework? What if you were evaluating a task that was less obviously structured?"
- **Discussion prompt for debrief:** "Decision Point 2 in the walkthrough says Slack messages are 'structured at the RSTRM level' even though they're free-text. In your team's Slack channels, could you write a rule that classifies messages as blockers, decisions, or FYI? If yes, your Slack channel passes Structured. If no — what would make it pass?"
- **If learners finish early:** Direct them to the Stretch prompt: "The worked example concludes the automation should run Tuesday morning, not Monday, because of stale Jira data. What does a Tuesday delivery cost Tracy's stakeholders compared to Monday? When would Monday delivery at higher stale-data risk be preferable?" This is a judgment exercise, not a right/wrong question.
- **Solution:** See `worked-example/solution/status-report-rstrm-scorecard.md` (instructor-only). The solution is the clean scorecard without narrative — useful as a reference answer when debriefing the self-check questions, but do not display it until all three self-check questions have been attempted.

#### ch01-ex02: Completion — RSTRM Analysis for Email Inbox Triage (15 min)

- **Time box:** 15 minutes
- **Stage:** completion
- **What to watch for:**
  - **Failure Mode 1 (most common):** Tracy scores Structured = No because individual Gmail message bodies vary. This is the pack's most prevalent misapplication of the framework. If you see a learner stuck on this, ask: "Before you score Structured, write down one rule you apply when triaging your inbox. Not a format rule — a decision rule. Something like 'if the sender is my VP, I respond same day.' Can you write that rule? Then the task is Structured." Do not tell them the correct score; use the question to surface the rule.
  - **Failure Mode 2 (caught by verify script):** The checkpoint specification is incomplete — it names the review but omits the approval action. The verify script exits 1 with a specific error message. Instruct learners to read the error message literally: it identifies the missing field. If they ask what "approval action" means, ask: "What specific thing does Tracy do — in what interface — to tell the automation it is safe to proceed with bulk-labeling 4,200 messages?"
  - Do not accept "Tracy approves it" as a complete approval action. The answer must be a concrete gesture: clicking a button in the Cowork UI, running `cowork approve <task-id>`, or sending a specific message.
- **Discussion prompt for debrief:** "In your team's Gmail triage workflow — or whatever inbox system you use — which classification rules are stable enough to write down, and which require judgment every time? The stable ones are automatable today. The judgment ones need a checkpoint." Give learners 30 seconds to think before taking answers.
- **If learners finish early:** Direct them to the Stretch prompt: "Tracy has 4,200 unread messages. If the triage skill processes 150 per week and the inbox grows by 80 messages per week net, how many weeks until the backlog reaches zero? At that point, does the recurring automation still make sense, or does the use case change?"
- **Solution:** See `exercise-02/solution/email-triage-rstrm-solution.md` (instructor-only).

#### ch01-ex03: Independent — Choose a Task and Apply RSTRM (8 min)

- **Time box:** 8 minutes
- **Stage:** independent
- **What to watch for:**
  - **Failure Mode 1:** Vendor status update parsing is scored as Weak / Structured because three vendor emails use different HTML formats. See Pack Failure Mode A. If you observe this, do not correct it during the exercise — wait for the debrief. Let the learner complete their analysis, then ask: "You scored Structured as Weak because the formats differ. Before I say whether that's correct: can you write an extraction rule for Vendor A's email? Just one rule — 'in Vendor A's email, the timeline status appears in paragraph 2.' Can you write that?" If they can, the criterion passes and the score needs revision.
  - **Failure Mode 2:** Task 3 (meeting follow-up action item distribution) selected with "skill" as the tool type. The verify script does not catch this error — the rubric evaluates it. During debrief, ask the learner: "Your skill distributes action items by email. Walk me through how the skill sends the email. What does it call?" When the learner cannot answer, the gap becomes apparent: the skill needs a Gmail plugin to send, and a workflow that reads a document and sends to multiple owners needs agent-level orchestration.
  - Exercise 03 has a lower estimated completion rate (65%) than Exercises 01 and 02. If the 8-minute time box expires and a learner has not finished, allow them to continue during the debrief of earlier exercises. The exercise is more valuable completed than abandoned.
- **Discussion prompt for debrief:** "Which of the five candidate tasks on Tracy's list is the weakest automation candidate in your judgment, and what single RSTRM criterion does it fail most clearly? What would Tracy need to change about how she runs that task — not the automation, the task itself — to make it automatable?"
- **If learners finish early:** Direct them to the Stretch prompt: "Take the task you identified as weakest. What structural change to the workflow — how it is triggered, what data it draws from, or what its output format is — would raise the weakest criterion from Weak to Partial? This is a redesign exercise, not a score-inflating exercise."
- **Solution:** See `exercise-03/solution/all-five-tasks-reference.md` and `exercise-03/solution/my-task-analysis-solution.md` (instructor-only). The solution directory contains a reference analysis for each of the five tasks. Match to the learner's chosen task.

---

### Quiz (8 min)

- Administer Form A after the exercises are complete.
- Allow Form B retry for learners who score below 80%.
- Weighted LO focus for Form B: LO-01.3 (RSTRM application) is the most commonly missed in this chapter because learners who read the framework conceptually but did not complete Exercise 02 or 03 will struggle with applied scoring questions. Prioritize Form B items that present a new workflow (not the status report or email triage) and ask for a criterion-by-criterion rating with justification.
- The most common distractor mistake: selecting "an agent is needed to retrieve Jira data" (quiz_seed candidate misconception 2). Flag this in debrief if multiple learners chose it — it means the skill/plugin/agent distinction has not been operationalized.

---

### Closing (5 min)

**Recap — retrieval cue from doc §12 (Retrieval Checkpoints):**

Ask the room: "Name three characteristics that make a PM task a strong automation candidate. Then describe the difference between a Claude skill and a Claude plugin — one example of each from Tracy's status report workflow."

Give learners 60 seconds to write their answers. Take one or two responses. Correct any learner who conflates a skill with a plugin (e.g., "the Jira skill" — Jira is a plugin; the status report aggregation skill calls the Jira plugin).

**Preview Chapter 2:**

Chapter 2 builds on the RSTRM framework by teaching workflow decomposition — breaking a multi-step PM task into discrete, verifiable sub-steps that Claude can execute reliably. The running example shifts to Tracy's Google Meet transcript-to-structured-summary workflow, which shares the RSTRM profile you established today but introduces a new design challenge: the source is a single document, the output has five sections with different extraction rules, and there is no stable template yet. Before Chapter 2, complete Reflection Prompt 3 from the chapter doc: draft a preliminary RSTRM scorecard for one task from your own workload and bring it to the Chapter 2 exercises.

**Assign stretch goals (optional, outside time budget):**

- Complete the Stretch prompt for whichever exercise was not attempted during the session.
- Bring a completed RSTRM scorecard for a real recurring task from your own PM workload to the Chapter 2 session.

---

## Answers to Reflection Prompts

*For instructor reference only — not for distribution.*

**Prompt 1:** "The distinction between skills, plugins, and agents is clean on a diagram but blurry in practice. Which of the three did you find hardest to pin down?"

The expected hard case is the agent. Skills and plugins have intuitive analogies (SOP and API connector, respectively). An agent is harder to pin down because it describes behavior — autonomous planning and sequencing — rather than a fixed artifact. A complete 30-second explanation: "An agent is a Claude configuration that can plan. It reads the situation, decides what to call next — a skill, a plugin, or a pause for my review — and continues until it reaches a stopping condition. A skill just executes instructions. An agent decides which instructions to execute and when." The test of understanding is whether the learner can identify, for a given workflow, when agent-level orchestration adds value vs. when a skill calling plugins sequentially is sufficient.

**Prompt 2:** "Before reading this chapter, how did you think about the boundary between what automation can do and what requires your professional judgment?"

There is no single correct answer. The insight instructors should listen for is a shift from a capability boundary ("automation can do X, I do Y") to a stakes boundary ("automation produces the draft; I review anything that reaches a leadership audience"). Learners who articulate this shift have internalized the human-in-the-loop checkpoint as a design principle, not a limitation.

**Prompt 3:** "Which one task in your current workflow would you score using the RSTRM framework before Chapter 2? Draft the scorecard now."

This is a bridging exercise. Evaluate the scorecard on internal consistency — not on whether the scores are "correct." A learner who can state a rating and a one-sentence justification for each criterion has applied the framework correctly, regardless of whether a different observer would score the same task differently. Look for: (a) at least one criterion where the learner acknowledged uncertainty rather than defaulting to Strong; (b) a tool-type verdict that follows logically from the Multi-step score.

---

## Assessment Guidance

- **Chapter quiz passing threshold:** 80% (Form A or Form B)
- **Exercise rubric passing average:** 3.0 / 4.0 across all three exercises (rubrics at `worked-example/`, `exercise-02/rubric.json`, `exercise-03/rubric.json`)
- **Learners below threshold:** point to the remediation links in the quiz item JSON (`remediation_link` field per item); all remediation links point to specific sections in the Chapter 1 doc or cheatsheet. Do not ask learners to redo the full chapter — identify the specific criterion or building block where their Form A score was weakest and direct them to that section.
- **Common below-threshold pattern:** A learner who scores well on LO-01.2 (skill/plugin/agent distinction) but fails LO-01.3 (RSTRM application) has conceptual knowledge but has not operationalized the framework. Prescribe Exercise 02 or 03 redo, not a re-read of the framework section. The framework is learned by scoring, not by reading.

---

## Accessibility Notes

- All tables in the chapter doc, cheatsheet, and exercises are color-independent — ratings (Strong / Partial / Weak) use text labels, not color coding. No information is conveyed by color alone.
- Verify scripts output plain text to stdout and stderr; no color-coded terminal output is required to interpret results.
- The three-layers mental model diagram (`diagrams/three-layers-mental-model.svg`) has a full alt text description in the handoff JSON. If delivering in a screen-reader context, read the alt text aloud before discussing the diagram: "A flowchart with three labeled layers — Skills at the top, Plugins in the middle, Agents at the bottom — with arrows showing that a skill calls plugins, and an agent orchestrates both skills and plugins, pausing at a human-in-the-loop checkpoint."
- All exercise starter files are plain Markdown — no tables with merged cells, no inline images. Compatible with standard screen readers.
- Font size and contrast: if projecting the cheatsheet or slide deck, verify that table text renders at minimum 12pt at the projected size. The pitfall table and RSTRM scored reference table have the highest information density and are the first to become unreadable at small sizes.
