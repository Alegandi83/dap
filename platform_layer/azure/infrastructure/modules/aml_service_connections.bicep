
param project string
param env string
param location string = resourceGroup().location
param deployment_id string


param synWorkspace_name string = '${project}-syws-${env}-${deployment_id}'
param synSparkPool_name string = 'synsp${env}${deployment_id}'
param amlWorkspace_name string = '${project}-amlws-${env}-${deployment_id}'
param evhNamespace_name string = '${project}-evh-${env}-${deployment_id}'

param DataLakeAccountName string = '${project}st${env}${deployment_id}'
param DataLakeZoneContainerNames array = [
  'datalake'
//  'datastore'
]

/*
param eventHubNamespaceName string
param eventHubName string
param eventHubPartitionCount int
*/

var storageEnvironmentDNS = environment().suffixes.storage


resource synWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synWorkspace_name
}

resource synSparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-03-01' existing = {
  name: synSparkPool_name
}


//Azure Machine Learning Datastores
resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-07-01' existing = {
  
  name: amlWorkspace_name

  // Data Lake Datastores
  resource amlDataStores 'datastores@2021-03-01-preview' = [for containerName in DataLakeZoneContainerNames: {
    name: '${DataLakeAccountName}_${containerName}'
    properties: {
      contents: {
        contentsType:'AzureDataLakeGen2'
        accountName: DataLakeAccountName
        containerName: containerName
        credentials: {
          credentialsType: 'None'
        }
        endpoint: storageEnvironmentDNS
        protocol: 'https'
      }
    }
  }]
}

/*
resource amlSynapseSparkCompute 'Microsoft.MachineLearningServices/workspaces/computes@2021-04-01' = {
  parent: amlWorkspace
  name: synSparkPool_name
  location: location
  properties:{
    computeType:'SynapseSpark'
    resourceId: synSparkPool.id
  }
}
*/


resource amlSynapseLinkedService 'Microsoft.MachineLearningServices/workspaces/linkedServices@2020-09-01-preview' = {
  parent: amlWorkspace
  name: synWorkspace_name
  location: location
  identity:{
    type:'SystemAssigned'
  }
  properties:{
    linkedServiceResourceId: synWorkspace.id
    linkType: 'Synapse'
  }
}

/*
//Event Hub Capture
resource evhNamespace 'Microsoft.EventHub/namespaces@2021-11-01' existing = {
  name: evhNamespace_name

  resource r_eventHub 'eventhubs' = {
    name: eventHubName
    properties:{
      messageRetentionInDays:1
      partitionCount:eventHubPartitionCount
      captureDescription:{
        enabled:true
        skipEmptyArchives: true
        encoding: 'Avro'
        intervalInSeconds: 300
        sizeLimitInBytes: 314572800
        destination: {
          name: 'EventHubArchive.AzureBlockBlob'
          properties: {
            storageAccountResourceId: rawDataLakeAccountID
            blobContainer: 'raw'
            archiveNameFormat: '{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'
          }
        }
      }
    }
  }
}
*/
