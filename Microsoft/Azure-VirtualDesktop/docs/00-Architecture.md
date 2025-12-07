# 00 – Azure Virtual Desktop Architecture (Storage Options)
![AVD](https://img.shields.io/badge/Azure%20Virtual%20Desktop-Architecture-0a84ff)
![Storage](https://img.shields.io/badge/Storage-Azure%20Files%20%7C%20DFS-blue)
![Profiles](https://img.shields.io/badge/FSLogix-Profile%20Containers-orange)

---

# 🧭 1. Overview
This document provides the updated **AVD Architecture Overview**, now including a clearly structured **“Choose Azure Files OR DFS”** storage decision model.

This matches real enterprise AVD architecture (Cabrini-style) while fully supporting your home-lab setup.

---

# 🧱 2. Core AVD Architecture

```mermaid
flowchart LR
    User["User Devices"]
    AVD["Azure Virtual Desktop<br>Workspace & Broker"]
    HP["Host Pool"]
    VMSS["VM Scale Set<br>Session Hosts"]
    IMG["Shared Image Gallery<br>(Golden Images)"]

    User --> AVD --> HP --> VMSS --> IMG
```

This remains unchanged — storage only impacts where FSLogix profile containers live.

---

# 🎯 3. Storage Architecture (Choose One)

Azure Virtual Desktop supports multiple backend storage options for FSLogix profile containers.  
Your environment supports **two valid architectures**:

---

# 🔵 Option A — Azure Files Premium (Enterprise Production)

**Use for:** Hospitals, large orgs, compliance environments, real AVD deployments.

### ✔ Features
- Highly available, resilient storage
- Kerberos authentication (AADDS or Entra ID)
- Azure Backup & snapshots
- Microsoft-recommended for production
- Predictable throughput & scalability

### ✔ Architecture

```mermaid
flowchart LR
    SH["AVD Session Hosts"]
    AF["Azure Files Premium<br>\\\\storageacct.file.core.windows.net\\profiles"]
    AAD["AADDS / Entra Kerberos"]

    SH -->|SMB 445| AF
    SH -->|Kerberos| AAD
    AF --> SH
```

### ✔ Choose Azure Files when:
- Deploying AVD in **Cabrini or enterprise environments**
- Need DR, snapshots, retention
- Want Microsoft supportability
- Running large concurrent user workloads

---

# 🟠 Option B — Local DFS / SMB Storage (Home Lab or Hybrid On-Prem)

**Use for:**  
Home labs, PoC environments, or when enterprise has existing file servers.

Example DFS path used in your lab:

```
\\home.lab\DFSRoot\Profiles
```

### ✔ Features
- Identical FSLogix behaviour to Azure Files
- Uses Windows NTFS permissions
- Supports Kerberos (if domain joined)
- Fully supports multi-session AVD
- Zero Azure Files cost
- Leverages existing infrastructure

### ✔ Architecture

```mermaid
flowchart LR
    SH["AVD Session Hosts"]
    DFS["DFS Namespace<br>\\\\home.lab\\DFSRoot\\Profiles"]
    FS01["File Server Backend<br>\\\\FS01.home.lab\\FSLogixProfiles$"]

    SH -->|SMB 445| DFS
    DFS --> FS01
    FS01 --> SH
```

### ✔ Choose DFS when:
- Building a realistic **AVD home lab**
- Avoiding Azure Files cost
- Simulating full enterprise FSLogix behaviour
- Testing DFS, NTFS permissions & SMB throughput

---

# 🟣 4. What Stays the Same in Both Architectures

| Component | Azure Files | DFS |
|----------|-------------|------|
| FSLogix profile container (VHDX) | ✔ | ✔ |
| Redirections.xml | ✔ | ✔ |
| Office Container | ✔ | ✔ |
| Cloud Cache support | ✔ | ✔ |
| Login behaviour | ✔ | ✔ |
| Multi-session roaming profile support | ✔ | ✔ |

🎉 **FSLogix does not care where the VHDX lives — only that SMB is reachable.**

---

# 🟤 5. What Changes Between Azure & DFS

| Feature | Azure Files | DFS |
|--------|-------------|------|
| Identity | Kerberos via AADDS/Entra | AD DS or NTLM fallback |
| Backup | Azure Backup, snapshots | Your backup tools (Veeam, etc.) |
| Throughput | Azure-managed scaling | Local hardware performance |
| Cost | Consumption-based | Zero cloud cost |
| DR | Geo-zone redundancy | Depends on DFS-R strategy |
| Permissions | RBAC + NTFS | NTFS only |

---

# 🧭 6. Storage Decision Model

| Scenario | Recommended Storage |
|----------|---------------------|
| **Cabrini production deployment** | Azure Files Premium |
| Home lab, cost-sensitive | DFS / SMB |
| High compliance requirement | Azure Files |
| Existing on-prem file servers | DFS |
| DR-critical workloads | Azure Files or Azure NetApp Files |

---

# 🔧 7. FSLogix Path Examples

### Azure Files
```
\\storageacct.file.core.windows.net\profiles
```

### DFS (your home lab)
```
\\home.lab\DFSRoot\Profiles
```

FSLogix registry key example:

```reg
"VHDLocations"=multi:"\\\\home.lab\\DFSRoot\\Profiles"
```

---

# 🏁 8. Summary

You now have two valid, documented FSLogix storage backends:

### ✔ Azure Files Premium  
Enterprise-grade, highly available, Microsoft-supported.

### ✔ Local DFS File Server  
Perfect for your home lab, nearly identical behaviour to production.
