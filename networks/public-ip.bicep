@description('name for public-ip')
param name string
@description('resource location for public-ip')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
])
@description('sku name of public ip')
param skuName string = 'Standard'
@allowed([
  'Regional'
  'Global'
])
@description('sku tier of public ip')
param skuTier string = 'Regional'
@allowed([
  'IPv4'
  'IPv6'
])
@description('IP versoin IPv4/IPv6')
param ipAddressVersion string = 'IPv4'
@description('set true if you want enable availability zone')
param enableZones bool = true
@description('description of availability zone')
param zones array = [
  '1'
  '2'
  '3'
]

resource ip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: ipAddressVersion
  }
  zones: enableZones ? zones : json('null')
}

output name string = ip.name
output ipAddr string = ip.properties.ipAddress
