@description('private dns zone name')
param name string
@description('link name for vnet')
param linkName string = guid('${resourceGroup().location}-${resourceGroup().name}-link')

@description('virtual network id')
param vnId string
@description('enable auto registration for private dns')
param autoRegistration bool = false
@description('Tag information')
param tags object = {}

var location = 'global'

resource privateDns 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: location
}

resource vnLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${name}/${linkName}'
  location: location
  properties: {
    registrationEnabled: autoRegistration
    virtualNetwork: {
      id: vnId
    }
  }
  dependsOn: [
    privateDns
  ]
  tags: tags
}


output id string = privateDns.id
output name string = privateDns.name
