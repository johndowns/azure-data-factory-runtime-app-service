param name string

param location string

param vnetAddressPrefix string = '10.0.0.0/16'

param appOutboundSubnetAddressPrefix string = '10.0.0.0/24'

param dataFactorySubnetAddressPrefix string = '10.0.1.0/24'

param storageSubnetAddressPrefix string = '10.0.2.0/24'

param privateDnsZoneName string = 'privatelink.blob.${environment().suffixes.storage}'

var appOutboundSubnetName = 'app-outbound'
var dataFactorySubnetName = 'data-factory'
var storageSubnetName = 'storage'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: appOutboundSubnetName
        properties: {
          addressPrefix: appOutboundSubnetAddressPrefix
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
      {
        name: dataFactorySubnetName
        properties: {
          addressPrefix: dataFactorySubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }

  resource appOutboundSubnet 'subnets' existing = {
    name: appOutboundSubnetName
  }

  resource dataFactorySubnet 'subnets' existing = {
    name: dataFactorySubnetName
  }

  resource storageSubnet 'subnets' existing = {
    name: storageSubnetName
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneLinkToVNet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privateDnsZone
  name: 'link_to_${toLower(virtualNetwork.name)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

output privateDnsZoneResourceId string = privateDnsZone.id

output storageSubnetResourceId string = virtualNetwork::storageSubnet.id
