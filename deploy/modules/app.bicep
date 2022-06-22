param appServicePlanName string = 'shir-plan'

param location string

param appName string

param subnetResourceId string

param appServicePlanSku object

param applicationInsightsInstrumentationKey string

param applicationInsightsConnectionString string

param containerRegistryName string

param containerImageName string

param containerImageTag string

param containerStartCommand string

param dataFactoryName string

param dataFactoryIntegrationRuntimeName string

param dataFactoryIntegrationRuntimeNodeName string = 'AppServiceContainer'

var managedIdentityName = 'SampleApp'

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

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

module appAcrRoleAssignment 'acr-role-assignment.bicep' = {
  name: 'app-acr-role-assignment'
  params: {
    containerRegistryName: containerRegistryName
    principalId: managedIdentity.properties.principalId
  }
}

resource app 'Microsoft.Web/sites@2021-03-01' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: subnetResourceId
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
          value: containerRegistry.listCredentials().username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
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
      ]
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentity.properties.clientId
      windowsFxVersion: appWindowsFxVersion
      appCommandLine: containerStartCommand
      alwaysOn: true
      ftpsState: 'Disabled'
    }
  }
  dependsOn: [
    appAcrRoleAssignment // Wait for the role assignment so the app can pull from the container registry.
  ]
}
