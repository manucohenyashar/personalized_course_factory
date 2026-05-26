# =============================================================================
# Preflight check — cowork-automation-tracy-2026 lab environment (Windows)
# PowerShell equivalent of preflight.sh for Windows 11 users.
#
# Usage (run from the repo root in PowerShell):
#   .\environment\preflight.ps1
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more required tools are missing or at the wrong version
#
# This script is idempotent: safe to run multiple times.
# It does NOT install missing tools — it checks and reports clearly.
# =============================================================================

#Requires -Version 5.1

$CourseSlug  = "cowork-automation-tracy-2026"
$PassCount   = 0
$FailCount   = 0
$FailedTools = @()

# ------------------------------------------------------------------------------
# Helper: Test-Tool
#   DisplayName     — friendly name for console output
#   RequiredVersion — exact version string (used in error messages)
#   VersionCommand  — scriptblock that returns the version string
#   VersionPattern  — substring to look for in the output (case-sensitive)
# ------------------------------------------------------------------------------
function Test-Tool {
    param(
        [string]$DisplayName,
        [string]$RequiredVersion,
        [scriptblock]$VersionCommand,
        [string]$VersionPattern
    )

    try {
        $output = & $VersionCommand 2>&1 | Out-String
        if ($output -like "*$VersionPattern*") {
            Write-Host "  [PASS] $DisplayName $RequiredVersion" -ForegroundColor Green
            $script:PassCount++
        } else {
            Write-Host "  [FAIL] $DisplayName $RequiredVersion — not found or version mismatch" -ForegroundColor Red
            $script:FailCount++
            $script:FailedTools += $DisplayName
        }
    } catch {
        Write-Host "  [FAIL] $DisplayName $RequiredVersion — command not found" -ForegroundColor Red
        $script:FailCount++
        $script:FailedTools += $DisplayName
    }
}

Write-Host ""
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  $CourseSlug — Environment Preflight (Windows)" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ' -AsUTC)" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Checking required tools..."
Write-Host ""

# ------------------------------------------------------------------------------
# Claude CLI 1.0.58
# Install: https://docs.anthropic.com/claude-code/installation
#   winget install Anthropic.Claude  (or download the installer)
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "claude (Claude CLI)" `
    -RequiredVersion "1.0.58" `
    -VersionCommand  { claude --version } `
    -VersionPattern  "1.0.58"

# ------------------------------------------------------------------------------
# Node.js 22.12.0 LTS
# Install: https://nodejs.org/en/download  (Windows Installer)
#   or: winget install OpenJS.NodeJS.LTS
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "node (Node.js LTS)" `
    -RequiredVersion "22.12.0" `
    -VersionCommand  { node --version } `
    -VersionPattern  "v22.12.0"

# ------------------------------------------------------------------------------
# npm 10.9.0 (bundled with Node 22.12.0)
# If this fails after installing Node, restart your terminal.
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "npm" `
    -RequiredVersion "10.9.0" `
    -VersionCommand  { npm --version } `
    -VersionPattern  "10.9.0"

# ------------------------------------------------------------------------------
# Playwright 1.48.0
# Install: npm install -g @playwright/test@1.48.0
#          npx playwright install chromium
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "playwright (via npx)" `
    -RequiredVersion "1.48.0" `
    -VersionCommand  { npx playwright --version } `
    -VersionPattern  "1.48.0"

# ------------------------------------------------------------------------------
# Python 3.11.9
# Install: https://www.python.org/downloads/release/python-3119/
#   or: winget install Python.Python.3.11
# Windows may use "py -3.11" or "python" depending on install method.
# ------------------------------------------------------------------------------
$pythonFound = $false

$pythonCandidates = @(
    { py -3.11 --version },
    { python --version },
    { python3 --version }
)

foreach ($candidate in $pythonCandidates) {
    try {
        $ver = & $candidate 2>&1 | Out-String
        if ($ver -like "*3.11.9*") {
            Write-Host "  [PASS] python 3.11.9" -ForegroundColor Green
            $PassCount++
            $pythonFound = $true
            break
        }
    } catch {
        # try next candidate
    }
}

if (-not $pythonFound) {
    Write-Host "  [FAIL] python 3.11.9 — not found or version mismatch" -ForegroundColor Red
    Write-Host "         Install from: https://www.python.org/downloads/release/python-3119/" -ForegroundColor Yellow
    $FailCount++
    $FailedTools += "python"
}

# ------------------------------------------------------------------------------
# Git 2.44.0
# Install: https://git-scm.com/download/win
#   or: winget install Git.Git
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "git" `
    -RequiredVersion "2.44.0" `
    -VersionCommand  { git --version } `
    -VersionPattern  "2.44.0"

# ------------------------------------------------------------------------------
# curl 8.7.1
# Windows 11 ships curl in C:\Windows\System32\curl.exe.
# Update: winget upgrade curl.curl  or download from https://curl.se/windows/
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "curl" `
    -RequiredVersion "8.7.1" `
    -VersionCommand  { curl --version } `
    -VersionPattern  "8.7.1"

# ------------------------------------------------------------------------------
# jq 1.7.1
# Install: winget install jqlang.jq
#   or download from https://jqlang.github.io/jq/download/
# ------------------------------------------------------------------------------
Test-Tool `
    -DisplayName    "jq" `
    -RequiredVersion "1.7.1" `
    -VersionCommand  { jq --version } `
    -VersionPattern  "1.7.1"

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "-------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  Results: $PassCount passed, $FailCount failed" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------------------" -ForegroundColor Cyan

if ($FailCount -gt 0) {
    Write-Host ""
    Write-Host "  ACTION REQUIRED: The following tools need attention:" -ForegroundColor Yellow
    foreach ($tool in $FailedTools) {
        Write-Host "    - $tool" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  See environment/README.md for per-tool install instructions." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "  All checks passed. Your lab environment is ready." -ForegroundColor Green
Write-Host "  Course: $CourseSlug" -ForegroundColor Green
Write-Host ""
exit 0
