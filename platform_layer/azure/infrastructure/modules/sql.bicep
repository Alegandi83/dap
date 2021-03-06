param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string


param administratorUsername string = 'sqladminuserag83'
//@secure()
param administratorPassword string
param sqlserverAdminGroupName string = ''
param sqlserverAdminGroupObjectID string = ''

// param subnetId string
//param privateDnsZoneIdSqlServer string = ''


// Resources
resource sqlserver 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: '${project}sql${env}${deployment_id}'
  location: location
  tags: {
    DisplayName: 'SQL Server'
    Environment: env
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorUsername
    administratorLoginPassword: administratorPassword
    administrators: {}
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    version: '12.0'
  }
}

resource sqlserverAdministrators 'Microsoft.Sql/servers/administrators@2020-11-01-preview' = if (!empty(sqlserverAdminGroupName) && !empty(sqlserverAdminGroupObjectID)) {
  parent: sqlserver
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlserverAdminGroupName
    sid: sqlserverAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}

resource sqlserverDatabase 'Microsoft.Sql/servers/databases@2020-11-01-preview' = {
  parent: sqlserver
  name: '${project}sqldb${env}${deployment_id}'
  location: location
  tags: {
    DisplayName: 'SQL Server Database'
    Environment: env
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    autoPauseDelay: -1
    catalogCollation: 'DATABASE_DEFAULT'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    readScale: 'Disabled'
    highAvailabilityReplicaCount: 0
    licenseType: 'LicenseIncluded'
    maxSizeBytes: 524288000
    minCapacity: 1
    requestedBackupStorageRedundancy: 'Geo'
    zoneRedundant: false
  }
}

resource sqlserverFirewallAllowAzure 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlserver
  properties:{
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}


output sql_server_name string = sqlserver.name
output sql_database_name string = sqlserverDatabase.name
output sql_admin_name string = administratorUsername
