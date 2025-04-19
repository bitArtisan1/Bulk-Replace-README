#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bulk-update README.md files across all public GitHub repos for a user,
    replacing BuyMeACoffee badges with Ko‑fi badges.

.DESCRIPTION
    - If available, uses GitHub CLI (gh) to list and clone repos.
    - Otherwise, falls back to GitHub REST API + git clone.
    - Performs multi-line regex replacements in README.md.
    - Configures local git user identity if provided, commits and pushes changes back to 'main'.

.NOTES
    Prerequisites:
      • PowerShell 7+ (for '-Raw' file reads).
      • Write access to the target repos.
      • Optionally, GitHub CLI (https://cli.github.com/) for convenience.
      • If gh is not installed:
          – Export a Personal Access Token with repo scope as GITHUB_TOKEN:
            $Env:GITHUB_TOKEN = '<your_token_here>'

    Windows Execution Policy:
      Run with process-level bypass:
         pwsh -ExecutionPolicy Bypass -File .\update_readmes.ps1
#>

param(
    [string]$User       = 'bitArtisan1',
    [string]$KoFiUrl     = 'https://ko-fi.com/D1D11CZNM1',
    [int]   $RepoLimit   = 100,
    [string]$GitName    = '',    # Optional local git user.name for commits
    [string]$GitEmail   = ''     # Optional local git user.email for commits
)

function Get-Repos {
    param(
        [string]$User,
        [int]$Limit
    )
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "Using GitHub CLI 'gh' to list repos..."
        $jsonOutput = gh repo list $User --visibility=public --limit $Limit --json name 2>&1
        try {
            $reposObj = $jsonOutput | ConvertFrom-Json
            return $reposObj | ForEach-Object { $_.name }
        } catch {
            Write-Error "Failed to parse 'gh' JSON output.\n$jsonOutput"
            exit 1
        }
    } else {
        Write-Host "'gh' not found; falling back to GitHub REST API..."
        if (-not $Env:GITHUB_TOKEN) {
            Write-Error "GITHUB_TOKEN env var not set. Please export a token with repo scope."
            exit 1
        }
        $headers = @{ Authorization = "token $Env:GITHUB_TOKEN"; 'User-Agent' = 'PowerShell' }
        $uri = "https://api.github.com/users/$User/repos?per_page=$Limit&type=public"
        try {
            $repos = Invoke-RestMethod -Uri $uri -Headers $headers
            return $repos | ForEach-Object { $_.name }
        } catch {
            Write-Error "Failed to fetch repos via REST API.\n$($_.Exception.Message)"
            exit 1
        }
    }
}

Write-Host "Fetching public repos for '$User'..."
$repos = Get-Repos -User $User -Limit $RepoLimit

foreach ($repo in $repos) {
    Write-Host "`n=== Processing $User/$repo ==="

    # Clone repository
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        gh repo clone "$User/$repo" | Out-Null
    } else {
        git clone "https://github.com/$User/$repo.git" -q
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to clone '$repo'. Skipping."
        continue
    }

    Push-Location $repo

    # Configure local git user identity if provided
    if ($GitName) { git config user.name "$GitName" }
    if ($GitEmail) { git config user.email "$GitEmail" }

    if (Test-Path README.md) {
        Write-Host "Updating README.md..."
        $original = Get-Content README.md -Raw

        # Replacement patterns
        $pattern1 = '(?s)<div align="right">.*?</div>'
        $newBlock1 = @"
<p align="center">
  <a href="${KoFiUrl}">
    <img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Support me on Ko-fi" />
  </a>
</p>
"@

        $pattern2 = '(?s)<a\s+href="https://www\.buymeacoffee\.com/bitArtisan".*?</a>'
        $newBlock2 = @"
<a href="${KoFiUrl}">
  <img src="https://github.com/user-attachments/assets/ba118768-9054-416f-b7b2-adaa69a53434" alt="Support me on Ko-fi" width="200" />
</a>
"@

        $updated = $original -replace $pattern1, $newBlock1
        $updated = $updated -replace $pattern2, $newBlock2

        if ($updated -eq $original) {
            Write-Host "No matching badge patterns found; skipping commit."
        } else {
            Set-Content README.md -Value $updated
            Write-Host "Committing changes..."
            git add README.md
            git commit -m "chore: replace BuyMeACoffee badges with Kofi badges"
            git push origin main
            Write-Host "Pushed updates for '$repo'."
        }
    } else {
        Write-Host "README.md not found; skipping."
    }

    Pop-Location
    Remove-Item -Recurse -Force $repo
}

Write-Host "`nAll done!"
