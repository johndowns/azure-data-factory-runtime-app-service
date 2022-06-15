param name string

param location string

param skuName string = 'Basic'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true // TODO check if this can be disabled
  }
}
