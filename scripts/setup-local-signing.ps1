#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Configure per-machine HarmonyOS signing so it never breaks git again.

.DESCRIPTION
    Why this exists: signing material is bound to one machine and must NOT be shared:
      1) build-profile.json5 stores absolute paths containing a user name, so they
         differ per machine;
      2) passwords are encrypted by DevEco using the keystore's own directory as the
         key (see hvigor DecipherUtil.decryptPwd), so they cannot be decrypted after
         the material moves to another machine or directory.

    Therefore every machine must generate its own signing material once, and that
    local configuration must not be committed. This script:
      1) verifies the signing material referenced by build-profile.json5 exists here;
      2) marks build-profile.json5 as assume-unchanged so your local signing config
         is not committed and does not cause branch-switch conflicts.

    Run once per machine. Output is intentionally ASCII-only because Windows
    PowerShell 5.1 reads .ps1 files as ANSI and would corrupt non-ASCII text.

.PARAMETER Undo
    Remove the assume-unchanged mark, restoring normal git tracking.
#>
[CmdletBinding()]
param(
    [switch]$Undo
)

$ErrorActionPreference = 'Stop'

# Resolve repo root from this script's location (scripts/..).
$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $repoRoot) { $repoRoot = (Get-Location).Path }
Set-Location $repoRoot

$profileFile = 'build-profile.json5'

if (-not (Test-Path -LiteralPath $profileFile)) {
    Write-Host "[ERROR] $profileFile not found. Run this from the project repository." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------- undo mode
if ($Undo) {
    git update-index --no-assume-unchanged $profileFile
    Write-Host "[OK] assume-unchanged removed; $profileFile is tracked by git again." -ForegroundColor Green
    exit 0
}

# ------------------------------------------------- 1) check signing material
Write-Host "=== Checking local signing configuration ===" -ForegroundColor Cyan

$content = Get-Content -LiteralPath $profileFile -Raw

$storeFile = [regex]::Match($content, '"storeFile"\s*:\s*"([^"]+)"').Groups[1].Value
$certPath  = [regex]::Match($content, '"certpath"\s*:\s*"([^"]+)"').Groups[1].Value
$p7bPath   = [regex]::Match($content, '"profile"\s*:\s*"([^"]+)"').Groups[1].Value

if (-not $storeFile) {
    Write-Host "[MISSING] No signingConfigs section found in $profileFile." -ForegroundColor Yellow
    Write-Host "          Generate a signature first in DevEco Studio:" -ForegroundColor Yellow
    Write-Host "            File > Project Structure > Signing Configs" -ForegroundColor Yellow
    Write-Host "            tick 'Automatically generate signature' > Apply" -ForegroundColor Yellow
    exit 1
}

$allOk = $true
$items = @(
    @{ Label = 'storeFile (.p12)'; Path = $storeFile },
    @{ Label = 'certpath  (.cer)'; Path = $certPath  },
    @{ Label = 'profile   (.p7b)'; Path = $p7bPath   }
)

foreach ($item in $items) {
    if ([string]::IsNullOrWhiteSpace($item.Path)) {
        Write-Host ("  [MISSING] {0}: <empty>" -f $item.Label) -ForegroundColor Red
        $allOk = $false
    }
    elseif (Test-Path -LiteralPath $item.Path) {
        Write-Host ("  [OK]      {0}: {1}" -f $item.Label, $item.Path) -ForegroundColor Green
    }
    else {
        Write-Host ("  [MISSING] {0}: {1}" -f $item.Label, $item.Path) -ForegroundColor Red
        $allOk = $false
    }
}

# A path belonging to another user means this config came from a different machine.
$ownerMatch = [regex]::Match($storeFile, '\\Users\\([^\\]+)\\')
if ($ownerMatch.Success) {
    $owner = $ownerMatch.Groups[1].Value
    if ($owner -ne $env:USERNAME) {
        Write-Host ""
        Write-Host ("[WARN] Signing paths belong to user '{0}', but the current user is '{1}'." -f $owner, $env:USERNAME) -ForegroundColor Yellow
        Write-Host "       This configuration was generated on another machine and cannot be used here." -ForegroundColor Yellow
        $allOk = $false
    }
}

if (-not $allOk) {
    Write-Host ""
    Write-Host "Signing material is not usable on this machine. Generate it locally first:" -ForegroundColor Yellow
    Write-Host "  File > Project Structure > Signing Configs" -ForegroundColor Yellow
    Write-Host "  tick 'Automatically generate signature' > Apply" -ForegroundColor Yellow
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 1
}

# ------------------------------------- 2) freeze local config against git churn
Write-Host ""
Write-Host "=== Freezing local signing config ===" -ForegroundColor Cyan

git update-index --assume-unchanged $profileFile

Write-Host "[OK] Marked assume-unchanged: your local signing config will not be committed" -ForegroundColor Green
Write-Host "     and will not cause conflicts when switching branches." -ForegroundColor Green
Write-Host ""
Write-Host "Undo with: .\scripts\setup-local-signing.ps1 -Undo" -ForegroundColor DarkGray
Write-Host "Note: some git operations (reset --hard, conflicting checkout) may still" -ForegroundColor DarkGray
Write-Host "      overwrite the file. If that happens, re-run DevEco auto-signature" -ForegroundColor DarkGray
Write-Host "      and then this script." -ForegroundColor DarkGray
