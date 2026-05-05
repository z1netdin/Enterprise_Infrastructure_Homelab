#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Creates the Proxmox VE virtual machine on Hyper-V with nested virtualization.

.DESCRIPTION
    Automates the creation of a Proxmox VE VM on Hyper-V for the Enterprise
    Infrastructure Home Lab project. Creates the VM, configures networking,
    enables nested virtualization, and mounts the Proxmox ISO.

.PARAMETER ProxmoxIsoPath
    Path to the Proxmox VE ISO file.

.PARAMETER VmPath
    Directory where VM files will be stored. Defaults to C:\HyperV\Proxmox-VE.

.EXAMPLE
    .\Create-ProxmoxVM.ps1 -ProxmoxIsoPath "C:\ISOs\proxmox-ve_8.3-1.iso"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ProxmoxIsoPath,

    [string]$VmPath = "C:\HyperV\Proxmox-VE"
)

$ErrorActionPreference = "Stop"

$VmName = "Proxmox-VE"
$VmMemory = 32GB
$VmProcessors = 8
$VhdSizeBytes = 200GB
$LabSwitchName = "LabSwitch"

# --- Check prerequisites ---
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

$hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
if ($hyperv.State -ne "Enabled") {
    Write-Error "Hyper-V is not enabled. Run: Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"
    exit 1
}

# Check if VM already exists
if (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
    Write-Error "VM '$VmName' already exists. Remove it first or choose a different name."
    exit 1
}

# --- Create lab network switch ---
Write-Host "Creating lab network switch '$LabSwitchName'..." -ForegroundColor Cyan

if (-not (Get-VMSwitch -Name $LabSwitchName -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name $LabSwitchName -SwitchType Internal | Out-Null

    $adapter = Get-NetAdapter | Where-Object { $_.Name -like "*$LabSwitchName*" }
    New-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -IPAddress 10.10.10.254 -PrefixLength 24 | Out-Null

    Write-Host "  Created internal switch with host IP 10.10.10.254/24" -ForegroundColor Green
} else {
    Write-Host "  Switch '$LabSwitchName' already exists, skipping." -ForegroundColor Yellow
}

# --- Create VM directory ---
if (-not (Test-Path $VmPath)) {
    New-Item -ItemType Directory -Path $VmPath -Force | Out-Null
}

# --- Create the VM ---
Write-Host "Creating VM '$VmName'..." -ForegroundColor Cyan

$vhdPath = Join-Path $VmPath "$VmName.vhdx"

New-VM -Name $VmName `
    -MemoryStartupBytes $VmMemory `
    -Generation 2 `
    -NewVHDPath $vhdPath `
    -NewVHDSizeBytes $VhdSizeBytes `
    -SwitchName "Default Switch" | Out-Null

# --- Configure VM settings ---
Write-Host "Configuring VM settings..." -ForegroundColor Cyan

# Set processors and enable nested virtualization
Set-VMProcessor -VMName $VmName -Count $VmProcessors -ExposeVirtualizationExtensions $true

# Disable dynamic memory
Set-VMMemory -VMName $VmName -DynamicMemoryEnabled $false

# Disable secure boot (Proxmox uses Linux bootloader)
Set-VMFirmware -VMName $VmName -EnableSecureBoot Off

# Add the lab network adapter
Add-VMNetworkAdapter -VMName $VmName -SwitchName $LabSwitchName

# Mount the Proxmox ISO
Add-VMDvdDrive -VMName $VmName -Path $ProxmoxIsoPath

# Set boot order: DVD first, then hard drive
$dvd = Get-VMDvdDrive -VMName $VmName
$hdd = Get-VMHardDiskDrive -VMName $VmName
Set-VMFirmware -VMName $VmName -BootOrder $dvd, $hdd

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host " Proxmox VE VM created successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "VM Configuration:" -ForegroundColor Cyan
Write-Host "  Name:        $VmName"
Write-Host "  CPUs:        $VmProcessors"
Write-Host "  Memory:      $($VmMemory / 1GB) GB"
Write-Host "  Disk:        $($VhdSizeBytes / 1GB) GB"
Write-Host "  Nested Virt: Enabled"
Write-Host "  Network 1:   Default Switch (WAN/management)"
Write-Host "  Network 2:   $LabSwitchName (Lab LAN)"
Write-Host "  ISO:         $ProxmoxIsoPath"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Start the VM:  Start-VM -Name '$VmName'"
Write-Host "  2. Connect:       vmconnect localhost '$VmName'"
Write-Host "  3. Install Proxmox VE following the setup guide"
Write-Host ""
