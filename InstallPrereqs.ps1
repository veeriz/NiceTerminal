# PowerShell Profile Prerequisite Installer
# Run as Administrator for winget installs

Write-Host "=== Installing PowerShell Profile Prerequisites ===" -ForegroundColor Cyan

# --- Helper Functions ---
function Install-PSModuleIfMissing {
    param(
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Installing PowerShell module: $ModuleName" -ForegroundColor Yellow
        Install-Module $ModuleName -Scope CurrentUser -Force -AllowClobber
    }
    else {
        Write-Host "Module $ModuleName already installed" -ForegroundColor Green
    }
}

function Install-WingetPackageIfMissing {
    param(
        [string]$PackageId,
        [string]$CheckCommand
    )
    if (-not (Get-Command $CheckCommand -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $PackageId via winget" -ForegroundColor Yellow
        winget install --id $PackageId -e --source winget
    }
    else {
        Write-Host "$PackageId already installed" -ForegroundColor Green
    }
}

# --- Install PowerShell Modules ---
Install-PSModuleIfMissing -ModuleName PSReadLine
Install-PSModuleIfMissing -ModuleName PSColors
Install-PSModuleIfMissing -ModuleName Terminal-Icons

# --- Install External Tools ---
Install-WingetPackageIfMissing -PackageId "Git.Git" -CheckCommand git
Install-WingetPackageIfMissing -PackageId "Gerardog.gsudo" -CheckCommand gsudo
Install-WingetPackageIfMissing -PackageId "JanDeDobbeleer.OhMyPosh" -CheckCommand oh-my-posh

# --- Verify Git UNIX tools ---
$gitUnixPath = "C:\Program Files\Git\usr\bin"
if (-not (Test-Path $gitUnixPath)) {
    Write-Host "WARNING: Git UNIX tools not found at $gitUnixPath" -ForegroundColor Red
    Write-Host "Ensure Git for Windows was installed with 'Add Unix tools to PATH' option"
}
else {
    Write-Host "Git UNIX tools found at $gitUnixPath" -ForegroundColor Green
}

# --- Verify Oh My Posh theme path ---
if (-not $env:POSH_THEMES_PATH) {
    $defaultThemesPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    if (Test-Path $defaultThemesPath) {
        [System.Environment]::SetEnvironmentVariable("POSH_THEMES_PATH", $defaultThemesPath, "User")
        Write-Host "Set POSH_THEMES_PATH to $defaultThemesPath" -ForegroundColor Green
    }
    else {
        Write-Host "WARNING: POSH_THEMES_PATH not set and themes folder not found" -ForegroundColor Red
    }
}
else {
    Write-Host "POSH_THEMES_PATH is already set to $env:POSH_THEMES_PATH" -ForegroundColor Green
}

Write-Host "=== All prerequisites installed or verified ===" -ForegroundColor Cyan
