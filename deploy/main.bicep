param location string = resourceGroup().location

param containerRegistryName string = 'shir${uniqueString(resourceGroup().id)}'

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
param vmAdminUsername string = 'shirdemoadmin'

@description('The administrator password to use for the virtual machine.')
@secure()
param vmAdminPassword string

var containerStartCommand = 'powershell.exe -command "C:/SHIR/setup.ps1"'

// Deploy the container registry and build the container image.
module acr 'modules/acr.bicep' = {
  name: 'acr'
  params: {
    name: containerRegistryName
    location: location
  }
}

// Deploy a virtual machine with a private web server.
var vmImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}

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

// Deploy the data factory.
module adf 'modules/data-factory.bicep' = {
  name: 'adf'
  params: {
    dataFactoryName: dataFactoryName
    location: location
  }
}

// Deploy a Data Factory pipeline to connect to the private web server on the VM.
module dataFactoryPipeline 'modules/data-factory-pipeline.bicep' = {
  name: 'adf-pipeline'
  params: {
    dataFactoryName: adf.outputs.dataFactoryName
    integrationRuntimeName: adf.outputs.integrationRuntimeName
    virtualMachinePrivateIPAddress: vm.outputs.virtualMachinePrivateIPAddress
  }
}

// Deploy Application Insights, which the App Service app uses.
module applicationInsights 'modules/application-insights.bicep' = {
  name: 'application-insights'
  params: {
    location: location
  }
}

// Deploy the App Service app resources and deploy the container image from the container registry.
module app 'modules/app.bicep' = {
  name: 'app'
  params: {
    location: location
    appName: appName
    subnetResourceId: vnet.outputs.appOutboundSubnetResourceId
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerRegistryName: acr.outputs.containerRegistryName
    containerImageName: acr.outputs.containerImageName
    containerImageTag: acr.outputs.containerImageTag
    containerStartCommand: containerStartCommand
    dataFactoryName: adf.outputs.dataFactoryName
    dataFactoryIntegrationRuntimeName: adf.outputs.integrationRuntimeName
    appServicePlanSku: appServicePlanSku
  }
}
