# Chapter 1 Cheatsheet — Introduction to Claude Cowork Automation

## Learning Outcomes

- **LO-01.1:** Identify what makes a PM workflow a strong Claude Cowork automation candidate. [Bloom: Understand]
- **LO-01.2:** Distinguish skill / plugin / agent and select the right building block for a given PM workflow. [Bloom: Understand]
- **LO-01.3:** Apply the RSTRM framework criterion by criterion to produce a scored evaluation and design verdict. [Bloom: Apply]

---

## Key Terms

| Term | Definition |
|------|-----------|
| Claude skill | A saved, reusable instruction set — equivalent to a written SOP. Encodes what source information to expect, what report draft to produce, and what constraints apply. Cannot connect to Jira or Gmail independently; calls plugins for live project data. |
| Claude plugin | A connector giving Claude read or write access to one external system (Jira, Confluence, Slack, Gmail, Google Drive, ServiceNow). Handles authentication. Requires explicit authorization; revocable at any time. |
| agent | A Claude configuration that autonomously plans and sequences a multi-step workflow — calling skills and plugins, evaluating intermediate results, and pausing at a human-in-the-loop checkpoint — until it reaches a stopping condition. |
| RSTRM framework | Five-criterion automation evaluation checklist: **R**epetitive, **S**tructured, **T**ime-consuming, **R**ules-based, **M**ulti-step. All Strong = high-confidence candidate. Two or more Weak ratings = redesign or defer. |
| human-in-the-loop checkpoint | A deliberate pause where Tracy reviews and approves the generated report draft before the automation proceeds — sending an executive status report, applying a Gmail label, or moving a Google Drive file. Non-negotiable for high-stakes outputs. |

---

## Skills / Plugins / Agents

| Building Block | Role | Cannot do alone | Tracy's example |
|---------------|------|-----------------|-----------------|
| **Skill** | Encodes instructions + output format | Connect to Jira, Gmail, or any live system | Status report aggregation skill: accepts supplied Jira/Confluence/Slack/transcript data; produces five-section executive summary |
| **Plugin** | Read/write access to one external system | Follow instructions or transform data | Jira plugin: retrieves closed and blocked tickets; Gmail plugin: reads inbox and applies labels |
| **Agent** | Plans and sequences a multi-step workflow across skills + plugins; manages checkpoints | Replace Tracy's professional judgment | Weekly report agent: Jira → Confluence → Slack → transcripts → draft → pause for Tracy's review |

---

## RSTRM Framework — Quick Reference

| Criterion | Strong | Partial | Weak | Tracy's status report score |
|-----------|--------|---------|------|-----------------------------|
| **R**epetitive | Fixed schedule; same steps every cycle | Mostly regular, occasionally varies | Ad hoc or unpredictable | **Strong** — every Monday, 50×/year per program |
| **S**tructured | Decisions expressible as "if X, then Y" rules | Some rules writable; others need judgment | No writable rules | **Strong** — all four sources follow extractable patterns; template stable 8 months |
| **T**ime-consuming | Hours/week or 100+ hours/year recoverable | 30–60 min/week savings | Minimal ROI | **Strong** — 2.5 hrs × 2 programs × 50 weeks = 250 hrs/year |
| **R**ules-based | All decisions follow explicit, stable rules | Most rule-based; a few need judgment | Most decisions require professional discretion | **Strong** — rules writable for all sources; Slack classification has one judgment checkpoint |
| **M**ulti-step | 4+ discrete steps; multiple systems | 2–3 steps; one system | Single step; no intermediate state | **Strong** — six steps across four systems + review pause |

---

## Decision Guide — Which Building Block to Use

```
Touches MORE THAN ONE external system?
  YES → Needs intermediate evaluation OR a checkpoint?
          YES → AGENT (orchestrates skills + plugins)
          NO  → SKILL calling multiple PLUGINS
  NO  → Reads from or writes to any external system?
          YES → SKILL + one PLUGIN
          NO  → SKILL with manually supplied source information
```

Tracy's weekly status report: M = Strong (6 steps, 4 systems) → **agent** coordinating a status-report skill and four plugins (Jira, Confluence, Slack, Google Meet), with a human-in-the-loop checkpoint before distribution.

---

## Common Pitfalls Quick Reference

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| "Claude can impose structure on inconsistent inputs" | Each automation run produces the executive summary in a different section order | Standardize the output template manually for 2–3 reporting cycles before encoding it in the skill |
| "5/5 RSTRM = skip Tracy's review" | Automation sends the executive status report to leadership the moment synthesis completes | Automate the draft; require Tracy's review before distribution — time savings come from eliminating data-gathering, not from removing her from the approval chain |
| "An agent is needed just to pull Jira data" | First automation is over-engineered and fails silently | Single retrieval = skill + plugin. Agent = multi-system, multi-step with a review checkpoint. Build complexity incrementally |
| "Structured = No because Slack messages are free-text" | Email triage and transcript workflows incorrectly scored as non-automatable | Structured measures whether decisions follow writable rules — not whether inputs are machine-formatted. "If message contains [blocker keyword], classify as Risk" is a writable rule |

---

## Key Retrieval Questions

1. What is the single characteristic that separates automatable PM tasks from human-judgment-required tasks? *(Answer: the decisions within the task can be expressed as explicit, stable, writable rules.)*

2. Tracy wants to draft an executive status report by reading Jira, Confluence, Slack, and two Google Meet transcripts — then pause for her review before sending. Which building block handles this, and why not a skill alone? *(Answer: an agent; a skill alone cannot coordinate multiple plugins across four systems or manage a mid-workflow human-in-the-loop checkpoint.)*

3. Name all five RSTRM criteria in order. *(Answer: Repetitive, Structured, Time-consuming, Rules-based, Multi-step.)*
