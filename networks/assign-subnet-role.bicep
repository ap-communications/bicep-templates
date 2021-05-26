@description('Virtual network name')
param virtualNetworkName string
@description('query subnet name')
param subnetName string
@description('target principal id')
param targetPrincipalId string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

// networking
var networkContributorRoleObjectId = '4d97b98b-1d4f-4787-a291-c67834d212e7'
module queryNetrowkContributorRole 'role-definition.bicep' = {
  name: 'query-${networkContributorRoleObjectId}'
  params: {
    roleId: networkContributorRoleObjectId
  }
}

resource assignNetworkContributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subnet.id, networkContributorRoleObjectId, targetPrincipalId)
  scope: subnet
  properties:{
    principalId: targetPrincipalId
    roleDefinitionId: queryNetrowkContributorRole.outputs.id
    description: '${virtualNetworkName}-${subnetName}-NetworkContributor'
  }
}
