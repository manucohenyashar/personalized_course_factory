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
| `content_files` | List of local file paths to upload as source material. |

If any input is missing from the user's request, ask for it before proceeding. Do not
invent a notebook name, a podcast name, or file paths.

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

For every path in `content_files`, call `mcp__notebooklm-mcp__source_add` with:

- `notebook_id = <notebook_id>`
- `source_type = "file"`
- `file_path = <the path>`
- `wait = true` (so processing completes before moving on; raise `wait_timeout` for
  large media files)

Track the returned source ID for each file. Behavior on failure:

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
- Optionally pass `source_ids` with the IDs collected in Step 2 to scope the podcast to
  exactly the uploaded files; omit to use all sources in the notebook.

Record the returned artifact ID as `podcast_id`.

If `studio_create` fails, surface a descriptive error ("Podcast generation failed") with
the reason and stop.

## Step 4 — Name the podcast

The audio artifact is created without the requested title, so rename it: call
`mcp__notebooklm-mcp__studio_status` with `action = "rename"`,
`notebook_id = <notebook_id>`, `artifact_id = <podcast_id>`, and
`new_title = podcast_name`.

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
