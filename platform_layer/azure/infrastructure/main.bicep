param project string = 'mdwdo'
param env string = 'dev'
param deployment_id string

param tenant_id string = tenant().tenantId
param subscription_id string = subscription().id
param rg_name string = resourceGroup().name
param location string = resourceGroup().location

param keyvault_owner_object_id string

@secure()
param synapse_sqlpool_admin_password string
param sql_administrator_Password string

param pbi_tenant_id string
param pbi_ws_name string


// User Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${project}-deploy-${env}-${deployment_id}-sp'
  location: location
}

module storage './modules/storage.bicep' = {
  name: 'storage_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}


module sql './modules/sql.bicep' = {
  name: 'sql_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    administratorPassword: sql_administrator_Password
    //subnetId: subnetId
    //administratorUsername: administratorUsername
    //administratorPassword: administratorPassword
    //privateDnsZoneIdSqlServer: privateDnsZoneIdSqlServer
    //sqlserverAdminGroupName: ''
    //sqlserverAdminGroupObjectID: ''
  }
}

module databricks './modules/databricks.bicep' = {
  name: 'databricks_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    //contributor_principal_id: datafactory.outputs.datafactory_principal_id
  }
}

module synapse './modules/synapse.bicep' = {
  name: 'synapse_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    synapse_sqlpool_admin_password: synapse_sqlpool_admin_password
  }
}

module datafactory './modules/datafactory.bicep' = {
  name: 'datafactory_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module purview './modules/purview.bicep' = {
  name: 'purview_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'keyvault_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    keyvault_owner_object_id: keyvault_owner_object_id
    userAssignedIdentity: userAssignedIdentity.properties.principalId
  }
  dependsOn:[
    userAssignedIdentity
    synapse
    datafactory
    purview
  ]  
}

module appinsights './modules/appinsights.bicep' = {
  name: 'appinsights_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module loganalytics './modules/log_analytics.bicep' = {
  name: 'log_analytics_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module diagnostic './modules/diagnostic_settings.bicep' = {
  name: 'diagnostic_settings_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    deployment_id: deployment_id
    loganalytics_workspace_name: loganalytics.outputs.loganalyticswsname
    synapse_workspace_name: synapse.outputs.synapseWorkspaceName
    synapse_sql_pool_name: synapse.outputs.synapse_sql_pool_output.synapse_pool_name
    synapse_spark_pool_name: synapse.outputs.synapseBigdataPoolName
  }
  dependsOn: [
    loganalytics
    synapse
  ]
}



module eventHub './modules/eventHub.bicep' = {
  name: 'eventHub_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module streamAnalytics './modules/streamAnalytics.bicep' = {
  name: 'streamAnalytics_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
}

module machineLearning './modules/aml_workspace.bicep' = {
  name: 'amlWorkspace_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
  }
  dependsOn:[
    keyvault
  ]  
}


module aml_services './modules/aml_service_connections.bicep' = {
  name: 'amlServices_deploy_${deployment_id}'
  params: {
    project: project
    env: env
    location: location
    deployment_id: deployment_id
    synapse_sprk_pool_id: synapse.outputs.synapse_sprk_pool_id
  }
  dependsOn:[
    machineLearning
    synapse
  ]  
}

//********************************************************
// RBAC Role Assignments
//********************************************************
module RBACRoleAssignment 'modules/RBAC_deploy.bicep' = {
  name: 'RBACRoleAssignmentDeploy'
  dependsOn:[
    userAssignedIdentity
    storage
    sql
    databricks
    synapse
    datafactory
    purview
    keyvault
    appinsights
    loganalytics
    diagnostic
    eventHub
    streamAnalytics
    machineLearning
  ]
  params: {
    project: project
    env: env
    deployment_id: deployment_id
    keyvault_owner_object_id: keyvault_owner_object_id
  }
}


/*
// Purview Data Plane Operations
resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'script'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '6.2'
    arguments: '-project ${project} -env ${env} -deployment_id ${deployment_id} -tenant_id ${tenant_id} -subscriptionId ${subscription_id} -resourceGroupName ${rg_name} -location ${location} -user_id ${keyvault_owner_object_id} -purview_account ${purview.outputs.purview_name} -vault_name ${keyvault.outputs.keyvault_name} -vault_uri ${keyvault.outputs.keyvault_resource_uri} -admin_login ${sql.outputs.sql_admin_name} -sql_secret_name ${sql_administrator_Password} -sql_server_name ${sql.outputs.sql_server_name} -sql_db_name ${sql.outputs.sql_database_name} -storage_account_name ${storage.outputs.storage_account_name} -adf_name ${datafactory.outputs.datafactory_name} -adf_principal_id ${datafactory.outputs.datafactory_principal_id} -syn_name ${synapse.outputs.synapseWorkspaceName} -syn_principal_id ${synapse.outputs.synapse_principal_id} -managed_identity ${userAssignedIdentity.properties.principalId} -pbi_tenant_id ${pbi_tenant_id} -pbi_ws_name ${pbi_ws_name}'
    // scriptContent: loadTextContent('deploymentScript.ps1')
    primaryScriptUri: 'https://raw.githubusercontent.com/Alegandi83/dap/main/platform_layer/azure/purview/deploy_purview_artifacts.ps1'
    forceUpdateTag: guid(resourceGroup().id)
    retentionInterval: 'PT4H' // deploymentScript resource will delete itself in 4 hours
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  dependsOn: [
    RBACRoleAssignment
  ]
}
*/


output storage_account_name string = storage.outputs.storage_account_name

output sql_server_name string = sql.outputs.sql_server_name
output sql_database_name string = sql.outputs.sql_database_name
output sql_admin_name string = sql.outputs.sql_admin_name

output databricks_output object = databricks.outputs.databricks_output
output databricks_id string = databricks.outputs.databricks_id

output synapse_output_spark_pool_name string = synapse.outputs.synapseBigdataPoolName
output synapse_sql_pool_output object = synapse.outputs.synapse_sql_pool_output
output synapseworskspace_name string = synapse.outputs.synapseWorkspaceName

output datafactory_name string = datafactory.outputs.datafactory_name

output purview_name string = purview.name

output keyvault_name string = keyvault.outputs.keyvault_name
output keyvault_resource_id string = keyvault.outputs.keyvault_resource_id

output loganalytics_name string = loganalytics.outputs.loganalyticswsname
output appinsights_name string = appinsights.outputs.appinsights_name

output eventHub_name string = eventHub.outputs.eventHubNamespaceName
output eventHub_id string = eventHub.outputs.eventHubNamespaceID

output streamAnalytics_name string = streamAnalytics.outputs.streamAnalyticsJobName
output streamAnalytics_id string = streamAnalytics.outputs.streamAnalyticsJobID
