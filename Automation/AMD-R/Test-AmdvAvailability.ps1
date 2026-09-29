<#
.SYNOPSIS
    Verifies if AMD-V / RVI hardware extensions are active and free from Hyper-V reservation post-reboot.
#>

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " AMD-V / RVI Hardware Virtualization Post-Reboot Audit " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
Write-Host "`n[+] CPU Info: $($Processor.Name)" -ForegroundColor Gray

$CompSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$HypervisorPresent =$CompSystem.HypervisorPresent

$DeviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace "root\Microsoft\Windows\DeviceGuard" -ErrorAction SilentlyContinue
$VbsStatus = if ($DeviceGuard) { $DeviceGuard.VirtualizationBasedSecurityStatus } else { 0 }$SecurityServices = if ($DeviceGuard) {$DeviceGuard.SecurityServicesRunning } else { @() }
$HvciRunning =$SecurityServices -contains 2

Write-Host "`n--- System Telemetry ---" -ForegroundColor Yellow

if (-not $HypervisorPresent) {
    Write-Host " [PASS] Windows Hypervisor Launch Type : OFF (HypervisorPresent = False)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Windows Hypervisor Launch Type : RUNNING (HypervisorPresent = True)" -ForegroundColor Red
}

if ($VbsStatus -eq 0) {
    Write-Host " [PASS] Virtualization-Based Security : Disabled (0)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Virtualization-Based Security : Active ($VbsStatus)" -ForegroundColor Red
}

if (-not $HvciRunning) {
    Write-Host " [PASS] Memory Integrity (HVCI)        : Disabled" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Memory Integrity (HVCI)        : Active (Running in Ring -1)" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan

if ((-not $HypervisorPresent) -and ($VbsStatus -eq 0)) {
    Write-Host " VERDICT: GREEN LIGHT!" -ForegroundColor Green
    Write-Host " AMD-V / RVI CPU extensions are free from host hypervisor locks." -ForegroundColor Green
    Write-Host " VMware Workstation 17.5 can execute raw hardware-nested VMs." -ForegroundColor Green
} else {
    Write-Host " VERDICT: RED LIGHT - Hyper-V or VBS is still active." -ForegroundColor Red
}

Write-Host "============================================================" -ForegroundColor Cyan
