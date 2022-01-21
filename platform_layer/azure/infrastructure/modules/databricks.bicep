param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string


resource databricks 'Microsoft.Databricks/workspaces@2018-04-01' = {
  name: '${project}-dbw-${env}-${deployment_id}'
  location: location
  tags: {
    DisplayName: 'Databricks Workspace'
    Environment: env
  }
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: '${subscription().id}/resourceGroups/${project}-dbw-rg-${env}-${deployment_id}'
  }
}


output databricks_output object = databricks
output databricks_id string = databricks.id
