param(
    [string]$ResourceGroupName = "RG-AVD-Lab",
    [string]$Location = "australiaeast",
    [string]$StorageAccountName,
    [string]$ShareName = "fslogix"
)

if (-not $StorageAccountName) {
    throw "Please provide -StorageAccountName (must be globally unique)."
}

Write-Host "Creating StorageV2 account '$StorageAccountName' in '$ResourceGroupName'..."

az storage account create `
  --name $StorageAccountName `
  --resource-group $ResourceGroupName `
  --location $Location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --enable-large-file-share true | Out-Null

$saKey = az storage account keys list `
  --account-name $StorageAccountName `
  --resource-group $ResourceGroupName `
  --query "[0].value" -o tsv

Write-Host "Creating Azure Files share '$ShareName'..."

az storage share-rm create `
  --resource-group $ResourceGroupName `
  --storage-account $StorageAccountName `
  --name $ShareName `
  --quota 100 | Out-Null

Write-Host "Storage account and FSLogix share created."
