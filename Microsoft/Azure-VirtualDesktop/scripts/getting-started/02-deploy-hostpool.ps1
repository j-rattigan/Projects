param(
    [string]$ResourceGroup = "RG-AVD-Lab",
    [string]$HostPoolName = "AVD-HostPool"
)

Write-Host "Creating AVD Host Pool (stub)..."

az desktopvirtualization hostpool create `
  --resource-group $ResourceGroup `
  --location australiaeast `
  --name $HostPoolName `
  --type "Pooled" `
  --load-balancer-type "DepthFirst" | Out-Null

Write-Host "Host Pool structure created. VMSS deployment to follow."
