#!/usr/bin/env python
"""
build_plugin.py — assemble the Personalized Course Factory as a self-contained,
relocatable Claude Code plugin.

WHY THIS EXISTS
---------------
The factory's agents and skills live under `.claude/` and reference sibling files
by repo-relative paths (`doc/*.md` specs, `tools/notebooklm_podcast_gen.py`, and
`CLAUDE.md`). Those paths only resolve when Claude Code runs *inside this repo*.
A plugin, however, is installed into someone else's project, so bundled-file
references must point at the plugin's own install dir via `${CLAUDE_PLUGIN_ROOT}`.

This script keeps `.claude/` as the single source of truth and *generates* a
self-contained plugin under `course-factory-plugin/`:

  - .claude/agents/*.md   → course-factory-plugin/agents/*.md      (paths rewritten)
  - .claude/skills/*.md   → course-factory-plugin/commands/*.md    (paths rewritten)
  - doc/*.md              → course-factory-plugin/doc/*.md         (copied verbatim)
  - tools/notebooklm_podcast_gen.py → course-factory-plugin/tools/ (copied verbatim)
  - CLAUDE.md             → course-factory-plugin/CLAUDE.md        (copied verbatim)
  - inputs/templates/*    → course-factory-plugin/templates/inputs/ (copied)
  - generated: .claude-plugin/plugin.json, .mcp.json, README.md

It also writes/refreshes `.claude-plugin/marketplace.json` at the repo root so the
repo doubles as the install marketplace.

Re-run after editing anything under `.claude/`, `doc/`, `tools/`, or `CLAUDE.md`:

    python tools/build_plugin.py

PATH REWRITES (applied to agent + command markdown only; never to copied specs):
  <repo_root>/tools/notebooklm_podcast_gen.py → ${CLAUDE_PLUGIN_ROOT}/tools/...
  tools/notebooklm_podcast_gen.py             → ${CLAUDE_PLUGIN_ROOT}/tools/...
  doc/<spec>.md                               → ${CLAUDE_PLUGIN_ROOT}/doc/<spec>.md
  CLAUDE.md                                   → ${CLAUDE_PLUGIN_ROOT}/CLAUDE.md
`inputs/` and `outputs/` are intentionally NOT rewritten — they are the user's
project working directories (resolved from the cwd where Claude Code runs).
"""

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PLUGIN_NAME = "personalized-course-factory"
PLUGIN_DIR = REPO / "course-factory-plugin"
REPO_URL = "https://github.com/manucohenyashar/personalized_course_factory"
VERSION = "1.0.0"

PLUGIN_ROOT = "${CLAUDE_PLUGIN_ROOT}"


# ---------------------------------------------------------------------------
# Path rewriting (agents + commands only)
# ---------------------------------------------------------------------------
def rewrite_paths(text: str) -> str:
    # Most-specific first: the literal "<repo_root>/tools/..." invocation.
    text = text.replace(
        "<repo_root>/tools/notebooklm_podcast_gen.py",
        f"{PLUGIN_ROOT}/tools/notebooklm_podcast_gen.py",
    )
    # Bare references, but not when already part of a path or a ${VAR}/ prefix.
    # Negative lookbehind excludes a preceding word char, slash, '$', or '}'.
    text = re.sub(
        r"(?<![\w/$}])tools/notebooklm_podcast_gen\.py",
        f"{PLUGIN_ROOT}/tools/notebooklm_podcast_gen.py",
        text,
    )
    text = re.sub(
        r"(?<![\w/$}])doc/([A-Za-z0-9_.-]+\.md)",
        rf"{PLUGIN_ROOT}/doc/\1",
        text,
    )
    # Bundle the project guide under a non-special name so Claude Code does not
    # treat it as an (inert) plugin-root CLAUDE.md; agents read it explicitly.
    text = re.sub(
        r"(?<![\w/$}])CLAUDE\.md",
        f"{PLUGIN_ROOT}/course-factory-guide.md",
        text,
    )
    return text


# ---------------------------------------------------------------------------
# Copy helpers
# ---------------------------------------------------------------------------
def copy_markdown_rewritten(src_dir: Path, dst_dir: Path) -> int:
    dst_dir.mkdir(parents=True, exist_ok=True)
    n = 0
    for f in sorted(src_dir.glob("*.md")):
        (dst_dir / f.name).write_text(
            rewrite_paths(f.read_text(encoding="utf-8")), encoding="utf-8"
        )
        n += 1
    return n


def copy_tree_verbatim(src_dir: Path, dst_dir: Path, pattern: str = "*") -> int:
    dst_dir.mkdir(parents=True, exist_ok=True)
    n = 0
    for f in sorted(src_dir.glob(pattern)):
        if f.is_file():
            shutil.copy2(f, dst_dir / f.name)
            n += 1
    return n


# ---------------------------------------------------------------------------
# Generated files
# ---------------------------------------------------------------------------
def plugin_manifest() -> dict:
    return {
        "$schema": "https://json.schemastore.org/claude-code-plugin-manifest.json",
        "name": PLUGIN_NAME,
        "displayName": "Personalized Course Factory",
        "version": VERSION,
        "description": (
            "Multi-agent pipeline that generates complete, personalized technical "
            "training courses — chapter docs, exercises, slide decks, quizzes, a "
            "capstone lab, NotebookLM podcasts, and a student onboarding guide — all "
            "grounded in learning-science best practices and personalized to the "
            "learner's domain and reading level."
        ),
        "author": {"name": "Manu Cohen Yashar"},
        "homepage": REPO_URL,
        "repository": REPO_URL,
        "license": "MIT",
        "keywords": [
            "course", "education", "training", "curriculum", "instructional-design",
            "learning-science", "agents", "notebooklm", "podcast",
        ],
    }


def mcp_config() -> dict:
    # Declares the optional NotebookLM MCP server. Requires the user to have
    # installed notebooklm-mcp-cli (provides the `notebooklm-mcp` command) and run
    # `nlm login`. If absent, the server simply fails to start and the rest of the
    # plugin works; the chapter-podcast phase is best-effort.
    return {
        "mcpServers": {
            "notebooklm-mcp": {
                "type": "stdio",
                "command": "notebooklm-mcp",
                "args": [],
            }
        }
    }


def plugin_readme(n_agents: int, n_commands: int) -> str:
    return f"""# Personalized Course Factory (Claude Code plugin)

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
/plugin install {PLUGIN_NAME}@course-factory-marketplace
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
   `/{PLUGIN_NAME}:plan-course`, `/{PLUGIN_NAME}:next-chapter`,
   `/{PLUGIN_NAME}:course-status`, `/{PLUGIN_NAME}:generate-lab`.

Outputs are written under `outputs/{{course_slug}}/` in your current project.

## What's inside

- **{n_agents} agents** (`agents/`) — orchestrator, planner, per-chapter supervisor,
  generators, evaluators, and the 7 quality-gate sub-agents.
- **{n_commands} commands** (`commands/`) — the orchestration and per-artifact skills
  (invoke as `/{PLUGIN_NAME}:<command>`).
- **Specs** (`doc/`) — the binding specifications the agents follow.
- **Tool** (`tools/notebooklm_podcast_gen.py`) — batch NotebookLM podcast generator.
- **`course-factory-guide.md`** — the project rules/schemas the agents read (the project's
  `CLAUDE.md`, bundled; agents load it from `${{CLAUDE_PLUGIN_ROOT}}/course-factory-guide.md`).
- **`templates/inputs/`** — starter input files.

## Optional: NotebookLM podcasts

The chapter-podcast phase uses NotebookLM via the `notebooklm-mcp-cli` package
(provides the `nlm` CLI and the `notebooklm-mcp` server declared in `.mcp.json`):

```
uv tool install notebooklm-mcp-cli      # or: pip install notebooklm-mcp-cli
nlm login                               # authenticate (verify: nlm login --check)
```

Without it, the podcast phase is skipped and the rest of the course still generates.

## Requirements

- Claude Code, Node.js 18+, Python 3 (for the podcast tool), and the
  `anthropic-skills:docx` / `anthropic-skills:pptx` skills.
- See the project README for full details: {REPO_URL}
"""


def marketplace_manifest() -> dict:
    return {
        "name": "course-factory-marketplace",
        "owner": {"name": "Manu Cohen Yashar", "url": REPO_URL},
        "description": (
            "Personalized Course Factory — install the full multi-agent "
            "course-generation pipeline as one plugin."
        ),
        "plugins": [
            {
                "name": PLUGIN_NAME,
                "source": "./course-factory-plugin",
                "description": (
                    "Multi-agent pipeline for generating complete, personalized "
                    "technical training courses (chapters, exercises, slides, quizzes, "
                    "capstone lab, NotebookLM podcasts) grounded in learning science."
                ),
                "version": VERSION,
                "license": "MIT",
                "homepage": REPO_URL,
                "keywords": ["course", "education", "training", "agents", "learning-science"],
            }
        ],
    }


# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------
def main() -> int:
    print(f"Building plugin -> {PLUGIN_DIR.relative_to(REPO)}")

    if PLUGIN_DIR.exists():
        shutil.rmtree(PLUGIN_DIR)
    PLUGIN_DIR.mkdir(parents=True)

    # Components (with path rewriting)
    n_agents = copy_markdown_rewritten(REPO / ".claude/agents", PLUGIN_DIR / "agents")
    n_commands = copy_markdown_rewritten(REPO / ".claude/skills", PLUGIN_DIR / "commands")
    print(f"  agents:   {n_agents}")
    print(f"  commands: {n_commands}")

    # Bundled reference files (verbatim)
    n_doc = copy_tree_verbatim(REPO / "doc", PLUGIN_DIR / "doc", "*.md")
    print(f"  doc specs: {n_doc}")

    (PLUGIN_DIR / "tools").mkdir(parents=True, exist_ok=True)
    for name in ("notebooklm_podcast_gen.py", "README.md"):
        src = REPO / "tools" / name
        if src.exists():
            shutil.copy2(src, PLUGIN_DIR / "tools" / name)
    print("  tools: notebooklm_podcast_gen.py (+ README)")

    shutil.copy2(REPO / "CLAUDE.md", PLUGIN_DIR / "course-factory-guide.md")
    print("  CLAUDE.md bundled as course-factory-guide.md")

    tpl_src = REPO / "inputs" / "templates"
    if tpl_src.exists():
        n_tpl = copy_tree_verbatim(tpl_src, PLUGIN_DIR / "templates" / "inputs")
        print(f"  input templates: {n_tpl}")

    # Generated manifests / config
    (PLUGIN_DIR / ".claude-plugin").mkdir(parents=True, exist_ok=True)
    (PLUGIN_DIR / ".claude-plugin" / "plugin.json").write_text(
        json.dumps(plugin_manifest(), indent=2) + "\n", encoding="utf-8"
    )
    (PLUGIN_DIR / ".mcp.json").write_text(
        json.dumps(mcp_config(), indent=2) + "\n", encoding="utf-8"
    )
    (PLUGIN_DIR / "README.md").write_text(
        plugin_readme(n_agents, n_commands), encoding="utf-8"
    )
    print("  plugin.json, .mcp.json, README.md written")

    # Marketplace at repo root (repo doubles as the marketplace)
    mp_dir = REPO / ".claude-plugin"
    mp_dir.mkdir(parents=True, exist_ok=True)
    (mp_dir / "marketplace.json").write_text(
        json.dumps(marketplace_manifest(), indent=2) + "\n", encoding="utf-8"
    )
    print("  .claude-plugin/marketplace.json written (repo = marketplace)")

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
