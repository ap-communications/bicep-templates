@description('storage account name')
param accountName string
@description('storage container name')
param containerName string
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('sku name of this storage account, like Standard_LRS')
param skuName string
@description('resource location')
param location string = resourceGroup().location
@allowed([
  'Hot'
  'Cool'
])
@description('access tier of storage account')
param accessTier string = 'Hot'
@description('allow public access of blob')
param allowBlobPublicAccess bool = false
@description('allow shared key access')
param allowSharedKeyAccess bool = true
@description('versioning enabled')
param isVersioningEnabled bool = true

@description('resource tags')
param tags object = {}

var actualAccountName = replace(accountName, '-', '')

module storageAccount './storage-account.bicep' = {
  name: 'deploy-storage-account-${actualAccountName}'
  params: {
    accountName: actualAccountName
    location: location
    kind: 'StorageV2'
    skuName: skuName
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    tags: tags
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  name: '${actualAccountName}/default'
  properties: {
    isVersioningEnabled: isVersioningEnabled
  }
  dependsOn:[
    storageAccount
  ]
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${actualAccountName}/default/${containerName}'
  dependsOn:[
    blobService
  ]
}

output accountName string = storageAccount.outputs.accountName
output blobEndpoint string = storageAccount.outputs.endPoinds.blob
output containerName string = containerName
