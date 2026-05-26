# Failure Modes — Exercise 02: RSTRM Analysis for Email Inbox Triage

---

## Failure Mode 1: "Inconsistent Source Disqualification" — Scoring Structured = No because email body text is not uniform

**Broken state:** Tracy examines Gmail message bodies and concludes they are too varied — vendor emails, internal team updates, leadership notes, and automated digests all have different formats. She scores S = No and marks the workflow as "not automatable."

**What the correct analysis shows:** Structured does not require uniform message formatting. It requires that classification decisions can be expressed as rules. Gmail metadata (sender, subject line, labels, timestamps) is highly structured. Message-body classification rules — "if sender is in [Jira notification domain], then bulk-archive" — are writable even when individual bodies vary. The workflow is Structured because the rules are writable, not because every message looks the same.

**Expected consequence if left unresolved:** Tracy abandons the automation before building it. She continues spending 45 minutes per Monday on triage that is largely automatable.

**Diagnosis steps:**
1. Before scoring S, write down three classification rules Tracy applies. If you can write them as "if sender X, then action Y" or "if subject contains keyword Z, then action Y," the criterion passes.
2. Ask: "Am I scoring Structured based on input formatting or on the describability of the decision?" If the answer is input formatting, you are applying the criterion incorrectly. Structured is about decisions, not formats.

**Remediation:** Re-read Section 5 of the Chapter 1 doc, specifically the suitability table. Note that email triage is listed as automatable in the table despite free-text message bodies.

---

## Failure Mode 2: "Incomplete Checkpoint" — Checkpoint specification omits the approval action

**Broken state:** The learner writes a checkpoint specification that says "Tracy reviews the triage report and the proposed actions" but does not specify what Tracy does to signal approval. The verify script reports: `FAIL: Checkpoint field missing — **Approval action:**`.

**What the correct specification shows:** A human-in-the-loop checkpoint must answer three questions, not two: (1) When does the automation pause? (2) What does Tracy review? (3) What specific action does Tracy take to resume execution? Without the approval action, the checkpoint is designed for review but not for continuation — the automation would either time out or proceed without approval.

**Expected error if left unresolved:** In a real Cowork implementation, a checkpoint with no approval mechanism either halts indefinitely (`checkpoint timed out after 24h — run cowork resume <task-id>`) or is bypassed because the developer wired no wait condition. The second outcome means bulk actions execute without Tracy's review — exactly the failure the checkpoint was meant to prevent.

**Diagnosis steps:**
1. Read your checkpoint specification and ask: "If I handed this to a developer building the skill, would they know what user action resumes the workflow?" If the answer is "no" or "maybe," the approval action is missing.
2. The approval action must be a concrete gesture in a specific interface: clicking a button in the Cowork UI, running a CLI command (`cowork approve <task-id>`), or sending a message in a specific format. Vague language ("Tracy approves") is not sufficient.

**Remediation:** Re-read the "human-in-the-loop checkpoint" definition in the Chapter 1 Glossary Delta. The definition specifies three components explicitly: trigger + review + approval action.
