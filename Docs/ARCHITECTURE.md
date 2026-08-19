System Architecture
Overview
WinServer-2025-for-Epworth-Richmond implements a three-tier healthcare infrastructure with defense-in-depth security principles:

┌─────────────────────────────────────────────────────────────────┐
│                    Clinical Endpoints                           │
│  (Virtual Machines - Isolated on Clinical-External-Switch)      │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────┴────────────────────────────────────┐
│              Virtual Networking Layer                           │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Clinical-External-Switch (QoS Enabled)                 │   │
│  │  - Dedicated for medical endpoints                       │   │
│  │  - Priority-based traffic management                     │   │
│  │  - Isolated from management traffic                      │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────┴────────────────────────────────────┐
│           Hyper-V Host Administration Layer                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Management OS                                           │   │
│  │  - Hyper-V Role                                          │   │
│  │  - Storage Management                                    │   │
│  │  - Access Control                                        │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌────────────────────────────┴────────────────────────────────────┐
│          Physical Infrastructure Layer                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Host Hardware                                           │   │
│  │  ├── CPU: Virtualization-Enabled Processor              │   │
│  │  ├── Memory: High-capacity, ECC (recommended)           │   │
│  │  ├── Storage: C:\ClusterStorage\HyperV-Data (100GB+)    │   │
│  │  └── Network: Redundant adapters (Up state)             │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
Component Architecture
1. Deployment Orchestration (src/Deploy.ps1)
Responsibilities:

Configuration loading
Module initialization
Phase sequencing
Error aggregation
Comprehensive reporting
Key Features:

Idempotent execution
Skip-phase capabilities
Custom configuration support
Phase-level error handling
2. PowerShell Modules
Logging Module (src/modules/Logging.psm1)
Centralized logging framework for all operations.

Exported Functions:

Initialize-Logging - Start logging session
Write-LogMessage - Color-coded logging with levels
Stop-Logging - Cleanup and close logging
Log Location: C:\Logs\Deployment-Automation-*.log

Validation Module (src/modules/Validation.psm1)
Pre-flight system validation and prerequisite checking.

Exported Functions:

Test-AdminPrivilege - Verify administrator rights
Test-OSRequirements - Validate OS version (Win10+)
Test-HyperVCapability - Check virtualization support
Test-DiskSpace - Verify storage availability
Test-NetworkAdapter - Ensure network connectivity
Invoke-PreFlightChecks - Run all validations
Storage Module (src/modules/Storage.psm1)
Hyper-V storage repository management with security hardening.

Exported Functions:

New-StorageRepository - Create and configure storage paths
Protect-StorageDirectory - Apply ACL restrictions
Get-StorageStats - Report storage usage
Storage Structure:

C:\ClusterStorage\HyperV-Data\
├── Virtual-Hard-Disks\       (VHD storage)
└── VM-Configurations\        (VM config files)
Network Module (src/modules/Network.psm1)
Virtual switch configuration and network topology management.

Exported Functions:

New-ClinicalExternalSwitch - Create isolated switch
Set-NetworkQoS - Configure quality of service
Get-NetworkAdapterInfo - Retrieve adapter details
Network Isolation:

Dedicated "Clinical-External-Switch" for healthcare traffic
Separate from management/host traffic
QoS prioritization for medical data
3. Deployment Phases
Phase A: Physical Environment (src/phases/Phase-A-PreFlight.ps1)
Validates hardware and optimizes system configuration.

Steps:

Verify Hyper-V firmware capabilities
Set Windows power policy to High-Performance
Validate all prerequisites met
Exit Criteria:

System ready for virtualization
Power management optimized for stability
Phase M: Core Installation (src/phases/Phase-M-HyperV.ps1)
Installs Hyper-V role and establishes infrastructure.

Steps:

Install Hyper-V role (if not present)
Discover primary network adapter
Create external virtual switch
Establish isolated storage repositories
Harden storage directory permissions
Exit Criteria:

Hyper-V installed and configured
Network switching operational
Storage ready for VMs
Phase Z: Network & Storage (src/phases/Phase-Z-Network.ps1)
Advanced networking and high-availability configuration.

Steps:

Configure QoS policies
Setup storage replication (planned)
Enable redundancy features
Exit Criteria:

Network prioritization active
High-availability ready
Phase Ω: VM Provisioning (src/phases/Phase-Omega-VM.ps1)
Provisions clinical endpoint virtual machines.

Functions:

New-ClinicalVM - Create individual VM with parameters
Connects to Clinical-External-Switch
Allocates configurable resources
Usage:

New-ClinicalVM -VMName "ClinicTerminal-01" -MemoryGB 4 -ProcessorCount 2
Security Architecture
Defense in Depth Strategy
Layer 1: Access Control (ACLs)
├── Storage directories restricted to Admin/System
├── Inheritance protection enabled
└── No unauthorized user access

Layer 2: Network Isolation
├── Dedicated clinical switch
├── Management traffic separated
└── QoS prioritization enabled

Layer 3: Data Protection
├── Hyper-V storage encryption (optional)
├── Audit logging enabled
└── HIPAA compliance configuration

Layer 4: System Hardening
├── Power management optimization
├── Virtualization isolation
└── Error handling and recovery
Access Control Model
Administrators (Full Control)
├── Hyper-V Management
├── Storage Administration
└── VM Lifecycle

System Account (Required Access)
├── Virtual Switch Operation
├── Storage I/O
└── VM Runtime

Clinical Users (Read-Only/Delegated)
├── VM Console Access (optional)
└── Clinical Application Access
Compliance Features
HIPAA-Ready: Clinical data isolation, audit logging
Audit Trail: Full transcripts of all operations
Change Control: Version tracking, deployment history
Security Hardening: ACL restrictions, inheritance protection
Data Flow
VM Provisioning Data Flow
Deploy.ps1
    │
    ├─→ Load Configuration
    │   └─→ default-config.psd1
    │
    ├─→ Import Modules
    │   ├─→ Logging.psm1
    │   ├─→ Validation.psm1
    │   ├─→ Storage.psm1
    │   └─→ Network.psm1
    │
    ├─→ Phase A (Validation)
    │   └─→ Pre-flight checks
    │
    ├─→ Phase M (Installation)
    │   ├─→ Install Hyper-V
    │   ├─→ Discover Network
    │   ├─→ Create Virtual Switch
    │   └─→ Setup Storage
    │
    ├─→ Phase Z (Advanced Config)
    │   ├─→ Configure QoS
    │   └─→ Setup Replication
    │
    └─→ Phase Ω (Provisioning)
        └─→ Create VMs (on-demand)
Module Dependencies
Deploy.ps1
├── Logging.psm1 (initialization)
├── Validation.psm1 (pre-flight)
├── Phase-A-PreFlight.ps1
│   └── Validation.psm1
├── Phase-M-HyperV.ps1
│   ├── Storage.psm1
│   └── Network.psm1
├── Phase-Z-Network.ps1
│   └── Network.psm1
└── Phase-Omega-VM.ps1
    └── Storage.psm1
Configuration Management
Configuration is centralized in src/config/default-config.psd1:

@{
    # Environment settings
    ProjectName = "WinServer-2025-for-Epworth-Richmond"
    Environment = "Production"
    
    # Storage topology
    Storage = @{
        StorageRoot = "C:\ClusterStorage\HyperV-Data"
        RequiredDiskSpaceGB = 100
    }
    
    # Network topology
    Network = @{
        ExternalSwitchName = "Clinical-External-Switch"
        EnableQoS = $true
    }
    
    # Hyper-V defaults
    HyperV = @{
        DefaultMemoryGB = 4
        DefaultProcessorCount = 2
    }
    
    # Compliance settings
    Clinical = @{
        DataIsolation = $true
        ComplianceMode = "HIPAA"
    }
}
Extensibility Points
Adding Custom Phases
Create new phase script in src/phases/Phase-*.ps1
Define orchestration function
Import required modules
Add to Deploy.ps1 phase sequence
Test with Pester
Adding Custom Modules
Create module in src/modules/ directory
Export required functions
Add Import-Module call to Deploy.ps1
Document exported functions
Add unit tests
Custom Configuration
Copy default-config.psd1 to new file
Modify settings as needed
Run: Deploy.ps1 -ConfigPath ".\custom-config.psd1"
Performance Considerations
Optimization Recommendations
High-Performance Power Policy - Maintains CPU speed
SSD Storage - Improves VM I/O performance
Redundant Adapters - Provides network failover
ECC Memory - Ensures data integrity
Adequate vCPUs - Minimum 4 cores recommended
Scalability
Current architecture supports:

10-20 VMs on standard hardware
100+ VMs with enterprise-grade hardware
Horizontal scaling via additional Hyper-V hosts
Storage replication (Phase Z) for high-availability
Monitoring & Logging
Log Locations
Deployment Logs: C:\Logs\Deployment-Automation-*.log
PowerShell Transcript: Enabled by default
Event Viewer: Windows Event Logs
Health Checks
Recommended monitoring:

VM CPU/Memory utilization
Storage space availability
Network QoS statistics
Hyper-V host health
Disaster Recovery
Backup Strategy
Configuration: Version control in Git
VHD Files: Regular snapshots
VM Configs: Backed up to secure storage
Logs: Archived for audit compliance
Recovery Procedures
See TROUBLESHOOTING.md for:

Phase rollback procedures
VM recovery steps
Storage recovery
Network reconfiguration
References
Microsoft Hyper-V Docs
HIPAA Compliance
PowerShell Documentation
Windows Server Security
