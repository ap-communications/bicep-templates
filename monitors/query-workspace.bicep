@description('subscription id for workspace')
param subscriptionId string = subscription().subscriptionId
@description('Prefix string for Log analytics workspace name')
@minLength(2)
@maxLength(16)
param workspaceNamePrefix string

var workspaceName = '${workspaceNamePrefix}-${subscriptionId}'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: workspaceName
}

output id string = workspace.id
output name string = workspace.name
