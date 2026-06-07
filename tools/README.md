# tools/

Reusable helper scripts for the course factory pipeline.

## `notebooklm_podcast_gen.py`

Batch-generates one NotebookLM **Audio Overview (podcast) per chapter** for a whole course,
into a single shared notebook. Used by the `orchestrate-generation-course-podcasts` agent.

```bash
python tools/notebooklm_podcast_gen.py \
  --notebook-name "<course_slug>" \
  --course-root   "outputs/<course_slug>"
```

Run it with **any** Python — it auto-re-execs into the `notebooklm-mcp-cli` virtualenv Python
(located next to the `nlm` executable, or in the standard uv/pipx tool dirs). Prerequisite:
`nlm login` has been run and is valid (check with `nlm login --check`).

**Flags:** `--rename-only` (only the post-completion rename pass), `--no-rename` (generate
without waiting to rename), `--no-slides` (skip slides upload).

**Resumable:** progress is written to `<course_root>/_podcast_gen.results.json`. Re-running
skips chapters already marked `ok` and retries the rest — no manual cleanup needed.

### Why this exists (problems it solves)

The `notebooklm-mcp` `studio_create` tool (and `server_info` / `refresh_auth`) report a **false
`auth expired`** on many accounts: their live health check fetches the NotebookLM HTML homepage,
which redirects to the Google sign-in page, even though the RPC API auth is valid. This script
bypasses the broken guard by driving the package's working client + service layer directly. It
also handles:

- **Per-chapter source scoping** — all chapters share one notebook, so each podcast is generated
  with `source_ids` limited to that chapter's 3 files (otherwise podcasts bleed across chapters).
- **Transient upload errors** — `source_add` intermittently returns `INVALID_ARGUMENT`; uploads
  are retried with backoff, and a chapter's partial uploads are deleted on failure (no orphans).
- **Rename-after-completion** — NotebookLM overwrites an audio title with its own on completion,
  so renames are applied in a post-completion polling pass.
- **Slides conversion** — converts `slides.pptx` → `slides.pdf` (LibreOffice `soffice`, else
  PowerPoint COM); drops slides gracefully if no converter is available.

See also: `.claude/skills/generate-notebooklm-podcast.md` for the single-podcast case.
