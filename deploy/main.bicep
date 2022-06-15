param location string = resourceGroup().location

param acrRegistryName string = 'acr-${uniqueString(resourceGroup().id)}'

param vnetName string = 'shir-demo'

module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: acrRegistryName
    location: location
  }
}

module vnet 'modules/acr.bicep' = {
  name: 'vnet'
  params: {
    name: vnetName
    location: location
  }
}
