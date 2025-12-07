# 03 – Storage Architecture for FSLogix Profiles  
**Azure Virtual Desktop – Storage Strategy Overview**  
_Last updated: 2026-01-xx_

---

## 🎯 Purpose
AVD requires a reliable, low-latency file share for storing FSLogix Profile Containers and Office Containers.  
There are **two fully supported architectures**:

---

# 🟦 Option A — Azure Files (Recommended for Cloud-Native AVD)

**Best for:**  
- Pure Azure deployments  
- Enterprise scalability  
- High availability + Microsoft-managed storage  
- Azure AD (Entra) Kerberos authentication  
- No on-prem dependencies  

Azure Files gives you:  
✔ Global redundancy  
✔ Snapshot backups  
✔ High IOPS (Premium tier)  
✔ Integrated identity (Entra Kerberos or AD DS)

See **03a-Azure-Files-FSLogix.md** for full design + config.

---

# 🟩 Option B — On-Prem DFS Namespace + File Servers  
(AVD Hybrid Storage)

**Best for:**  
- Organisations with existing file server infrastructure  
- Needing to keep profile data on-prem  
- Where backups, compliance, and storage are already centralised locally  
- Scenarios where WAN <-> Azure latency is acceptable

Architecture typically includes:  
✔ DFS Namespace (`\\home.lab\DFSRoot\Profiles`)  
✔ DFS Replication (optional)  
✔ SMB share hosting FSLogix VHDX files  
✔ Line-of-sight via VPN/ExpressRoute/S2S  

See **03b-DFS-FSLogix.md** for full design + config.

---

# 🧭 Choosing the Right Option

| Requirement | Azure Files | DFS On-Prem |
|------------|-------------|-------------|
| Pure-cloud, zero infra | ⭐⭐⭐⭐⭐ | ⭐ |
| Low-latency connectivity guaranteed | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Existing strong backup & NAS | ⭐ | ⭐⭐⭐⭐⭐ |
| Entra Kerberos, passwordless | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Disaster recovery built-in | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Cost control | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

# 🏗 High-Level Architecture Diagram

```mermaid
flowchart LR

subgraph User["AVD Session Hosts (VMSS)"]
A1[FSLogix Profile Service]
A2[Windows 11 Multi-session]
end

subgraph Storage["Storage Options"]
B1[Azure Files (Premium/LRS)<br/>Entra Kerberos]
B2[DFS Namespace<br/>On-Prem File Server]
end

A1 --> |Profile Container (VHDX read/write)| B1
A1 -.-> |Alternative Path| B2
