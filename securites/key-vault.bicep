@description('tenant id for key vault')
param tenantId string = subscription().tenantId
@description('Key vault name')
param name string
@description('resource location')
param location string = resourceGroup().location
@description('key vault sku')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'
@description('principal id for role assingment')
param rolePrincipalId string = ''
@description('access princal ids { id: string, admin: boolean }')
param principalIds array
@description('set true this is for production')
param production bool = false
@description('tags for resource')
param tags object = {}

var readerPermission = [
  'get'
  'list'
]
var adminPermission = [
  'all'
]


resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties:{
    tenantId: tenantId
    sku:{
      family: 'A'     // Fixed value 'A'
      name: sku
    }
    createMode: 'default'
    enableSoftDelete: production
    accessPolicies: [ for principal in principalIds: {
      tenantId: tenantId
      objectId: principal.id
      permissions: {
          secrets: principal.admin ? adminPermission : readerPermission 
          keys: principal.admin ? adminPermission : readerPermission
          certificates: principal.admin ? adminPermission : readerPermission
          storage: principal.admin ? adminPermission : readerPermission
      }
    }]
  }
  tags: tags
}

var readerRoleObjectId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
module readerRoleDef 'role-definition.bicep' = {
  name: readerRoleObjectId
  params: {
    roleId: readerRoleObjectId
  }
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(!empty(rolePrincipalId)) {
  name: guid('${name}-role-assign')
  scope: vault
  properties: {
    principalId: rolePrincipalId
    roleDefinitionId: readerRoleDef.outputs.id
  }
}
