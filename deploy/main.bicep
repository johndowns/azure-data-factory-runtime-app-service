param location string = resourceGroup().location

param acrRegistryName string = 'acr-${uniqueString(resourceGroup().id)}'

param vnetName string = 'shir-demo'

param dataFactoryName string = 'shir-demo'

param appName string = 'app-${uniqueString(resourceGroup().id)}'

param appServicePlanSku object = {
  name: 'P2v3'
  capacity: 1
}

param containerImageName string

param containerImageTag string

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

module adf 'modules/data-factory.bicep' = {
  name: 'adf'
  params: {
    dataFactoryName: dataFactoryName
    location: location
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: acr.outputs.registryName
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adf.outputs.dataFactoryName

  resource integrationRuntime 'integrationRuntimes' existing = {
    name: adf.outputs.integrationRuntimeName
  }
}

module app 'modules/app.bicep' = {
  name: 'app'
  params: {
    location: location
    appName: appName
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: acr.outputs.registryName
    dockerRegistryUrl: 'https://${acr.outputs.registryHostName}'
    dockerRegistryUsername: containerRegistry.listCredentials().username
    dockerRegistryPassword: containerRegistry.listCredentials().passwords[0].value
    containerImageName: containerImageName
    containerImageTag: containerImageTag
     dataFactoryIntegrationRuntimeAuthKey: dataFactory::integrationRuntime.listAuthKeys().authKey1
    appServicePlanSku: appServicePlanSku
  }
}
