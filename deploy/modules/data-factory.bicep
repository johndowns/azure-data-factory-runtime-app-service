param dataFactoryName string

param virtualMachinePrivateIPAddress string

param location string

var integrationRuntimeName = 'self-hosted-runtime'
var pipelineName = 'sample-pipeline'

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

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'GetWebContent'
        type: 'WebActivity'
        typeProperties: {
          url: 'http://${virtualMachinePrivateIPAddress}/'
          connectVia: {
            referenceName: integrationRuntime.name
            type: 'IntegrationRuntimeReference'
          }
          method: 'GET'
          disableCertValidation: true
        }
      }
    ] 
  }
}

output dataFactoryName string = dataFactory.name

output integrationRuntimeName string = integrationRuntimeName
