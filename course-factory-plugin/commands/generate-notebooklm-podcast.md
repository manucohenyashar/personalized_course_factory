---
name: generate-notebooklm-podcast
description: Automate end-to-end creation of a NotebookLM Audio Overview (podcast) from a set of source files using the notebooklm-mcp server. Given a notebook name, a podcast name, and a list of content file paths, this skill verifies the MCP server is available, finds or creates the target notebook, uploads every source file, triggers podcast (audio) generation, names it, and returns the notebook and podcast identifiers. Use when the user asks to "make a NotebookLM podcast", "generate an audio overview from these files", or "turn these documents into a podcast".
---

# Generate NotebookLM Podcast

Drive the `notebooklm-mcp` server to produce a NotebookLM Audio Overview ("podcast")
from a set of source files, end to end. The skill is idempotent on the notebook: if a
notebook with the requested name already exists it is reused, otherwise it is created.

## Inputs

| Input | Meaning |
|-------|---------|
| `notebook_name` | Name of the target NotebookLM notebook (find-or-create). |
| `podcast_name` | Title to assign to the generated Audio Overview. |
| `content_files` | Source material to upload. Either a list of local file paths, or a list of `{ "path": <local path>, "display_title": <name to show in the notebook> }` objects when you want each uploaded source to have a distinct display name (see Step 2). |
| `general_instructions` | *Optional.* Free-text context about the rest of the course and how this episode fits in, plus any extra steering for the host(s). It is passed to NotebookLM as the audio **focus prompt** (Step 3) so the podcast references its place in the series and does not re-tell the overall scenario from scratch. Example: *"This is Chapter 3 of 9 of the course 'Automate Your Work with Claude'. Open by saying 'This is the podcast for Chapter 3 of 9 …'. Do not re-introduce the overall scenario or characters from scratch — assume listeners have heard the earlier chapters; briefly connect back and preview the next chapter."* |

If a required input (`notebook_name`, `podcast_name`, `content_files`) is missing from the
user's request, ask for it before proceeding. Do not invent a notebook name, a podcast name,
or file paths. `general_instructions` is optional — omit the focus prompt when it is absent.

Supported source file extensions (per the MCP server): PDF, TXT, MD, DOCX, CSV, EPUB,
MP3, M4A, WAV, AAC, OGG, OPUS, MP4, JPG, JPEG, PNG, GIF, WEBP. If a path in
`content_files` has an unsupported extension or does not exist on disk, flag it before
the upload step rather than failing mid-run.

---

## Step 0 — Verify the notebooklm-mcp server is available

Call `mcp__notebooklm-mcp__server_info`.

- If the tool is **not connected** (no `notebooklm-mcp` tools are available in this
  session) and **no alternative NotebookLM tool is connected**, stop and return this
  exact error message:

  ```
  Error: The notebooklm-mcp server is not available.
  To install it, follow the instructions at: https://github.com/sirmews/notebooklm-mcp
  ```

- If `server_info` returns and `auth_status` is `not_configured` or `stale`, stop and
  tell the user to authenticate by running `nlm login` in their terminal (suggest the
  `! nlm login` prefix so the output lands in this session), then re-run the skill. An
  `unverified` status may still work, so proceed but be ready to surface an auth error.
- If `update_available` is `True`, mention the available update and the
  `update_command`, but continue.

Only fall through to the install error when the server genuinely cannot be reached. A
returning `server_info` call means the server is available.

## Step 1 — Find or create the notebook

1. Call `mcp__notebooklm-mcp__notebook_list`.
2. Look for a notebook whose title matches `notebook_name` (case-insensitive exact
   match).
   - **Found:** reuse it. Record its notebook UUID as `notebook_id`. If more than one
     notebook shares the name, prefer the most recently updated and tell the user which
     one was selected.
   - **Not found:** call `mcp__notebooklm-mcp__notebook_create` with
     `title=notebook_name`. Record the returned UUID as `notebook_id`.
3. If notebook creation fails, surface a descriptive error naming the step
   ("Notebook creation failed") and the underlying reason, then stop.

## Step 2 — Upload each content file

For every entry in `content_files`, call `mcp__notebooklm-mcp__source_add` with:

- `notebook_id = <notebook_id>`
- `source_type = "file"`
- `file_path = <the path>`
- `wait = true` (so processing completes before moving on; raise `wait_timeout` for
  large media files)

Track the returned source ID for each file. Behavior on failure:

> **Setting a distinct display name (`display_title`).** The file-upload RPC ignores any
> title and shows the on-disk filename, so when entries provide a `display_title` (or when you
> otherwise need unique names — e.g. several chapters of one course share a notebook and all
> have files literally named `tutorial.docx` / `slides.pdf`), apply the name with a follow-up
> `mcp__notebooklm-mcp__source_rename` (`notebook_id`, the returned `source_id`, and the
> desired title) right after the upload of that file. This is what lets sources be uploaded as,
> e.g., `chapter_03_tutorial.docx` so a person browsing the notebook can tell which chapter each
> file belongs to.



- If a single file fails to upload, report which file failed and why, then ask the user
  whether to continue with the successfully uploaded files or abort. Do not silently
  skip a file.
- If **no** files upload successfully, stop with an error: podcast generation needs at
  least one source.

## Step 3 — Trigger podcast (audio) generation

Call `mcp__notebooklm-mcp__studio_create` with:

- `notebook_id = <notebook_id>`
- `artifact_type = "audio"`  (Audio Overview = podcast)
- `confirm = true`  (only after the user has approved generation; if they have not
  explicitly approved, confirm with them first since this consumes NotebookLM quota)
- `source_ids` = the IDs collected in Step 2, to scope the podcast to exactly the files
  uploaded for THIS episode. When several episodes of a course share one notebook this is
  **required**, not optional — otherwise the podcast would be generated from every chapter's
  sources. Omit only when the notebook holds a single episode's sources.
- `focus_prompt = general_instructions` — when `general_instructions` is provided, pass it as
  the focus prompt so NotebookLM frames the episode within the series (states its position,
  avoids re-telling the scenario from scratch, connects to adjacent chapters). Omit when
  `general_instructions` is absent.

Record the returned artifact ID as `podcast_id`.

> **Known false positive — "auth expired" / "reason: expired".** On some accounts
> `studio_create` refuses with an `auth expired` error **even when auth is valid** (verify
> with `nlm login --check`). Its pre-flight guard fetches the NotebookLM HTML homepage, which
> redirects to the Google sign-in page, so the guard reports `expired` before ever attempting
> the real call. `notebook_list` / `source_add` have no such guard and work fine. **Do not
> tell the user to re-login if `nlm login --check` is already valid.** Instead, bypass the
> guard by driving the package service layer directly with the working client:
>
> ```python
> # run with the notebooklm-mcp-cli venv python (next to the `nlm` executable)
> from notebooklm_tools.mcp.tools._utils import get_client
> from notebooklm_tools.services import studio as st
> res = st.create_artifact(get_client(), notebook_id, "audio", source_ids=[...])
> # res["artifact_id"] is the podcast id
> ```
>
> For the whole-course batch case, prefer the committed tool
> `${CLAUDE_PLUGIN_ROOT}/tools/notebooklm_podcast_gen.py`, which encodes this and the other workarounds (upload
> retries, orphan cleanup, rename-after-completion, per-chapter source scoping).

If `studio_create` fails for a reason other than the false-positive above, surface a
descriptive error ("Podcast generation failed") with the reason and stop.

## Step 4 — Name the podcast

The audio artifact is created without the requested title, so rename it: call
`mcp__notebooklm-mcp__studio_status` with `action = "rename"`,
`notebook_id = <notebook_id>`, `artifact_id = <podcast_id>`, and
`new_title = podcast_name`.

> **Rename only sticks after completion.** NotebookLM overwrites an audio artifact's title
> with its own auto-generated title **when generation finishes**. A rename applied while the
> artifact is still `in_progress` (the RPC often returns falsy) will be lost. If you need the
> title to persist, run the rename in Step 5 **after** the artifact reports `completed`.

If rename fails, it is non-fatal: report that the podcast was generated but could not be
renamed, and include the default title.

## Step 5 — (Optional) Wait for completion

Audio generation runs asynchronously. If the user wants the final result now, poll
`mcp__notebooklm-mcp__studio_status` (`action = "status"`, `notebook_id = <notebook_id>`)
until the audio artifact reports completed, then include its playback/download URL. If
the user only wants the generation kicked off, skip polling and note that the podcast is
processing.

## Step 6 — Return the confirmation

On success, return:

```
✓ NotebookLM podcast generation started.

Notebook:  {notebook_name}  (id: {notebook_id})  [reused | created]
Podcast:   {podcast_name}   (id: {podcast_id})
Sources:   {N} file(s) uploaded
Status:    {processing | completed}
{If completed: Listen/download: {url}}
```

---

## Error handling summary

- **Server unavailable** (and no alternative NotebookLM tool connected): return the
  exact install-instructions error from Step 0.
- **Any step fails** (notebook creation, file upload, podcast generation, rename):
  return a descriptive error that names *which* step failed and *why* (include the
  underlying message from the MCP tool). Never report success when a required step
  failed.
