@description('tenant id for key vault')
param tenantId string = subscription().tenantId
@description('key vault name')
param name string
@description('access principal ids { id: string, admin: boolean }')
param principalIds array

var readerPermission = [
  'get'
  'list'
]
var adminPermission = [
  'all'
]

resource ap 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: '${name}/replace'
  properties: {
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
}

