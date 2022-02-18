param project string
param env string
param location string = resourceGroup().location
param deployment_id string


param userAssignedIdentity_name string = '${project}-deploy-${env}-${deployment_id}-sp'
param synStorageAccount_name string = '${project}st2${env}${deployment_id}'
param mainStorageAccount_name string = '${project}st${env}${deployment_id}'
param databricks_name string = '${project}-dbw-${env}-${deployment_id}'
param synWorkspace_name string = '${project}-syws-${env}-${deployment_id}'
param dataFactory_name string = '${project}-adf-${env}-${deployment_id}'
param purview_name string = '${project}pview${env}${deployment_id}'

param eventHubNamespace_name string = '${project}-evh-${env}-${deployment_id}'
param streamAnalyticsJob_name string = '${project}-asa-${env}-${deployment_id}'

param amlWorkspace_name string = '${project}-amlws-${env}-${deployment_id}'
param amlStorageAccount_name string  = '${project}amlst${env}${deployment_id}'
param amlAppInsights_name string  = '${project}-amlappi-${env}-${deployment_id}'
param amlContainerRegistry_name string  = '${project}amlcr${env}${deployment_id}'


//https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var owner = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var reader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')

//https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-event-hubs-data-owner
var storage_blob_data_contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var azureEventHubsDataOwner = resourceId('Microsoft.Authorization/roleDefinitions', 'f526a384-b230-433a-b45c-95f59c4a2dec')

// User Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userAssignedIdentity_name
}

resource synStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: synStorageAccount_name
}

resource mainStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: mainStorageAccount_name
}

resource dbricks 'Microsoft.Databricks/workspaces@2018-04-01' existing = {
  name: databricks_name
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-03-01' existing = {
  name: synWorkspace_name
}

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactory_name
}

resource pv 'Microsoft.Purview/accounts@2020-12-01-preview' existing = {
  name: purview_name
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01'existing = {
  name: eventHubNamespace_name
}

resource streamAnalyticsJob 'Microsoft.StreamAnalytics/streamingjobs@2020-03-01' existing = {
  name: streamAnalyticsJob_name
}

resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-07-01' existing = {
  name: amlWorkspace_name
}

resource amlStorageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: amlStorageAccount_name
}

resource amlAppInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: amlAppInsights_name
}

resource amlContainerRegistry 'Microsoft.ContainerRegistry/registries@2021-08-01-preview' existing = {
  name: amlContainerRegistry_name
}


// User Assigned Identity (configDeployer) as Contributor on resource group
resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(userAssignedIdentity.name, resourceGroup().id)
  scope: resourceGroup()
  properties: {
    principalId: userAssignedIdentity.properties.principalId
    roleDefinitionId: owner
    principalType: 'ServicePrincipal'
  }
}


// Synapse as data contributor on Synapse Storage Account
resource roleAssignmentSynStorage1 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, resourceId('Microsoft.Storage/storageAccounts', synStorage.name))
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: synStorage
}

// Synapse as data contributor on Data Lake
resource roleAssignmentSynStorage2 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, resourceId('Microsoft.Storage/storageAccounts', mainStorage.name))
  properties: {
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: mainStorage
}

// Synapse as contributor on Databricks
resource databricks_roleassignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(synapseWorkspace.name, resourceId('Microsoft.Databricks/workspaces', dbricks.name))
  scope: dbricks
  properties: {
    roleDefinitionId: contributor
    principalId: synapseWorkspace.identity.principalId
  }
}


// Data Factory as data contributor on Synapse Storage Account
resource roleAssignmentAdfStorage1 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(datafactory.name, resourceId('Microsoft.Storage/storageAccounts', synStorage.name))
  properties: {
    principalId: datafactory.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: synStorage
}

// Data Factory as data contributor on Data Lake
resource roleAssignmentAdfStorage2 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(datafactory.name, resourceId('Microsoft.Storage/storageAccounts', mainStorage.name))
  properties: {
    principalId: datafactory.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: mainStorage
}

// Data Factory as contributor on Databricks
resource databricks_Adfroleassignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(datafactory.name, resourceId('Microsoft.Databricks/workspaces', dbricks.name))
  scope: dbricks
  properties: {
    roleDefinitionId: contributor
    principalId: datafactory.identity.principalId
  }
}


// Purview as data contributor on Data Lake
resource roleAssignmentPviewStorage2 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(pv.name, resourceId('Microsoft.Storage/storageAccounts', mainStorage.name))
  properties: {
    principalId: pv.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType: 'ServicePrincipal'
  }
  scope: mainStorage
}

// Purview as Reader on Synapse Workspace
// https://docs.microsoft.com/en-us/azure/purview/register-scan-synapse-workspace#authentication-for-enumerating-serverless-sql-database-resources
resource roleAssignmentPviewSynWorkspace 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(pv.name, subscription().subscriptionId, resourceGroup().id)
  properties:{
    principalId: pv.identity.principalId
    roleDefinitionId: reader
    principalType:'ServicePrincipal'
  }
  scope: synapseWorkspace
}


// StreamAnalytics as EventHub Data Onwer on EventHub
// https://docs.microsoft.com/en-us/azure/stream-analytics/event-hubs-managed-identity#grant-the-stream-analytics-job-permissionsto-access-the-event-hub
resource roleAssignmentAsaEventHubNamespace 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(eventHubNamespace.name, streamAnalyticsJob.name)
  properties:{
    roleDefinitionId: azureEventHubsDataOwner
    principalId: streamAnalyticsJob.identity.principalId
    principalType:'ServicePrincipal'
  }
  scope: eventHubNamespace
}

// TODO - StreamAnalytics as EventHub Data Receiver on EventHub

// EventHub as Data Contributor on  Data Lake
//https://docs.microsoft.com/en-us/azure/stream-analytics/blob-output-managed-identity#grant-access-via-the-azure-portal
resource roleAssignmentAsaSynWorkspace 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(eventHubNamespace.name, mainStorage.name)
  properties:{
    principalId: eventHubNamespace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType:'ServicePrincipal'
  }
  scope: mainStorage
}

// Synapse as Data Owner on EventHub
//https://docs.microsoft.com/en-us/azure/stream-analytics/blob-output-managed-identity#grant-access-via-the-azure-portal
resource roleAssignmentSynEventHubNamespace 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(synapseWorkspace.name, eventHubNamespace.name)
  properties:{
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: azureEventHubsDataOwner
    principalType:'ServicePrincipal'
  }
  scope: eventHubNamespace
}


// Synapse as Contributor on Azure ML workspace.
//https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/quickstart-integrate-azure-machine-learning#give-msi-permission-to-the-azure-ml-workspace
resource roleAssignmentSynAmlWorkspace 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(synapseWorkspace.name, amlWorkspace.name)
  properties:{
    principalId: synapseWorkspace.identity.principalId
    roleDefinitionId: contributor
    principalType:'ServicePrincipal'
  }
  scope: amlWorkspace
}

// Azure ML Workspace as Data Contributor on Data Lake
// https://docs.microsoft.com/en-us/azure/machine-learning/how-to-identity-based-data-access
resource roleAssignmentAmlWorkspaceSynWorkspace 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(amlWorkspace.name, mainStorage.name)
  properties:{
    principalId: amlWorkspace.identity.principalId
    roleDefinitionId: storage_blob_data_contributor
    principalType:'ServicePrincipal'
  }
  scope: mainStorage  
}
*/
