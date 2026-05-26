# Failure Modes — Exercise 03: Independent RSTRM Analysis

---

## Failure Mode 1: "Inconsistent Format Disqualification" — Applying Structured as "uniform input format required"

**Broken state:** Tracy (or the learner) chooses Task 5 (vendor status update parsing) and scores Structured = Weak because the three vendor emails use different HTML structures and subject-line conventions. Based on this score, the overall verdict is "Not an automation candidate."

**What the correct analysis shows:** Structured evaluates the describability of classification and extraction rules — not the uniformity of the input format. The three vendor emails have different formats, but the extraction targets are identical across all three: timeline status, open risks, and next deliverable date. Vendor-specific extraction rules ("for Vendor A, look for paragraph 2; for Vendor B, look for the 'current status:' label") are explicit, stable, and writable. A task can be Structured even when inputs are heterogeneous, as long as the extraction rules for each input variant can be documented.

**Expected consequence if unresolved:** The vendor status parsing task — one of the strongest candidates on the list — is incorrectly eliminated. Tracy continues spending 20–30 minutes per week on a workflow that automation handles cleanly.

**Diagnosis steps:**
1. Before scoring Structured, ask: "Can I write an extraction rule for each input source?" If yes for all sources (even with source-specific rules), the criterion passes.
2. Ask: "Am I evaluating the input format or the rule describability?" Structured is always about rules, not formats.
3. If you scored Weak, check whether you can now write at least two vendor-specific rules. If you can, revise your score to Partial or Strong with a notation about the per-vendor rule maintenance requirement.

**Remediation:** Re-read Section 5 of the Chapter 1 doc and the "Structured" criterion definition in the RSTRM framework. Note that the Slack messages in the status report worked example (Exercise 01) are also free-text but score Strong on Structured — the analogy applies directly.

---

## Failure Mode 2: "Skill Sufficiency Error" — Selecting "skill" as the tool type for a multi-source, multi-system workflow

**Broken state:** The learner chooses Task 3 (meeting follow-up action item distribution) and selects "skill" as the tool type, reasoning that the task is conceptually simple: "read notes, parse action items, send emails."

**What the correct analysis shows:** A skill cannot send email independently — it requires a Gmail plugin with the `sendMessage` MCP tool. A workflow that reads a document (Drive plugin or Notes), parses it (skill), and sends to multiple recipients (Gmail plugin, called once per owner) is a multi-step, multi-plugin workflow. That requires agent-level orchestration: a planner that reads, then loops through owners, then dispatches individual sends, then pauses for Tracy's review before execution. Selecting "skill" for this workflow produces an under-specified architecture that will fail at the distribution step.

**Expected consequence if unresolved:** Tracy builds a skill that produces a formatted action item list but cannot distribute it. She still sends the emails manually, defeating the primary purpose of the automation. The time savings are 0.

**Diagnosis steps:**
1. For any workflow where the verdict includes "send email" or "write to an external system," the tool type is at minimum skill + plugin. If the workflow reads from one system and writes to another, the tool type is agent.
2. Check your Multi-step score. If M = Strong with more than two steps across multiple systems, the tool type should be agent. A skill is appropriate only when the workflow operates within a single system or processes pre-supplied input with no external reads or writes.
3. Re-read the tool-type classification table in Section 5 of the Chapter 1 doc. The rule: "A skill alone cannot connect to external systems. Connections require plugins. Coordination of multiple plugins requires an agent."

**Remediation:** Revise your tool-type verdict for Task 3. Use the Multi-step and Rules-based scores to justify the revision — the same evidence that drove those scores drives the tool-type selection.
