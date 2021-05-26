@description('Role id')
param roleId string

resource roleDef 'Microsoft.Authorization/roleDefinitions@2020-03-01-preview' existing = {
  scope: subscription()
  name: roleId
}

output id string = roleDef.id

