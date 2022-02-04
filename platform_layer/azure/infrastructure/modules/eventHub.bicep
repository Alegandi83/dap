param project string
param env string
param location string = resourceGroup().location
param deployment_id string


resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01'{
  name: '${project}-evh-${env}-${deployment_id}'
  location: location
  sku:{
    name: 'Standard'
    tier: 'Standard'
    capacity:1
  }
  identity: {
    type: 'SystemAssigned'
  }

}


output eventHubNamespaceName string = eventHubNamespace.name
output eventHubNamespaceID string = eventHubNamespace.id
