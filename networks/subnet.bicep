@description('Name of the VNET to add a subnet to')
param vnetName string

@description('Name of the subnet to add')
param subnetName string

@description('Address space of the subnet to add')
param subnetPrefix string

@description('private endpoint network policies of new subnet')
param endpointPolicy string = 'Enabled'

@description('private link service network policies of new subnet')
param servicePolicy string = 'Enabled'

resource sn 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vnetName}/${subnetName}'
  properties: {
    addressPrefix: subnetPrefix
    privateEndpointNetworkPolicies: endpointPolicy
    privateLinkServiceNetworkPolicies: servicePolicy
  }
}
