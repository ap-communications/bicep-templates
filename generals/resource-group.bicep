// this file can only be deployed at a subscription scope
targetScope = 'subscription'

@description('Resource group name')
param name string
@description('resource location')
param location string
@description('tags for resource')
param tags object = {}


resource group 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: name
  location: location
  tags: tags
}

output id string = group.id
