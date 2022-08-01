@description('storage account name')
param accountName string
@description('location for this resource')
param location string = resourceGroup().location

@description('type of storage account, default is StorageV2')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'StorageV2'
])
param kind string = 'StorageV2'

@description('type of sku for strage account, default is Standard_LRS')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'


@description('storage access tier the be required for BloStorage, default is Hot')
@allowed([
  'Cool'
  'Hot'
])
param accessTier string = 'Hot'
@description('allowed public access to all, default is true')
param allowBlobPublicAccess bool = true
@description('permits requests to be authorized with account access key, default is true')
param allowSharedKeyAccess bool = true
@description('resource tags')
param tags object = {}

var minimumTlsVersion = 'TLS1_2'
var actualAccountName = replace(accountName, '-', '')

resource sa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: actualAccountName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
  }
  tags: tags
}

output accountName string = actualAccountName
output endPoinds object = sa.properties.primaryEndpoints
