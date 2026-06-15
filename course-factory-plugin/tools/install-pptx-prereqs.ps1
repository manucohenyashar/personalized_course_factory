#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Install the prerequisites the `pptx-generator` slide renderer needs to build slide decks.

.DESCRIPTION
  The course factory renders chapter slide decks with the `pptx-generator` skill, which compiles
  PptxGenJS slide scripts to a .pptx. Those compiled scripts live under
  outputs\<course_slug>\chapters\<ch>\_pptx-build\slides\ and resolve `require('pptxgenjs')` by
  walking UP the directory tree. Installing pptxgenjs into the project root's local node_modules
  (the directory where outputs\ is generated) therefore makes it resolvable from the build dir.

  This script installs, into the target directory:
    - pptxgenjs                                  (REQUIRED — builds the .pptx)
    - markitdown[pptx]                           (recommended — QA text extraction from .pptx)
    - react-icons, react, react-dom, sharp       (optional — only with -WithIcons)

  Run it from your project root: the same directory where you launch Claude Code and where
  outputs\ is generated.

.PARAMETER TargetDir
  Project root to install into. Defaults to the current directory.

.PARAMETER WithIcons
  Also install the optional icon-rasterization libraries (react-icons react react-dom sharp).

.PARAMETER SkipMarkitdown
  Skip the optional Python markitdown QA tool.

.EXAMPLE
  pwsh tools/install-pptx-prereqs.ps1

.EXAMPLE
  pwsh tools/install-pptx-prereqs.ps1 -WithIcons
#>
param(
  [string]$TargetDir = (Get-Location).Path,
  [switch]$WithIcons,
  [switch]$SkipMarkitdown
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }
function Write-Warn2($msg) { Write-Host "!!  $msg" -ForegroundColor Yellow }

Write-Step "pptx-generator prerequisites -> $TargetDir"

if (-not (Test-Path -LiteralPath $TargetDir)) {
  throw "Target directory does not exist: $TargetDir"
}

# --- Node.js / npm (required) ----------------------------------------------
$node = Get-Command node -ErrorAction SilentlyContinue
$npm  = Get-Command npm  -ErrorAction SilentlyContinue
if (-not $node -or -not $npm) {
  throw "Node.js 18+ and npm are required but were not found on PATH. Install Node.js from https://nodejs.org and re-run."
}
Write-Ok "Node.js $(node --version) / npm $(npm --version)"

Push-Location $TargetDir
try {
  # A package.json lets npm record and reproduce the dependency. Create a minimal
  # one only if the project does not already have it (never overwrite an existing manifest).
  if (-not (Test-Path -LiteralPath (Join-Path $TargetDir 'package.json'))) {
    Write-Step "No package.json found; creating a minimal one (npm init -y)"
    npm init -y | Out-Null
  }

  Write-Step "Installing pptxgenjs (required)"
  npm install pptxgenjs
  Write-Ok "pptxgenjs installed into node_modules"

  if ($WithIcons) {
    Write-Step "Installing optional icon libraries (react-icons react react-dom sharp)"
    npm install react-icons react react-dom sharp
    Write-Ok "icon libraries installed"
  } else {
    Write-Host "    (skipping optional icon libraries; pass -WithIcons to include them)"
  }
}
finally {
  Pop-Location
}

# --- markitdown (recommended QA tool, Python) ------------------------------
if (-not $SkipMarkitdown) {
  $py = Get-Command python -ErrorAction SilentlyContinue
  if (-not $py) { $py = Get-Command python3 -ErrorAction SilentlyContinue }
  if ($py) {
    Write-Step "Installing markitdown[pptx] (recommended QA tool)"
    try {
      & $py.Source -m pip install --user "markitdown[pptx]"
      Write-Ok "markitdown installed"
    } catch {
      Write-Warn2 "markitdown install failed (optional). Verify pip is available, or re-run with -SkipMarkitdown. Details: $($_.Exception.Message)"
    }
  } else {
    Write-Warn2 "Python not found; skipping markitdown (optional QA tool). Install Python 3 to enable it."
  }
} else {
  Write-Host "    (skipping markitdown; -SkipMarkitdown set)"
}

Write-Host ""
Write-Ok "Done. Slide rendering prerequisites are installed in: $TargetDir"
Write-Host "Generate courses from this directory so the compiled slide scripts can resolve pptxgenjs from node_modules." -ForegroundColor Cyan
