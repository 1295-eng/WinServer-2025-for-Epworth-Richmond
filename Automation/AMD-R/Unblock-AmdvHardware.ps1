<#
.SYNOPSIS
    Disables BCD hypervisor launch, VBS, HVCI, and conflicting Windows features to unblock direct AMD-V/RVI access.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please re-launch PowerShell as Administrator!"
    exit 1
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " AMD-V / RVI Direct Hardware Virtualization Configuration " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Turn off Hypervisor at boot in BCD
Write-Host "`n[+] Stage 1: Setting hypervisorlaunchtype to OFF in BCD..." -ForegroundColor Yellow
bcdedit /set hypervisorlaunchtype off

# 2. Disable VBS and Core Isolation in Registry
Write-Host "`n[+] Stage 2: Disabling VBS & Core Isolation (HVCI) in Registry..." -ForegroundColor Yellow
$DeviceGuardPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
if (-not (Test-Path $DeviceGuardPath)) { New-Item -Path $DeviceGuardPath -Force | Out-Null }
Set-ItemProperty -Path $DeviceGuardPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $DeviceGuardPath -Name "HypervisorEnforcedCodeIntegrity" -Value 0 -Type DWord -Force

$HvciScenarioPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
if (-not (Test-Path $HvciScenarioPath)) { New-Item -Path $HvciScenarioPath -Force | Out-Null }
Set-ItemProperty -Path $HvciScenarioPath -Name "Enabled" -Value 0 -Type DWord -Force

# 3. Disable Conflicting Windows Features Safely
Write-Host "`n[+] Stage 3: Checking and disabling present hypervisor features..." -ForegroundColor Yellow
$CandidateFeatures = @("HypervisorPlatform", "VirtualMachinePlatform", "Microsoft-Hyper-V-All", "Microsoft-Hyper-V")
$InstalledFeatures = Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FeatureName

foreach ($Feature in$CandidateFeatures) {
    if ($InstalledFeatures -contains$Feature) {
        Write-Host "    [-] Disabling $Feature..." -ForegroundColor Gray
        Disable-WindowsOptionalFeature -Online -FeatureName $Feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
    } else {
        Write-Host "    [x] $Feature not installed/applicable on this SKU." -ForegroundColor DarkGray
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Configuration complete! Reboot required to release AMD-V." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
