@description('AKS cluster name')
param clusterName string 
@description('name for flux control plane')
param fluxName string = 'flux'
@description('namespace for flux control plane')
param fluxNamespace string = 'flux-system'
@description('auto upgrade minor version for flux')
param autoUpgradeMinorVersion bool =  true

resource aks 'Microsoft.ContainerService/managedClusters@2022-04-01' existing = {
  name: clusterName
}

resource flux 'Microsoft.KubernetesConfiguration/extensions@2022-04-02-preview' = {
  name: fluxName
  scope: aks
  properties: {
    extensionType: 'microsoft.flux'
    scope: {
      cluster: {
        releaseNamespace: fluxNamespace
      }
    }
    autoUpgradeMinorVersion: autoUpgradeMinorVersion
  }
}
