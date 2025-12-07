### *(Cloud-native FSLogix storage design)*

```md
# 03a – FSLogix Storage Architecture (Azure Files)

## 🚀 Overview
Azure Files is the Microsoft-recommended storage backend for enterprise FSLogix deployments.  
It provides resilient SMB file shares with cloud-native identity and autoscaling performance.

---

# 🏗 Architecture Components

### ✔ Storage Account  
- Name: `stavdprofilesnn1`  
- Type: `StorageV2`  
- Tier: **Premium File Shares** for best performance  
- Kerberos auth enabled  
- Virtual network integrated (optional private endpoint)

### ✔ File Share Structure
/fslogix
/profiles
/office


### ✔ Authentication
You configured **Microsoft Entra Kerberos** — meaning:  
- No AD DS needed  
- No line-of-sight to domain controllers  
- Passwordless profile access  

---

# ⚙ FSLogix Configuration (Azure Files)

### Example `fslogix.ini`

```ini
[Profile]
Enabled=1
VHDLocations=\\stavdprofilesnn1.file.core.windows.net\fslogix\profiles
VolumeType=VHDX
SizeinMBs=30000
IsDynamic=1

### Session Host GPO/Registry
[HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles]
"Enabled"=dword:00000001
"VHDLocations"="\\stavdprofilesnn1.file.core.windows.net\\fslogix\\profiles"
"PreventLoginWithFailure"=dword:00000001
"DeleteLocalProfileWhenVHDShouldApply"=dword:00000001

📈 Performance Considerations
Factor	Recommendation
IOPS	Premium tier (guaranteed baseline)
Protocol	SMB 3.1.1 with AES encryption
Latency	< 7 ms recommended
Scaling	Meets most AVD environments

🔐 Backup & DR
Azure File Share Snapshots
Azure Backup integration
Cross-region redundancy (if not premium)

📦 Summary

Azure Files = best general-purpose solution for AVD.
It eliminates infrastructure, simplifies identity, and supports large-scale growth.

Return to the parent: 03 – Storage Architecture
