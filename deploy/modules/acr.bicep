param name string = 'shir${uniqueString(resourceGroup().id)}'

param skuName string = 'Standard'

param location string  = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: true
  }
}

// Build the container image.
var containerImageName = 'adf/shir'
var containerImageTag = 'v3'
var dockerfileSourceGitRepository = 'https://github.com/johndowns/Azure-Data-Factory-Integration-Runtime-in-Windows-Container.git'
resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  parent: containerRegistry
  name: 'buildTask'
  properties: {
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: 'Dockerfile'
      sourceLocation: dockerfileSourceGitRepository
      imageNames: [
        '${containerImageName}:${containerImageTag}'
      ]
      platform: {
        os: 'Windows'
        architecture: 'x86'
      }
    }
  }
}

output containerRegistryName string = containerRegistry.name
output containerImageName string = containerImageName
output containerImageTag string = containerImageTag
