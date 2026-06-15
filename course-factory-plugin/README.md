# Personalized Course Factory (Claude Code plugin)

Generate complete, personalized technical training courses with a single multi-agent
pipeline: planning → environment → chapters (doc, exercises, slides, quiz, podcast
script, companion) → course evaluation → capstone lab → NotebookLM podcasts → student
onboarding guide. Everything is grounded in learning-science best practices and
personalized to the learner's domain and reading level.

> This directory is **generated** by `tools/build_plugin.py` from the canonical
> sources under `.claude/`, `doc/`, `tools/`, and `CLAUDE.md`. Do not edit it by
> hand — edit the sources and re-run the build.

## Install

```
/plugin marketplace add manucohenyashar/personalized_course_factory
/plugin install personalized-course-factory@course-factory-marketplace
```

(Or, for local development, point Claude Code at this folder with
`claude --plugin-dir course-factory-plugin`.)

## Use

From any project, after installing:

1. Prepare the curriculum and cohort specs (or let the builder agents do it):
   - `@subject-spec-builder-agent` — build/validate `inputs/subject.md`
   - `@spec-builder-agent` — build `inputs/problem.yaml` + `inputs/students.yaml`
   - Starter templates are bundled under `templates/inputs/`.
2. Generate the course end to end:
   - `@course-factory-agent` — runs the full pipeline (two human-review halts in planning).
3. Or drive it manually with the bundled commands, e.g.
   `/personalized-course-factory:plan-course`, `/personalized-course-factory:next-chapter`,
   `/personalized-course-factory:course-status`, `/personalized-course-factory:generate-lab`.

Outputs are written under `outputs/{course_slug}/` in your current project.

## What's inside

- **30 agents** (`agents/`) — orchestrator, planner, per-chapter supervisor,
  generators, evaluators, and the 7 quality-gate sub-agents.
- **12 commands** (`commands/`) — the orchestration and per-artifact skills
  (invoke as `/personalized-course-factory:<command>`).
- **Specs** (`doc/`) — the binding specifications the agents follow.
- **Skills** (`skills/`) — bundled skills the agents invoke, including the `pptx-generator`
  slide renderer.
- **Tools** (`tools/`) — `notebooklm_podcast_gen.py` (batch NotebookLM podcast generator) and
  `install-pptx-prereqs.{ps1,sh}` (slide-rendering prerequisites installer).
- **`course-factory-guide.md`** — the project rules/schemas the agents read (the project's
  `CLAUDE.md`, bundled; agents load it from `${CLAUDE_PLUGIN_ROOT}/course-factory-guide.md`).
- **`templates/inputs/`** — starter input files.

## Setting up slide rendering

Chapter slide decks are rendered by the bundled **`pptx-generator`** skill (under `skills/`), which
compiles [PptxGenJS](https://gitbrent.github.io/PptxGenJS/) scripts into a `.pptx`. That needs the
`pptxgenjs` package installed in your project. Run the bundled one-shot installer from your project
root (where `outputs/` is generated):

```powershell
# Windows (PowerShell)
pwsh ${CLAUDE_PLUGIN_ROOT}/tools/install-pptx-prereqs.ps1
```

```bash
# macOS / Linux
bash ${CLAUDE_PLUGIN_ROOT}/tools/install-pptx-prereqs.sh
```

It installs `pptxgenjs` (required) plus the optional `markitdown[pptx]` QA tool into your project's
`node_modules/`. The pipeline generates the slide scripts under
`outputs/<course_slug>/chapters/<ch>/_pptx-build/` and deletes them after compiling each deck, so
only `slides.pptx` is kept. Requires Node.js 18+ (and Python 3 for the optional QA tool).

## Optional: NotebookLM podcasts

The chapter-podcast phase uses NotebookLM via the `notebooklm-mcp-cli` package
(provides the `nlm` CLI and the `notebooklm-mcp` server declared in `.mcp.json`):

```
uv tool install notebooklm-mcp-cli      # or: pip install notebooklm-mcp-cli
nlm login                               # authenticate (verify: nlm login --check)
```

Without it, the podcast phase is skipped and the rest of the course still generates.

## Requirements

- Claude Code, Node.js 18+ (for the bundled `pptx-generator` slide renderer, which uses
  PptxGenJS), Python 3 (for the podcast tool), and the `anthropic-skills:docx` skill. The
  `pptx-generator` skill ships with the plugin under `skills/`.
- See the project README for full details: https://github.com/manucohenyashar/personalized_course_factory
