@description('Name for postgreSQL')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('Administrator user name')
@secure()
param adminUser string
@description('Administrator user password')
@secure()
param adminPassword string
@description('allow public access')
param allowPublicAccess bool = false
@description('SKU tier')
@allowed([
  'Basic'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Basic'
@description('The family of hardware')
param skuFamily string = 'Gen5'
@description('The scale up/out capacity')
param skuCapacity int = skuTier == 'Basic' ? 2 : 4


@description('Virtual network name')
param virtualNetworkName string
@description('query subnet name')
param subnetName string

var skuNamePrefix = skuTier == 'GeneralPurpose' ? 'GP' : (skuTier == 'Basic' ? 'B' : 'OM')
var skuName = '${skuNamePrefix}_${skuFamily}_${skuCapacity}'

resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}


resource pgsql 'Microsoft.DBForPostgreSQL/servers@2017-12-01' = {
  name: name
  location: location
  sku: {
    name: skuName
    tier: skuTier
    family: skuFamily
    capacity: skuCapacity
  }
  properties: {
    createMode: 'Default'
    publicNetworkAccess: allowPublicAccess ? 'Enabled' : 'Disabled'
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
  }
}

var endpointName = '${name}-endpoint'

module endpoint 'private-endpoint.bicep' = {
  name: 'inner-deploy-${endpointName}'
  params: {
    name: endpointName
    subnetId: subnet.id
    linkServiceConnections: [
      {
        serviceId: pgsql.id
        groupIds: [
          'postgresqlServer'
        ]
      }
    ]
  }
}

var postgresDomainName = 'privatelink.postgres.database.azure.com'
module dns 'private-dns.bicep' = {
  name: 'inner-deploy-dns-${postgresDomainName}'
  params: {
    name: postgresDomainName
    vnId: vn.id
  }
}

module dnsGroup 'private-zone-group.bicep' = {
  name: 'inner-dns-group-${postgresDomainName}'
  params: {
    name: '${endpointName}/default'
    zoneIds: [
      {
        zoneName: postgresDomainName
        zoneId: dns.outputs.id
      }
    ]
  }
  dependsOn: [
    pgsql
    endpoint
  ]
}
