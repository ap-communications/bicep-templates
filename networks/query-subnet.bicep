@description('Virtual network name')
param virtualNetworkName string
@description('query subnet name')
param subnetName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

output id string = subnet.id
output name string = subnet.name
