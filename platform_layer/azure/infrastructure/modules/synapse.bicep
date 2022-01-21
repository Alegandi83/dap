param project string
param env string
param location string = resourceGroup().location
param deployment_id string

param synStorageAccount string = '${project}st2${env}${deployment_id}'
param mainStorageAccount string = '${project}st${env}${deployment_id}'
param synStorageFileSys string = 'synapsedefaultfs'
param purview_name string = '${project}pview${env}${deployment_id}'

param synapse_sqlpool_admin_username string = 'sqlAdmin'
@secure()
param synapse_sqlpool_admin_password string



resource synStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: synStorageAccount
}

resource synFileSystem 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' existing = {
  name: synStorageFileSys
}

resource mainStorage 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: mainStorageAccount
}

resource pv 'Microsoft.Purview/accounts@2020-12-01-preview' existing = {
  name: purview_name
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: '${project}-syws-${env}-${deployment_id}'
  tags: {
    DisplayName: 'Synapse Workspace'
    Environment: env
  }
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${synStorage.name}.dfs.${environment().suffixes.storage}'
      filesystem: synFileSystem.name
    }
    purviewConfiguration: {
      purviewResourceId: resourceId('Microsoft.Purview/accounts', pv.name)
    }    
    publicNetworkAccess: 'Enabled'
    managedResourceGroupName: '${project}-syn-mrg-${env}-${deployment_id}'
    sqlAdministratorLogin: synapse_sqlpool_admin_username
    sqlAdministratorLoginPassword: synapse_sqlpool_admin_password
  }

  resource synapseFirewall 'firewallRules@2021-06-01-preview' = {
      name: 'AllowAllWindowsAzureIps'
      properties: {
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
      }
  }
}

resource synapse_spark_sql_pool 'Microsoft.Synapse/workspaces/bigDataPools@2021-03-01' = {
  parent: synapseWorkspace
  name: 'synsp${env}${deployment_id}'
  location: location
  tags: {
    DisplayName: 'Spark SQL Pool'
    Environment: env
  }
  properties: {
    isComputeIsolationEnabled: false
    nodeSizeFamily: 'MemoryOptimized'
    nodeSize: 'Small'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    dynamicExecutorAllocation: {
      enabled: false
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '2.4'
    sessionLevelPackagesEnabled: true
    customLibraries: []
    defaultSparkLogFolder: 'logs/'
    sparkEventsFolder: 'events/'
  }
}

resource synapse_sql_pool 'Microsoft.Synapse/workspaces/sqlPools@2021-03-01' = {
  parent: synapseWorkspace
  name: 'syndp${env}${deployment_id}'
  location: location
  tags: {
    DisplayName: 'Synapse Dedicated SQL Pool'
    Environment: env
  }
  sku: {
    name: 'DW100c'
    tier: 'DataWarehouse'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

resource synapseWorkspaceFirewallRule1 'Microsoft.Synapse/workspaces/firewallrules@2021-03-01' = {
  parent: synapseWorkspace
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}


output synapseWorkspaceName string = synapseWorkspace.name
output synapse_principal_id string = synapseWorkspace.identity.principalId
output synapseDefaultStorageAccountName string = synStorage.name
output synapseBigdataPoolName string = synapse_spark_sql_pool.name
output synapse_sql_pool_output object = {
  username: synapseWorkspace.properties.sqlAdministratorLogin
  password: synapse_sqlpool_admin_password
  synapse_pool_name: synapse_sql_pool.name
}


