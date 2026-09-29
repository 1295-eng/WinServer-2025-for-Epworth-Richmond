# Windows Hypervisor BCD Automation & Diagnostics Toolkit

Automated PowerShell tooling to resolve low-level hypervisor conflicts on Windows 11 host machines, enabling dynamic switching between **Virtualization-Based Security (VBS/WHPX/WSL2/Docker)** and **Bare-Metal AMD-V / RVI Hardware Virtualization** for VMware Workstation 17.5.

---

## Technical Problem Statement

Windows Hyper-V and Virtualization-Based Security (VBS) lock the CPU's Ring -1 virtualization extensions (`AMD-V / SVM`) at boot. This causes performance degradation and restricts nested virtualization capabilities (such as nested ESXi, KVM, or Active Directory labs) in third-party hypervisors like VMware Workstation.

This repository provides a **Third-Way BCD Automation Strategy** that implements dual boot profiles on a single Windows 11 installation, alongside dynamic audit scripts to verify host hardware execution states.

---

## Repository Contents

| Script Name | Purpose | Execution Scope |
| :--- | :--- | :--- |
| `Unblock-AmdvHardware.ps1` | Disables hypervisor boot launch, registry VBS/HVCI keys, and optional features. | Administrator |
| `Test-AmdvAvailability.ps1` | Verifies unblocked Ring -1 AMD-V hardware access post-reboot. | User |
| `Test-HyperVAvailability.ps1` | Audits Hyper-V and VBS active execution telemetry. | User |
| `Test-HypervVmwareCoexistence.ps1` | Tests for WHPX API Coexistence Mode support. | User |
| `Set-BcdDualBootProfiles.ps1` | Provisions automated dual-boot entries in Windows BCD store. | Administrator |
| `Switch-BootTarget.ps1` | One-click auto-switcher targeting alternate BCD profile for next boot. | Administrator |
| `New-SwitchShortcut.ps1` | Generates a desktop `.lnk` shortcut forcing elevated execution for `Switch-BootTarget.ps1`. | User |

---

## Quick Start Guide

### 1. Provision Dual BCD Profiles
Open **PowerShell as Administrator** and execute:
```powershell
.\Set-BcdDualBootProfiles.ps1
