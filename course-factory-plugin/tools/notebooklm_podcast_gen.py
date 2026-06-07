#!/usr/bin/env python
"""
notebooklm_podcast_gen.py — batch-generate one NotebookLM podcast (Audio
Overview) per chapter for a whole course, into a single shared notebook.

WHY THIS SCRIPT EXISTS
----------------------
The `notebooklm-mcp` server's `studio_create` tool (used by the
`generate-notebooklm-podcast` skill) has a pre-flight auth guard that runs a
LIVE health check. On some Google accounts that check fetches the NotebookLM
HTML homepage, which redirects to the Google sign-in page even when auth is
perfectly valid — so `studio_create` (and `refresh_auth` / `server_info`)
report `auth expired` / `stale` and refuse to run, even right after a
successful `nlm login`. It is a FALSE POSITIVE: the real RPC API (used by
`notebook_list`, `source_add`, and the actual generation call) authenticates
via a SAPISID-hash and works fine. Symptom: the orchestrator loops forever on
"run nlm login" and generates zero podcasts.

This script bypasses the broken guard by driving the notebooklm-mcp-cli
package's WORKING client + service layer directly — exactly the code path the
succeeding MCP tools use. It also handles the other rough edges discovered in
practice:

  * Shared notebook, per-chapter scoping. All chapters share ONE notebook, so
    each podcast is scoped to that chapter's own 3 source_ids — otherwise every
    podcast would be generated from every chapter's content.
  * Distinguishable source names. Because all chapters share one notebook,
    every uploaded source is titled with a chapter prefix (e.g.
    `chapter_03_tutorial.docx`, `chapter_03_slides.pdf`, `chapter_03_podcast-script.md`)
    so a person browsing the notebook can tell which chapter each file belongs to.
  * Course-series framing. Each podcast is generated with a focus prompt telling
    NotebookLM the episode is Chapter N of M of the course, so it opens with that
    context (e.g. "This is the podcast for Chapter 3 of 9 of <course>: <title>.
    In this chapter we will discuss ...") and does NOT re-tell the overall
    scenario from scratch. Extra guidance can be appended via
    `--general-instructions`.
  * Transient `INVALID_ARGUMENT` upload errors. `source_add` intermittently
    fails (often on the 2nd/3rd file of a chapter). Uploads are retried with
    backoff; if a chapter still fails, its already-uploaded sources are deleted
    so no orphans accumulate.
  * Rename-after-completion. NotebookLM overwrites an audio artifact's title
    with its own auto-generated title WHEN GENERATION COMPLETES, so a rename
    applied while the artifact is still `in_progress` does not stick. Renames
    are therefore applied in a post-completion polling pass.
  * Resumable. Progress is written to `<course_root>/_podcast_gen.results.json`;
    re-running skips chapters already marked ok and retries the rest.

USAGE
-----
Run with ANY Python — the script auto-re-execs itself with the
notebooklm-mcp-cli virtualenv's Python (located next to the `nlm` executable)
if `notebooklm_tools` is not importable in the current interpreter:

    python tools/notebooklm_podcast_gen.py \
        --notebook-name "<course_slug>" \
        --course-root   "outputs/<course_slug>"

Options:
    --course-title "<title>"      human course title used in the series prompt
                                  (default: prettified --notebook-name)
    --general-instructions "..."  extra guidance appended to every chapter's
                                  series focus prompt
    --rename-only                 skip generation; only run the rename pass
    --no-rename                   generate only; do not wait/rename (fastest)
    --no-series-prompt            do not inject the course-series focus prompt
    --no-slides                   do not upload slides.pdf even if present

Prerequisites:
    * `nlm login` has been run and is valid (verify with `nlm login --check`).
    * The notebooklm-mcp-cli package is installed (the `nlm` CLI is on PATH).
    * Chapters live under <course_root>/chapters/ch{NN}-{slug}/ and each
      contains tutorial.docx, podcast-script.md, and (optionally) slides.pptx /
      slides.pdf. slides.pptx is converted to slides.pdf when possible
      (LibreOffice `soffice`, else PowerPoint COM); if conversion is
      unavailable the slides are dropped and the podcast is still generated
      from tutorial.docx + podcast-script.md.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path


# ---------------------------------------------------------------------------
# Bootstrap: ensure we run under the interpreter that has `notebooklm_tools`.
# ---------------------------------------------------------------------------
def _candidate_venv_pythons() -> list[Path]:
    """Best-effort list of interpreters that may have `notebooklm_tools`.

    The `nlm` entry on PATH is often a uv shim in ~/.local/bin (POSIX) or a
    launcher under WindowsApps, NOT the package venv. So we probe several
    known locations in addition to the dir next to `nlm`.
    """
    names = ("python.exe", "python", "python3")
    dirs: list[Path] = []

    nlm = shutil.which("nlm") or shutil.which("nlm.exe")
    if nlm:
        nlm_path = Path(nlm)
        dirs.append(nlm_path.parent)
        # If `nlm` is a symlink into the venv, its real parent is the venv bin.
        try:
            dirs.append(nlm_path.resolve().parent)
        except Exception:
            pass

    home = Path.home()
    appdata = Path(os.environ.get("APPDATA", home / "AppData/Roaming"))
    tool = "notebooklm-mcp-cli"
    # uv tool install layouts (Windows / POSIX) + pipx + plain venv.
    dirs += [
        appdata / "uv/tools" / tool / "Scripts",          # uv tool, Windows
        home / ".local/share/uv/tools" / tool / "bin",    # uv tool, POSIX
        home / ".local/pipx/venvs" / tool / "Scripts",    # pipx, Windows
        home / ".local/pipx/venvs" / tool / "bin",        # pipx, POSIX
    ]

    out, seen = [], set()
    for d in dirs:
        for name in names:
            p = d / name
            rp = str(p)
            if rp in seen:
                continue
            seen.add(rp)
            if p.exists():
                out.append(p)
    return out


def _ensure_notebooklm_tools() -> None:
    try:
        import notebooklm_tools  # noqa: F401
        return
    except Exception:
        pass

    # Guard against an infinite re-exec loop.
    if os.environ.get("_NLM_PODCAST_REEXEC") == "1":
        sys.stderr.write(
            "ERROR: re-exec'd interpreter still cannot import `notebooklm_tools`.\n"
            "Install the CLI (`uv tool install notebooklm-mcp-cli` or "
            "`pip install notebooklm-mcp-cli`) and ensure `nlm` is on PATH.\n"
        )
        sys.exit(2)
    os.environ["_NLM_PODCAST_REEXEC"] = "1"

    here = os.path.abspath(__file__)
    me = Path(sys.executable).resolve()
    for cand in _candidate_venv_pythons():
        try:
            if cand.resolve() == me:
                continue
        except Exception:
            pass
        # Use subprocess, NOT os.execv: on Windows os.execv re-joins argv into a
        # single command-line string and loses the quoting around arguments that
        # contain spaces (e.g. --course-title "A B C"), corrupting them. subprocess
        # quotes each argument correctly via list2cmdline.
        rc = subprocess.call([str(cand), here, *sys.argv[1:]])
        sys.exit(rc)

    # Last resort: run inside the uv tool environment.
    uv = shutil.which("uv")
    if uv:
        rc = subprocess.call([uv, "tool", "run", "--from", "notebooklm-mcp-cli",
                              "python", here, *sys.argv[1:]])
        sys.exit(rc)

    sys.stderr.write(
        "ERROR: could not import `notebooklm_tools` and could not locate the "
        "notebooklm-mcp-cli virtualenv Python.\n"
        "Install the CLI (`uv tool install notebooklm-mcp-cli` or "
        "`pip install notebooklm-mcp-cli`) and ensure `nlm` is on PATH, then retry.\n"
    )
    sys.exit(2)


_ensure_notebooklm_tools()

from notebooklm_tools.mcp.tools._utils import get_client          # noqa: E402
from notebooklm_tools.services import notebooks as nbsvc          # noqa: E402
from notebooklm_tools.services import sources as srcsvc           # noqa: E402
from notebooklm_tools.services import studio as studiosvc         # noqa: E402


# ---------------------------------------------------------------------------
# Constants / tunables
# ---------------------------------------------------------------------------
CHAPTER_RE = re.compile(r"^ch\d{2}-")
UPLOAD_BACKOFF = [0, 20, 45, 90]        # seconds before each upload attempt
GENERATE_BACKOFF = [0, 90, 150, 240]    # seconds before each generation attempt
RENAME_RETRIES = 3
PAUSE_BETWEEN_CHAPTERS = 45             # rate-limit courtesy between chapters
RENAME_POLL_INTERVAL = 30
RENAME_POLL_MAX = 80                    # ~40 min ceiling


def log(msg: str) -> None:
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def chapter_number(slug: str) -> str:
    """'ch03-context-and-session-management' -> '03'."""
    m = re.match(r"^ch(\d{2})-", slug)
    return m.group(1) if m else slug


def chapter_title(cdir: Path) -> str:
    """Human chapter title: from tutorial.handoff.json if present, else from the slug."""
    handoff = cdir / "tutorial.handoff.json"
    if handoff.exists():
        try:
            data = json.loads(handoff.read_text(encoding="utf-8"))
            t = (data.get("chapter") or {}).get("title")
            if t:
                return str(t).strip()
        except Exception:
            pass
    # Fallback: prettify the slug (drop 'chNN-', hyphens -> spaces, title case).
    return re.sub(r"^ch\d{2}-", "", cdir.name).replace("-", " ").strip().title()


def prettify_course(notebook_name: str) -> str:
    """Derive a human course title from a slug when none is supplied."""
    return notebook_name.replace("-", " ").replace("_", " ").strip().title()


def build_series_prompt(course_title: str, n: int, total: int, this_title: str,
                        all_titles: list[str], extra: str = "") -> str:
    """Instruct NotebookLM that this podcast is one episode in a course series.

    Ensures the episode references its position in the series and does NOT
    re-tell the overall scenario from scratch.
    """
    roster = "; ".join(f"{i}. {t}" for i, t in enumerate(all_titles, start=1))
    lines = [
        f'This audio is Chapter {n} of {total} in a multi-part podcast SERIES for the '
        f'course "{course_title}". Each chapter is a separate episode; together they form '
        f'one course.',
        f'This episode is Chapter {n}: "{this_title}".',
        f'Open by clearly stating the series context, for example: "This is the podcast for '
        f'Chapter {n} of {total} of the course {course_title}: {this_title}. In this chapter '
        f'we will discuss ...".',
        'Treat this as part of an ongoing series: do NOT re-introduce the overall course '
        'scenario, characters, setting, or premise from scratch. Assume listeners have '
        'already heard the earlier chapters. Briefly connect back to what prior chapters '
        'established and, where natural, preview what the next chapter covers.',
        'Base the discussion ONLY on the provided sources for this chapter; do not pull in '
        'material from other chapters except for brief connective references.',
        f'For context, the full ordered chapter list of the course is: {roster}.',
    ]
    if extra.strip():
        lines.append(extra.strip())
    return "\n".join(lines)


def _id(result, *keys) -> str:
    if isinstance(result, dict):
        for k in keys:
            if result.get(k):
                return result[k]
        return ""
    for k in keys:
        v = getattr(result, k, None)
        if v:
            return v
    return ""


# ---------------------------------------------------------------------------
# Slides conversion (best effort)
# ---------------------------------------------------------------------------
def ensure_slides_pdf(chapter_dir: Path) -> Path | None:
    """Return a usable slides.pdf path, converting from slides.pptx if needed.

    Returns None if neither a PDF exists nor conversion is possible.
    """
    pdf = chapter_dir / "slides.pdf"
    if pdf.exists():
        return pdf
    pptx = chapter_dir / "slides.pptx"
    if not pptx.exists():
        return None

    # 1) LibreOffice
    soffice = shutil.which("soffice") or shutil.which("soffice.exe")
    if soffice:
        try:
            subprocess.run(
                [soffice, "--headless", "--convert-to", "pdf",
                 "--outdir", str(chapter_dir), str(pptx)],
                check=True, capture_output=True, timeout=180,
            )
            if pdf.exists():
                log(f"  converted slides.pptx -> slides.pdf (LibreOffice)")
                return pdf
        except Exception as e:
            log(f"  WARN LibreOffice conversion failed: {str(e)[:100]}")

    # 2) PowerPoint COM (Windows)
    try:
        import win32com.client  # type: ignore
        ppt = win32com.client.Dispatch("PowerPoint.Application")
        try:
            pres = ppt.Presentations.Open(str(pptx), WithWindow=False)
            pres.SaveAs(str(pdf), 32)  # 32 = ppSaveAsPDF
            pres.Close()
        finally:
            ppt.Quit()
        if pdf.exists():
            log(f"  converted slides.pptx -> slides.pdf (PowerPoint COM)")
            return pdf
    except Exception as e:
        log(f"  WARN PowerPoint COM conversion unavailable/failed: {str(e)[:100]}")

    log("  WARN no slides converter available; dropping slides for this chapter")
    return None


# ---------------------------------------------------------------------------
# Results persistence
# ---------------------------------------------------------------------------
def load_results(path: Path) -> dict:
    if path.exists():
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def save_results(path: Path, results: dict) -> None:
    path.write_text(json.dumps(results, indent=2), encoding="utf-8")


# ---------------------------------------------------------------------------
# Notebook / source / generation primitives (service layer = no broken guard)
# ---------------------------------------------------------------------------
def find_or_create_notebook(client, name: str) -> str:
    nbs = nbsvc.list_notebooks(client)
    items = nbs.get("notebooks", nbs) if isinstance(nbs, dict) else nbs
    matches = [n for n in items
               if str(n.get("title", "")).strip().lower() == name.strip().lower()]
    if matches:
        matches.sort(key=lambda n: str(n.get("modified_at", "")), reverse=True)
        nid = matches[0]["id"]
        log(f"reusing notebook '{name}' (id={nid})")
        return nid
    created = nbsvc.create_notebook(client, name)
    nid = _id(created, "notebook_id", "id")
    log(f"created notebook '{name}' (id={nid})")
    return nid


def upload_one(client, notebook_id: str, fpath: Path, display_title: str | None = None) -> str:
    last_err = ""
    label = display_title or fpath.name
    for attempt, wait in enumerate(UPLOAD_BACKOFF):
        if wait:
            log(f"    retry {label} in {wait}s (attempt {attempt+1}): {last_err[:100]}")
            time.sleep(wait)
        try:
            res = srcsvc.add_source(client, notebook_id, "file", file_path=str(fpath),
                                    title=display_title, wait=True, wait_timeout=300.0)
            sid = _id(res, "source_id", "id")
            if sid:
                log(f"    uploaded {fpath.name} as '{label}' -> {sid}")
                return sid
            last_err = "no source_id returned"
        except Exception as e:
            last_err = f"{type(e).__name__}: {e}"
    raise RuntimeError(f"upload failed for {label}: {last_err}")


def generate_audio(client, notebook_id: str, source_ids: list[str], focus_prompt: str = "") -> str:
    last_err = ""
    for attempt, wait in enumerate(GENERATE_BACKOFF):
        if wait:
            log(f"  generation retry in {wait}s (attempt {attempt+1}): {last_err[:100]}")
            time.sleep(wait)
        try:
            res = studiosvc.create_artifact(client, notebook_id, "audio",
                                            source_ids=source_ids, focus_prompt=focus_prompt)
            aid = _id(res, "artifact_id", "id")
            if aid:
                return aid
            last_err = "no artifact_id returned"
        except Exception as e:
            last_err = f"{type(e).__name__}: {e}"
    raise RuntimeError(f"audio generation failed: {last_err}")


def rename_when_completed(client, notebook_id: str, aid2name: dict[str, str]) -> dict:
    """Poll until each artifact completes, then rename it to its chapter name.

    Renames must happen AFTER completion or NotebookLM overwrites the title.
    Returns {artifact_id: bool renamed}.
    """
    renamed: dict[str, bool] = {}
    for _ in range(RENAME_POLL_MAX):
        try:
            arts = studiosvc.get_studio_status(client, notebook_id)["artifacts"]
        except Exception as e:
            log(f"  status poll error: {str(e)[:100]}")
            time.sleep(RENAME_POLL_INTERVAL)
            continue
        status = {a["artifact_id"]: a for a in arts}
        pending = []
        for aid, name in aid2name.items():
            if renamed.get(aid):
                continue
            a = status.get(aid, {})
            if a.get("status") == "completed":
                ok = False
                for _r in range(RENAME_RETRIES):
                    try:
                        studiosvc.rename_artifact(client, aid, name)
                        ok = True
                        break
                    except Exception:
                        time.sleep(2)
                renamed[aid] = ok
                log(f"  {'renamed' if ok else 'RENAME-FAILED'} -> {name}")
            else:
                pending.append(name)
        if not pending:
            break
        log(f"  waiting on {len(pending)} to finish: {', '.join(sorted(pending))}")
        time.sleep(RENAME_POLL_INTERVAL)
    return renamed


# ---------------------------------------------------------------------------
# Main orchestration
# ---------------------------------------------------------------------------
def discover_chapters(course_root: Path) -> tuple[list[Path], list[tuple[str, str]]]:
    chapters_dir = course_root / "chapters"
    if not chapters_dir.is_dir():
        raise SystemExit(
            f"Error: expected a chapters directory at {chapters_dir} but it was not found.\n"
            f"Verify --course-root points at the course folder (e.g. outputs/<course_slug>)."
        )
    valid, bad = [], []
    for d in sorted(chapters_dir.iterdir(), key=lambda p: p.name):
        if not d.is_dir():
            continue
        if CHAPTER_RE.match(d.name):
            valid.append(d)
        else:
            bad.append((d.name, "unexpected folder name (does not match ch{NN}-{slug})"))
    return valid, bad


def process_chapter(client, notebook_id: str, cdir: Path, use_slides: bool,
                    focus_prompt: str = "") -> dict:
    """Upload a chapter's sources and generate its scoped podcast.

    Uploaded sources are titled with a chapter prefix (e.g. chapter_03_tutorial.docx)
    so they are distinguishable in the shared notebook. The podcast is generated
    with a series-context focus prompt so it references its place in the course.
    Cleans up its own uploads if generation never starts, so failures leave no
    orphan sources behind.
    """
    nn = chapter_number(cdir.name)
    files = [cdir / "tutorial.docx"]
    if use_slides:
        pdf = ensure_slides_pdf(cdir)
        if pdf:
            files.append(pdf)
    files.append(cdir / "podcast-script.md")

    missing = [f.name for f in files if not f.exists()]
    if missing:
        return {"ok": False, "error": f"missing required files: {missing}"}

    uploaded: list[str] = []
    try:
        for f in files:
            title = f"chapter_{nn}_{f.name}"
            uploaded.append(upload_one(client, notebook_id, f, display_title=title))
        aid = generate_audio(client, notebook_id, uploaded, focus_prompt=focus_prompt)
        return {"ok": True, "artifact_id": aid, "source_ids": uploaded}
    except Exception as e:
        # Clean up partial uploads so a later retry doesn't accumulate orphans.
        for sid in uploaded:
            try:
                srcsvc.delete_source(client, sid)
            except Exception:
                pass
        return {"ok": False, "error": f"{type(e).__name__}: {e}"}


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="Batch-generate NotebookLM podcasts per chapter.")
    ap.add_argument("--notebook-name", required=True, help="Shared NotebookLM notebook name (find-or-create).")
    ap.add_argument("--course-root", required=True, help="Course folder; chapters under <root>/chapters/.")
    ap.add_argument("--course-title", default="", help="Human course title used in the series prompt (default: prettified --notebook-name).")
    ap.add_argument("--general-instructions", default="", help="Extra instructions appended to every chapter's series focus prompt.")
    ap.add_argument("--rename-only", action="store_true", help="Only run the post-completion rename pass.")
    ap.add_argument("--no-rename", action="store_true", help="Generate only; skip the rename pass.")
    ap.add_argument("--no-series-prompt", action="store_true", help="Do not inject the course-series focus prompt.")
    ap.add_argument("--no-slides", action="store_true", help="Do not upload slides even if present.")
    args = ap.parse_args(argv)

    course_root = Path(args.course_root).resolve()
    results_path = course_root / "_podcast_gen.results.json"
    client = get_client()

    chapter_dirs, bad = discover_chapters(course_root)
    for name, reason in bad:
        log(f"STRUCTURE-ERROR {name}: {reason}")
    if not chapter_dirs:
        raise SystemExit("Error: the course has no chapter folders matching ch{NN}-{slug}.")
    log(f"discovered {len(chapter_dirs)} chapter(s)")

    # Precompute course metadata for the series focus prompt.
    course_title = args.course_title.strip() or prettify_course(args.notebook_name)
    titles = [chapter_title(d) for d in chapter_dirs]
    total = len(chapter_dirs)

    notebook_id = find_or_create_notebook(client, args.notebook_name)
    results = load_results(results_path)

    if not args.rename_only:
        first = True
        for idx, cdir in enumerate(chapter_dirs, start=1):
            name = cdir.name
            if results.get(name, {}).get("ok"):
                log(f"SKIP {name} (already succeeded)")
                continue
            if not first:
                log(f"pausing {PAUSE_BETWEEN_CHAPTERS}s before next chapter ...")
                time.sleep(PAUSE_BETWEEN_CHAPTERS)
            first = False
            log(f"=== {name} ===")
            focus = "" if args.no_series_prompt else build_series_prompt(
                course_title, idx, total, titles[idx - 1], titles,
                extra=args.general_instructions)
            outcome = process_chapter(client, notebook_id, cdir,
                                      use_slides=not args.no_slides, focus_prompt=focus)
            results[name] = outcome
            save_results(results_path, results)
            log(f"  {'OK' if outcome['ok'] else 'FAIL'} {name}"
                + ("" if outcome["ok"] else f": {outcome['error']}"))

    # Post-completion rename pass.
    if not args.no_rename:
        aid2name = {v["artifact_id"]: ch for ch, v in results.items()
                    if v.get("ok") and v.get("artifact_id")}
        if aid2name:
            log("==== RENAME PASS (waits for generation to complete) ====")
            renamed = rename_when_completed(client, notebook_id, aid2name)
            for ch, v in results.items():
                if v.get("artifact_id") in renamed:
                    v["renamed"] = renamed[v["artifact_id"]]
            save_results(results_path, results)

    # Summary
    log("==== SUMMARY ====")
    ok = 0
    for cdir in chapter_dirs:
        v = results.get(cdir.name, {})
        if v.get("ok"):
            ok += 1
            log(f"OK   {cdir.name}  artifact_id={v.get('artifact_id')}  renamed={v.get('renamed')}")
        else:
            log(f"FAIL {cdir.name}  {v.get('error', '(not processed)')}")
    log(f"Notebook: {args.notebook_name} (id={notebook_id})")
    log(f"Total: {ok} succeeded, {len(chapter_dirs) - ok} failed")
    return 0 if ok == len(chapter_dirs) else 1


if __name__ == "__main__":
    sys.exit(main())
