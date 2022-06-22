@description('The name of the data factory to create. This must be globally unique.')
param dataFactoryName string

@description('The location into which the Azure resources should be deployed.')
param location string

var integrationRuntimeName = 'self-hosted-runtime'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: dataFactory
  name: integrationRuntimeName
  properties: {
    type: 'SelfHosted'
  }
}

output dataFactoryName string = dataFactory.name

output integrationRuntimeName string = integrationRuntimeName
