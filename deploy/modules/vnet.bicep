param name string

param location string

param vnetAddressPrefix string = '10.0.0.0/16'

param appOutboundSubnetAddressPrefix string = '10.0.0.0/24'

param dataFactorySubnetAddressPrefix string = '10.0.1.0/24'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
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
        name: 'app-outbound'
        properties: {
          addressPrefix: appOutboundSubnetAddressPrefix
        }
      }
      {
        name: 'data-factory'
        properties: {
          addressPrefix: dataFactorySubnetAddressPrefix
        }
      }
    ]
  }
}
