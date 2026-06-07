# tools/

Reusable helper scripts for the course factory pipeline.

## `notebooklm_podcast_gen.py`

Batch-generates one NotebookLM **Audio Overview (podcast) per chapter** for a whole course,
into a single shared notebook. Used by the `generate-course-podcasts` agent.

```bash
python tools/notebooklm_podcast_gen.py \
  --notebook-name "<course_slug>" \
  --course-root   "outputs/<course_slug>" \
  --course-title  "<human course title>"
```

Run it with **any** Python — it auto-re-execs into the `notebooklm-mcp-cli` virtualenv Python
(located next to the `nlm` executable, or in the standard uv/pipx tool dirs). Prerequisite:
`nlm login` has been run and is valid (check with `nlm login --check`).

**Flags:** `--course-title "<title>"` (human course title used in the series framing; defaults
to a prettified `--notebook-name`), `--general-instructions "<text>"` (extra steering appended
to every episode's series prompt), `--rename-only` (only the post-completion rename pass),
`--no-rename` (generate without waiting to rename), `--no-series-prompt` (disable series
framing), `--no-slides` (skip slides upload).

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
- **Distinguishable source names** — on-disk files are all `tutorial.docx` / `slides.pdf` /
  `podcast-script.md`; each upload is titled `chapter_{NN}_…` so the shared notebook is browsable.
- **Course-series framing** — each podcast is generated with a focus prompt stating it is Chapter
  N of M of the course, so it references the series and does not re-tell the scenario from
  scratch. Append extra guidance with `--general-instructions`.
- **Transient upload errors** — `source_add` intermittently returns `INVALID_ARGUMENT`; uploads
  are retried with backoff, and a chapter's partial uploads are deleted on failure (no orphans).
- **Rename-after-completion** — NotebookLM overwrites an audio title with its own on completion,
  so renames are applied in a post-completion polling pass.
- **Slides conversion** — converts `slides.pptx` → `slides.pdf` (LibreOffice `soffice`, else
  PowerPoint COM); drops slides gracefully if no converter is available.

See also: `.claude/skills/generate-notebooklm-podcast.md` for the single-podcast case.
