@description('private dns zone group name')
param name string
@description('array of { zoneName: string, zoneId: string }')
param zoneIds array

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = {
  name: name
  properties: {
    privateDnsZoneConfigs: [for item in zoneIds: {
      name: item.zoneName
      properties: {
        privateDnsZoneId: item.zoneId
      }
    }]
  }
}
