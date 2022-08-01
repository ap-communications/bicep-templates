@description('name for azure functions')
param functionAppName string
@description('resource location')
param location string = resourceGroup().location

@description('Runtime language')
@allowed([
  'DotNet6'
  'Node16'
])
param language string

@description('storage account name using this functions')
param storageAccountName string
@description('name of hosting plan')
param hostingPlanName string
@description('Application insights name')
param appInsightsName string

var defaultAppConfig = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(functionAppName)
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsights.properties.InstrumentationKey
  }
]

var workerRuntimeVersion = {
  DotNet6: {
    additionalConfig: [
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet'
      }
    ]
    fxVersion: 'DOTNET|6.0'
  }
  Node16: {
    additionalConfig: [
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'node'
      }
      {
        name: 'WEBSITE_NODE_DEFAULT_VERSION'
        value: '~16'
      }
    ]
    fxVersion: 'Node|16'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' existing = {
  name: hostingPlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: union(defaultAppConfig, workerRuntimeVersion[language].additionalConfig)
      netFrameworkVersion: hostingPlan.kind != 'linux' ? 'v6.0' : json('null')
      linuxFxVersion: hostingPlan.kind == 'linux' ? workerRuntimeVersion[language].fxVersion : json('null')
      windowsFxVersion: hostingPlan.kind != 'linux' ? workerRuntimeVersion[language].fxVersion : json('null')
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
