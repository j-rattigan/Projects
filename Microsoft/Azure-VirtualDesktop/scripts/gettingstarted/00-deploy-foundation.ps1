param(
    [string]$Location = "australiaeast",
    [string]$ResourceGroup = "RG-AVD-Lab"
)

Write-Host "Creating Resource Group..."
az group create -l $Location -n $ResourceGroup | Out-Null

Write-Host "Creating AVD VNet..."
az network vnet create `
  --resource-group $ResourceGroup `
  --name VNET-AVD-Lab `
  --address-prefix 10.1.0.0/16 `
  --subnet-name AVD-Hosts `
  --subnet-prefix 10.1.1.0/24 | Out-Null

az network vnet subnet create `
  --resource-group $ResourceGroup `
  --vnet-name VNET-AVD-Lab `
  --name Management `
  --address-prefixes 10.1.2.0/24 | Out-Null

Write-Host "Updating DNS servers for AADDS..."
az network vnet update `
  --resource-group $ResourceGroup `
  --name VNET-AVD-Lab `
  --dns-servers 10.0.0.4 10.0.0.5 | Out-Null

Write-Host "FOUNDATION DEPLOYED."
