# ============================================================================
# Maven Flow Simple Installation Script (Windows PowerShell)
# ============================================================================

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Parse arguments
$InstallMode = if ($args.Count -gt 0) { $args[0] } else { "global" }
$ProjectDir = if ($args.Count -gt 1) { $args[1] } else { $PWD }

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Blue
Write-Host "  Maven Flow Installation" -ForegroundColor Blue
Write-Host "===============================================================" -ForegroundColor Blue
Write-Host ""

# ============================================================================
# Step 0: Check and install jq (required for Maven Flow hooks)
# ============================================================================
Write-Host "[Step 0/5] Checking for jq (JSON processor)..." -ForegroundColor Blue

try {
    $null = Get-Command jq -ErrorAction Stop
    $jqVersion = & jq --version 2>$null
    Write-Host "  [OK] jq found: $jqVersion" -ForegroundColor Green
} catch {
    Write-Host "  [WARN] jq not found. Installing jq..." -ForegroundColor Yellow
    if (Test-Path "$ScriptDir\install\install-jq.ps1") {
        & "$ScriptDir\install\install-jq.ps1"
    } else {
        Write-Host "  [ERROR] jq installer not found. Please install jq manually:" -ForegroundColor Red
        Write-Host "     Windows: winget install jqlang.jq" -ForegroundColor Cyan
        Write-Host "     Or download from: https://jqlang.org/download/" -ForegroundColor Cyan
        exit 1
    }
}

# Install globally
if ($InstallMode -eq "global") {
    Write-Host "Installing globally to $env:USERPROFILE\.claude\"

    # Maven Flow internal files
    $TargetDir = "$env:USERPROFILE\.claude\maven-flow"
    # Global locations for Claude Code
    $AgentsDir = "$env:USERPROFILE\.claude\agents"
    $CommandsDir = "$env:USERPROFILE\.claude\commands"
    $SkillsDir = "$env:USERPROFILE\.claude\skills"

    # Create directories
    @("hooks", "config", ".claude") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path "$TargetDir\$_" | Out-Null
    }
    New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

    # Copy agents to global location
    if (Test-Path "$ScriptDir\.claude\agents") {
        Get-ChildItem "$ScriptDir\.claude\agents\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$AgentsDir\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Agents installed to ~/.claude/agents/" -ForegroundColor Green
    }

    # Copy commands to global location
    if (Test-Path "$ScriptDir\.claude\commands") {
        Get-ChildItem "$ScriptDir\.claude\commands\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$CommandsDir\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Commands installed to ~/.claude/commands/" -ForegroundColor Green
    }

    # Copy skills
    if (Test-Path "$ScriptDir\.claude\skills") {
        Get-ChildItem "$ScriptDir\.claude\skills" -Directory | ForEach-Object {
            $skillName = $_.Name
            New-Item -ItemType Directory -Force -Path "$SkillsDir\$skillName" | Out-Null
            if (Test-Path "$_\SKILL.md") {
                $dest = "$SkillsDir\$skillName\SKILL.md"
                if (-not (Test-Path $dest)) {
                    Copy-Item "$_\SKILL.md" $dest
                }
            }
        }
        Write-Host "[OK] Skills installed" -ForegroundColor Green
    }

    # Copy hooks
    if (Test-Path "$ScriptDir\.claude\maven-flow\hooks") {
        Get-ChildItem "$ScriptDir\.claude\maven-flow\hooks\*.sh" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\hooks\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Hooks installed" -ForegroundColor Green
    }

    # Copy config
    if (Test-Path "$ScriptDir\.claude\maven-flow\config") {
        Get-ChildItem "$ScriptDir\.claude\maven-flow\config\*.mjs" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\config\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Config installed" -ForegroundColor Green
    }

    # Copy settings
    if (Test-Path "$ScriptDir\.claude\maven-flow\.claude\settings.json") {
        $dest = "$TargetDir\.claude\settings.json"
        if (-not (Test-Path $dest)) {
            Copy-Item "$ScriptDir\.claude\maven-flow\.claude\settings.json" $dest
        }
        Write-Host "[OK] Settings configured" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "[OK] Maven Flow installed globally!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Create a PRD: /flow-prd"
    Write-Host "  2. Convert to JSON: /flow-convert"
    Write-Host "  3. Start development: /flow start"

# Install locally
}
elseif ($InstallMode -eq "local") {
    Write-Host "Installing locally to $ProjectDir"

    $TargetDir = "$ProjectDir\.claude\maven-flow"
    $SkillsDir = "$ProjectDir\.claude\skills"

    # Create directories
    @("agents", "commands", "hooks", "config", ".claude") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path "$TargetDir\$_" | Out-Null
    }
    New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
    New-Item -ItemType Directory -Force -Path "$ProjectDir\docs" | Out-Null

    # Copy agents
    if (Test-Path "$ScriptDir\.claude\agents") {
        Get-ChildItem "$ScriptDir\.claude\agents\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\agents\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Agents installed" -ForegroundColor Green
    }

    # Copy commands
    if (Test-Path "$ScriptDir\.claude\commands") {
        Get-ChildItem "$ScriptDir\.claude\commands\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\commands\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Commands installed" -ForegroundColor Green
    }

    # Copy skills
    if (Test-Path "$ScriptDir\.claude\skills") {
        Get-ChildItem "$ScriptDir\.claude\skills" -Directory | ForEach-Object {
            $skillName = $_.Name
            New-Item -ItemType Directory -Force -Path "$SkillsDir\$skillName" | Out-Null
            if (Test-Path "$_\SKILL.md") {
                $dest = "$SkillsDir\$skillName\SKILL.md"
                if (-not (Test-Path $dest)) {
                    Copy-Item "$_\SKILL.md" $dest
                }
            }
        }
        Write-Host "[OK] Skills installed" -ForegroundColor Green
    }

    # Copy hooks
    if (Test-Path "$ScriptDir\.claude\maven-flow\hooks") {
        Get-ChildItem "$ScriptDir\.claude\maven-flow\hooks\*.sh" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\hooks\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Hooks installed" -ForegroundColor Green
    }

    # Copy config
    if (Test-Path "$ScriptDir\.claude\maven-flow\config") {
        Get-ChildItem "$ScriptDir\.claude\maven-flow\config\*.mjs" -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = "$TargetDir\config\$($_.Name)"
            if (-not (Test-Path $dest)) {
                Copy-Item $_.FullName $dest
            }
        }
        Write-Host "[OK] Config installed" -ForegroundColor Green
    }

    # Copy settings
    if (Test-Path "$ScriptDir\.claude\maven-flow\.claude\settings.json") {
        $dest = "$TargetDir\.claude\settings.json"
        if (-not (Test-Path $dest)) {
            Copy-Item "$ScriptDir\.claude\maven-flow\.claude\settings.json" $dest
        }
        Write-Host "[OK] Settings configured" -ForegroundColor Green
    }

    # Create prd.json if not exists
    $prdPath = "$ProjectDir\docs\prd.json"
    if (-not (Test-Path $prdPath)) {
        @{
            projectName = "My Project"
            branchName = "main"
            stories = @()
        } | ConvertTo-Json | Set-Content $prdPath
        Write-Host "[OK] Created docs/prd.json" -ForegroundColor Green
    }

    # Create progress.txt if not exists
    $progressPath = "$ProjectDir\docs\progress.txt"
    if (-not (Test-Path $progressPath)) {
        @"
# Maven Flow Progress

## Codebase Patterns
<!-- Add reusable patterns discovered during development -->

## Iteration Log
<!-- Progress from each iteration will be appended here -->
"@ | Set-Content $progressPath
        Write-Host "[OK] Created docs/progress.txt" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "[OK] Maven Flow installed locally!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Create a PRD: /flow-prd"
    Write-Host "  2. Convert to JSON: /flow-convert"
    Write-Host "  3. Start development: /flow start"

}
else {
    Write-Host "[ERROR] Invalid install mode: $InstallMode" -ForegroundColor Red
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\install-simple.ps1 global     # Install globally"
    Write-Host "  .\install-simple.ps1 local      # Install locally"
    exit 1
}
