param project string
param env string
param location string = resourceGroup().location
param deployment_id string


param amlWorkspace_name string = '${project}-amlws-${env}-${deployment_id}'
param amlStorageAccount_name string  = '${project}amlst${env}${deployment_id}'
param amlAppInsights_name string  = '${project}-amlappi-${env}-${deployment_id}'
param amlContainerRegistry_name string  = '${project}amlcr${env}${deployment_id}'
param kv_name string = '${project}-kv-${env}-${deployment_id}'



resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kv_name
}


//Azure ML Storage Account
resource amlStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: amlStorageAccount_name
  location: location
  tags: {
    DisplayName: 'Azure ML Storage Account'
    Environment: env
  }  
  kind:'StorageV2'
  sku:{
    name:'Standard_LRS'
  }
  properties:{
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    encryption:{
      services:{
        blob:{
          enabled:true
        }
        file:{
          enabled:true
        }
      }
      keySource:'Microsoft.Storage'
    }
  }
  
}

//Azure ML Application Insights
resource amlAppInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: amlAppInsights_name
  location: location
  kind:'web'
  properties:{
    Application_Type:'web'
  }
}
  
//Azure ML Container Registry
resource amlContainerRegistry 'Microsoft.ContainerRegistry/registries@2021-08-01-preview' = {
  name: amlContainerRegistry_name
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Enabled'
  }
}

//Azure Machine Learning Workspace
resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-04-01' = {
  name: amlWorkspace_name
  location: location
  sku:{
    name: 'Basic'
    tier: 'Basic'
  }
  identity:{
    type:'SystemAssigned'
  }
  properties:{
    friendlyName: amlWorkspace_name
    keyVault: kv.id
    storageAccount: amlStorageAccount.id
    applicationInsights: amlAppInsights.id
    containerRegistry: amlContainerRegistry.id
    allowPublicAccessWhenBehindVnet: true
  }
}


output amlWorkspace_id string = amlWorkspace.id
output amlWorkspace_name string = amlWorkspace.name

output amlContainerRegistry_id string = amlContainerRegistry.id
output amlContainerRegistry_name string = amlContainerRegistry.name

output amlApplicationInsights_id string = amlAppInsights.id
output amlApplicationInsights_name string = amlAppInsights.name

output amlStorageAccount_id string = amlStorageAccount.id
output amlStorageAccount_name string = amlStorageAccount.name
