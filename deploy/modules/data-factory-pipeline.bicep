param dataFactoryName string

param virtualMachinePrivateIPAddress string

param integrationRuntimeName string

var pipelineName = 'sample-pipeline'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName

  resource integrationRuntime 'integrationRuntimes' existing = {
    name: integrationRuntimeName
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
            referenceName: dataFactory::integrationRuntime.name
            type: 'IntegrationRuntimeReference'
          }
          method: 'GET'
          disableCertValidation: true
        }
      }
    ] 
  }
}
