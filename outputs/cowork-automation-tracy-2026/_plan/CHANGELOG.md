# Plan Changelog — cowork-automation-tracy-2026

All overrides, resolutions, and deviations from master spec defaults are logged here.
This file is append-only. Never delete or modify prior entries.

---

## 2026-05-25 — Initial plan created (PlannerAgent v2.0.0)

### Numeric overrides applied
- **None.** All numeric_overrides in `inputs/orchestration.yaml` are commented out.
  All master spec defaults are used as-is:
  - doc: 3,000–6,000 words
  - quiz: 10 items, 2 carry-forward, 80% pass, difficulty 0.40–0.95, 2 forms
  - exercises: 30 min per pack
  - slides: 12–25 slides
  - podcast: 1,200–2,300 words
  - capstone: 120 minutes

### Compact-mode quiz
- **Not activated.** Chapter count = 16 < 25. Standard quiz mode applies.

### Precedence conflicts resolved
| Field | Specs involved | Winner | Resolution |
|---|---|---|---|
| mode_targets | students.yaml (self_taught) vs orchestration.yaml ([self_taught, cohort]) | Student Context | primary=self_taught, secondary=cohort both produced |
| reading_level | students.yaml (FK 13) vs subject.md (knowledge workers, implicit intermediate) | Student Context | FK grade 13 enforced; sentence length ≤ 30 words avg |
| chapter time | subject.md (30–50 min) | Subject spec (no conflict; no override) | Upper bound 50 min per chapter used |

### Capstone scenario reservation
- **scenario-02** (Cross-project risk and dependency detection) reserved for capstone.
- Confirmed by user at Step 2 normalization review (2026-05-25).
- All 16 chapter common envelopes carry `forbidden_examples: [scenario-02]`.

### Chapter count
- 16 chapters as declared in subject.md. No splits required (all ≤ 60 min).
- No chapter partition changes from subject.md structure.

### Scenario allocation
- 5 active scenarios across 16 chapters (some scenarios assigned to multiple chapters):
  - scenario-01: ch01, ch06, ch11, ch12, ch16
  - scenario-03: ch02, ch05, ch07
  - scenario-04: ch03, ch08, ch10
  - scenario-05: ch04, ch09
  - scenario-06: ch13, ch14, ch15
  - scenario-02: RESERVED (capstone only)

---

*Future entries will be appended here by downstream agents as they apply overrides.*
