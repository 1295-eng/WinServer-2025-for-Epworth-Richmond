# WinServer-2025-for-Epworth-Richmond
# A-toZ Deployment Automation
# Automated PowerShell Scripts for Hyper-V deployment with Entra ID integration

# ============================================================================
# Phase A: Physical environment and preparation
# ============================================================================

# 1. Verify hardware virtualization capabilities in firmware
$HyperVCheck = Get-ComputerInfo | Select-Object HyperV*
Write-Host "--- Hyper-V Firmware Requirements Status ---" -ForegroundColor Cyan
$HyperVCheck | Format-List

# 2. Optimize power configuration for enterprise host workloads (High Performance)
Write-Host "Enforcing High-Performance power policy for virtualization stability..." -ForegroundColor Green
Powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# ============================================================================
# Phase M: Core Installation and Hyper vising Supervising
# ============================================================================

# 3. Install Hyper-V Role along with PowerShell administrative tools
Write-Host "Installing Hyper-V role and management binaries..." -ForegroundColor Green
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools

# [SYSTEM NOTE] A system restart is required after this step.
# You can execute the restart safely by uncommenting the line below:
# Restart-Computer -Force

# 4. Discover the fastest active physical network adapter for external bridging
$PhysicalAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Sort-Object LinkSpeed -Descending | Select-Object -First 1

Write-Host "Binding External Virtual Switch to adapter: $($PhysicalAdapter.Name)" -ForegroundColor Green

# 5. Provision the External Virtual Switch for Clinical Data Isolation
New-VMSwitch -Name "Clinical-External-Switch" `
             -NetAdapterName $PhysicalAdapter.Name `
             -AllowManagementOS $True `
             -Notes "Dedicated network bridge for medical endpoints and telemetry data streams."

# 6. Establish and lock down dedicated virtual storage repositories
$StorageRoot = "C:\ClusterStorage\HyperV-Data"
$VHDPath     = "$StorageRoot\Virtual-Hard-Disks"
$ConfigPath  = "$StorageRoot\VM-Configurations"

# Create the directories programmatically if they don't exist
New-Item -ItemType Directory -Force -Path $VHDPath | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigPath | Out-Null

# Force Hyper-V Host default paths to point to these isolated directories
Set-VMHost -VirtualHardDiskPath $VHDPath -VirtualMachinePath $ConfigPath
Write-Host "Hyper-V default storage paths successfully isolated to $StorageRoot" -ForegroundColor Green

# ============================================================================
# Phase Z: Virtual network and storage typologies
# ============================================================================
# [Additional Phase Z configurations to be implemented]

# ============================================================================
# Phase Ω: Virtual Machine Provisioning (Clinical Terminal)
# ============================================================================
# [Additional Phase Ω configurations to be implemented]
