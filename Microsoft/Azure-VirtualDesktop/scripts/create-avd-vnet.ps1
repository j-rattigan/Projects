param(
    [string]$ResourceGroupName = "RG-AVD-Lab",
    [string]$Location = "australiaeast"
)

# Creates the AVD VNet and subnets used in the lab.

$vnetName = "VNET-AVD-Lab"

Write-Host "Creating VNet '$vnetName' in '$ResourceGroupName'..."

az network vnet create `
  --resource-group $ResourceGroupName `
  --name $vnetName `
  --address-prefixes 10.1.0.0/16 `
  --location $Location `
  --subnet-name AVD-Hosts `
  --subnet-prefix 10.1.1.0/24 | Out-Null

az network vnet subnet create `
  --resource-group $ResourceGroupName `
  --vnet-name $vnetName `
  --name Management `
  --address-prefixes 10.1.2.0/24 | Out-Null

Write-Host "Done. VNet '$vnetName' created with AVD-Hosts and Management subnets."
