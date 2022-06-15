param appServicePlanName string = 'shir-plan'

param location string

param appName string

param appServicePlanSku object

param applicationInsightsInstrumentationKey string

param applicationInsightsConnectionString string

param containerRegistryName string

param containerImageName string

param containerImageTag string

param dataFactoryName string

param dataFactoryIntegrationRuntimeName string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource integrationRuntime 'integrationRuntimes' existing = {
    name: dataFactoryIntegrationRuntimeName
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServicePlanSku
}

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Java'
          value: '1'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryName}.azurecr.io' // TODO
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'AUTH_KEY'
          value: dataFactory::integrationRuntime.listAuthKeys().authKey1
        }
      ]
      acrUseManagedIdentityCreds: true
      vnetRouteAllEnabled: true
      windowsFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerImageName}:${containerImageTag}' // TODO assemble this properly
      appCommandLine: ''
      alwaysOn: true
      ftpsState: 'Disabled'
    }
  }
}

output appManagedIdentityPrincipalId string = app.identity.principalId
