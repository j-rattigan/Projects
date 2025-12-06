azure-avd-homelab/
│
├── README.md                     <-- Main overview + diagrams + links
├── docs/
│   ├── 00-Architecture.md        <-- Diagrams (PNG + SVG), description
│   ├── 01-Networking.md          <-- VNETs, Peering, DNS, CLI cmds
│   ├── 02-AADDS.md               <-- Domain Services walkthrough
│   ├── 03-Storage-FSLogix.md     <-- Storage account + Kerberos setup
│   ├── 04-AVD-HostPool.md        <-- Host Pool + VMSS deployment
│   ├── 05-Image-Management.md    <-- SIG + versioning
│   ├── 06-FSLogix-Config.md      <-- Registry + GPO + testing
│   ├── 07-Operations.md          <-- Monitoring + scaling + logs
│   └── assets/
│        ├── avd-architecture.png
│        ├── avd-architecture.svg
│        ├── network-topology.png
│        └── fslogix-flow.png
│
└── scripts/
    ├── create-vnets.ps1
    ├── update-dns.sh
    ├── enable-kerberos.ps1
    └── deploy-hostpool.json     <-- ARM/Bicep (if you want)
