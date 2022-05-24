@description('Location for resource')
param location string = resourceGroup().location

@description('Name for azure container apps environment')
param environmentName string
@description('Name for azure application insights')
param insightsName string
@description('Actual name of log analytics workspace')
param workspaceName string


resource insights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: insightsName
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: workspaceName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environmentName
  location: location
  properties: {
    daprAIInstrumentationKey: insights.properties.InstrumentationKey
    daprAIConnectionString: insights.properties.ConnectionString
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: workspace.properties.customerId
        sharedKey: workspace.listKeys().primarySharedKey
      }
    }
  }
}

output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
