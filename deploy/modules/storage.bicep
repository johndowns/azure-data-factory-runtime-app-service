param name string

param location string

param storageAccountSku object

param privateEndpointName string = 'storage-private-endpoint'

param privateEndpointSubnetResourceId string

param privateDnsZoneResourceId string

var blobStorageAccountPrivateEndpointGroupName = 'blob'
var blobPrivateDnsZoneGroupName = 'blobPrivateDnsZoneGroup'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  sku: storageAccountSku
  kind: 'StorageV2'
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            blobStorageAccountPrivateEndpointGroupName
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointSubnetResourceId
    }
    customDnsConfigs: [
      {
        fqdn: '${storageAccount.name}.blob.${environment().suffixes.storage}'
      }
    ]
  }
}

resource blobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-03-01' = {
  parent: privateEndpoint
  name: blobPrivateDnsZoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZoneResourceId
        }
      }
    ]
  }
}
