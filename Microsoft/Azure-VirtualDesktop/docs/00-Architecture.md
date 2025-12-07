# 00 - Azure Virtual Desktop Architecture

## 1. Overview

This document provides a high‑level and technical architecture overview for the Azure Virtual Desktop (AVD) lab deployment.  
It covers identity, networking, storage, compute, FSLogix, Kerberos for Azure Files, and supporting Azure resources.

---

## 2. High-Level Architecture Diagram

```
+--------------------------+        +-----------------------------+
|     Azure AD / Entra ID |        |  Azure AD Domain Services   |
|  (Identity & AuthN/Z)   |        |  (Kerberos / LDAP / DNS)    |
+------------+-------------+        +-------------+---------------+
             |                                       |
             | Hybrid Identity Sync                  |
             |                                       |
+------------v-------------+        +----------------v-------------+
|         Users            |  RDP   |    AADDS-VNET (10.0.0.0/24)  |
|  (Windows / macOS etc.) +-------->  Domain Controllers (A/B)    |
+--------------------------+        |    DNS: 10.0.0.4 / 10.0.0.5  |
                                    +------------------------------+

                                   Peered VNETs (bidirectional)

+---------------------------------------------------------------+
|                    VNET-AVD-Lab (10.1.0.0/16)                 |
|                                                               |
|  +------------------+     +------------------+                |
|  | AVD Session Host |     | AVD Session Host |  Scaling Plan |
|  | VM 01 (10.1.1.x) | ... | VM 02 (10.1.1.x) | <------------->|
|  +------------------+     +------------------+                |
|            | FSLogix Profile Container Access                 |
|            |                                                  |
|  +-----------------------------+                               |
|  | Azure Files (Profile SMB)  | Kerberos Auth (AADDS)         |
|  | Storage Account:           | DNS-integrated share          |
|  | \stavdprofiles1.file.core |                               |
|  +-----------------------------+                               |
+---------------------------------------------------------------+

```

---

## 3. Identity Architecture

### Components
| Component | Purpose |
|----------|----------|
| **Microsoft Entra ID** | Primary identity provider for AVD, portal access, RBAC |
| **Azure AD Domain Services (AADDS)** | Kerberos + LDAP domain used by session hosts |
| **Hybrid Identity (optional)** | Allows syncing users from on‑prem AD if used |

### Key Decisions
- Using **Azure AD DS** for simplicity — no on‑prem DC required.  
- Users authenticate via **Entra ID**, session hosts join **AADDS** domain.  
- FSLogix profiles use **Kerberos authentication** (no access keys).

---

## 4. Networking Architecture

### VNETs
| VNET | Address Space | Purpose |
|------|---------------|---------|
| **AADDS‑VNET** | `10.0.0.0/24` | Domain controllers, DNS, LDAP/Kerberos |
| **AVD‑Lab‑VNET** | `10.1.0.0/16` | Session hosts, Bastion, management |

### Subnets (AVD)
| Subnet | CIDR | Purpose |
|--------|------|---------|
| `default` | 10.1.0.0/24 | Shared resources |
| `AVD-Hosts` | 10.1.1.0/24 | Session Host VMs |
| `Management` | 10.1.2.0/24 | Bastion / Jumpbox |

### DNS Forwarding
- AVD VNET uses **DNS 10.0.0.4 and 10.0.0.5** from AADDS.
- Required so domain join and Kerberos succeed.

### Peering
| Peering | Direction | Purpose |
|---------|-----------|---------|
| AVD-VNET → AADDS-VNET | Enabled | Domain join, DNS, Kerberos |
| AADDS-VNET → AVD-VNET | Enabled | DC responses, profile access |

Both peerings enable:
- **Forwarded traffic**
- **Remote VNET access**

---

## 5. Storage Architecture (FSLogix)

### Storage Account
| Setting | Value |
|--------|--------|
| Type | Azure Files (Standard) |
| Redundancy | LRS/GRS (lab uses GRS) |
| Identity Source | **Azure AD DS Kerberos** |
| Authentication | **Kerberos only** |

### FSLogix Profile Share
```
\stavdprofiles1.file.core.windows.net\profiles
```

Permissions:
- AADDS Group: `FSLogix-Users`
  - `Modify` NTFS + Share permissions
- Session Hosts: machine accounts require share access

### Kerberos Setup Summary
- Enable `AADDS` identity source on the share
- Create Kerberos keys automatically during setup
- Rotate keys via PowerShell if required

---

## 6. Compute Architecture

### AVD Session Hosts
- Windows 11 / Windows Server (lab uses Win11 Multi-session)
- Joined to **AADDS domain**
- Deployed via:
  - Scaling Plan
  - Host Pool (Pooled, breadth-first)

### Host Pool Components
| Component | Purpose |
|----------|----------|
| **Host Pool** | Logical grouping of session hosts |
| **Application Group** | Assigns RemoteApp/Desktop access |
| **Workspace** | Where users connect (Remote Desktop app) |

---

## 7. Security Architecture

### Access Control
- Entra ID roles:
  - **AVD Administrator**
  - **Virtual Machine Contributor**
  - **Storage File Data SMB Share Contributor**

### Network Security
- NSGs applied to:
  - AVD session hosts
  - Management subnet
- Allow:
  - RDP (only if Bastion not used)
  - SMB to storage
  - LDAP/Kerberos to AADDS

### Encryption
- Data encrypted at‑rest via **MMK**
- SMB traffic encrypted in‑transit

---

## 8. Deployment Flow Summary

1. Deploy **Resource Group**
2. Deploy **AADDS**
3. Deploy **Two VNETs**:
   - AADDS-VNET
   - AVD-Lab-VNET
4. Add subnets and NSGs
5. Peer VNETs
6. Set DNS in AVD VNET → 10.0.0.4/10.0.0.5
7. Deploy Storage account
8. Enable **AADDS Kerberos**
9. Deploy AVD Host Pool + Session hosts
10. Install FSLogix
11. Assign AVD access to users

---

## 9. Architecture Decision Record (ADR Summary)

| Decision | Outcome |
|----------|---------|
| **Use Azure AD Domain Services** | Simplifies identity, enables Kerberos |
| **Use Azure Files for FSLogix** | No IaaS file server required |
| **Peered VNETs instead of hub-spoke** | Simplified lab design |
| **Kerberos auth instead of access keys** | Secure, aligns with production design |
| **AVD pooled model** | Lower cost, easier scaling |

---

## 10. Future Enhancements

- Replace AADDS with **Entra ID Domain Join + Azure Files Kerberos (Native)**  
- Move to **Hub-Spoke** with Azure Firewall  
- Add **Terraform/Bicep** deployments  
- Introduce monitoring via **Log Analytics + Diagnostics**  
- Implement DR by replicating FSLogix and host pool resources  

---

_End of Architecture Document_
