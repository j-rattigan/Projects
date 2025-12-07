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
