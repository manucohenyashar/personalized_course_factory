# Course Specification: Automate Your Work with Claude Cowork
<!-- COURSE SPEC v1.1 — for use with Claude Code course generator -->

## Metadata

| Field | Value |
|---|---|
| Title | Automate Your Work with Claude Cowork |
| Subtitle | A practical course for knowledge workers — no code required |
| Version | 1.1 |
| Total Duration | 3.5 hours |
| Format | Instructor-led, hands-on labs |
| Prerequisites | Basic familiarity with AI chat interfaces. No programming experience required. |
| Audience | Business professionals, analysts, project managers, operations, marketing, HR, customer success, sales operations, product managers |

---

## Course Philosophy

This course is built on one rule: **do first, understand second.**

Every concept is introduced through a real task. Theory is introduced only when it directly helps the learner do the task better. Learners should spend more than 60% of each chapter with their hands on the keyboard.

### Design Principles

| Principle | Description |
|---|---|
| Do first, understand second | Every concept is introduced through a real task, not a lecture |
| One deliverable per chapter | Each chapter ends with a working artifact the learner keeps and reuses |
| Real work, real workflows | All exercises use business scenarios: reports, emails, research, CRM updates |
| Human always in control | Every automation includes a review or approval step — no blind execution |
| Minimum viable theory | Only enough explanation to operate effectively — no architecture deep dives |

### What This Course Emphasizes

1. **Reusable skills** — the biggest productivity multiplier
2. **Context management** — the biggest reliability factor
3. **Human-in-the-loop workflows** — the biggest safety factor
4. **Plugins and MCP tool connections** — the biggest business impact area
5. **Practical evaluation** — the biggest quality differentiator

### What This Course Intentionally Avoids

- Software engineering concepts
- Protocol internals and low-level implementation
- Complex infrastructure and deployment architecture
- Heavy programming
- Enterprise platform engineering theory

---

## Learning Outcomes

By the end of this course, learners will be able to:

- Automate repetitive knowledge work using Claude Cowork
- Create, test, and refine reusable skills
- Develop and deploy custom plugins
- Import and safely adapt community skills and plugins
- Connect Claude to real business tools using MCP connectors
- Build simple agent workflows with human approval checkpoints
- Set up recurring automations for daily and weekly workflows
- Manage context effectively to improve reliability and output quality
- Compact and reset sessions without losing important context
- Evaluate automation quality and fix common failures
- Build a personal automation portfolio worth 2–4 hours per week in time savings

---

## Chapter Format (applies to every chapter)

Every chapter follows this five-beat structure:

| Beat | Name | Description | Duration |
|---|---|---|---|
| 1 | Hook | The real workplace problem this solves | 2 min |
| 2 | Demo | Instructor runs the full workflow live | 5 min |
| 3 | Your turn | Learner does the same task independently | 10–15 min |
| 4 | Watch out | 2–3 common mistakes and how to spot them | 3 min |
| 5 | Keep it | One deliverable saved to the learner's portfolio | — |

---

## Course Structure


#### Chapter 1 — What Cowork Can Do For You. Workspace organization, and Claude.md

**Duration:** 20 minutes

**Hook:** Most knowledge workers spend 30–40% of their time on work that follows a repeatable pattern — summarizing, drafting, researching, formatting. This chapter shows that Claude Cowork can handle most of it.

**Concepts covered:**
- What Claude Cowork is and how it differs from chat
- The automation landscape: skills, plugins, agents, orchestrations — defined in plain language
- What types of work can and cannot be reliably automated
- Human-in-the-loop as a design principle, not an afterthought
- Workspace organization: folder structure, naming conventions for skills and outputs
- Session management: what persists, what doesn't, and why it matters
- Saving and reusing prompts
- What CLAUDE.MD is and why it is the most important file you will create today

**Demo:** Instructor runs three live workflows back-to-back:
1. Meeting notes → structured summary with action items
2. Raw data → formatted weekly status report
3. Customer request → draft response email

**Exercise:** Learner picks one of the three workflows and runs it with their own input material.

**Common mistakes:**
- Expecting Claude to know context it was never given
- Treating the first output as final — automation is a draft, not a decision
- Automating something that varies too much to be repeatable

**Deliverable:** Personal automation opportunity list — learner identifies 5 repetitive tasks in their own work that could be automated


#### Chapter 2 — Creating Skills from Scratch and the Skill Creator Tool

**Duration:** 35 minutes

**Hook:** A skill is a reusable instruction set that turns a task you do manually into something Claude can do reliably on demand. You write it once; you use it forever.

**Concepts covered:**
- What a skill is and how it differs from a one-off prompt
- When to create a skill vs. when a prompt is enough
- Skill anatomy: task definition, input format, output format, constraints, examples
- The skill lifecycle: write → test → refine → use → improve
- Writing useful operational guidance: tone rules, output format standards, business preferences, communication style
- How to write a skill specification that the Skill Creator can work from
- From a long conversation with a chat agent to a reusable skill through a specification    
- Using the Skill Creator to generate a skill
- Reviewing generated skills: what to check, what to change
- Iterating quickly: one refinement loop, not five

**Demo:** Instructor builds a meeting summarizer skill from scratch, including one round of refinement after a bad output.

**Exercise:** Learner builds the same meeting summarizer using their own meeting notes.

**Common mistakes:**
- Skills that are too broad ("help me with emails")
- Missing output format specification — Claude will guess, and guess inconsistently
- Not testing with edge cases (empty input, very short input, unusual formatting)
- Accepting the generated skill without reviewing it
- Specification that is too vague — garbage in, garbage out
- Over-editing on the first pass — get it to 80%, then use it, then refine

**Deliverable:** Your first working skill


#### Chapter 3 — Evaluating Skill Quality

**Duration:** 15 minutes

**Hook:** An automation you cannot trust is worse than no automation — it creates rework and erodes confidence. This chapter gives you a simple method for knowing whether your skill is reliable.

**Concepts covered:**
- Why evaluation matters more than the initial output
- The five evaluation questions: Was it accurate? Was it complete? Was it formatted correctly? Was it useful? Was anything fabricated or risky?
- Consistency checking: run the same input twice and compare
- Spotting hallucinations in business outputs
- When to iterate vs. when to accept

**Demo:** Instructor runs the meeting summarizer against three different inputs and grades each output using the rubric.

**Exercise:** Learner evaluates their own skill using three test inputs they bring from their real work.

**Common mistakes:**
- Only testing with one input
- Grading on effort ("it tried") rather than output quality
- Not checking the output against the source material

**Deliverable:** Skill evaluation rubric and results for both skills built in this module


#### Chapter 4 — Giving Claude the Right Context, Session Management and Compacting Context

**Duration:** 20 minutes

**Hook:** The most common reason automations fail is not the skill — it is missing or bad context. Claude can only work with what it is given.

**Concepts covered:**
- Why context is the biggest reliability variable
- What belongs in context: reference documents, examples, constraints, role framing
- What does not belong in context: everything irrelevant (it degrades performance)
- Structured inputs: how formatting your input improves your output
- Reusable reference documents: create once, attach to every relevant task
- How context windows work in plain language: tokens, limits, and what happens when you approach them
- Signs your session needs compacting: degrading output quality, repetition, confusion about earlier instructions
- How to compact a session: summarize what matters, discard what does not, restart clean
- When to start a new session vs. continue the current one
- Saving and compacting a session summary so you can resume exactly where you left off

**Demo:** Instructor runs the same skill with poor context (generic input) and rich context (reference doc + structured input) and shows the difference in output quality.

**Exercise:** Learner selects one of their skills and creates a reusable reference document (one page of domain context) that improves its output.

**Common mistakes:**
- Dumping everything into context and hoping Claude figures it out
- Assuming Claude remembers anything from a previous session
- Using the same long conversation for many different tasks
- Waiting until the session is fully broken before compacting
- Compacting without saving the summary — losing context you needed
- Starting a new session without carrying forward the reference documents

**Deliverable:** Context management checklist + one reusable reference document

#### Chapter 5 — Connecting Claude to Your Tools with MCP

**Duration:** 20 minutes

**Hook:** Claude becomes dramatically more useful when it can read from and write to the tools you already use — your calendar, CRM, email, Slack, Notion, or task manager. MCP connectors are how that connection works.

**Concepts covered:**
- What MCP connectors are in plain language: Claude's hands into other systems
- The difference between reading and writing through a connector — and why that distinction matters for trust
- Available connectors: Google Workspace, Slack, Notion, HubSpot, Jira, Asana, and others
- How to connect a tool: step-by-step for at least one connector
- Running a real task through a live connection


**Demo:** Instructor connects to Google Workspace and runs a task: pull this week's calendar, identify back-to-back meetings, and draft a summary to share with the team.

**Exercise:** Each learner connects one tool from their own stack and runs a read task through it.

**Common mistakes:**
- Connecting a tool without understanding what Claude can write back to it
- Not testing read before attempting write
- Connecting tools you do not actually use — start with one you use daily

**Deliverable:** Business tool integration map — which tools are connected, what Claude can read, what Claude can write. 


#### Chapter 6 — Importing and Adapting Community Plugins and Skills. Developing and Deploying Custom Plugins

**Duration:** 15 minutes

**Hook:** The Anthropic community has already built skills and plugins for most common business workflows. Importing one takes minutes. The risk is importing something you have not reviewed.

**Concepts covered:**
- What a plugin is and how it differs from an MCP connector
- Plugin anatomy: name, description, tool definitions, input/output schema
- Writing a plugin specification: what Claude needs to know to use the tool correctly
- Using the Plugin Creator tool to generate a first draft
- Deploying a plugin locally for personal use
- Sharing a plugin within a team
- Where to find community skills and plugins: Anthropic repositories, GitHub
- The import workflow: find, review, test, adapt, use
- What to check before importing: what does this skill do? What data does it touch? What can it write?
- Adapting imported skills to your context: tone, format, domain vocabulary
- Trust levels: known source vs. unknown source

**Demo:** Instructor imports a community competitive intelligence skill, reviews it line by line, makes two adjustments, and runs it.

**Exercise:** Learner imports one community skill relevant to their work, reviews it, makes at least one adaptation, and tests it.

**Common mistakes:**
- Importing and running without reading the skill instructions first
- Assuming community skills are production-ready — they are starting points
- Not checking whether the skill has write access to any external system

**Deliverable:** One working custom plugin, deployed and tested, Safe import checklist + one imported and adapted skill


#### Chapter 7 — Practical Agents for Business Work

**Duration:** 20 minutes

**Hook:** An agent is Claude running a multi-step task autonomously — planning, executing, checking, and adjusting — without you driving every step. This chapter shows what that looks like in a real business context, and what its limits are.

**Concepts covered:**
- What an agent is in plain language: a workflow, not a robot
- Types of agents useful in business: research agents, preparation agents, follow-up agents, synthesis agents
- How agents plan and execute: the loop in plain language
- Agent limitations: when to use one, when not to
- Designing your first agent: start with a task you already do in 3+ manual steps

**Demo:** Instructor builds a weekly business review agent — pulls data from three sources, synthesizes a summary, drafts a report, flags items for human review.

**Exercise:** Learner designs and runs a simple agent for a recurring task in their own work (research brief, meeting prep, status report).

**Common mistakes:**
- Agents that are too broad and lose coherence across steps
- Not including a checkpoint — letting Claude make decisions it should not make alone
- Expecting agents to work perfectly on the first run — they need iteration

**Deliverable:** Personal business agent, running end-to-end

---

#### Chapter 8 — Recurring Automations and Scheduled Work

**Duration:** 15 minutes

**Hook:** The real productivity gain from automation is not running a task once — it is setting it up to run on its own, every day or every week, without you touching it.

**Concepts covered:**
- Scheduled automations: daily summaries, weekly KPI reports, competitive monitoring
- Triggered workflows: automation that runs when a condition is met (new email, calendar event, CRM update)
- Loops and iteration: processing a list of items one by one
- Managing scheduled automation outputs: where they go, how to review them

**Demo:** Instructor sets up a daily email digest automation — runs every morning, summarizes overnight emails by category, flags anything requiring action.

**Exercise:** Learner sets up one recurring automation relevant to their work.

**Common mistakes:**
- Scheduled automations that fail silently — always include an output you can check
- Not accounting for variability in input format over time
- Automations that write without a review step

**Deliverable:** One scheduled or triggered automation, running

---

#### Chapter 9 — Human-in-the-Loop: Approval and Escalation Patterns

**Duration:** 20 minutes

**Hook:** Automation without oversight is risk. Every automation that touches something real — sends an email, updates a record, publishes content — should have a human checkpoint before it does the irreversible thing.

**Concepts covered:**
- Why human-in-the-loop is not optional — it is a design principle
- Approval before action: how to build a "show me before you send" step
- Clarification when input is ambiguous: how to teach Claude to ask instead of guess
- Escalation patterns: what happens when Claude is uncertain
- Stopping unsafe or unexpected actions before they execute

**Demo:** Instructor adds an approval checkpoint to the agent built in Chapter 11 — Claude drafts the report, presents it for review, and waits for explicit sign-off before sending.

**Exercise:** Learner adds a human checkpoint to one of their own automations from this course.

**Common mistakes:**
- Approval steps that are too generic — "does this look right?" is not a useful checkpoint
- Bypassing the checkpoint "just this once" — consistency is what makes it safe
- Not defining what escalation looks like in practice

**Deliverable:** Agent with human approval gate, working end-to-end



## Demonstration Strategy

All demonstrations must use:
- Real business workflows with realistic input data
- Cross-functional examples (not only one industry or role)
- Low technical complexity — no code shown unless unavoidable
- Live, unscripted execution — show real behavior, including imperfect first outputs

Recommended demonstration scenarios across the course:
- Executive assistant workflows
- Competitive intelligence briefs
- Meeting preparation and follow-up
- Customer communication drafts
- Sales operations and CRM updates
- Research synthesis and literature review
- Weekly KPI and status reporting
- HR onboarding communication
- Marketing campaign coordination
- Document processing and summarization

---

## Assessment and Success Metrics

A learner has succeeded when they can:

- [ ] Run a complete automation end-to-end without instructor help
- [ ] Build a new skill from a one-sentence task description
- [ ] Connect Claude to one real tool in their stack
- [ ] Build or import a plugin and deploy it
- [ ] Add a human approval step to any automation
- [ ] Debug a failing automation using the five-root-cause method
- [ ] Compact a stale session and resume with clean context
- [ ] Explain to a colleague what they automated and why it is safe

Outcome target: Every learner saves at least 2 hours per week within 30 days of completing this course.

---

## Portfolio Artifacts

Every learner should graduate with the following artifacts in their personal automation portfolio:

| Artifact | Built In |
|---|---|
| Personal CLAUDE.MD | Module 1 |
| Meeting summarizer skill | Module 2 |
| Second skill of choice | Module 2 |
| Skill evaluation rubric + results | Module 2 |
| Context management checklist | Module 3 |
| Session management protocol | Module 3 |
| Business tool integration map | Module 4 |
| Custom plugin | Module 4 |
| Safe import checklist + imported skill | Module 4 |
| Business agent with approval gate | Module 5 |
| Scheduled automation | Module 5 |
| Troubleshooting checklist | Module 6 |
| 30-day automation roadmap | Module 6 |

---

## Excluded Topics (Out of Scope)

The following topics are intentionally excluded to keep the course practical and within the time budget:

- MCP protocol internals and transport layer details
- Plugin server hosting and infrastructure deployment at scale
- Advanced distributed agent architectures
- LLM fine-tuning and model selection
- Enterprise SSO and identity management for tool connectors
- API rate limiting and production reliability engineering
- Multi-tenant plugin deployment
- Custom MCP server development from scratch (beyond the plugin spec)
