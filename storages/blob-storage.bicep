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
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'
@description('allow public access of blob')
param allowBlobPublicAccess bool = false
@description('allow shared key access')
param allowSharedKeyAccess bool = true
@description('versioning enabled')
param isVersioningEnabled bool = true

@description('resource tags')
param tags object = {}

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
  }
  tags: tags
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  name: '${accountName}/default'
  properties: {
    isVersioningEnabled: isVersioningEnabled
  }
  dependsOn:[
    sa
  ]
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: '${accountName}/default/${containerName}'
  dependsOn:[
    blobService
  ]
}

output blobEndpoint string = sa.properties.primaryEndpoints.blob
output containerName string = containerName
