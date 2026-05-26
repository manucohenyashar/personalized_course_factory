# Speaker Notes — Chapter 1: Introduction to Claude Cowork Automation
# cowork-automation-tracy-2026--ch01--intro-cowork-automation--slides-notes.md

**Deck:** 18 slides | **Chapter time budget:** 50 minutes | **Mode:** self-taught primary, cohort secondary
**Running example:** Tracy's weekly executive status report for one of her two Advisor360° programs — aggregated from Jira, Confluence, Slack, and Google Meet stand-up transcripts.

---

## Slide S01 — Title

**Timing:** [click-through: 60 s]
**Bloom:** n/a (title slide)
**LO ref:** n/a

### Cohort sidebar
- Ask the room: "Before we start — how long does it take you to produce your most recurring weekly report? Does anyone track that number?"
- Likely misconception: learners may assume "automation" means replacing their judgment. Correct at this point only if raised: "We are automating the data-gathering grind, not the professional decisions."

### Solo sidebar
- If working alone, pause here and write down the one weekly workflow that costs you the most time. You will score it against RSTRM before the chapter ends.

### Speaker script
Tracy's Monday morning looks like this: Jira board open in one tab, Confluence project page in another, Slack project channel in a third, and two Google Meet transcript documents in a fourth. Two and a half hours later she has an executive status report and a set of detailed supporting notes. This chapter is about making that 2.5-hour grind a 20-minute review — not by removing Tracy from the equation, but by automating the part that does not require her professional judgment. By the end of this chapter, Tracy will have the vocabulary and the evaluation framework to decide, for any workflow, whether Claude Cowork can meaningfully reduce that cost.

---

## Slide S02 — Learning Outcomes

**Timing:** [explain: 2 min]
**Bloom:** Remember / Understand / Remember
**LO ref:** LO-01.1, LO-01.2, LO-01.3

### Cohort sidebar
- Ask the room: "On a scale of 1-5, how confident are you right now that you could identify a strong automation candidate in your own workflow?" Note the distribution — revisit it on slide 17.
- Likely misconception: LO-01.3 says "recognize" RSTRM, not "memorize." The framework exists precisely so Tracy does not have to rely on memory — it is a checklist, not a recall test.

### Solo sidebar
- If working alone, write a 1-5 confidence rating for each LO in your notebook now. Return to this page after slide 17 to see whether the numbers moved.

### Speaker script
Three learning outcomes anchor this chapter. LO-01.1 is about recognizing the right candidates — not every repetitive task is a good fit, and this chapter sharpens that judgment. LO-01.2 is about the building blocks: skills, plugins, and agents each have a specific role, and conflating them leads to architectures that are either over-engineered or under-powered. LO-01.3 introduces RSTRM — five criteria that give Tracy a structured scorecard rather than a gut feeling. All three LOs connect directly to her primary goal: building a reusable status report automation that reduces Monday-morning report prep from 2.5 hours to a 20-minute review.

---

## Slide S03 — Agenda

**Timing:** [click-through: 90 s]
**Bloom:** n/a (agenda slide)
**LO ref:** n/a

### Cohort sidebar
- Ask the room: "Which of these five sections do you expect to be the most useful for a task you are already thinking about automating?"
- No misconception to correct here — agenda slides are orientation, not instruction.

### Solo sidebar
- If working alone, scan the five sections and note which one you want to spend extra time on. Sections 3 and 4 (RSTRM framework and worked example) are the highest-leverage sections for immediate application.

### Speaker script
Five sections, roughly 50 minutes. Sections 1 through 3 are conceptual groundwork: what Claude Cowork can and cannot automate, the three building blocks, and the RSTRM scoring framework. Section 4 is where it all converges — Tracy applies every concept from sections 1 through 3 to her own Monday-morning status report workflow. Section 5 closes with the pitfalls that derail first automations and a retrieval prompt, so Tracy leaves with the concepts in active memory, not just short-term recall.

---

## Slide S04 — Vocabulary and Mental Model

**Timing:** [explain: 3 min]
**Bloom:** Remember (pre-training)
**LO ref:** LO-01.1, LO-01.2, LO-01.3

### Cohort sidebar
- Ask the room: "Has anyone encountered the word 'skill' or 'plugin' in the context of Claude or another AI tool? What did you understand it to mean?"
- Likely misconception: "skill" sounds like a capability Claude has natively — it may need explicit correction that a skill is a saved instruction set Tracy creates, not a factory-default feature.

### Solo sidebar
- If working alone, try writing a one-sentence definition of each of these four terms before reading the slides that expand on them. Compare your definitions to the worked example on slide 14.

### Speaker script
Four terms appear constantly throughout this course, and they mean specific things. A Claude skill is analogous to the standard operating procedures Tracy used to write for offshore teams at Nuance — step-by-step, unambiguous instructions that Claude reads and executes rather than a human. A plugin is the connector between Claude and an external system: it handles authentication and data retrieval for Jira, Confluence, Slack, or Gmail. An agent is an autonomous planner — it sequences skills and plugins across multiple steps and escalates to Tracy at the human-in-the-loop checkpoint when a decision requires her judgment. RSTRM is the evaluation framework that tells Tracy whether a given workflow is worth the investment of building an automation. These four terms are the vocabulary of every conversation in this course.

---

## Slide S05 — Concept: Automation Boundary

**Timing:** [explain: 3 min]
**Bloom:** Remember
**LO ref:** LO-01.1

### Cohort sidebar
- Ask the room: "What is an example from your own work where you do a task that feels formulaic but occasionally requires a judgment call? Where does the formulaic part end and the judgment begin?"
- Likely misconception: learners may believe "if Claude can do it 80% of the time, it should do it 100% of the time." Correct: the 20% that requires professional judgment is exactly what the human-in-the-loop checkpoint preserves. Removing the checkpoint is the pitfall, not the goal.

### Solo sidebar
- If working alone, write down one task you currently perform that belongs clearly in the left column (automatable) and one that belongs in the right (requires your judgment). Name the specific decision logic that separates them.

### Speaker script
The fundamental design principle of Claude Cowork automation is this: Claude extracts, aggregates, and formats — Tracy interprets, decides, and distributes. The left column on this slide is what Claude does reliably: pulling Jira closed tickets into a structured list, extracting change log entries from Confluence, compiling the past week's Slack messages. The right column is where Tracy's 15 years of program management experience lives: reading between the lines of a stakeholder's Slack message to decide whether it signals a real blocker or a passing concern. That distinction is not a limitation to engineer around — it is the design principle that makes these automations trustworthy.

---

## Slide S06 — Concept: Structured Inputs (with diagram)

**Timing:** [explain: 3 min | diagram: 1 min]
**Bloom:** Remember
**LO ref:** LO-01.1

### Cohort sidebar
- Ask the room: "Think about the sources you pull from for your most time-consuming report. Would you describe each source as 'structured,' 'pattern-based,' or 'unstructured'? Does anything surprise you about that classification?"
- Likely misconception: learners may assume "structured" means machine-readable (JSON, CSV). Clarify: structured in the RSTRM sense means consistently formatted and reliably extractable — Jira board exports, Confluence pages with a stable layout, and Google Meet transcripts all qualify, even though they are human-readable documents.

### Solo sidebar
- If working alone, draw this diagram for your own highest-priority workflow. Replace the four source boxes with your actual source systems and label each edge with its structure type: structured, pattern-based, or unstructured.

### Speaker script
The diagram on this slide is Tracy's status report workflow reduced to its essential structure. Four source systems feed one Claude skill, which produces a draft executive status report. Notice the 'pattern-based' label on the Slack channel arrow — Slack messages are not machine-formatted, but they follow consistent patterns. Stakeholders tend to say "blocked on" or "at risk" or "need a decision on" in recognizable ways. That consistency is sufficient for the RSTRM Structured criterion, as long as the edge cases — the ambiguous messages — are handled at the checkpoint. The key insight from this diagram: if any one of these four source systems produces inconsistent or unpredictably formatted data, the skill's output will be inconsistent in the same way.

---

## Slide S07 — Concept: Claude Skill

**Timing:** [explain: 3 min]
**Bloom:** Understand
**LO ref:** LO-01.2

### Cohort sidebar
- Ask the room: "Has anyone written a standard operating procedure — or a set of instructions detailed enough that someone unfamiliar with the task could follow them without asking questions? What made those instructions good or bad?"
- Likely misconception: learners often assume a skill is a prompt they type once. Correct: a skill is a saved, reusable instruction set — it is invoked by name or trigger, not retyped. The reusability is the value.

### Solo sidebar
- If working alone, think about the most detailed set of instructions you have ever written for a recurring process. Would those instructions, as written, be sufficient for Claude to produce the right output every time? What would you need to add?

### Speaker script
When Tracy wrote SOPs for offshore annotation teams at Nuance, she learned that ambiguity in instructions produces inconsistency in outputs. A Claude skill is that same discipline applied to automation. It encodes three things: what inputs to expect — in this case, Jira closed ticket data, the Confluence change log, a Slack channel summary, and two transcript excerpts — what format to produce — a five-section executive summary and a detailed supporting notes document — and what constraints to apply, for example, never include a ticket in the Accomplishments section if it was only partially closed. The critical distinction on this slide is the third row: a skill cannot independently reach into Jira or Confluence. It needs a plugin to retrieve that live data. The skill transforms inputs into outputs — it does not gather the inputs.

---

## Slide S08 — Concept: Plugin

**Timing:** [explain: 3 min]
**Bloom:** Understand
**LO ref:** LO-01.2

### Cohort sidebar
- Ask the room: "What external systems do you currently access every week for a recurring report? If you had to grant a junior analyst read-only access to each of those systems — scoped to just the fields you need — would you feel comfortable doing that?"
- Likely misconception: learners may conflate a plugin with a Zapier integration or a native Jira connector. Clarify: a Claude plugin is specifically a connector that gives Claude Cowork access to the system's data within a session, under explicit authorization that Tracy controls.

### Solo sidebar
- If working alone, list the external systems your highest-priority workflow touches. For each, note whether you would grant read-only plugin access, read-write access, or neither — and write one sentence explaining why for any system you would not connect.

### Speaker script
A plugin is the authorization layer between Claude Cowork and Tracy's business systems. The Jira plugin queries closed tickets, blocked items, and sprint status. The Confluence plugin reads project pages and decision logs. The Slack plugin reads the past week of messages from the project channel. The Gmail plugin reads inbox messages and, after Tracy's explicit approval, applies labels. Every plugin requires deliberate authorization — Tracy decides which systems Claude can access, to what depth, and in which direction. The revocation point matters: if Tracy disconnects the Jira plugin, Claude loses access immediately. That auditability and reversibility is what makes plugin architecture appropriate for a professional program management context where data access boundaries matter.

---

## Slide S09 — Concept: Agent (with diagram)

**Timing:** [explain: 4 min | diagram: 2 min]
**Bloom:** Understand
**LO ref:** LO-01.2

### Cohort sidebar
- Ask the room: "Looking at this diagram — where would you be most nervous about removing the human-in-the-loop checkpoint? What could go wrong if the report were distributed without Tracy reviewing it?"
- Likely misconception: learners may think the agent makes autonomous decisions throughout — including whether to send the report. Correct explicitly: the agent plans and executes the retrieval and synthesis steps autonomously; the distribution decision is always Tracy's.

### Solo sidebar
- If working alone, trace the arrows in this diagram and narrate what is happening at each step. If you can narrate the whole diagram without looking at the slide text, you have internalized the architecture.

### Speaker script
This diagram is the complete architecture Tracy will build across Chapters 6, 8, and 11 — shown here as a mental model. The agent at the top is the orchestrator: it does not retrieve data or synthesize text itself. It invokes the four plugins in sequence — Jira, Confluence, Slack, Google Meet — each returning its data to the Status Report skill. The skill synthesizes the executive summary and detailed supporting notes. Then the agent pauses. It does not distribute the report. It delivers a draft to Tracy at the human-in-the-loop checkpoint. Tracy reads, edits if necessary, and approves. Only then does the report reach leadership. The loop-back arrow — Tracy edits, the skill re-runs — is intentional. Chapter 7 will teach Tracy how to evaluate the draft systematically so that the edit-rerun loop tightens over time.

---

## Slide S10 — Retrieval: Three Building Blocks

**Timing:** [pause: 90 s | discuss: 2 min]
**Bloom:** Remember
**LO ref:** LO-01.2

### Cohort sidebar
- Give learners genuine silence — 60 to 90 seconds — before asking anyone to share. The retrieval effect requires the attempt, not just the answer.
- Ask two volunteers: "What did you write for each? Where did your definition differ from the formal definition?" The most common conflation: plugin described as "what the skill does" rather than "what retrieves the data."
- Correct by asking: "Can a skill reach into Jira without a plugin?" (No.) "What does?" (The plugin.) That single question clarifies the distinction faster than any explanation.

### Solo sidebar
- If working alone, write three sentences — one per building block — before scrolling to the next slide. Do not look back at slides 7-9. Commit to the attempt.

### Speaker script
This is a deliberate pause. The three definitions you have just encountered — skill, plugin, agent — are the vocabulary of every chapter in this course. The goal of this slide is not to test whether Tracy memorized them; it is to give her the experience of retrieving them under mild pressure, which is what makes retrieval practice effective. Answer key for the facilitator: a skill is a reusable instruction set that transforms inputs into a formatted output. A plugin is a connector that retrieves data from or writes data to an external system under explicit authorization. An agent is an autonomous planner that sequences skills and plugins, halting at human-in-the-loop checkpoints for decisions that require Tracy's judgment.

---

## Slide S11 — Concept: RSTRM Table (with diagram)

**Timing:** [explain: 4 min | diagram: 1 min]
**Bloom:** Remember
**LO ref:** LO-01.3

### Cohort sidebar
- Ask the room: "Before we score Tracy's workflow — which of these five criteria do you expect to be the hardest to satisfy for a typical program management task? Which is the easiest?"
- Likely misconception: some learners interpret "all five Strong" as the only path to automation. Correct: the framework uses Strong / Partial / Weak. Two or more Weak ratings is a signal to redesign the scope, not an absolute prohibition on automation.

### Solo sidebar
- If working alone, read the five criteria aloud — say the letter and the word — then close the slide and write them from memory. This exercise takes 90 seconds and significantly improves retention.

### Speaker script
Tracy already uses structured evaluation frameworks in her program management work — risk matrices, readiness assessments, milestone scorecards. RSTRM is the same genre of tool, applied to automation decisions. Each criterion asks a specific question: Repetitive — does this task run on a predictable schedule or trigger? Structured — are the inputs and outputs in a consistent, extractable format? Time-consuming — are there enough hours at stake to justify the investment? Rules-based — can the decision logic be written down without ambiguity? Multi-step — does the task span multiple systems and sequential actions? Strong ratings on all five indicate a high-confidence automation candidate. Partial ratings indicate the scope needs adjustment. Two or more Weak ratings indicate the task should be redesigned or deferred — not forced into an automation it is not ready for.

---

## Slide S12 — Concept: RSTRM Diagnostics R, S, T

**Timing:** [explain: 3 min]
**Bloom:** Remember
**LO ref:** LO-01.3

### Cohort sidebar
- Ask the room: "For the T criterion — how many hours per year does your most time-consuming recurring report cost? Has anyone actually calculated that number before?"
- Likely misconception: learners may underestimate their own time cost by thinking in minutes per instance rather than hours per year. The annualized calculation — instances per year times minutes per instance divided by 60 — is almost always more motivating than the per-instance figure.

### Solo sidebar
- If working alone, apply these three diagnostic questions to the workflow you identified on slide 1. Write your ratings (Strong / Partial / Weak) and justifications in your notebook. You will complete the full scorecard in Exercise 02.

### Speaker script
Three of the five RSTRM criteria have clear, two-minute diagnostic questions. For Repetitive: Tracy's status report runs every Monday for both programs — 50 weeks per year, approximately 100 instances annually. That is as Repetitive as a workflow gets. For Structured: Jira exports a ticket list in a consistent format; Confluence pages have had a stable layout for eight months; Google Meet transcripts follow a predictable format. The Structured rating is Strong. For Time-consuming: two and a half hours per report, two programs, 50 weeks — that is 250 hours per year. Even at 60 percent automation success, Tracy recovers 150 hours annually. The 250-hour figure is the business case for building this automation. Name it explicitly; it tends to shift the conversation from "is this worth trying" to "why haven't we done this already."

---

## Slide S13 — Concept: RSTRM Diagnostics R (Rules-based), M (Multi-step)

**Timing:** [explain: 3 min]
**Bloom:** Remember
**LO ref:** LO-01.3

### Cohort sidebar
- Ask the room: "For the Rules-based criterion — can you articulate, in writing, the decision rule that separates what belongs in the 'Accomplishments' section of a status report from what belongs in 'Risks'? If you had to document that rule today, how long would it take?"
- Likely misconception: learners may assume that because Slack messages are free-text, the Rules-based criterion is Partial. Correct: "rules-based" at the RSTRM level means the extraction logic is articulable and consistent — even if individual messages require first-pass classification by Claude and final judgment by Tracy at the checkpoint.

### Solo sidebar
- If working alone, write the decision rule for one section of your own recurring report — the rule that determines what content belongs in that section. If you cannot write it in two sentences, it may be a Partial on the Rules-based criterion.

### Speaker script
Rules-based is the criterion that brings professional judgment most directly into the picture. For Tracy's status report, the classification rules are articulable: a Jira ticket is an Accomplishment if its status changed to Done in the past week; it is a Risk if its status is Blocked and no resolution is documented. A Confluence entry is a Decision if it is in the decision log section. A Slack message is flagged for first-pass classification by Claude — potential blocker, potential action item, or noise — with Tracy's validation at the checkpoint. The rule is articulable even for the ambiguous cases, because the rule is "Claude classifies; Tracy validates." Multi-step confirms the architecture: six discrete steps across four systems is agent scope. A single skill without orchestration cannot manage sequential retrieval and synthesis across multiple plugins.

---

## Slide S14 — Worked Example: Tracy Scores Her Status Report Workflow

**Timing:** [explain: 6 min | diagram: 2 min]
**Bloom:** Apply
**LO ref:** LO-01.1

### Cohort sidebar
- Ask the room: "Looking at the Before column — which of those five manual steps do you find most tedious in your own equivalent workflow? Which do you think Claude Cowork will handle most reliably?"
- Likely misconception: learners may assume the After column shows zero human involvement. Correct explicitly: Tracy's 20-minute review is not an afterthought — it is the design feature that makes this automation trustworthy. The time savings come from eliminating data-gathering and synthesis labor, not from removing Tracy from the approval chain.

### Solo sidebar
- If working alone, compare the Before and After columns step by step. For each step where "Tracy reads" becomes "Agent reads," write down what information Tracy was previously responsible for extracting — and confirm that the corresponding plugin captures the same information.

### Speaker script
This worked example applies every concept from this chapter to Tracy's actual Monday-morning situation. The Before column is her current workflow: five sequential manual steps that consume two and a half hours. The After column is the automation: the same five information-gathering steps executed by the agent through plugins, followed by the skill's synthesis, followed by Tracy's 20-minute review. The RSTRM scorecard result — all five criteria rated Strong — is the green light. Three numbers are worth naming explicitly: 250 hours per year recoverable, six discrete steps confirming agent scope, and eight months of template stability confirming the Structured criterion. One decision point from the analysis deserves specific attention: stakeholder Slack message classification stays with Tracy at the checkpoint. Claude performs a first-pass classification — potential blocker, potential action item, potential noise — that Tracy validates. This is the Rules-based criterion applied to its most ambiguous input, and it works precisely because the rules are articulable, not because they are automatic.

---

## Slide S15 — Try This Now

**Timing:** [practice: 15-23 min]
**Bloom:** Apply
**LO ref:** LO-01.1

### Cohort sidebar
- In cohort mode: run Exercise 02 as a paired or small-group activity. Ask each pair to compare their ratings — differences in rating are more interesting than agreements, because they surface assumptions about what "structured" or "rules-based" means in each person's context.
- After 15 minutes: ask one group to share a criterion where they rated Partial rather than Strong. What would need to change to move that rating to Strong?

### Solo sidebar
- If working alone: open exercise-02/email-triage-rstrm.md. Complete the five-criterion table for Tracy's email inbox triage scenario before moving to Exercise 03. Do not look at the solution file until you have committed your own ratings.

### Speaker script
Exercise 02 applies the RSTRM scorecard to Tracy's email inbox triage workflow — a scenario she named explicitly as a pain point in the course intake. The starter file in exercise-02/ contains the five-criterion table pre-populated with the scenario context; Tracy's task is to provide the ratings and justifications. Exercise 03 is an independent exercise that asks Tracy to apply the same scorecard to a workflow she selects from her own program — any workflow she has been thinking about automating but has not yet evaluated systematically. Both exercises use the RSTRM scorecard format from the worked example on slide 14. The solution files are available in each exercise's solution/ folder, but the retrieval effect requires the attempt before the reveal.

---

## Slide S16 — Common Pitfalls

**Timing:** [explain: 4 min]
**Bloom:** Remember
**LO ref:** LO-01.1

### Cohort sidebar
- Ask the room: "Which of these three pitfalls do you think is most common for someone building their first Claude Cowork automation? Has anyone encountered any of these in a previous automation project — with any tool?"
- Likely misconception for Pitfall 1: learners may assume they should fix the template by automating it. Correct: standardize the template manually first, through two or three cycles of use, before encoding it in a skill. Automation cannot stabilize an unstable template; it amplifies the instability.

### Solo sidebar
- If working alone, for each pitfall write one sentence describing the diagnostic sign that would tell you this pitfall has occurred in your own automation — before reading the diagnostic line on the slide. Then compare.

### Speaker script
Three failure modes, each grounded in Tracy's own scenario. Pitfall one: automating an inconsistent output template. If the executive summary template changes monthly — different sections added or removed depending on the audience — the skill will produce a different structure monthly, because the skill encodes the template. Fix the template before building the skill; use it manually for two or three report cycles to confirm it is stable. Pitfall two: removing the human-in-the-loop checkpoint. A status report reaching leadership with a factual error or a misclassified blocker damages Tracy's credibility. The automation cannot assess its own accuracy against her professional judgment — that is the purpose of the review step. Pitfall three: over-engineering the first automation. Pulling Jira closed tickets into a list is a plugin invocation, not an agent. The instinct to build the full six-step agent on the first attempt leads to a system that is difficult to debug when something goes wrong. Start with the simplest combination that accomplishes one step; add complexity in subsequent chapters.

---

## Slide S17 — Recap (Retrieval Cue)

**Timing:** [pause: 2 min | discuss: 3 min]
**Bloom:** Remember
**LO ref:** LO-01.1, LO-01.2, LO-01.3

### Cohort sidebar
- In cohort mode: have learners write answers to all three questions before any discussion begins. Then cold-call two or three participants — not volunteers — to share their answers. The mild social pressure of cold-calling significantly increases retrieval effort.
- After answers: return to the confidence ratings from slide 2. Ask: "Did any of your ratings change? Which LO moved the most — and what caused that shift?"

### Solo sidebar
- If working alone: write your answers to all three questions before clicking through to the quiz. Resist the urge to scroll back through the slides. The retrieval attempt — even an imperfect one — is the learning event.

### Speaker script
Answer key. Question one: automatable PM tasks have articulable, consistent decision rules — rules that can be written down without ambiguity. Judgment-required tasks involve professional interpretation of ambiguous signals, where the classification depends on context that Claude cannot reliably access. Question two: a Claude skill is the Status Report Aggregation skill — it takes the data retrieved from the four plugins and transforms it into a formatted executive summary and supporting notes document. A Claude plugin is the Jira plugin — it authenticates to Jira, queries closed and blocked tickets from the past week, and returns structured data to the skill. Question three: Repetitive — Strong, runs every Monday for both programs. Structured — Strong, all four source systems produce consistently extractable data. Time-consuming — Strong, 250 hours per year recoverable. Rules-based — Strong, classification rules for each source are articulable; Slack edge cases validated at checkpoint. Multi-step — Strong, six discrete steps across four systems confirms agent scope.

---

## Slide S18 — Quiz Cue / Next Up

**Timing:** [click-through: 60 s]
**Bloom:** n/a
**LO ref:** n/a

### Cohort sidebar
- Direct learners to the quiz file. Remind the group that the quiz uses Tracy's status report workflow as the primary scenario — the same scenario they have been working with throughout this chapter.
- Mention Form B for learners who want a second attempt: different scenario (email inbox triage), same LOs.

### Solo sidebar
- If working alone: open the quiz.json file now. Attempt Form A before looking at any solutions. Attempt Form B after a gap of at least 24 hours for spaced practice — the scenario differences between Form A and Form B test transfer, not repetition.

### Speaker script
The quiz file — cowork-automation-tracy-2026--ch01--intro-cowork-automation--quiz.json — contains questions that apply the three LOs from this chapter to Tracy's status report scenario. Form B uses her email inbox triage scenario to test the same LOs in a different context; it is most effective when attempted a day after Form A, leveraging spaced practice. Chapter 2 picks up where this chapter leaves off: Tracy takes a raw Google Meet stand-up transcript — the most free-form of her four source systems — and maps every manual step she currently performs to extract decisions and action items. The chapter then systematically replaces each manual step with a Claude Cowork component, building the automation mindset that underlies every chapter that follows.
