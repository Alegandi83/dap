param project string
param env string
param location string = resourceGroup().location
param deployment_id string


resource streamAnalyticsJob 'Microsoft.StreamAnalytics/streamingjobs@2020-03-01' = {
  name: '${project}-asa-${env}-${deployment_id}'
  location: location
  identity:{
    type:'SystemAssigned'
  }
  properties:{
    sku:{
      name: 'Standard'
    }
    jobType:'Cloud'
  }
}


output streamAnalyticsJobName string = streamAnalyticsJob.name
output streamAnalyticsJobID string = streamAnalyticsJob.id
