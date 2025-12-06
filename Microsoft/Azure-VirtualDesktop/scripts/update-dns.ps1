param(
    [string]$ResourceGroupName = "RG-AVD-Lab",
    [string]$VNetName = "VNET-AVD-Lab",
    [string[]]$DnsServers = @("10.0.0.4","10.0.0.5")
)

# Updates DNS servers on the AVD VNet to point at AADDS domain controllers.

Write-Host "Updating DNS servers on VNet '$VNetName' to: $($DnsServers -join ', ')"

az network vnet update `
  --resource-group $ResourceGroupName `
  --name $VNetName `
  --dns-servers $DnsServers | Out-Null

Write-Host "Done."
