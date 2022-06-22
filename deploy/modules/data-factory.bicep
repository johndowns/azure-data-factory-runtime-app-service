@description('The name of the data factory to create. This must be globally unique.')
param dataFactoryName string

@description('The location into which the Azure resources should be deployed.')
param location string

@description('The resource ID of the subnet to use for the data factory\'s private endpoint.')
param dataFactorySubnetResourceId string

@description('The resource ID of the private DNS zone to use for the private endpoint.')
param privateDnsZoneResourceId string

var integrationRuntimeName = 'self-hosted-runtime'
var privateEndpointName = 'self-hosted-runtime-private-endpoint'
var privateEndpointNicName = 'self-hosted-runtime-private-endpoint-nic'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: dataFactory
  name: integrationRuntimeName
  properties: {
    type: 'SelfHosted'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: dataFactorySubnetResourceId
    }
    customNetworkInterfaceName: privateEndpointNicName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: dataFactory.id
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
  }

  resource privateDnsZoneGroup 'privateDnsZoneGroups' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-datafactory-azure-net'
          properties: {
            privateDnsZoneId: privateDnsZoneResourceId
          }
        }
      ]
    }
  }
}

output dataFactoryName string = dataFactory.name

output integrationRuntimeName string = integrationRuntimeName
