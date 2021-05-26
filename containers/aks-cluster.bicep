@description('location for aks cluster')
param location string = resourceGroup().location
@description('execute cluster version')
param kubernetesVersion string
@description('AKS cluster name')
param clusterName string 
@description('The DNS prefix to use with hosted Kubernetes API server FQDN')
param dnsPrefix string = clusterName
@description('default agent pool name')
@minLength(1)
@maxLength(12)
param defaultAgentPoolName  string = 'defaultpool'
@description('availability zone array')
param availabilityZones array = []
@description('The mininum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(50)
param agentMinCount int = 1
@description('The maximum number of nodes for the cluster. 1 Node is enough for Dev/Test and minimum 3 nodes, is recommended for Production')
@minValue(1)
@maxValue(100)
param agentMaxCount int = agentMinCount
@description('VM size for agent node')
param agentVMSize string = 'Standard_B2s'
@description('Node disk size in GB')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0
@description('Node resource group name')
param nodeResourceGroup string = 'MC_${resourceGroup().name}'
@description('service princilal client id')
param servicePrincipalId string = ''
@description('service principal secret')
param servicePrincipalSecret string = ''
@description('Log analytics workspace id')
param workspaceId string = ''
@description('Virtual network name')
param virtualNetworkName string
@description('query subnet name')
param subnetName string
@description('tags for aks cluster')
param tags object = {}
@allowed([
  'azure'
  'calico'
])
@description('network plugin for network policy')
param networkPolicy string = 'azure'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

var servicePrincipalProfile = {
  clientId: servicePrincipalId
  secret: servicePrincipalSecret
}
var systemAssignedPrincipalProfile = {
  clientId: 'msi'
}

var actualAgentMinCount = agentMinCount < length(availabilityZones) ? length(availabilityZones) : agentMinCount
var actualAgentMaxCount = agentMaxCount < actualAgentMinCount ? actualAgentMinCount : agentMaxCount

// Azure kubernetes service
resource aks 'Microsoft.ContainerService/managedClusters@2020-12-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: defaultAgentPoolName
        count: actualAgentMinCount
        minCount: actualAgentMinCount
        maxCount: actualAgentMaxCount
        osDiskSizeGB: osDiskSizeGB
        mode: 'System'
        vmSize: agentVMSize
        type: 'VirtualMachineScaleSets'
        osType: 'Linux'
        enableAutoScaling: true
        availabilityZones: length(availabilityZones) == 0 ? json('null') : availabilityZones
        vnetSubnetID: empty(subnetName) ? json('null') : subnet.id
      }
    ]
    servicePrincipalProfile: length(servicePrincipalId) != 0 ? servicePrincipalProfile : systemAssignedPrincipalProfile
    nodeResourceGroup: nodeResourceGroup
    networkProfile: {
      networkPlugin: 'azure'  // use Azure CNI
      networkPolicy: networkPolicy // use Azure Network Policy
      loadBalancerSku: 'standard'
    }
    addonProfiles: {
      omsagent: empty(workspaceId) ? json('null') : {
        config: {
          logAnalyticsWorkspaceResourceID: workspaceId
        }
        enabled: true
      }
    }
  }
}

var principalIdForCluster = any(aks.properties.identityProfile.kubeletidentity).objectId

// networking role
module assignNetworkRole 'assign-subnet-role.bicep' = {
  name: 'assigning-network-contributor-role-to-${clusterName}'
  params: {
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    targetPrincipalId: principalIdForCluster
  }
}

// monitor metrics
var monitoringMetricsPublisherRoleObjectId = '3913510d-42f4-4e42-8a64-420c390055eb'
module queryMonitorRole 'role-definition.bicep' = {
  name: 'query-${monitoringMetricsPublisherRoleObjectId}'
  params: {
    roleId: monitoringMetricsPublisherRoleObjectId
  }
}

var monitoringMetricsPublisherRoleId = queryMonitorRole.outputs.id
resource assignMonitorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(clusterName, monitoringMetricsPublisherRoleObjectId)
  scope: aks
  properties:{
    principalId: principalIdForCluster
    roleDefinitionId: queryMonitorRole.outputs.id
    principalType: 'ServicePrincipal'
    description: '${clusterName}-MonitringMetricsPublisher'
  }
}

// EnsureClusterUserAssignedHasRbacToManageVMS
var vmContributerRoleObjectId = '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
module queryVmContributorRole 'role-definition.bicep' = {
  name: 'query-${vmContributerRoleObjectId}'
  params: {
    roleId: vmContributerRoleObjectId
  }
}

resource assignVmContributerRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(clusterName, vmContributerRoleObjectId)
  scope: aks
  properties:{
    principalId: principalIdForCluster
    roleDefinitionId: queryVmContributorRole.outputs.id
    principalType: 'ServicePrincipal'
    description: 'It is required to grant the AKS cluster with Virtual Machine Contributor role permissions over the cluster infrastructure resource group to work with Managed Identities and aad-pod-identity. Otherwise MIC component fails while attempting to update MSI on VMSS cluster nodes'
  }
}

output id string = aks.id
output name string = aks.name
output apiServerAddress string = aks.properties.fqdn
output principalId string = any(aks.properties.identityProfile.kubeletidentity).objectId
