# Azure Virtual Desktop – Architecture Overview

## 🏗️ High-Level Architecture

```mermaid
flowchart LR
    subgraph AVD["Azure Virtual Desktop"]
        HP["Host Pools"]
        WS["Session Hosts"]
        FS["FSLogix Profiles"]
    end

    subgraph NET["Networking"]
        VNET["AVD VNET"]
        SUB1["AVD-Hosts Subnet"]
        SUB2["Management Subnet"]
    end

    subgraph ID["Identity"]
        AAD["Microsoft Entra ID"]
        AADDS["Entra Domain Services"]
        KRB["AAD Kerberos"]
    end

    subgraph STG["Storage"]
        SA["Storage Account"]
        FILES["Azure Files (Premium)"]
    end

    AVD --> NET
    WS --> FILES
    FILES --> AADDS
    AAD --> KRB
    VNET --> AADDS
```

---

## 📌 Architecture Components Table

| Component | Purpose | Notes |
|----------|---------|-------|
| **Host Pool** | Logical grouping of session hosts | Used by RemoteApp & Desktop |
| **Session Hosts** | VMs running Windows 11 multisession | Joined to AADDS |
| **FSLogix** | User profile container | Stored on Azure Files |
| **Azure Files Premium** | Profile storage | Requires AD-based auth |
| **AADDS** | Domain service required for Kerberos | Provides LDAP/Kerberos |
| **AVD VNET** | Networking backbone | Peered with AADDS VNET |
| **Kerberos for Azure Files** | Auth without domain join | Requires hybrid identity |

---

## 🧩 Logical Layout

```mermaid
graph TD
    AAD["Microsoft Entra ID"]
    HYB["Hybrid Identity (Synced Users)"]
    AADDS["Entra Domain Services"]
    SA["Storage Account"]
    FILES["Azure Files (FSLogix)"]
    HP["Host Pool"]
    SH1["Session Host 1"]
    SH2["Session Host 2"]
    VNET["AVD Virtual Network"]
    SUB1["AVD Hosts Subnet"]
    SUB2["Management Subnet"]

    AAD --> HYB --> AADDS
    AADDS --> FILES
    FILES --> SH1
    FILES --> SH2
    HP --> SH1
    HP --> SH2
    VNET --> SUB1
    VNET --> SUB2
```

---

## 🌐 Networking Diagram (VNET Peering + DNS)

```mermaid
flowchart LR
    AVDVNET["AVD VNET<br>10.1.0.0/16"]
    AADDVNET["AADDS VNET<br>10.0.0.0/24"]
    DNS1["DNS IP: 10.0.0.4"]
    DNS2["DNS IP: 10.0.0.5"]

    AVDVNET <--> AADDVNET
    AVDVNET --> DNS1
    AVDVNET --> DNS2
```

---

## 🔐 Identity Flow (Kerberos for Azure Files)

```mermaid
sequenceDiagram
    participant User
    participant AVD as AVD Session Host
    participant AAD as Entra ID
    participant AADDS as Domain Services
    participant FILES as Azure Files

    User->>AAD: Authenticate
    AAD->>AVD: Provide token
    AVD->>AADDS: Kerberos ticket request
    AADDS->>AVD: Kerberos TGT
    AVD->>FILES: Access with Kerberos
    FILES->>AVD: FSLogix Profile Loaded
```

---

## 🏷️ Technology Badges

![Azure](https://img.shields.io/badge/Azure-0089D6?logo=microsoftazure&logoColor=white)
![AVD](https://img.shields.io/badge/Azure%20Virtual%20Desktop-Blue?logo=microsoft)
![FSLogix](https://img.shields.io/badge/FSLogix-Orange)
![EntraID](https://img.shields.io/badge/Entra%20ID-2560E0?logo=microsoft)
![Kerberos](https://img.shields.io/badge/Kerberos-5E2750)

---

## 🧱 Detailed Architecture Breakdown

### 1. **Identity**
- Microsoft Entra ID (Primary authentication)
- AADDS for Kerberos (required for Azure Files auth)
- Hybrid identities synced via Cloud Sync

### 2. **Compute**
- Windows 11 multisession hosts
- Autoscale recommended (Scaling Plan)
- Registered into the Host Pool automatically via ARM/Bicep/CLI

### 3. **Storage**
- Azure Files Premium (LRS or ZRS)
- FSLogix Profile Container
- Kerberos enabled

### 4. **Networking**
- Dedicated VNET (10.1.0.0/16)
- Subnets:
  - AVD-Hosts
  - Management
- VNET Peering:
  - AVD-VNET ↔ AADDS-VNET
- DNS:
  - Custom DNS pointing to AADDS IPs
  - Conditional forwarding automatically handled by AADDS

---

## 📄 Appendix – Resource Naming

| Resource | Example Name |
|---------|---------------|
| Host Pool | `avd-hp-prod` |
| Resource Group | `RG-AVD-Lab` |
| Storage Account | `stavdprofilesnnn` |
| VNET | `VNET-AVD-Lab` |
| Subnets | `AVD-Hosts`, `Management` |

---

## ✔️ Summary

This architecture provides:

- Secure hybrid identity with Kerberos
- Fast profile load times using Azure Files Premium
- Scalable and modular VNET design
- Clear separation of compute, identity, storage, and network

Perfect for **production-grade AVD**, **lab environments**, or **enterprise landing zones**.
