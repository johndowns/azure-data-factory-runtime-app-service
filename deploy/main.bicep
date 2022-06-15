param location string = resourceGroup().location

param acrRegistryName string = 'acr${uniqueString(resourceGroup().id)}'

param vnetName string = 'shirdemo'

param dataFactoryName string = 'shirdemo${uniqueString(resourceGroup().id)}'

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

module app 'modules/app.bicep' = {
  name: 'app'
  params: {
    location: location
    appName: appName
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: acr.outputs.registryName
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    dataFactoryName: adf.outputs.dataFactoryName
    dataFactoryIntegrationRuntimeName: adf.outputs.integrationRuntimeName
    appServicePlanSku: appServicePlanSku
  }
}

module appAcrRoleAssignment 'modules/acr-role-assignment.bicep' = {
  name: 'app-acr-role-assignment'
  params: {
    containerRegistryName: acr.outputs.registryName
    principalId: app.outputs.appManagedIdentityPrincipalId
  }
}
