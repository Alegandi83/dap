param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string

var purviewName = '${project}pview${env}${deployment_id}'

resource purview 'Microsoft.Purview/accounts@2021-07-01' = {
  name: purviewName
  location: location
  tags: {
    DisplayName: 'Purview'
    Environment: env
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    cloudConnectors: {}
    managedResourceGroupName: '${purviewName}-rg'
    publicNetworkAccess: 'Enabled'
  }
}


output purview_name string = purview.name
output purviewManagedStorageId string = purview.properties.managedResources.storageAccount
output purviewManagedEventHubId string = purview.properties.managedResources.eventHubNamespace
