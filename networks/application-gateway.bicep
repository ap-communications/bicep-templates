param location string = resourceGroup().location
param applicationGatewayName string
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param tier string = 'Standard_v2'
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param skuSize string = 'Standard_v2'
param capacity int = 2
param virtualNetworkName string
param subnetName string
@allowed([
  '1'
  '2'
  '3'
])
param zones array = []
param publicIpAddressName string
@description('sku name of public ip')
@allowed([
  'Standard'
  'Basic'
])
param sku string = 'Standard'
@allowed([
  'Static'
  'Dynamic'
])
param allocationMethod string = 'Static'
@allowed([
  '1'
  '2'
  '3'
])
param publicIpZones array = []
param tags object = {}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
}

resource pip 'Microsoft.Network/publicIPAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: sku
  }
  zones: publicIpZones
  properties: {
    publicIPAllocationMethod: allocationMethod
  }
  tags: tags
}

var this = resourceId('Microsoft.Network/applicationGateways',applicationGatewayName)

resource appgw 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: applicationGatewayName
  location: location
  tags: tags
  zones: zones
  properties: {
    sku: {
      name: skuSize
      tier: tier
      capacity: capacity
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'defaultaddresspool'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaulthttpsetting'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'fl-${uniqueString(resourceGroup().id)}'
        properties: {
          frontendIPConfiguration: {
            id: '${this}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${this}/frontendPorts/port_80'
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rr-${uniqueString(resourceGroup().id)}'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: '${this}/httpListeners/fl-${uniqueString(resourceGroup().id)}'
          }
          backendAddressPool: {
            id: '${this}/backendAddressPools/defaultaddresspool'
          }
          backendHttpSettings: {
            id: '${this}/backendHttpSettingsCollection/defaulthttpsetting'
          }
        }
      }
    ]
    enableHttp2: true
    sslCertificates: []
    probes: []
  }
}
