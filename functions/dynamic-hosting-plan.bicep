@description('Name for plan')
param name string
@description('resource location')
param location string = resourceGroup().location

@allowed([
  'Windows'
  'Linux'
])
param platformType string = 'Linux'

@description('tags for this resource')
param tags object = {}

var skuTier = 'Dynamic'
var skuCode = 'Y1'
var kind = platformType == 'Linux' ? 'linux' : ''

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  kind: kind
  sku: {  // for Dynamic hosting
    tier: skuTier
    name: skuCode
  }
  properties: {
    reserved: platformType == 'Linux' ? true : false
  }
  tags: tags
}

output planName string = hostingPlan.name
