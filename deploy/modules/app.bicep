param appServicePlanName string = 'shir-plan'

param location string

param appName string

param subnetResourceId string

param appServicePlanSku object

param applicationInsightsInstrumentationKey string

param applicationInsightsConnectionString string

param containerRegistryName string

param containerRegistryUsername string

@secure()
param containerRegistryPassword string

param containerImageName string

param containerImageTag string

param containerStartCommand string

param dataFactoryName string

param dataFactoryIntegrationRuntimeName string

param dataFactoryIntegrationRuntimeNodeName string = 'AppServiceContainer'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

var containerRegistryHostName = '${containerRegistryName}.azurecr.io'
var appWindowsFxVersion = 'DOCKER|${containerRegistryHostName}/${containerImageName}:${containerImageTag}'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource integrationRuntime 'integrationRuntimes' existing = {
    name: dataFactoryIntegrationRuntimeName
  }
}

var dataFactoryAuthKey = dataFactory::integrationRuntime.listAuthKeys().authKey1

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: appServicePlanSku
  properties: {
    hyperV: true
  }
}

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    //virtualNetworkSubnetId: subnetResourceId
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
          value: 'https://${containerRegistryHostName}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistryPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'AUTH_KEY'
          value: dataFactoryAuthKey
        }
        {
          name: 'NODE_NAME'
          value: dataFactoryIntegrationRuntimeNodeName
        }
        {
          name: 'CONTAINER_AVAILABILITY_CHECK_MODE'
          value: 'Off'
        }
        {
          name: 'WEBSITES_CONTAINER_STOP_TIME_LIMIT'
          value: '00:02:00'
        }
      ]
      windowsFxVersion: appWindowsFxVersion
      appCommandLine: containerStartCommand
      alwaysOn: true
      ftpsState: 'Disabled'
    }
  }
}

output appManagedIdentityPrincipalId string = app.identity.principalId
