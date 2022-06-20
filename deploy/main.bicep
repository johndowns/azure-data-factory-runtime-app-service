param location string = resourceGroup().location

param containerRegistryName string

param containerRegistryUsername string

@secure()
param containerRegistryPassword string

param containerImageName string = 'adf/shir'

param containerImageTag string = 'v3'

param vnetName string = 'shirdemo'

param dataFactoryName string = 'shirdemo${uniqueString(resourceGroup().id)}'

param appName string = 'app-${uniqueString(resourceGroup().id)}'

param appServicePlanSku object = {
  name: 'P2v3'
  capacity: 1
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    name: vnetName
    location: location
  }
}

@description('The name of the SKU to use when creating the virtual machine.')
param vmSize string = 'Standard_DS1_v2'

@description('The type of disk and storage account to use for the virtual machine\'s OS disk.')
param vmOSDiskStorageAccountType string = 'StandardSSD_LRS'

@description('The administrator username to use for the virtual machine.')
param vmAdminUsername string = 'jdadmin'

@description('The administrator password to use for the virtual machine.')
@secure()
#disable-next-line secure-parameter-default // TODO
param vmAdminPassword string = 'Test123!!!!!'

var vmImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}

var containerStartCommand = 'powershell.exe -command "C:/SHIR/setup.ps1"'

module vm 'modules/vm.bicep' = {
  name: 'vm'
  params: {
    location: location
    subnetResourceId: vnet.outputs.vmSubnetResourceId
    vmSize: vmSize
    vmImageReference: vmImageReference
    vmOSDiskStorageAccountType: vmOSDiskStorageAccountType
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
  }
}

module adf 'modules/data-factory.bicep' = {
  name: 'adf'
  params: {
    dataFactoryName: dataFactoryName
    location: location
  }
}

module dataFactoryPipeline 'modules/data-factory-pipeline.bicep' = {
  name: 'adf-pipeline'
  params: {
    dataFactoryName: adf.outputs.dataFactoryName
    integrationRuntimeName: adf.outputs.integrationRuntimeName
    virtualMachinePrivateIPAddress: vm.outputs.virtualMachinePrivateIPAddress
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
    subnetResourceId: vnet.outputs.appOutboundSubnetResourceId
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: containerRegistryName
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    containerStartCommand: containerStartCommand
    dataFactoryName: adf.outputs.dataFactoryName
    dataFactoryIntegrationRuntimeName: adf.outputs.integrationRuntimeName
    appServicePlanSku: appServicePlanSku
  }
}

/*
module appAcrRoleAssignment 'modules/acr-role-assignment.bicep' = {
  name: 'app-acr-role-assignment'
  params: {
    containerRegistryName: acr.outputs.registryName
    principalId: app.outputs.appManagedIdentityPrincipalId
  }
}
*/
