# 🧱 Azure Virtual Desktop Home Lab – Foundation Build

This document describes the exact steps used to deploy a fully functional Azure Virtual Desktop (AVD) home lab using:

- **Microsoft Entra Domain Services (AADDS)**
- **Azure Files (FSLogix Profile Container)**
- **Azure Virtual Desktop (Host Pool + VMSS)**
- **Azure Virtual Networks (Peered)**
- **Kerberos Authentication**

This architecture mirrors a real enterprise AVD deployment and provides a solid foundation for Week 1–4 AVD SME study.

---

# 🗺️ Architecture Overview

```
Azure Subscription
└─ RG-AVD-Lab
   ├─ Microsoft Entra Domain Services (jasonlab.com)
   │   └─ aadds-vnet (10.0.0.0/24)
   │       └─ AADDS-Subnet (Domain Controllers)
   │
   ├─ VNET-AVD-Lab (10.1.0.0/16)
   │   ├─ AVD-Hosts      (10.1.1.0/24)
   │   └─ Management     (10.1.2.0/24)
   │
   ├─ Peering (bi-directional)
   │   aadds-vnet ⇄ VNET-AVD-Lab
   │
   ├─ Storage Account (FSLogix Profiles)
   │   ├─ File Share: fslogix
   │   └─ Identity-based access (Kerberos)
   │
   └─ Azure Cloud Shell / CLI configuration
```

---

# ✔️ Completed Steps (with commands + portal notes)

---

## 1. Create Resource Group

```
RG-AVD-Lab
Region: Australia East
```

Created in the Azure Portal.

---

## 2. Deploy Microsoft Entra Domain Services (AADDS)

**Parameters:**

- Domain name: `jasonlab.com`
- SKU: Standard
- Region: Australia East
- Virtual Network: **aadds-vnet**
- Subnet: **AADDS-Subnet**

Azure auto-created the `aadds-vnet` VNet:

```
Name: aadds-vnet
Address space: 10.0.0.0/24
Subnet: 10.0.0.0/24 (AADDS-Subnet)
```

---

## 3. Create the AVD Virtual Network

**Virtual Network: `VNET-AVD-Lab`**

```
Address space: 10.1.0.0/16
Subnets:
  - AVD-Hosts      10.1.1.0/24
  - Management     10.1.2.0/24
```

---

## 4. Fix Address Space Overlap

The original plan overlapped `10.0.0.0/24` and `10.0.0.0/16`, which blocks peering.

Solution:  
Redesigned AVD VNet to use `10.1.0.0/16`.

---

## 5. Peer the VNets (bi-directional)

### From **VNET-AVD-Lab → Peerings → Add**

```
Peering name: AVD-to-AADDS
Remote VNet: aadds-vnet
Allow VNet access: Enabled
Allow forwarded traffic: Enabled
Gateway options: Disabled
```

### From **aadds-vnet → Peerings → Add**

```
Peering name: AADDS-to-AVD
Remote VNet: VNET-AVD-Lab
Allow VNet access: Enabled
Allow forwarded traffic: Enabled
Gateway options: Disabled
```

Both peerings show:

```
State: Connected
```

---

## 6. Configure DNS for AVD VNet (Critical)

Azure Portal “Network Foundation Preview” UI hid DNS settings, so configured via CLI:

### Azure CLI – Configure DNS Servers

```bash
az network vnet update   --resource-group RG-AVD-Lab   --name VNET-AVD-Lab   --dns-servers 10.0.0.4 10.0.0.5
```

### Validate DNS Settings

```pwsh
(Get-AzVirtualNetwork -Name "VNET-AVD-Lab" -ResourceGroupName "RG-AVD-Lab").DhcpOptions
```

Expected output:

```
DnsServers: {10.0.0.4, 10.0.0.5}
```

---

## 7. Storage Account Preparation (FSLogix Profiles)

A new storage account was created after replacing a misconfigured one:

- Kind: StorageV2  
- Region: Australia East  
- Public network access: Enabled  
- Large file shares: Enabled  
- Default Entra authorization: Enabled  

---

## 8. Azure Files → FSLogix Share

Created file share:

```
fslogix
Tier: Transaction Optimized
```

Identity-based access will be configured after Kerberos setup completes.

---

## 9. Foundation Validation Checklist

| Component | Status |
|----------|--------|
| AADDS Deployed | ✅ |
| AADDS VNet | ✅ |
| AVD VNet | ✅ |
| No overlapping spaces | ✅ |
| VNet Peering | ✅ |
| DNS to AADDS | ✅ |
| Storage Account correct | ✅ |
| FSLogix Share created | ✅ |
| Ready for Kerberos | ✅ |

---

# 📚 Recommended Git Commit Message

```
Initial AVD Lab Foundation:
- Added AADDS domain (jasonlab.com)
- Created VNET-AVD-Lab + subnets
- Implemented VNET peering
- Configured VNET DNS to AADDS
- Deployed FSLogix-compatible storage account
- Documented full setup procedure
```

---

# 🚀 Next Steps

Choose your next module:

### A) Deploy AVD Host Pool + VMSS  
### B) Enable Kerberos + FSLogix  
### C) Build Golden Image (SIG)  
### D) Autoscale + Monitoring

