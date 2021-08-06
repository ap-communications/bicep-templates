@description('name for secret')
param secretName string
@description('value for secret')
param secretValue string
@description('key vault name for this secret')
param keyvaultName string

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${keyvaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}
