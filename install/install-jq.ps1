#
# Cross-platform jq installer for Maven Flow (PowerShell version)
# Supports: Windows (PowerShell 5.1+ / PowerShell Core)
#
# Usage: irm https://raw.githubusercontent.com/your-repo/main/install/install-jq.ps1 | iex
# Or: .\install-jq.ps1
#

param(
    [switch]$Force = $false
)

$ErrorActionPreference = "Stop"

$JQ_VERSION = "1.8.1"
$JQ_DOWNLOAD_BASE = "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error-Msg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Detect architecture
function Get-Architecture {
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture
    switch ($arch.ToString()) {
        "X64"   { return "amd64" }
        "X86"   { return "i386" }
        "Arm64" { return "arm64" }
        default { return "unknown" }
    }
}

# Check if jq is already installed
function Test-JqInstalled {
    try {
        $null = Get-Command jq -ErrorAction Stop
        $version = & jq --version 2>$null
        Write-Info "jq is already installed: $version"
        return $true
    } catch {
        return $false
    }
}

# Install using winget (Windows Package Manager - built into Windows 10/11)
function Install-WithWinget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "Installing jq using winget..."
        try {
            $result = winget install --id jqlang.jq --accept-source-agreements --accept-package-agreements -e 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Info "jq installed successfully via winget"
                return $true
            }
        } catch {
            Write-Warn "winget installation failed: $_"
        }
    }
    return $false
}

# Install using Chocolatey
function Install-WithChocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "Installing jq using Chocolatey..."
        try {
            choco install jq -y
            if ($LASTEXITCODE -eq 0) {
                Write-Info "jq installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-Warn "Chocolatey installation failed: $_"
        }
    }
    return $false
}

# Install using Scoop
function Install-WithScoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Info "Installing jq using Scoop..."
        try {
            scoop install jq
            if ($LASTEXITCODE -eq 0) {
                Write-Info "jq installed successfully via Scoop"
                return $true
            }
        } catch {
            Write-Warn "Scoop installation failed: $_"
        }
    }
    return $false
}

# Install by downloading binary
function Install-Binary {
    Write-Info "Installing jq from binary..."

    $arch = Get-Architecture
    if ($arch -eq "unknown") {
        Write-Error-Msg "Unsupported architecture"
        return $false
    }

    # Determine binary name
    if ($arch -eq "amd64") {
        $binary = "jq-win64.exe"
    } else {
        $binary = "jq-win32.exe"
    }

    $downloadUrl = "${JQ_DOWNLOAD_BASE}/${binary}"

    # Installation directory (user local bin)
    $installDir = Join-Path $env:USERPROFILE "bin"
    $installPath = Join-Path $installDir "jq.exe"

    # Create directory if it doesn't exist
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Info "Created directory: $installDir"
    }

    Write-Info "Downloading jq from: $downloadUrl"

    # Download using Invoke-WebRequest (available on all Windows systems)
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $installPath -UseBasicParsing
        Write-Info "Downloaded to: $installPath"
    } catch {
        Write-Error-Msg "Failed to download jq: $_"
        return $false
    }

    # Add to PATH if not already there
    $pathEnv = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($pathEnv -notlike "*$installDir*") {
        Write-Warn "Adding $installDir to user PATH..."

        # Add to user PATH
        $newPath = "$pathEnv;$installDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

        Write-Warn "PATH updated. Please restart your shell for changes to take effect."
        Write-Warn "Or run: `$env:Path = '$installDir;' + `$env:Path"
    }

    Write-Info "jq installed to: $installPath"
    return $true
}

# Verify installation
function Test-Installation {
    Write-Info "Verifying jq installation..."

    try {
        # Refresh PATH for current session
        $installDir = Join-Path $env:USERPROFILE "bin"
        if ($env:Path -notlike "*$installDir*") {
            $env:Path = "$installDir;$env:Path"
        }

        $version = & jq --version 2>$null
        if ($version) {
            Write-Info "jq successfully installed: $version"

            # Test basic functionality
            $testResult = echo '{"test": "success"}' | jq -r '.test' 2>$null
            if ($testResult -eq "success") {
                Write-Info "jq is working correctly!"
                return $true
            } else {
                Write-Error-Msg "jq is installed but not working properly"
                return $false
            }
        } else {
            Write-Error-Msg "jq installation verification failed"
            return $false
        }
    } catch {
        Write-Error-Msg "Failed to verify jq installation: $_"
        return $false
    }
}

# Main installation flow
function Main {
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "Maven Flow - jq Installer" -ForegroundColor Cyan
    Write-Host "Windows PowerShell Installation" -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""

    $arch = Get-Architecture
    Write-Info "Detected architecture: $arch"

    # Check if already installed
    if (-not $Force -and (Test-JqInstalled)) {
        Write-Info "jq is already installed. Skipping installation."
        Test-Installation
        return
    }

    # Try installation methods in order of preference
    $success = $false

    # 1. Try winget (built into Windows 10/11)
    if (-not $success) {
        $success = Install-WithWinget
    }

    # 2. Try Chocolatey
    if (-not $success) {
        $success = Install-WithChocolatey
    }

    # 3. Try Scoop
    if (-not $success) {
        $success = Install-WithScoop
    }

    # 4. Fallback to binary download
    if (-not $success) {
        $success = Install-Binary
    }

    # Verify installation
    Write-Host ""
    if ($success -and (Test-Installation)) {
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host "jq installation complete!" -ForegroundColor Green
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host ""
        Write-Info "You can now use jq in your Maven Flow hooks!"
        Write-Host ""

        # Remind about PATH if needed
        $installDir = Join-Path $env:USERPROFILE "bin"
        $pathEnv = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($pathEnv -notlike "*$installDir*") {
            Write-Warn "IMPORTANT: Restart your shell for PATH changes to take effect"
        }
    } else {
        Write-Host "========================================================" -ForegroundColor Red
        Write-Host "jq installation failed" -ForegroundColor Red
        Write-Host "========================================================" -ForegroundColor Red
        Write-Host ""
        Write-Error-Msg "Please install jq manually using one of these methods:"
        Write-Host "  winget install jqlang.jq" -ForegroundColor Cyan
        Write-Host "  choco install jq" -ForegroundColor Cyan
        Write-Host "  scoop install jq" -ForegroundColor Cyan
        Write-Host "  Or download from: https://jqlang.org/download/" -ForegroundColor Cyan
        Write-Host ""
    }
}

# Run main
Main
