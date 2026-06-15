# Personalized Course Factory

A multi-agent Claude Code pipeline that generates complete, personalized technical training
courses from a subject specification, a problem domain, and a learner cohort description.

---

## What It Produces

For each chapter, the pipeline generates six artifacts:

| Artifact | File | Purpose |
|----------|------|---------|
| Chapter doc | `tutorial.docx` | 3,500–6,000 word structured learning text (Word) |
| Exercise pack | `exercises/` | Worked example + completion + independent exercises (Word briefs + code) |
| Slide deck | `slides.pptx` + `slides-notes.docx` | 12–25 slide deck (PowerPoint) + presenter notes (Word) |
| Quiz | `quiz.json` + `quiz-formB.json` | 10-item assessment, Form A + Form B |
| Podcast script | `podcast-script.md` | 1,200–2,300 word recording production script |
| Companion | `cheatsheet.docx` + `instructor-guide.docx` | Quick reference + facilitation guide (Word) |

Plus course-level artifacts: capstone lab (`capstone-lab.docx`), **chapter podcasts in
NotebookLM** (one Audio Overview per chapter, generated after the capstone), master glossary
(`glossary.docx`), prerequisite diagnostic, student onboarding guide (`README.docx`), and lab
environment scaffold.

All content is grounded in evidence-based learning science: Bloom's Taxonomy, retrieval
practice (Roediger & Karpicke), cognitive load theory (Sweller), Mayer's multimedia
principles, and the 4C/ID model.

---

## Install as a Claude Code plugin

The entire factory — all agents, commands, specs, the podcast tool, and the project rules — is
packaged as a single Claude Code plugin, so you can install it into any project as one unit:

```
/plugin marketplace add manucohenyashar/personalized_course_factory
/plugin install personalized-course-factory@course-factory-marketplace
```

Then generate a course from any project with `@course-factory-agent` (see
[Quick Start](#quick-start)). The bundled slash commands are namespaced under the plugin, e.g.
`/personalized-course-factory:plan-course`, `/personalized-course-factory:next-chapter`,
`/personalized-course-factory:course-status`. Starter input templates ship under the plugin's
`templates/inputs/`. For NotebookLM podcasts, also install the CLI and log in (see
[Setting up NotebookLM podcasts](#setting-up-notebooklm-podcasts-optional)).

> **Maintainers:** the plugin under `course-factory-plugin/` is **generated** from the canonical
> sources (`.claude/`, `doc/`, `tools/`, `CLAUDE.md`) by `python tools/build_plugin.py`, which
> rewrites bundled-file paths to `${CLAUDE_PLUGIN_ROOT}`. Edit the sources, re-run the build, and
> commit the regenerated `course-factory-plugin/`. The repo doubles as the install marketplace via
> `.claude-plugin/marketplace.json`.

---

## Quick Start

### Before you start — prepare your input specifications (optional)

Two helper agents can prepare your input files before you run the course generator:

**Validate or build your curriculum (`inputs/subject.md`):**
```
@subject-spec-builder-agent
```
Provide an existing curriculum file, paste a chapter outline, or describe your course topic.
The agent **searches the web** for similar courses, syllabi, and industry resources to
evaluate whether your curriculum is complete, well-sequenced, and current — then asks you
targeted questions and suggests additions or changes based on what it finds. It also validates
scope, chapter density, hands-on feasibility, and generator compatibility before writing a
validated `inputs/subject.md`. Use this when:
- You have an existing training spec or syllabus you want to adapt or improve
- You want to build a curriculum from scratch with research-backed guidance
- You are unsure whether your topic list covers the subject adequately for your audience
- You want to verify your curriculum is current and reflects industry expectations

**Build your domain and student specs from unstructured documents (`inputs/problem.yaml` + `inputs/students.yaml`):**
```
@spec-builder-agent
```
Share any documents — a business case, job descriptions, team wikis, a slide deck, or a
paragraph. The agent extracts the problem domain, student context, and success criteria,
asks targeted questions to fill gaps, and writes the two required YAML files.

Once all spec files are written, continue with Option A or B below.

---

### Option A — One command (recommended)

Describe your course to Claude Code in plain language:

```
@course-factory-agent

Create a personalized course for warehouse logistics supervisors learning to use AI
for exception triage in SAP WMS. They have SQL experience but no ML background.
Success criteria: students can build an automated triage pipeline and deploy it to
their WMS environment independently.

Curriculum:
- Chapter 1: Introduction to AI-assisted triage
- Chapter 2: Prompt engineering for exception analysis
- Chapter 3: Context injection from SAP WMS data
- Chapter 4: Building a triage automation workflow
- Chapter 5: Batch processing and scheduling
- Chapter 6: Testing, debugging, and deployment
```

If you already have a curriculum in `inputs/subject.md`, you can omit the chapter list
and the agent will use that file. If you provide neither, the agent will ask you to
supply one before proceeding.

The factory agent will:
1. Parse your domain + student specs and write the input files
2. Show you a **spec summary** for review → requires your approval
3. Run the planner and show a **normalization diff** → requires your approval
4. Show the **course plan** (chapters, LOs, scenarios) → requires your approval
5. Generate the environment, all chapters, evaluator, and capstone lab automatically
6. Generate one **NotebookLM podcast per chapter** (after the capstone) — best-effort; skipped
   with instructions if NotebookLM is not authenticated
7. Deliver a completion report with links to all outputs

Two mandatory human-review halts occur during planning. All chapter generation runs
automatically after your approvals.

You can also add **global course requirements** to your message to override the defaults — see
[Global Course Requirements](#global-course-requirements) below for the full list and examples.

---

### Option B — Pre-fill the input files, then run

If you prefer to edit the input files yourself:

```
inputs/
  subject.md                ← REQUIRED: your curriculum (default: Cowork Automation — replace with your own)
  problem.yaml              ← REQUIRED: fill in problem domain + ≥ 4 representative scenarios
  students.yaml             ← REQUIRED: fill in cohort profile
  general-requirements.yaml ← OPTIONAL: global overrides (time, chapters, focus areas, etc.)
  orchestration.yaml        ← optional: adjust low-level pipeline settings
```

Open each file and replace all `REPLACE_ME` values. Then:

```
@course-factory-agent
The input files are ready in inputs/. Generate the course.
```

---

### Option C — Step by step (advanced / manual control)

Run each agent individually for full control:

```
@subject-spec-builder-agent                 ← Step 0a: validate/build inputs/subject.md (optional)
@spec-builder-agent                         ← Step 0b: build inputs/problem.yaml + inputs/students.yaml (optional)
@planner-agent                              ← Step 1: plan (two human-review halts)
@environment-scaffold-generator             ← Step 2: environment (once)
@chapter-supervisor-agent chapter_number: 1 ← Step 3: repeat for each chapter
@evaluator-agent                            ← Step 4: course-wide evaluation
@lab-generator                              ← Step 5: capstone lab
@generate-course-podcasts                   ← Step 6: one NotebookLM podcast per chapter (after the lab)
```

Step 6 requires the NotebookLM CLI (`nlm login` must be valid). It is best-effort: if
NotebookLM is unavailable, the end-to-end pipeline skips it and you can run
`@generate-course-podcasts` for the course later.

### Resuming after interruption

If generation was interrupted, re-invoke `@course-factory-agent`. It will detect the
saved pipeline state and offer to resume from where it left off — no need to restart
from scratch.

---

## Subject Specification — Your Curriculum Contract

The **subject specification** (`inputs/subject.md`) is the curriculum baseline: it defines
the topics, chapters, and learning objectives that the course MUST teach. Every generated
artifact — chapter docs, exercises, quizzes, slides, the capstone lab — is built by taking
this curriculum and personalizing it for your students and problem domain.

**The subject spec is required.** The pipeline enforces that every topic listed in it is
covered in the generated course. Any topic that ends up without a corresponding chapter
section, exercise, or assessment will cause the final evaluation to fail.

### The recommended path: use `@subject-spec-builder-agent`

In most cases, you will start with a rough idea of what the course should cover — a list of
topics, a training brief, an existing syllabus, or just a description of what your students
need to learn. **Rather than writing `inputs/subject.md` by hand, use the subject spec
builder agent to turn that starting point into a validated curriculum.**

```
@subject-spec-builder-agent
```

Tell it what you have — paste a topic list, share a file path, or describe the course goal
in plain language. The agent will:

1. **Research the subject** — searches the web for similar courses, syllabi, professional
   certifications, and industry learning paths to understand what practitioners in this field
   actually need to know
2. **Evaluate your coverage** — compares your topics against what similar courses teach,
   flags common topics you may have missed, and identifies any topics in your spec that are
   unusual or rarely covered at this level
3. **Ask you targeted questions** — presents research-backed suggestions one at a time
   ("This topic appears in 4 of 5 similar curricula I found — would you like to add it?")
   and lets you accept, modify, or decline each one
4. **Validate generator compatibility** — checks chapter count, per-chapter scope, hands-on
   feasibility, concept density, and learning objective quality against the pipeline's
   hard constraints
5. **Write `inputs/subject.md`** — produces the validated, structured curriculum file ready
   for the planner

You can start from something as rough as:

```
@subject-spec-builder-agent

I want to build a course on AI-assisted exception triage for warehouse supervisors using
SAP WMS. They should learn to use prompts to analyse shipment exceptions, automate
escalations, and build a recurring monitoring workflow. No ML background assumed.
```

Or review an existing file:

```
@subject-spec-builder-agent

Review doc/MainSubjectSpec-Practical-Cowork-Automation.md and validate it.
Suggest any topics that are missing or could be improved.
```

See [`doc/MainSubjectSpec-Practical-Cowork-Automation.md`](doc/MainSubjectSpec-Practical-Cowork-Automation.md)
for a complete example of a finished subject spec (the 18-chapter default curriculum).

---

### Other ways to provide the subject spec

If you prefer not to use the agent interactively, two alternatives are available:

**Use the default curriculum (no action needed)**

`inputs/subject.md` already contains the 18-chapter Cowork Automation curriculum. If this
matches your course, keep it as-is and move straight to filling in `inputs/problem.yaml`
and `inputs/students.yaml`.

**Paste your curriculum inline when invoking `@course-factory-agent`**

Include your chapter list directly in the message. The factory agent extracts it and writes
it to `inputs/subject.md` automatically — without validation or research:

```
@course-factory-agent

Create a personalized course for claims adjusters learning AI-assisted coverage analysis.
They have 3+ years experience and are familiar with common policy types.

Curriculum:
- Chapter 1: Introduction to LLM-assisted analysis — what it can and cannot do
- Chapter 2: Reading and interpreting policy documents with AI
- Chapter 3: Drafting settlement summaries
- Chapter 4: Quality review and human oversight
- Chapter 5: Building a personal workflow
```

Note that this path skips the research and validation that `@subject-spec-builder-agent`
performs. Use it when you are confident your topic list is complete and well-scoped.

---

### What happens at planning time

The planner reads `inputs/subject.md` and builds a **subject coverage index** — a map from
every topic and chapter in the spec to the course chapters it generates. This index appears
in the normalization diff (first human-review halt) so you can see exactly how your curriculum
maps to the personalized course structure before any content is generated.

At evaluation time, the `evaluator-agent` verifies that every item in the coverage index is
actually addressed in the generated artifacts. Any uncovered topic blocks course delivery
until resolved.

---

## Global Course Requirements

You can tell the pipeline exactly how long your course should be, how many chapters to
produce, which topics to emphasize, and more. These requirements take the **highest
precedence** in the pipeline — they override the subject spec, orchestration settings,
and all other defaults.

### What you can control

| Requirement | What it does | Example |
|-------------|-------------|---------|
| **Total course time** | Sets a maximum (and optionally minimum) total duration | "max 4 hours", "3 to 5 hours" |
| **Chapter count** | Overrides the chapter count in the subject spec | "6 chapters", "8 modules" |
| **Chapter duration** | Sets a per-chapter time target (default: 45–90 min) | "60 minutes per chapter" |
| **Focus areas** | Topics that must have dedicated sections in some chapter | "focus on error recovery and debugging" |
| **Excluded topics** | Topics to omit entirely, even if in the subject spec | "skip history and background" |
| **Difficulty** | Shifts the Bloom taxonomy distribution across the course | "intermediate", "advanced" |
| **Artifact types** | Skip artifact types you don't need | "no podcast scripts", "skip slides" |
| **Delivery format** | Self-paced, instructor-led, or blended (affects tone and priorities) | "self-paced", "instructor-led" |
| **Custom instructions** | Any other binding constraint for the planner and generators | "all code examples must be Python" |

### How to provide them

**Option 1 — Inline in your message (easiest)**

State your requirements in plain language when you invoke `@course-factory-agent`.
The agent extracts them automatically and writes `inputs/general-requirements.yaml`
before planning begins.

```
@course-factory-agent

Create a personalized course for warehouse logistics supervisors learning AI-assisted
exception triage in SAP WMS. They know SQL but have no ML background.

Requirements:
- Max 4 hours total
- 6 chapters
- Focus on: prompt engineering, error recovery, batch automation
- Intermediate difficulty
- No podcast scripts
- All code examples in Python
```

You can phrase requirements naturally — "keep it under 5 hours", "about 8 chapters",
"emphasize hands-on practice" all work. The agent understands plain language.

**Option 2 — Edit `inputs/general-requirements.yaml` directly**

For precise control, open [`inputs/general-requirements.yaml`](inputs/general-requirements.yaml)
and uncomment the fields you want to set. Every field is documented with examples:

```yaml
total_hours_max: 4
chapter_count: 6
difficulty_target: intermediate
focus_areas:
  - "prompt engineering"
  - "error recovery"
  - "batch automation"
artifact_types:
  - doc
  - exercises
  - slides
  - quiz
  - companion          # no podcast
custom_instructions: |
  All code examples must be in Python. No shell scripts.
```

Then run:

```
@course-factory-agent
The input files are ready in inputs/. Generate the course.
```

**Option 3 — Mix both**

Pre-fill `inputs/general-requirements.yaml` for your standing constraints (e.g., always
Python, always self-paced), then add one-off overrides in your message (e.g., "this time
make it 5 chapters"). Inline requirements are merged with the file; inline values win on
any field that appears in both.

### What happens at planning time

Every active requirement is surfaced in the **normalization diff** (your first human-review
halt) so you can confirm how the planner interpreted them before any content is generated.
The final **course plan** also lists all applied requirements. If a requirement cannot be
satisfied (e.g., 3 chapters is too few for 18 topics), the planner will flag the conflict
and ask you how to resolve it.

All requirements are logged in `_plan/CHANGELOG.md` for traceability.

---

## Pipeline Architecture

```
planner-agent (opus)
  └─ two human-review halts: Step 2 (normalization) + Step 12 (PLAN_REVIEW.md)
  └─ outputs: _plan/course-plan.yaml, personalization-plan.json, reserved-scenarios.json

environment-scaffold-generator (sonnet)  [run once]

chapter-supervisor-agent (sonnet)  [per chapter, max 3 retries per artifact]
  ├─ chapter-text-generator    → chapter-text-evaluator    [sequential]
  ├─ exercise-generator        → exercise-evaluator        [sequential]
  ├─ presentation-generator ─┐ → presentation-evaluator ─┐ [parallel]
  ├─ quiz-generator         ─┘ → quiz-evaluator          ─┘
  ├─ podcast-generator         → podcast-evaluator        [sequential]
  ├─ companion-generator       → companion-evaluator      [sequential]
  └─ glossary-aggregator                                  [after all pass]

evaluator-agent (opus)  [after all chapters]

lab-generator (sonnet)   → lab-evaluator (opus)

generate-course-podcasts (sonnet)  [after the capstone; best-effort]
  └─ drives tools/notebooklm_podcast_gen.py → one NotebookLM Audio Overview per chapter,
     in a shared notebook, each framed as part of the course series

course README (README.docx)  [student onboarding guide]
```

Every evaluator spawns all 7 quality gate sub-agents in parallel.

---

## Quality Gates

Every artifact must pass 7 quality gates before shipping:

| Gate | Checks |
|------|--------|
| §16.1 Coverage | Every LO in ≥ 1 assessment; all Bloom tiers present |
| §16.2 Pedagogy | Retrieval checkpoints, worked examples, ≥ 60% hands-on time |
| §16.3 Personalization | All examples from personalization plan; no forbidden scenarios |
| §16.4 Format | Word count, slide count, section order, file naming |
| §16.5 Technical | Code compiles, verify/ passes, preflight succeeds |
| §16.6 Accessibility | WCAG 2.2 AA: alt text, contrast, no color-only info |
| §16.7 Calibration | Difficulty heuristic, rubric schema, FK reading grade |

On any gate failure, the generator is re-invoked with the specific failures as feedback
(up to 3 attempts). On 3rd failure, the pipeline halts and asks for human intervention.

---

## Changing the Subject

To generate a course on a different topic:
1. Replace `inputs/subject.md` with your subject specification
2. Fill in `inputs/problem.yaml` and `inputs/students.yaml` for your domain
3. Run `@planner-agent`

The default subject (`inputs/subject.md`) is an 18-chapter course on Claude-based workflow
automation for knowledge workers (Cowork Automation).

---

## Repository Structure

```
.claude/
  agents/           ← agent files (generators, evaluators, gate sub-agents, spec builders,
                       course-factory-agent, generate-course-podcasts)
  skills/           ← skill files (detailed generation + orchestration instructions)
  settings.json     ← project permissions

tools/              ← reusable helper scripts
  notebooklm_podcast_gen.py  ← batch NotebookLM podcast generator (used by generate-course-podcasts)
  README.md

doc/                ← specification documents (read-only)
  GreatCourseSpec.md         ← master spec
  PlannerSpec.md
  GreatTextSpec.md
  GreatModuleExercise.md
  GreatPresentationSpec.md
  GreatQuizSpec.md
  GreatLabSpec.md
  MainSubjectSpec-Practical-Cowork-Automation.md

inputs/                      ← user-supplied configuration (edit these)
  problem.yaml               ← problem domain + scenarios (REQUIRED)
  students.yaml              ← cohort profile (REQUIRED)
  general-requirements.yaml  ← global overrides: time, chapters, focus, difficulty (OPTIONAL)
  subject.md                 ← subject specification (default: Cowork Automation)
  orchestration.yaml         ← low-level pipeline settings

outputs/            ← generated course content (created at runtime)
  {course_slug}/
    _plan/
    chapters/
    capstone/
    environment/
    glossary.docx
    README.docx                  ← student onboarding guide
    COURSE_VERDICT.md
    _podcast_gen.results.json    ← podcast generation state (chapter podcasts live in NotebookLM)

CLAUDE.md           ← project guide + shared schemas (always loaded by Claude Code)
```

---

## Spec Precedence

When specifications conflict, this order resolves them:

```
General Requirements > Student Context > Problem Spec > Subject Spec > Orchestration Spec > Master Spec defaults
```

See [Global Course Requirements](#global-course-requirements) for how to set requirements
and what they override. The master spec's quality MUST gates cannot be overridden by any
input — they are non-negotiable.

---

## Requirements

- **Claude Code (required — install this first).** This entire pipeline *is* a set of Claude
  Code agents and skills; nothing here runs without it. If you don't already have it:

  ```bash
  npm install -g @anthropic-ai/claude-code      # requires Node.js 18+
  ```

  Then verify and launch it from the repo root:

  ```bash
  claude --version
  claude            # starts Claude Code in the current directory
  ```

  (Full install options — native installer, updates, troubleshooting — are at
  <https://docs.claude.com/en/docs/claude-code>.) Once Claude Code is running, invoke the agents
  below with `@agent-name` and skills with `/skill-name`.
- Node.js 18+ (for Claude Code itself, and for `npx mmdc` — Mermaid diagram export)
- Lab environment tools as declared in your subject spec (Python, etc.)
- The `pptx-generator` skill (ships under `.claude/skills/pptx-generator/`) and the
  `anthropic-skills:docx` skill. `pptx-generator` renders slide decks with PptxGenJS and needs
  `pptxgenjs` installed in your project. Run the one-shot installer below — see
  [Setting up slide rendering](#setting-up-slide-rendering). `anthropic-skills:docx` is available
  globally in Claude Code with no setup.
- **For chapter podcasts (optional):** the NotebookLM CLI / MCP server and a NotebookLM login.
  See [Setting up NotebookLM podcasts](#setting-up-notebooklm-podcasts-optional) below for the
  full install, authentication, and Claude Code registration steps. Without it, the podcast
  phase is skipped and the rest of the course still generates.

---

## Setting up slide rendering

Chapter slide decks (`slides.pptx`) are rendered by the **`pptx-generator`** skill, which compiles
[PptxGenJS](https://gitbrent.github.io/PptxGenJS/) slide scripts into a `.pptx`. That requires the
`pptxgenjs` package to be installed in your project. A one-shot installer sets it up.

### Run the installer (once per project)

Run it from your **project root** — the directory where you launch Claude Code and where
`outputs/` is generated:

```powershell
# Windows (PowerShell)
pwsh tools/install-pptx-prereqs.ps1
```

```bash
# macOS / Linux
bash tools/install-pptx-prereqs.sh
```

That installs, into the project's local `node_modules/`:

- **`pptxgenjs`** — required; builds the `.pptx`.
- **`markitdown[pptx]`** — recommended QA tool that extracts text from a `.pptx` (skipped
  automatically if Python is unavailable; opt out with `-SkipMarkitdown` / `--skip-markitdown`).

Add `-WithIcons` (PowerShell) or `--with-icons` (bash) to also install the optional
`react-icons react react-dom sharp` libraries used for rasterized slide icons.

### Why install into the project root

When the pipeline builds a deck it generates PptxGenJS scripts under
`outputs/<course_slug>/chapters/<ch>/_pptx-build/slides/` and runs them with Node. Node resolves
`require('pptxgenjs')` by walking **up** the directory tree, so a `pptxgenjs` installed in the
project root's `node_modules/` is found from the build directory. (The build scripts are deleted
automatically after each deck is compiled — only `slides.pptx` is kept.) Generate your courses
from the same directory where you ran the installer.

Prerequisites: **Node.js 18+** (already required for Claude Code) and, for the optional QA tool,
**Python 3** with `pip`.

---

## Setting up NotebookLM podcasts (optional)

The pipeline's chapter-podcast phase (and the `@generate-course-podcasts` agent) uses
[NotebookLM](https://notebooklm.google.com) via the **`notebooklm-mcp-cli`** package, which
provides two things from one install: the **`nlm`** command-line tool and the **`notebooklm-mcp`**
MCP server. Setup is three steps. If you skip it, course generation still works — the podcast
phase simply records itself as skipped.

### 1. Install `notebooklm-mcp` (and the `nlm` CLI)

One package installs both the `nlm` CLI and the `notebooklm-mcp` server:

```bash
uv tool install notebooklm-mcp-cli      # recommended
# or:
pip install notebooklm-mcp-cli
```

Verify both commands are on your `PATH`:

```bash
nlm --version
notebooklm-mcp --help        # the MCP server entry point
```

(Project home: <https://github.com/sirmews/notebooklm-mcp>.)

### 2. Authenticate to NotebookLM (`nlm login`)

Log in once; the tool stores credentials under `~/.notebooklm-mcp-cli/`:

```bash
nlm login                    # opens a browser for Google sign-in
nlm login --check            # confirms: "✓ Authentication valid! ... Account: ..."
```

- Multiple Google accounts: `nlm login switch <profile>` selects the active one.
- Re-auth when the session expires: just run `nlm login` again.
- **Trust `nlm login --check`** as the source of truth. The MCP server's own health report
  (`server_info` / `refresh_auth`) sometimes shows a *false* "auth expired" because its probe
  hits the NotebookLM web homepage, which redirects to Google sign-in even when the API works.
  The pipeline is built to trust the CLI check, not that probe.

### 3. Register the MCP server with Claude Code

So Claude Code agents can call NotebookLM tools, register the `notebooklm-mcp` server:

```bash
claude mcp add notebooklm-mcp --scope user -- notebooklm-mcp
```

Or add it manually to your Claude config (`~/.claude.json`, or a project-level `.mcp.json`):

```json
{
  "mcpServers": {
    "notebooklm-mcp": {
      "type": "stdio",
      "command": "notebooklm-mcp",
      "args": []
    }
  }
}
```

> **Behind a corporate proxy / custom CA?** Add the cert bundle to the server's `env` block so
> its HTTPS calls succeed:
> ```json
> "env": {
>   "SSL_CERT_FILE": "C:\\path\\to\\corp-ca-bundle.pem",
>   "REQUESTS_CA_BUNDLE": "C:\\path\\to\\corp-ca-bundle.pem"
> }
> ```

Restart Claude Code, then confirm the server is connected:

```bash
claude mcp list              # notebooklm-mcp should appear
```

…or run `/mcp` inside Claude Code.

> **Note:** the batch tool `tools/notebooklm_podcast_gen.py` drives NotebookLM through the
> package directly and only needs step 2 (`nlm login`) — not the MCP server. Step 3 is what lets
> the interactive agents/skills call NotebookLM MCP tools. Installing all three is recommended so
> both paths work.

### Slide conversion (optional, for richer podcasts)

Each chapter's `slides.pptx` is converted to `slides.pdf` before upload using **LibreOffice**
(`soffice`) or **PowerPoint** (COM automation on Windows). If neither is available, slides are
dropped and the podcast is generated from the chapter doc and script alone.
