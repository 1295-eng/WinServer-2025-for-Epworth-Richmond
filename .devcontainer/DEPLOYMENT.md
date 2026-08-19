Deployment Guide
Complete step-by-step instructions for deploying WinServer-2025-for-Epworth-Richmond.

Pre-Deployment Checklist
 Windows Server 2022+ or Windows 10+ installed
 Administrator account available
 100GB+ free disk space (C: drive)
 Network adapter active and connected
 PowerShell 5.1+ installed
 Git installed (for cloning repository)
 Backup any existing Hyper-V configurations
 Disable Hyper-V if previously installed
Step 1: Environment Preparation
1.1 Open PowerShell as Administrator
# Right-click PowerShell → Run as Administrator
# Verify you're running as admin
[Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() | Select-Object -ExpandProperty Groups | Select-Object Value
# Should show S-1-5-32-544 (Administrators group)
1.2 Set Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
1.3 Verify System Requirements
# Check OS version
Get-ComputerInfo | Select-Object OSName, OSVersion

# Check CPU virtualization support
Get-ComputerInfo | Select-Object HyperVPhysicalProcessor, HyperVVirtualizationFirmwareEnabled

# Check free disk space
Get-Volume | Where-Object { $_.DriveLetter -eq 'C' } | Select-Object DriveLetter, SizeGB, SizeRemainingGB
Step 2: Repository Setup
2.1 Clone Repository
# Choose installation location
$InstallPath = "C:\Projects\WinServer-2025"
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
cd $InstallPath

# Clone repository
git clone https://github.com/1295-eng/WinServer-2025-for-Epworth-Richmond.git
cd WinServer-2025-for-Epworth-Richmond
2.2 Verify Structure
# Check directory structure
tree /F

# Verify key files exist
Test-Path ".\src\Deploy.ps1"
Test-Path ".\src\config\default-config.psd1"
Test-Path ".\src\modules\*.psm1"
Step 3: Configuration Review
3.1 Review Default Configuration
# Open configuration file
code .\src\config\default-config.psd1

# Load and verify configuration
$Config = Import-PowerShellDataFile -Path ".\src\config\default-config.psd1"
$Config | Format-List
3.2 Customize Configuration (Optional)
# Copy default config for customization
Copy-Item .\src\config\default-config.psd1 .\src\config\custom-config.psd1

# Edit custom configuration
code .\src\config\custom-config.psd1

# Example: Change storage location
# Storage.StorageRoot = "D:\ClusterStorage\HyperV-Data"
Step 4: Pre-Deployment Validation
4.1 Run Pre-Flight Checks
# Import validation module
Import-Module ".\src\modules\Validation.psm1" -Force

# Run all validation checks
Invoke-PreFlightChecks
4.2 Review Warnings/Errors
# Address any warnings before proceeding
# Common issues:
# - Hyper-V virtualization not enabled in BIOS → Enable in BIOS/UEFI
# - Insufficient disk space → Free up space or change storage location
# - No active network adapter → Connect network cable or enable adapter
# - Not running as admin → Re-run PowerShell as Administrator
Step 5: Execution
5.1 Start Deployment
# Run full deployment
.\src\Deploy.ps1

# Or with custom configuration
.\src\Deploy.ps1 -ConfigPath ".\src\config\custom-config.psd1"
5.2 Monitor Progress
# Deployment output shows:
# ✓ Completed phases (green)
# ⚠ Warnings (yellow)
# ✗ Errors (red)

# Full transcript logged to:
# C:\Logs\Deployment-Automation-*.log
5.3 Handle Phase-Specific Execution
# Run only specific phases
.\src\Deploy.ps1 -SkipPhaseA          # Skip pre-flight
.\src\Deploy.ps1 -SkipPhaseM          # Skip Hyper-V install
.\src\Deploy.ps1 -SkipPhaseZ          # Skip networking
.\src\Deploy.ps1 -SkipPhaseOmega      # Skip VM provisioning

# Example: Skip everything except Hyper-V
.\src\Deploy.ps1 -SkipPhaseA -SkipPhaseZ -SkipPhaseOmega
Step 6: Post-Deployment
6.1 Verify Hyper-V Installation
# Check Hyper-V role
Get-WindowsFeature Hyper-V | Select-Object Name, InstallState

# Verify Hyper-V services
Get-Service | Where-Object { $_.Name -like "Hyper*" } | Select-Object Name, Status

# List created virtual switches
Get-VMSwitch
6.2 Verify Storage Configuration
# Check storage paths
$Config = Import-PowerShellDataFile -Path ".\src\config\default-config.psd1"
Get-Item $Config.Storage.StorageRoot -ErrorAction SilentlyContinue

# Check directory structure
dir $Config.Storage.StorageRoot -Recurse

# Verify permissions
Get-Acl $Config.Storage.StorageRoot | Select-Object Owner, Access
6.3 Review Deployment Logs
# Locate log file
$LogFile = Get-ChildItem "C:\Logs\Deployment-Automation-*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Review log
Write-Host "Log file: $($LogFile.FullName)"
Get-Content $LogFile.FullName | Tail -100

# Full review
code $LogFile.FullName
6.4 System Restart (If Required)
# If Phase M indicates restart required:
Restart-Computer -Force

# After restart, verify Hyper-V is fully installed
Get-VMSwitch
Get-VM  # Should work without errors
Step 7: VM Provisioning
7.1 Create First Clinical VM
# Load provisioning function
. ".\src\phases\Phase-Omega-VM.ps1"

# Create virtual machine
New-ClinicalVM -VMName "ClinicTerminal-01" `
               -MemoryGB 4 `
               -ProcessorCount 2
7.2 Verify VM Creation
# List created VMs
Get-VM

# Check VM details
Get-VM -Name "ClinicTerminal-01" | Select-Object Name, State, DynamicMemoryEnabled

# Check network connection
Get-VMNetworkAdapter -VMName "ClinicTerminal-01"
7.3 Provision Multiple VMs
# Create multiple clinical terminals
for ($i = 1; $i -le 5; $i++) {
    $vmName = "ClinicTerminal-{0:00}" -f $i
    New-ClinicalVM -VMName $vmName -MemoryGB 4 -ProcessorCount 2
    Write-Host "Created: $vmName"
}

# Verify all VMs
Get-VM | Format-Table Name, State, ProcessorCount, MemoryMB
Step 8: Post-Provisioning Configuration
8.1 Connect to VM Console
# Start VM if stopped
Start-VM -Name "ClinicTerminal-01"

# Connect via Hyper-V Manager
vmconnect.exe localhost "ClinicTerminal-01"

# Alternative: PowerShell
$vm = Get-VM -Name "ClinicTerminal-01"
$vmVideo = $vm | Get-VMVideo
Write-Host "VM console available - launch Hyper-V Manager or use vmconnect"
8.2 Configure Operating System
# VM will need:
# 1. Operating system installation (Windows Server 2022 or Windows 11)
# 2. Network configuration
# 3. Clinical application installation
# 4. Entra ID integration
# 5. MailEnable configuration (if applicable)
8.3 Apply Clinical Configuration
# After OS installation in VM:
# 1. Join Entra ID domain
# 2. Install clinical applications
# 3. Configure network policies
# 4. Enable audit logging
# 5. Implement HIPAA compliance settings
Troubleshooting
Common Issues
"Access Denied" during execution
# Solution: Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator
whoami  # Should show SYSTEM or Administrator account
"Hyper-V not available" after installation
# Solution: System restart required
Restart-Computer -Force

# After restart, verify
Get-VMSwitch
"Insufficient disk space" error
# Solution: Free up disk space or change storage location

# Check available space
Get-Volume | Format-Table DriveLetter, SizeGB, SizeRemainingGB

# Or modify configuration
$config = Import-PowerShellDataFile ".\src\config\default-config.psd1"
# Change to different drive, e.g., D:\ClusterStorage\HyperV-Data
"Network adapter not found" error
# Solution: Verify network adapter is active
Get-NetAdapter | Format-Table Name, Status, LinkSpeed

# Connect network cable or enable adapter if needed
Debug Mode
# Enable verbose output
$VerbosePreference = "Continue"

# Run deployment with verbose logging
.\src\Deploy.ps1 -Verbose

# Check logs for detailed information
Get-Content "C:\Logs\*.log" -Tail 50
Rollback Procedures
Phase-Level Rollback
# Revert to snapshot (if using storage snapshots)
# Or manually undo changes:

# Phase A: No rollback needed (read-only checks)

# Phase M: Uninstall Hyper-V
Uninstall-WindowsFeature -Name Hyper-V -ComputerName localhost

# Phase Z: Disable QoS
# (Reverse QoS policies)

# Phase Ω: Remove VMs
Get-VM | Remove-VM -Force
Remove-Item C:\ClusterStorage\HyperV-Data -Recurse -Force
Clean Slate
# Prepare system for fresh deployment
$feature = Get-WindowsFeature -Name Hyper-V
if ($feature.InstallState -eq "Installed") {
    Uninstall-WindowsFeature -Name Hyper-V -Force
    Write-Host "Hyper-V uninstalled. System restart required."
    Restart-Computer -Force
}
Validation
Post-Deployment Checklist
 Hyper-V role installed
 Virtual switch "Clinical-External-Switch" created
 Storage path configured: C:\ClusterStorage\HyperV-Data
 Logs exist: C:\Logs\
 First VM provisioned and running
 Network adapter correctly bound to switch
 No errors in deployment log
Performance Validation
# Check Hyper-V host performance
Get-Counter -Counter "\Hyper-V Hypervisor Logical Processor(_Total)\% Guest Run Time"

# Monitor VM resource usage
Get-VM | Get-VMProcessor | Select-Object VMName, Maximum, ExpectedTotal

# Check storage utilization
(Get-Item C:\ClusterStorage\HyperV-Data -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
Next Steps
Configure Entra ID Integration

Join VMs to Entra ID domain
Setup single sign-on
Configure conditional access
Install Clinical Applications

Deploy medical software
Configure application-specific settings
Test clinical workflows
Implement Monitoring

Setup Azure Monitor
Configure alert rules
Enable performance tracking
Security Hardening

Configure Windows Defender
Enable MFA
Implement network segmentation
Backup & Disaster Recovery

Setup VM backups
Create recovery procedures
Test restore procedures
Support
For additional help:

Review TROUBLESHOOTING.md
Check ARCHITECTURE.md
Visit GitHub Issues
Email: JamesWeardley@outlook.com
Last Updated: 2026-08-18
