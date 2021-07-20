@description('Name for application insights')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('kind of applications insights')
param kind string = 'web'
@description('Application type for insights')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'
@description('Log analytics workspace name prefix')
param workspaceNamePrefix string
@description('tags for resources')
param tags object = {}

module workspace 'query-workspace.bicep' = {
  name: 'query-${workspaceNamePrefix}-workspace'
  params: {
    workspaceNamePrefix: workspaceNamePrefix
  }
}

resource insights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: location
  kind: kind
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspace.outputs.id
  }
  tags: tags
}

output id string = insights.id
output instrumentationKey string = insights.properties.InstrumentationKey
