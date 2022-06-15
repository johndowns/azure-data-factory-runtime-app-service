param name string = 'shir-app-insights'

param location string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output instrumentationKey string = applicationInsights.properties.InstrumentationKey

output connectionString string = applicationInsights.properties.ConnectionString
