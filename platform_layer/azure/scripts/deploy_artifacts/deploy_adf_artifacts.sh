#!/bin/bash

# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.


#######################################################
# Deploys ADF artifacts
#
# Prerequisites:
# - User is logged in to the azure cli
# - Correct Azure subscription is selected
#######################################################

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace # For debugging


# Retrieve info from KeyVault
echo "Retrieve info from KeyVault"
ADF_DIR=.tmp/adf
RESOURCE_GROUP_NAME=$resource_group_name
DATAFACTORY_NAME=$(az keyvault secret show --vault-name "$kv_name" --name "adfName" --query value -o tsv)



# Consts
apiVersion="2018-06-01"
baseUrl="https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}"
adfFactoryBaseUrl="$baseUrl/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.DataFactory/factories/${DATAFACTORY_NAME}"


createIntegrationRuntime () {
    declare name=$1
    echo "Creating ADF IntegrationRuntime: $name"
    adfLsUrl="${adfFactoryBaseUrl}/integrationRuntimes/${name}?api-version=${apiVersion}"
    az rest --method put --uri "$adfLsUrl" --body @"${ADF_DIR}"/integrationRuntime/"${name}".json
}
getIntegrationRuntimeConnectionInfo () {
    declare name=$1
    echo "Get ADF IntegrationRuntime Connection Info: $name"
    adfLsUrl="${adfFactoryBaseUrl}/integrationRuntimes/${name}/getConnectionInfo?api-version=${apiVersion}"
    az rest --method post --uri "$adfLsUrl"
}
listAuthKeys () {
    declare name=$1
    adfLsUrl="${adfFactoryBaseUrl}/integrationRuntimes/${name}/listAuthKeys?api-version=${apiVersion}"
    az rest --method post --uri "$adfLsUrl"
}
createLinkedService () {
    declare name=$1
    echo "Creating ADF LinkedService: $name"
    adfLsUrl="${adfFactoryBaseUrl}/linkedservices/${name}?api-version=${apiVersion}"
    az rest --method put --uri "$adfLsUrl" --body @"${ADF_DIR}"/linkedService/"${name}".json
}
createDataset () {
    declare name=$1
    echo "Creating ADF Dataset: $name"
    adfDsUrl="${adfFactoryBaseUrl}/datasets/${name}?api-version=${apiVersion}"
    az rest --method put --uri "$adfDsUrl" --body @"${ADF_DIR}"/dataset/"${name}".json
}
createPipeline () {
    declare name=$1
    echo "Creating ADF Pipeline: $name"
    adfPUrl="${adfFactoryBaseUrl}/pipelines/${name}?api-version=${apiVersion}"
    az rest --method put --uri "$adfPUrl" --body @"${ADF_DIR}"/pipeline/"${name}".json
}
createTrigger () {
    declare name=$1
    echo "Creating ADF Trigger: $name"
    adfTUrl="${adfFactoryBaseUrl}/triggers/${name}?api-version=${apiVersion}"
    az rest --method put --uri "$adfTUrl" --body @"${ADF_DIR}"/trigger/"${name}".json
}

echo "Deploying Data Factory artifacts."

# Deploy all Integration Runtimes
createIntegrationRuntime "Lsshir01"
Lsshir01Key=$(listAuthKeys "Lsshir01" | jq -r '.authKey1')

# Deploy all Linked Services
createLinkedService "Ls_KeyVault_01"
createLinkedService "Ls_AdlsGen2_01"
createLinkedService "Ls_SqlDb_01"
createLinkedService "Ls_AzureSQLDW_01"
createLinkedService "Ls_AzureDatabricks_01"
createLinkedService "Ls_Onprem_SQLServer"

# Deploy all Datasets
createDataset "AzureDLStorage_GetMetadataDataset"
createDataset "AzureDLStorage_input_csv"       
createDataset "AzureDLStorage_input_parquet"
createDataset "AzureDLStorage"     
createDataset "AzureSqlDatabaseExternal_ControlTable"
createDataset "AzureSqlDatabaseTable"
createDataset "AzureSynapseAnalyticsTable"
createDataset "SqlServer_onPremise"      
createDataset "SqlServer_onPremise_ControlTable"
                 
# Deploy all Pipelines
createPipeline "BulkCopyfrom_AzureDLStorage_to_SynapseDedicatedPool_parquet" 
createPipeline "BulkCopyfrom_AzureDLStorage_to_SynapseDedicatedPool"         
createPipeline "BulkCopyfrom_AzureSQLdb_to_AzureDLStorage"                   
createPipeline "BulkCopyfrom_AzureSQLdb_to_SynapseDedicatedPool"
createPipeline "BulkCopyfrom_AzureSQLdb_to_SQLServer"  
createPipeline "BulkCopyfrom_SQLServer_to_AzureDLStorage"              
createPipeline "BulkCopyfrom_SQLServer_to_AzureSQLdb"                                                       
 


echo "Completed deploying Data Factory artifacts."
