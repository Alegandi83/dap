param project string
@allowed([
  'dev'
  'stg'
  'prod'
])
param env string
param location string = resourceGroup().location
param deployment_id string

param synWorkspace_name string = '${project}-syws-${env}-${deployment_id}'
param dataFactory_name string = '${project}-adf-${env}-${deployment_id}'
param purview_name string = '${project}pview${env}${deployment_id}'

param keyvault_owner_object_id string
param userAssignedIdentity string



resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-03-01' existing = {
  name: synWorkspace_name
}

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactory_name
  location: location
}

resource pv 'Microsoft.Purview/accounts@2020-12-01-preview' existing = {
  name: purview_name
}


resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${project}-kv-${env}-${deployment_id}'
  location: location
  tags: {
    DisplayName: 'Keyvault'
    Environment: env
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: keyvault_owner_object_id
        permissions: {
            keys: [
                'all'
            ]
            secrets: [
                'all'
            ]
        }
      }
      //Access Policy to allow Deployment Script UAMI to Get, Set and List Secrets
      //https://docs.microsoft.com/en-us/azure/purview/manage-credentials#grant-the-purview-managed-identity-access-to-your-azure-key-vault
      {
        tenantId: subscription().tenantId
        objectId: userAssignedIdentity        
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      } 
      // Synapse Access Policy
      {
        tenantId: subscription().tenantId
        objectId: synapseWorkspace.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }      
      // Data Factory Access Policy
      {
        tenantId: subscription().tenantId
        objectId: datafactory.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
      // Purview Access Policy
      {
        tenantId: subscription().tenantId
        objectId: pv.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}


output keyvault_name string = keyvault.name
output keyvault_resource_id string = keyvault.id
output keyvault_resource_uri string = keyvault.properties.vaultUri
