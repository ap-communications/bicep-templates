@description('private endpoint name')
param name string
@description('resource location')
param location string = resourceGroup().location

@description('subnet id for private endpoint')
param subnetId string
@description('connection target array of { serviceId: strng, groupIds: array of string }')
param linkServiceConnections array
@description('Tag information')
param tags object = {}

resource endpoint 'Microsoft.Network/privateEndpoints@2020-08-01' = {
  name: name
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [for item in linkServiceConnections: {
      name: name
      properties: {
        privateLinkServiceId: item.serviceId
        groupIds: item.groupIds
      }
    }]
  }
  tags: tags
}
