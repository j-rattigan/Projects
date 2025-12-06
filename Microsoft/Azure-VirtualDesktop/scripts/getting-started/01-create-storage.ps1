param(
    [string]$ResourceGroup = "RG-AVD-Lab",
    [string]$Location = "australiaeast",
    [string]$StorageAccountName,
    [string]$ShareName = "fslogix"
)

if (-not $StorageAccountName) {
    throw "You must provide -StorageAccountName"
}

Write-Host "Creating StorageV2 account..."
az storage account create `
    --name $StorageAccountName `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --enable-large-file-share true | Out-Null

Write-Host "Creating File Share..."
az storage share-rm create `
    --resource-group $ResourceGroup `
    --storage-account $StorageAccountName `
    --name $ShareName `
    --quota 100 | Out-Null

Write-Host "FSLogix storage ready."
