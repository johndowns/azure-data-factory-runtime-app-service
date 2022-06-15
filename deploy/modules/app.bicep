param appServicePlanName string = 'shir-plan'

param location string

param appName string

param appServicePlanSku object

param applicationInsightsInstrumentationKey string

param applicationInsightsConnectionString string

param dockerRegistryUrl string

param dockerRegistryUsername string

@secure()
param dockerRegistryPassword string

param containerRegistryName string

param containerImageName string

param containerImageTag string

@secure()
param dataFactoryIntegrationRuntimeAuthKey string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServicePlanSku
}

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  properties: {
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
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'AUTH_KEY'
          value: dataFactoryIntegrationRuntimeAuthKey
        }
      ]
      vnetRouteAllEnabled: true
      windowsFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerImageName}:${containerImageTag}' // TODO assemble this properly
      appCommandLine: ''
      alwaysOn: true
      ftpsState: 'Disabled'
    }
  }
}
