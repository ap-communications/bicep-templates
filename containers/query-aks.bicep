@description('query aks cluster name')
param name string

resource cluster 'Microsoft.ContainerService/managedClusters@2020-12-01' existing = {
  name: name
}

var servicePrincipalProfileClientId = cluster.properties.servicePrincipalProfile.clientId
output id string = cluster.id
output principalId string = servicePrincipalProfileClientId == 'msi' ? any(cluster.properties.identityProfile.kubeletidentity).objectId : servicePrincipalProfileClientId
output nodeResourceGroup string = cluster.properties.nodeResourceGroup
