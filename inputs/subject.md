# Claude Cowork Automation for Knowledge Workers
## Practical Automation Curriculum Specification

Version: 1.1
Chapters: 16
Delivery: 30–50 minutes per chapter

Audience:
- Business professionals
- Analysts
- Project managers
- Operations teams
- Customer success teams
- Marketing professionals
- HR professionals
- Product managers
- Sales operations
- Technical-but-not-developer users
- General knowledge workers

Prerequisites:
- Comfortable using modern software tools
- Basic familiarity with AI chat interfaces
- No programming experience required
- No software engineering background required

Course Goal:
Enable business and knowledge workers to safely and effectively automate significant portions of their daily work using Claude Cowork tools, skills, plugins, agents, orchestrations, and integrations — without requiring deep software engineering knowledge.

Primary Philosophy:
This course prioritizes:
- Practical business automation
- Real workplace productivity
- Human-in-the-loop workflows
- Reliable and safe automations
- Reusable skills
- Low-code/no-code approaches
- Operational confidence
- Fast wins with high impact

This course intentionally avoids:
- Deep software engineering
- Complex architecture theory
- Advanced infrastructure
- Heavy programming
- Internal implementation details
- Enterprise platform engineering

---

# COURSE STRUCTURE

## Total Chapters
16

## Recommended Delivery
- 30–50 minutes per chapter
- Short hands-on exercises
- Business-focused demonstrations
- Real workplace workflows
- Progressive automation portfolio

## Learning Outcomes

By the end of this course learners will be able to:

- Automate repetitive knowledge work
- Create reusable Claude skills
- Use plugins and MCP tools safely
- Build simple agent workflows
- Use orchestrations and scheduled work
- Automate browser tasks and SaaS workflows
- Manage Claude context effectively
- Use Claude CLI at a practical level
- Evaluate automation quality
- Safely import and adapt community skills/plugins
- Create reliable personal productivity systems

---

# COURSE DESIGN PRINCIPLES

## Teach Only What Is Operationally Necessary

The course teaches:
- What users need to operate effectively
- Common patterns
- High-value workflows
- Practical troubleshooting

The course does NOT teach:
- Deep protocol internals
- Low-level engineering
- Infrastructure implementation
- Advanced distributed systems concepts

---

# PART 1 — FOUNDATIONS

# Chapter 1 — Introduction to Claude Cowork Automation

## Objectives
- Identify what Claude Cowork can and cannot automate in a knowledge-work context
- Distinguish between skills, plugins, and agents at a conceptual level
- Recognize the types of business tasks suited to AI automation

## Topics
- What Claude Cowork is
- What automation means in a knowledge-work context
- Skills vs. plugins vs. agents (conceptual overview)
- Human-in-the-loop workflows
- What types of work can be automated
- Real business examples
- Limitations of AI automation
- Safe usage principles

## Business Examples
- Meeting preparation
- Research automation
- Email drafting
- CRM updates
- Reporting
- Document summarization
- Browser workflows
- Data gathering

## Deliverables
- Personal automation opportunity list

---

# Chapter 2 — The Automation Mindset

## Objectives
- Apply a structured framework to identify automation-suitable tasks in your own workflow
- Distinguish between tasks that benefit from automation and tasks that require human judgment
- Decompose a multi-step workplace process into automation-ready units

## Topics
- Identifying repetitive work
- Automation-friendly tasks
- Human review checkpoints
- Breaking work into steps
- Choosing the right automation approach
- When NOT to automate
- Building reliable workflows

## Key Framework
- Repetitive
- Structured
- Time-consuming
- Rules-based
- Multi-step

## Deliverables
- Personal workflow decomposition worksheet

---

# Chapter 3 — Setting Up Claude for Daily Work

## Objectives
- Configure a personal Claude workspace for daily professional use
- Demonstrate basic CLI usage for running and managing automations
- Organize automation outputs and session artifacts for reuse

## Topics
- Workspace organization
- File handling
- Session management
- Saving useful prompts
- Organizing automation assets
- Basic CLI usage
- Running automations
- Managing outputs

## Important Topics
- Sessions
- Context persistence
- Compact sessions
- Summaries

## Deliverables
- Personal Claude workspace setup

---

# PART 2 — PRACTICAL CONTEXT MANAGEMENT

# Chapter 4 — Context Management for Better Results

## Objectives
- Explain why context quality directly affects automation reliability
- Apply context organization strategies to reduce errors and improve consistency
- Design reusable reference documents for recurring workflows

## Topics
- Why context matters
- Giving Claude the right information
- Reference documents
- Avoiding overloaded conversations
- Reusing context
- Context organization
- Summarization workflows
- Compact sessions

## Best Practices
- Small focused tasks
- Clear instructions
- Reusable reference material
- Structured inputs

## Deliverables
- Context management checklist

---

# Chapter 5 — CLAUDE.MD for Business Users

## Objectives
- Construct a personal or team CLAUDE.MD file that encodes reusable behavioral preferences
- Apply persistent instructions to standardize tone, format, and output conventions
- Load and use context files and memory files (project.md, persona.md) within sessions to extend persistent guidance

## Topics
- What CLAUDE.MD does
- Persistent instructions
- Team conventions
- Writing useful operational guidance
- Defining business preferences
- Defining output standards
- Creating reusable behaviors
- Context files and memory files (loading project.md, persona.md into sessions)

## Examples
- Email tone rules
- Report formatting
- Meeting standards
- Customer communication rules

## Deliverables
- Personal or team CLAUDE.MD template

---

# PART 3 — SKILLS

# Chapter 6 — Creating and Generating Skills

## Objectives
- Design and build a reusable skill for a repetitive workplace task
- Use the Skill Creator tool to generate, review, and refine skill instructions
- Evaluate a generated skill for clarity, reliability, and appropriate scope before deployment

## Topics

### Creating Skills
- What skills are and when to create them
- Skill lifecycle (create → test → refine → reuse)
- Reusable workflows and business-oriented skill design
- Input/output thinking for reliable skills
- Skill organization

### Using the Skill Creator Tool
- Using Skill Creator to generate skills quickly
- Reviewing and refining generated instructions
- Improving skill reliability
- Testing skills before use
- Avoiding vague or over-broad behavior
- Reusable skill templates

## Examples
- Meeting summarizer
- Customer email generator
- Research assistant
- CRM note formatter
- Competitive analysis assistant

## Best Practices
- Clear task definition
- Explicit outputs
- Small, focused skills
- Human review before deployment

## Deliverables
- First reusable skill
- Skill generation workflow

---

# Chapter 7 — Evaluating Skills

## Objectives
- Apply a structured rubric to assess whether a skill's output is accurate, complete, and safe
- Identify hallucinations and reliability gaps in automation outputs
- Design an iterative refinement workflow for underperforming skills

## Topics
- Basic evaluation principles
- Spotting hallucinations
- Consistency checking
- Structured outputs
- Rubrics
- Human review workflows
- Iterative refinement

## Simple Evaluation Questions
- Was it accurate?
- Was it complete?
- Was it formatted correctly?
- Was it useful?
- Was anything risky or fabricated?

## Deliverables
- Simple skill evaluation rubric

---

# PART 4 — TOOLS, PLUGINS & MCP

# Chapter 8 — Connecting Tools and Importing Skills

## Objectives
- Connect Claude to at least one external business system using a plugin or MCP tool
- Evaluate a community-sourced skill or plugin for safety and fitness before importing it
- Apply a safe import checklist to adapt an external skill to a specific workplace context

## Note on Agents vs. Subagents
Plugins and MCP tools extend what a single Claude session can reach. Agents (covered in Chapter 9) are separate Claude instances that plan and act autonomously. Subagents are agents spawned by a parent agent to handle a sub-task. This chapter focuses on tools and imported skills, not agent coordination.

## Topics

### Plugins and MCP Tools
- What plugins are and what MCP tools are
- Connecting Claude to external systems
- Safe tool usage, permissions, and trust
- Common business integrations

### Importing Skills and Plugins
- Finding community skills (Anthropic repositories, GitHub)
- Importing safely and reviewing instructions
- Adapting existing skills to your context
- Trust and security basics

## Business Tool Examples
- Google Workspace
- CRM systems
- Slack
- Notion
- Email systems
- Task management tools

## Safe Import Principles
- Avoid unknown automations
- Review permissions before enabling
- Test in isolation before production use

## Deliverables
- Business tool integration map
- Safe import checklist

---

# Chapter 9 — Playwright MCP & Browser Automation

## Objectives
- Build a browser automation workflow for a repetitive web-based task
- Identify fragile browser automation patterns and apply mitigation strategies
- Insert human review checkpoints at high-risk steps in a browser workflow

## Topics
- Browser automation basics
- Repetitive web tasks
- Form filling
- Data gathering
- Navigation workflows
- Safe browser automation
- Reliability limitations

## Examples
- Collecting competitor information
- Updating web-based systems
- Research workflows
- Downloading reports

## Important Topics
- Human review checkpoints
- Avoiding fragile workflows

## Deliverables
- Browser automation workflow

---

# Chapter 10 — Zapier MCP & SaaS Automation

## Objectives
- Design a trigger-action workflow that connects two or more business applications
- Implement scheduled and event-triggered cross-application automations
- Compare direct MCP integrations with Zapier-mediated workflows and select the appropriate approach

## Topics
- Trigger-action workflows
- Cross-application automation
- Notifications
- Data synchronization
- Workflow chains
- Scheduled workflows

## Examples
- Slack notifications
- CRM updates
- Meeting follow-ups
- Task creation
- Email routing

## Deliverables
- SaaS automation workflow

---

# PART 5 — AGENTS & ORCHESTRATION

# Chapter 11 — Practical Agents for Knowledge Work

## Objectives
- Distinguish between a skill, a tool-enabled session, and an autonomous agent
- Design a multi-step agent workflow that includes human oversight checkpoints
- Evaluate a proposed agent workflow for scope, risk, and reliability before deploying it

## Note on Agents vs. Subagents
An agent is a Claude instance given a goal and allowed to plan and act across multiple steps. A subagent is an agent spawned by a parent (orchestrating) agent to handle a bounded sub-task — for example, a research agent that spawns a summarizer subagent. This chapter covers single-agent workflows. Multi-agent orchestration is introduced briefly and expanded in Chapter 12.

## Topics
- What agents are and how they differ from skills and tool-enabled sessions
- Multi-step autonomous workflows
- Planner agents, research agents, execution agents
- Human oversight and escalation
- Agent limitations in a knowledge-work context

## Examples
- Weekly business review agent
- Research assistant agent
- Meeting preparation agent
- Customer follow-up agent

## Deliverables
- Personal business agent design

---

# Chapter 12 — Orchestrations & Scheduled Work

## Objectives
- Configure a recurring scheduled automation for a real workplace workflow
- Implement approval and escalation checkpoints within an orchestrated workflow
- Assess which recurring tasks deliver the highest return on automation investment

## Topics
- Scheduled work
- Daily automations
- Weekly workflows
- Loops and iteration
- Approval checkpoints
- Triggered workflows
- Reporting automations

## Examples
- Daily summaries
- Weekly KPI reports
- Competitive monitoring
- Follow-up reminders

## Deliverables
- Recurring automation workflow

---

# Chapter 13 — AskUserQuestion & Human-in-the-Loop Automation

## Objectives
- Implement clarification and approval steps within an automation using AskUserQuestion
- Design escalation patterns that stop unsafe or ambiguous actions before execution
- Justify where human checkpoints add the most value in a given workflow

## Topics
- Clarification questions
- Approval workflows
- Escalation patterns
- Handling ambiguity
- Stopping unsafe actions
- Interactive workflows

## Examples
- Approval before sending email
- Clarifying incomplete requests
- Human review before updating systems

## Deliverables
- Human approval workflow

---

# PART 6 — PRACTICAL OPERATIONS

# Chapter 14 — Debugging & Improving Automations

## Objectives
- Diagnose the root cause of a failing automation using a structured troubleshooting approach
- Apply iterative refinement techniques to improve automation reliability
- Rewrite an overly broad instruction set into smaller, testable units

## Topics
- Why automations fail
- Bad context
- Missing information
- Overly broad instructions
- Reliability improvement
- Iterative refinement
- Simplifying workflows

## Best Practices
- Start small
- Test incrementally
- Add constraints
- Use structured outputs

## Deliverables
- Automation troubleshooting checklist

---

# Chapter 15 — Security, Safety & Governance

## Objectives
- Identify categories of sensitive information that require human review before automation
- Apply safe usage principles to prevent prompt injection and unauthorized data exposure
- Formulate a personal or team governance policy for automation permissions and output review

## Topics
- Sensitive information handling
- Data privacy
- Prompt injection basics
- Unsafe automations
- Permissions
- Reviewing outputs
- Human oversight
- Organizational policies

## Important Principle
Never blindly trust automation outputs.

## Deliverables
- Safe automation guidelines

---

# Chapter 16 — Designing Your Personal Automation System

## Objectives
- Synthesize skills, plugins, agents, and orchestrations into a coherent personal automation portfolio
- Prioritize automation opportunities by business impact and implementation effort
- Design a sustainable plan for sharing, documenting, and continuously improving automation assets

## Topics
- Personal automation portfolio
- Automation prioritization
- Reusable workflows
- Team sharing
- Documentation
- Continuous improvement
- Building an automation habit

## Final Exercise

> **Note for course factory pipeline:** The Final Exercise below defines the scope of the
> **capstone lab** for this course. It is NOT a chapter exercise and MUST NOT be treated as
> a chapter-level deliverable. The `lab-generator` agent uses this specification as its
> primary input. The chapter's own exercise is limited to the automation portfolio planning
> activity described in the Deliverables section.

Design and document a personal automation system comprising:
- 5 reusable skills
- 2 recurring orchestrations
- 1 browser automation workflow
- 1 SaaS automation workflow
- 1 agent workflow

## Deliverables
- Personal automation operating model (portfolio plan)

---

# COURSE-WIDE DEMONSTRATION STRATEGY

## Important Principle
All demonstrations should use:
- Real business workflows
- Cross-functional examples
- Reusable workplace scenarios
- Low technical complexity
- High operational value

---

# RECOMMENDED BUSINESS SCENARIOS

Examples used throughout the course may include:

- Executive assistant workflows
- Competitive intelligence
- Meeting operations
- Customer communication
- Sales operations
- Research synthesis
- Reporting automation
- HR onboarding support
- Marketing campaign coordination
- Knowledge management
- Document processing

---

# PEDAGOGICAL APPROACH

Every chapter should include:

## 1. Business Problem
What real workplace problem is being solved?

## 2. Simple Conceptual Explanation
Only enough technical depth to operate effectively.

## 3. Guided Demonstration
Step-by-step practical workflow.

## 4. Common Mistakes
Operational anti-patterns.

## 5. Practical Exercise
Small, immediately usable workflow.

---

# IMPORTANT SIMPLIFICATIONS FROM THE ENGINEERING COURSE

This curriculum intentionally simplifies or minimizes:

| Advanced Topic | Simplified Treatment |
|---|---|
| Deep MCP internals | Operational usage only |
| Complex architecture | Conceptual overview only |
| Distributed orchestration | Practical workflows only |
| Advanced evaluation frameworks | Simple rubrics |
| Reliability engineering | Practical troubleshooting |
| Security architecture | Safe usage principles |
| Multi-agent coordination | Basic business agents |
| Low-level CLI operations | Common commands only |
| Token optimization | Basic context management |
| Infrastructure concerns | Not covered |

---

# WHAT THIS COURSE EMPHASIZES MOST

## Highest Priority Skills

### 1. Reusable Skills
The biggest productivity multiplier.

### 2. Context Management
The biggest reliability factor.

### 3. Human-in-the-Loop Workflows
The biggest safety factor.

### 4. Browser & SaaS Automation
The biggest business impact area.

### 5. Practical Evaluation
The biggest quality differentiator.

---

# COURSE SUCCESS METRICS

A successful learner should be able to:

- Save several hours per week through automation
- Create reusable automation workflows
- Safely use plugins and browser automation
- Build recurring operational automations
- Improve output consistency and quality
- Reduce repetitive cognitive work
- Operate confidently without deep technical expertise

---

# FINAL COURSE OUTCOME

By the end of this curriculum, learners should think:

"I can reliably automate large portions of my knowledge work safely and effectively."

—not—

"I understand every technical detail of the platform."

This course optimizes for:
- Practical leverage
- Business productivity
- Confidence
- Reliability
- Sustainable adoption
- Immediate workplace value
