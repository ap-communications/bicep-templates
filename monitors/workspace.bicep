@description('subscription id for workspace')
param subscriptionId string = subscription().subscriptionId
@description('Prefix string for Log analytics workspace name')
@minLength(2)
@maxLength(16)
param workspaceNamePrefix string
@description('Location for workspace')
param location string = resourceGroup().location
@description('sku for workspace')
param sku string = 'pergb2018'
@minValue(1)
@maxValue(730)
param retentionDays int = 7
// Tag information for Log analytics workspace
param tags object = {}

var workspaceName = '${workspaceNamePrefix}-${subscriptionId}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01'= {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionDays
  }
  tags: tags
}

output id string = workspace.id
output name string = workspace.name
