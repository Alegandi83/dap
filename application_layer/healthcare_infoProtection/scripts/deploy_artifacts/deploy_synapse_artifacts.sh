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
# Deploys Synapse artifacts
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
RESOURCE_GROUP_NAME=$resource_group_name
SYNAPSE_WORKSPACE_NAME=$(az keyvault secret show --vault-name "$kv_name" --name "synapseWorkspaceName" --query value -o tsv)
SYNAPSE_DEV_ENDPOINT=$(az keyvault secret show --vault-name "$kv_name" --name "synapseDevEndpoint" --query value -o tsv)
BIG_DATAPOOL_NAME=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSparkPoolName" --query value -o tsv)
SQL_POOL_NAME=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSqlPoolName" --query value -o tsv)
LOG_ANALYTICS_WS_ID=$(az keyvault secret show --vault-name "$kv_name" --name "logAnalyticsId" --query value -o tsv)
LOG_ANALYTICS_WS_KEY=$(az keyvault secret show --vault-name "$kv_name" --name "logAnalyticsKey" --query value -o tsv)
AZURE_STORAGE_ACCOUNT=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)


# Consts
echo "Set Variables"
apiVersion="2020-12-01&force=true"
dataPlaneApiVersion="2019-06-01-preview"
synapseResource="https://dev.azuresynapse.net"

baseUrl="https://management.azure.com/subscriptions/${AZURE_SUBSCRIPTION_ID}"
synapseWorkspaceBaseUrl="$baseUrl/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Synapse/workspaces/${SYNAPSE_WORKSPACE_NAME}"
requirementsFileName='./synapse/config/requirements.txt'
packagesDirectory='./synapse/libs/'

synapse_ws_location=$(az group show \
    --name "${RESOURCE_GROUP_NAME}" \
    --output json |
    jq -r '.location')

# Function responsible to perform the 4 steps needed to upload a single package to the synapse workspace area
uploadSynapsePackagesToWorkspace(){
    declare name=$1
    echo "Uploading Library Wheel Package to Workspace: $name"

    #az synapse workspace wait --resource-group "${RESOURCE_GROUP_NAME}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --created
    # Step 1: Get bearer token for the Data plane    
    token=$(az account get-access-token --resource ${synapseResource} --query accessToken --output tsv)    
    # Step 2: create workspace package placeholder
    synapseLibraryBaseUri=${SYNAPSE_DEV_ENDPOINT}/libraries
    synapseLibraryUri="${synapseLibraryBaseUri}/${name}?api-version=${dataPlaneApiVersion}"

    if [[ -n $(az rest --method get --headers "Authorization=Bearer ${token}" 'Content-Type=application/json;charset=utf-8' --url "${synapseLibraryBaseUri}?api-version=${dataPlaneApiVersion}" --query "value[?name == '${name}']" -o tsv) ]]; then
        echo "Library exists: ${name}"
        echo "Skipping creation"
        return 0
    fi

    az rest --method put --headers "Authorization=Bearer ${token}" "Content-Type=application/json;charset=utf-8" --url "${synapseLibraryUri}"
    sleep 5

    # Step 3: upload package content to workspace placeholder
    #az synapse workspace wait --resource-group "${RESOURCE_GROUP_NAME}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --updated
    synapseLibraryUriForAppend="${SYNAPSE_DEV_ENDPOINT}/libraries/${name}?comp=appendblock&api-version=${dataPlaneApiVersion}"
    curl -i -X PUT -H "Authorization: Bearer ${token}" -H "Content-Type: application/octet-stream" --data-binary @./synapse/libs/"${name}" "${synapseLibraryUriForAppend}"
    sleep 15
  
    # Step4: Completing Package creation/Flush the library
    #az synapse workspace wait --resource-group "${RESOURCE_GROUP_NAME}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --updated
    synapseLibraryUriForFlush="${SYNAPSE_DEV_ENDPOINT}/libraries/${name}/flush?api-version=${dataPlaneApiVersion}"
    az rest --method post --headers "Authorization=Bearer ${token}" "Content-Type=application/json;charset=utf-8" --url "${synapseLibraryUriForFlush}"

}

# Function responsible to perform the update of a spark pool on 3 configurations: requirements.txt, packages and spark configuration
uploadSynapseArtifactsToSparkPool(){
    declare requirementList=$1
    declare customLibraryList=$2
    echo "Uploading Synapse Artifacts to Spark Pool: ${BIG_DATAPOOL_NAME}"

    json_body="{
        \"location\": \"${synapse_ws_location}\",
        \"properties\": {
            \"nodeCount\": 10,
            \"isComputeIsolationEnabled\": false,
            \"nodeSizeFamily\": \"MemoryOptimized\",
            \"nodeSize\": \"Small\",
            \"autoScale\": {
                \"enabled\": true,
                \"minNodeCount\": 3,
                \"maxNodeCount\": 10
            },
            \"cacheSize\": 0,
            \"dynamicExecutorAllocation\": {
                \"enabled\": false,
                \"minExecutors\": 0,
                \"maxExecutors\": 10
            },
            \"autoPause\": {
                \"enabled\": true,
                \"delayInMinutes\": 15
            },
            \"sparkVersion\": \"2.4\",
            \"libraryRequirements\": {
                \"filename\": \"requirements.txt\",
                \"content\": \"${requirementList}\"
            },
            \"sessionLevelPackagesEnabled\": true,
            ${customLibraryList}
            \"sparkConfigProperties\": {
                \"configurationType\": \"File\",
                \"filename\": \"spark_loganalytics_conf.txt\",
                \"content\": \"spark.synapse.logAnalytics.enabled true\r\nspark.synapse.logAnalytics.workspaceId ${LOG_ANALYTICS_WS_ID}\r\nspark.synapse.logAnalytics.secret ${LOG_ANALYTICS_WS_KEY}\"
            },
        }
    }"
    
    #Get bearer token for the management API
    managementApiUri="${synapseWorkspaceBaseUrl}/bigDataPools/${BIG_DATAPOOL_NAME}?api-version=${apiVersion}"
    az account get-access-token
    
    #Update the Spark Pool with requirements.txt and sparkconfiguration
    #az synapse spark pool wait --resource-group "${RESOURCE_GROUP_NAME}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --big-data-pool-name "${BIG_DATAPOOL_NAME}" --created
    az rest --method put --headers "Content-Type=application/json" --url "${managementApiUri}" --body "$json_body"
}

createIntegrationRuntime () {
    declare name=$1
    echo "Creating Synapse IntegrationRuntime: $name"
    az synapse integration-runtime create --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --type SelfHosted
}
getIntegrationRuntimeConnectionInfo () {
    declare name=$1
    echo "Get Synapse IntegrationRuntime Connection Info: $name"
    az synapse integration-runtime get-connection-info --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --name ${name} --resource-group "${RESOURCE_GROUP_NAME}"
}
listAuthKeys () {
    declare name=$1
    az synapse integration-runtime list-auth-key --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --name ${name} --resource-group "${RESOURCE_GROUP_NAME}"    
}
createLinkedService () {
    declare name=$1
    echo "Creating Synapse LinkedService: $name"
    az synapse linked-service create --file @./.tmp/synapse/linkedService/"${name}".json --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}"
}
createDataset () {
    declare name=$1
    echo "Creating Synapse Dataset: $name"
    az synapse dataset create --file @./.tmp/synapse/dataset/"${name}".json --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}"
}
createNotebook() {
    declare name=$1
    # As of 26 Oct 2021, there is an outstanding bug regarding az synapse notebook create command which prevents it from deploy notebook .JSON files
    # Thus, we are resorting to deploying notebooks in .ipynb format.
    # See here: https://github.com/Azure/azure-cli/issues/20037
    echo "Creating Synapse Notebook: $name"
    az synapse notebook create --file @./.tmp/synapse/notebook/"${name}".ipynb --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --spark-pool-name "${BIG_DATAPOOL_NAME}"
}
createPipeline () {
    declare name=$1
    echo "Creating Synapse Pipeline: $name"

    # Replace dedicated sql pool name
    tmp=$(mktemp)
    jq --arg a "${SQL_POOL_NAME}" '.properties.activities[5].sqlPool.referenceName = $a' ./synapse/pipeline/"${name}".json > "$tmp" && mv "$tmp" ./synapse/pipeline/"${name}".json
    # Deploy the pipeline
    az synapse pipeline create --file @./.tmp/synapse/pipeline/"${name}".json --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}"
}
createTrigger () {
    declare name=$1
    echo "Creating Synapse Trigger: $name"
    az synapse trigger create --file @./.tmp/synapse/trigger/"${name}".json --name="${name}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}"
}


getProvisioningState(){
    provision_state=$(az synapse spark pool show \
    --name "$BIG_DATAPOOL_NAME" \
    --workspace-name "$SYNAPSE_WORKSPACE_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --only-show-errors \
    --output json |
    jq -r '.provisioningState')
}

UpdateExternalTableScript () {
    echo "Replace SQL script with: $AZURE_STORAGE_ACCOUNT"
    sed "s/<data storage account>/$AZURE_STORAGE_ACCOUNT/" \
    ./synapse/scripts/create_external_table_template.sql \
    > ./synapse/scripts/create_external_table.sql
}

UploadSql () {
    echo "Try to upload sql script"
    declare name=$1
    echo "Uploading sql script to Workspace: $name"

    #az synapse workspace wait --resource-group "${RESOURCE_GROUP_NAME}" --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --created
    # Step 1: Get bearer token for the Data plane    
    token=$(az account get-access-token --resource ${synapseResource} --query accessToken --output tsv)    
    # Step 2: create workspace package placeholder
    synapseSqlBaseUri=${SYNAPSE_DEV_ENDPOINT}/sqlScripts
    synapseSqlApiUri="${synapseSqlBaseUri}/$name?api-version=${apiVersion}"
    body_content="$(sed 'N;s/\n/\\n/' ./synapse/sqlscript_orig/${name}.sql)"
    json_body="{
    \"name\": \"$name\",
    \"properties\": {
        \"description\": \"$name\",        
        \"content\":{ 
            \"query\": \"$body_content\",
            \"currentConnection\": { 
                \"name\": \"master\",
                \"type\": \"SqlOnDemand\"
                }
        },
        \"metadata\": {
            \"language\": \"sql\"
        },
        \"type\": \"SqlQuery\"      
    }
    }"    
    curl -X PUT -H "Content-Type: application/json" -H "Authorization:Bearer $token" --data-raw "$json_body" --url $synapseSqlApiUri
    sleep 5
}

getProvisioningState
echo "$provision_state"

#while [ "$provision_state" != "Succeeded" ]
#do
#    if [ "$provision_state" == "Failed" ]; then break ; else sleep 10; fi
#    getProvisioningState
#    echo "$provision_state: checking again in 10 seconds..."
#done

 
# Start Deploy Use Case - Healthcare information Protection ------------------------------------------
echo "Start deploying Synapse artifacts - Healthcare information Protection"


# Update Synapse LinkedServices to point to newly Databricks workspace URL
echo "Create temp dir"
synTempDir=.tmp/synapse
mkdir -p $synTempDir && cp -a synapse/ .tmp/


# This line allows the spark pool to be available to attach to the notebooks
echo "Deploy Notebook"
az synapse spark session list --workspace-name "${SYNAPSE_WORKSPACE_NAME}" --spark-pool-name "${BIG_DATAPOOL_NAME}"
createNotebook "Hpi Campaign Analytics DataPrep"

# Deploy all Pipelines
echo "Deploy Pipelines"
#createPipeline "loadData" 
 

# Deploy SQL Scripts
echo "Deploy SQL Scripts"
#UploadSql "0 Set up Script RLS DDM"
UploadSql "1_SQL_Pool_Security_DDM"
#UploadSql "2 HealthCare SQL Pool Security RLS"
#UploadSql "3 HealthCare SQL Pool Security CLS"
#UploadSql "CLS_ChiefOperatingManager"
#UploadSql "CLS_DAM_AC_New"
#UploadSql "CLS_DAM_F_New"
#UploadSql "Confirm_DDM"
#UploadSql "create_purview_user"
#UploadSql "createExternalTable_PatientInformation"
#UploadSql "createSchema_hpi"
#UploadSql "createTable_Campaign_Analytics_New"
#UploadSql "createTable_Campaign_Analytics"
#UploadSql "createTable_HealthCare-FactSales"
#UploadSql "createTable_HospitalEmpPIIData"
#UploadSql "createTable_Mkt_CampaignAnalyticLatest"
#UploadSql "createTable_PatientInformation"
#UploadSql "createTable_RoleNew"
#UploadSql "createUsers"
#UploadSql "loadTable_Campaign_Analytics_New"
#UploadSql "loadTable_Campaign_Analytics"
#UploadSql "loadTable_Healthcare-FactSales"
#UploadSql "loadTable_HospitalEmpPIIData"
#UploadSql "loadTable_Mkt_CampaignAnalyticLatest"
#UploadSql "loadTable_PatientInformation"
#UploadSql "loadTable_RoleNew"
#UploadSql "Sp_HealthCareRLS"
#UploadSql "SP_RLS_CareManagerLosAngeles"
#UploadSql "SP_RLS_CareManagerMiami"
#UploadSql "SP_RLS_ChiefOperatingManager"

echo "Completed deploying Synapse artifacts - Healthcare information Protection"
# End Deploy Use Case - Healthcare information Protection ------------------------------------------