<#
.SYNOPSIS
    Audits whether Hyper-V, VBS, and HVCI are active on the host OS.
#>

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Hyper-V & VBS Hardware Virtualization Audit " -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

$Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
Write-Host "`n[+] CPU Info: $($Processor.Name)" -ForegroundColor Gray

$CompSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$HypervisorPresent = $CompSystem.HypervisorPresent

$DeviceGuard = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace "root\Microsoft\Windows\DeviceGuard" -ErrorAction SilentlyContinue
$VbsStatus = if ($DeviceGuard) { $DeviceGuard.VirtualizationBasedSecurityStatus } else { 0 }
$SecurityServices = if ($DeviceGuard) { $DeviceGuard.SecurityServicesRunning } else { @() }
$HvciRunning = $SecurityServices -contains 2

Write-Host "`n--- System Telemetry ---" -ForegroundColor Yellow

if ($HypervisorPresent) {
    Write-Host " [PASS] Windows Hypervisor Launch Type : AUTO / RUNNING (HypervisorPresent = True)" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Windows Hypervisor Launch Type : OFF / NOT RUNNING (HypervisorPresent = False)" -ForegroundColor Red
}

if ($VbsStatus -eq 2) {
    Write-Host " [PASS] Virtualization-Based Security : Running (2)" -ForegroundColor Green
} else {
    Write-Host " [INFO] Virtualization-Based Security : Status Code = $VbsStatus" -ForegroundColor Gray
}

if ($HvciRunning) {
    Write-Host " [PASS] Memory Integrity (HVCI)        : Active (Running in Ring -1)" -ForegroundColor Green
} else {
    Write-Host " [INFO] Memory Integrity (HVCI)        : Disabled" -ForegroundColor Gray
}

Write-Host "`n============================================================" -ForegroundColor Cyan

if ($HypervisorPresent) {
    Write-Host " VERDICT: HYPER-V IS ACTIVE!" -ForegroundColor Green
    Write-Host " Hyper-V VMs, WSL2, and Windows Sandbox can run." -ForegroundColor Green
} else {
    Write-Host " VERDICT: HYPER-V IS INACTIVE." -ForegroundColor Red
}

Write-Host "============================================================" -ForegroundColor Cyan
