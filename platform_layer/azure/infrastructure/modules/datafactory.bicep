param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string

param purview_name string = '${project}pview${env}${deployment_id}'


resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${project}-adf-${env}-${deployment_id}'
  location: location
  tags: {
    DisplayName: 'Data Factory'
    Environment: env
    catalogUri: '${purview_name}.catalog.purview.azure.com'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output datafactory_name string = datafactory.name
output datafactory_principal_id string = datafactory.identity.principalId
