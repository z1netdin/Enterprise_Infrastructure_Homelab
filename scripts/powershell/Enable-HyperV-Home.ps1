#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Enables Hyper-V on Windows 11 Home edition.

.DESCRIPTION
    Windows 11 Home does not include Hyper-V by default. This script installs
    the Hyper-V feature using DISM. A restart is required after completion.

.NOTES
    This is a well-known workaround. If it does not work on your build,
    use VMware Workstation Player (free) as an alternative.
#>

$ErrorActionPreference = "Stop"

Write-Host "Checking Windows edition..." -ForegroundColor Cyan
$edition = (Get-ComputerInfo).WindowsEditionId

if ($edition -notlike "*Home*" -and $edition -notlike "*Core*") {
    Write-Host "You are running $edition. Hyper-V can be enabled normally:" -ForegroundColor Yellow
    Write-Host "  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All" -ForegroundColor White
    exit 0
}

Write-Host "Detected Windows 11 Home. Installing Hyper-V via DISM..." -ForegroundColor Cyan

# Install Hyper-V components
$packages = @(
    "Microsoft-Hyper-V-All",
    "Microsoft-Hyper-V-Tools-All",
    "Microsoft-Hyper-V-Management-PowerShell",
    "Microsoft-Hyper-V-Hypervisor",
    "Microsoft-Hyper-V-Services",
    "Microsoft-Hyper-V-Management-Clients"
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..." -ForegroundColor Gray
    dism /online /enable-feature /featurename:$pkg /all /norestart 2>$null
}

Write-Host ""
Write-Host "Hyper-V installation complete." -ForegroundColor Green
Write-Host "A restart is required. Restart now? (y/n)" -ForegroundColor Yellow
$answer = Read-Host

if ($answer -eq "y") {
    Restart-Computer
} else {
    Write-Host "Please restart your computer before using Hyper-V." -ForegroundColor Yellow
}
