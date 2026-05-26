# Pack-Level Failure Modes — Chapter 1 Exercise Pack

This file documents cross-cutting failure modes that apply across all three exercises in this pack. Individual exercises have their own `failure-modes.md` files with task-specific diagnosis steps. This file covers the conceptual misunderstandings that produce errors in multiple exercises.

---

## Pack Failure Mode A: "Consistent Format" Conflation — Treating Structured as "uniform input format required"

**Where it appears:** Exercise 02 (email triage scoring), Exercise 03 (vendor status update and meeting notes scoring)

**Broken state:** Tracy scores Structured = No or Structured = Weak for any workflow whose inputs are free-text — Slack messages, email bodies, meeting transcripts, or handwritten notes. She concludes these workflows cannot be automated.

**Why this is wrong:** The Structured criterion measures whether the *decisions* within the task follow writable rules — not whether the *inputs* have a uniform machine format. Slack messages, Gmail bodies, and vendor emails are free-text inputs, but the classification and extraction rules applied to them can still be explicit and consistent. A Jira ticket database is more structured than a Slack message, but both can satisfy the Structured criterion if the rules applied to them are articulable.

**Systemic consequence:** Over-application of this misunderstanding eliminates most knowledge-work automation candidates, because knowledge workers rarely work with purely machine-formatted inputs. The result is a false conclusion that Claude Cowork is only useful for database-to-report workflows.

**Correction:** Before scoring Structured, write down the rule — not the input format. If you can write "If [input contains / sender is / message includes] X, then classify as Y," the criterion passes. If you cannot write any rule, the criterion fails.

---

## Pack Failure Mode B: "RSTRM Verdict = Automation Permission" — Treating a Strong score as approval to skip the checkpoint

**Where it appears:** Worked example (Decision callout on the stakes filter), Exercise 02 (failure mode 2), Exercise 03 (design constraint step)

**Broken state:** After producing a 5/5 RSTRM scorecard (all Strong), the learner concludes the automation can run end-to-end without a human-in-the-loop checkpoint — because the RSTRM analysis confirmed the task is automatable.

**Why this is wrong:** RSTRM evaluates *whether* a workflow is worth automating. It does not evaluate *safety*. A status report distributed to leadership with an AI-generated error, or an email bulk-archived that should have been escalated, damages Tracy's professional credibility regardless of the RSTRM score. The checkpoint design is a separate analytical step that follows from the stakes of the output — not from the RSTRM verdict.

**Systemic consequence:** Automations built without checkpoints run correctly until they produce one consequential error. After that error, stakeholders may lose confidence in all of Tracy's automations — not just the one that failed. Rebuilding trust costs more time than the checkpoint would have required.

**Correction:** After completing the RSTRM scorecard, always ask: "Who receives this output? What happens if the output contains an error? Would the error be immediately visible to Tracy before consequences occur?" If the answer is "no" or "maybe not," a checkpoint is required.

---

## Pack Failure Mode C: "Skill vs. Plugin vs. Agent" Confusion — Selecting the wrong tool type by ignoring the Multi-step criterion

**Where it appears:** Exercise 02 (plugin specification), Exercise 03 (tool-type verdict)

**Broken state:** The learner selects "skill" for workflows that require reading from or writing to an external system, or selects "agent" for workflows that only need a single retrieval step.

**Why this is wrong:** The three building blocks have clear boundaries:
- A **skill** encodes instructions and transformation logic. It cannot connect to external systems without a plugin.
- A **plugin** provides read or write access to one external system. A plugin by itself cannot follow instructions — it needs a skill to direct it.
- An **agent** coordinates multiple steps, calls multiple skills and plugins, evaluates intermediate results, and manages a human-in-the-loop checkpoint. An agent is over-engineering for single-source, single-step workflows.

The Multi-step criterion determines which tier is appropriate:
- Single-step, single-system → skill + plugin
- Multi-step, single system → skill + plugin (or agent if state management is needed)
- Multi-step, multi-system with a review step → agent coordinating skills and plugins

**Correction:** After scoring Multi-step, derive the tool type from the number of distinct systems accessed and whether intermediate results need to be evaluated before the next step. If M = Partial (2–3 steps, 1 system), start with skill + plugin. If M = Strong (4+ steps, 2+ systems), use an agent.
