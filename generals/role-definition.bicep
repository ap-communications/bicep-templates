@description('Role id')
param roleId string

resource roleDef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: roleId
}

output id string = roleDef.id

