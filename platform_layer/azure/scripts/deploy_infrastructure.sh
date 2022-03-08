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
# Deploys all necessary azure resources and stores
# configuration information in an .ENV file
#
# Prerequisites:
# - User is logged in to the azure cli
# - Correct Azure subscription is selected
#######################################################

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace # For debugging

. ./scripts/common.sh

###################
# REQUIRED ENV VARIABLES:
#
# PROJECT
# DEPLOYMENT_ID
# ENV_NAME
# AZURE_LOCATION
# AZURE_SUBSCRIPTION_ID
# SYNAPSE_SQL_PASSWORD
# DB_SQL_PASSWORD


#####################
# DEPLOY ARM TEMPLATE

# Set account to where ARM template will be deployed to
echo "Deploying to Subscription: $AZURE_SUBSCRIPTION_ID"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Create resource group
echo "Creating resource group: $resource_group_name"
az group create --name "$resource_group_name" --location "$AZURE_LOCATION" --tags Environment="$ENV_NAME"

# By default, set all KeyVault permission to deployer
# Retrieve KeyVault User Id
kv_owner_object_id=$(az ad signed-in-user show --output json | jq -r '.objectId')


# Validate arm template
echo "Validating deployment"
arm_output=$(az deployment group validate \
    --resource-group "$resource_group_name" \
    --template-file "./infrastructure/main.bicep" \
    --parameters @"./infrastructure/main.parameters.${ENV_NAME}.json" \
    --parameters project="${PROJECT}" keyvault_owner_object_id="${kv_owner_object_id}" deployment_id="${DEPLOYMENT_ID}" synapse_sqlpool_admin_password="${SYNAPSE_SQL_PASSWORD}" sql_administrator_Password="${DB_SQL_PASSWORD}" \
    --output json)

# Deploy arm template
echo "Deploying resources into $resource_group_name"
arm_output=$(az deployment group create \
    --resource-group "$resource_group_name" \
    --template-file "./infrastructure/main.bicep" \
    --parameters @"./infrastructure/main.parameters.${ENV_NAME}.json" \
    --parameters project="${PROJECT}" deployment_id="${DEPLOYMENT_ID}" keyvault_owner_object_id="${kv_owner_object_id}" synapse_sqlpool_admin_password="${SYNAPSE_SQL_PASSWORD}" sql_administrator_Password="${DB_SQL_PASSWORD}" \
    --output json)

if [[ -z $arm_output ]]; then
    echo >&2 "ARM deployment failed."
    exit 1
fi


########################
# RETRIEVE KEYVAULT INFORMATION

echo "Retrieving KeyVault information from the deployment."

kv_name=$(echo "$arm_output" | jq -r '.properties.outputs.keyvault_name.value')
kv_dns_name=https://${kv_name}.vault.azure.net/
 

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "kvUrl" --value "$kv_dns_name"
az keyvault secret set --vault-name "$kv_name" --name "subscriptionId" --value "$AZURE_SUBSCRIPTION_ID"


#########################
# CREATE AND CONFIGURE SERVICE PRINCIPAL FOR ADLA GEN2

# Retrive account and key
azure_storage_account=$(echo "$arm_output" | jq -r '.properties.outputs.storage_account_name.value')
azure_storage_key=$(az storage account keys list \
    --account-name "$azure_storage_account" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.[0].value')


# Add file system storage account
storage_file_system=datalake
echo "Creating ADLS Gen2 File system: $storage_file_system"
az storage container create --name $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"

echo "Creating folders within the file system."
# Create folders for databricks libs
az storage fs directory create -n '/sys/databricks/libs' -f $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "datalakeAccountName" --value "$azure_storage_account"
az keyvault secret set --vault-name "$kv_name" --name "datalakeContainerName" --value "$storage_file_system"
az keyvault secret set --vault-name "$kv_name" --name "datalakeKey" --value "$azure_storage_key"
az keyvault secret set --vault-name "$kv_name" --name "datalakeurl" --value "https://$azure_storage_account.dfs.core.windows.net"

#########################
# POWER-BI
 
# Set PowerBI workspace name
export pbi_ws_name="$PROJECT-$DEPLOYMENT_ID-$ENV_NAME-ws"

# Create PowerBI workspace
pwsh ./powerbi/deploy_pbi_artifacts.ps1 -kvName ${kv_name} -workspaceName ${pbi_ws_name} -userEmail ${PBI_DAP_USR_MAIL}

# Retrieve PowerBI workspace id
pbi_ws_id=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsid" --query value -o tsv)


#########################
# PURVIEW

# Retrive account and key
purview_name=$(echo "$arm_output" | jq -r '.properties.outputs.purview_name.value')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "purviewName" --value "$purview_name"


#########################
# SQL DATABASE

# Retrive account and key
sql_server_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_server_name.value')
sql_database_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_database_name.value')
sql_admin_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_admin_name.value')

# Sql Pool Connection String
sql_connstr_nocred=$(az sql db show-connection-string --client ado.net \
    --name "$sql_database_name" --server "$sql_server_name" --output json |
    jq -r .)
sql_connstr_uname=${sql_connstr_nocred/<username>/$sql_admin_name}
sql_connstr_uname_pass=${sql_connstr_uname/<password>/$DB_SQL_PASSWORD}

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "sqlServerName" --value "$sql_server_name"
az keyvault secret set --vault-name "$kv_name" --name "sqlDatabaseName" --value "$sql_database_name"
az keyvault secret set --vault-name "$kv_name" --name "sqlConnectionString" --value "$sql_connstr_uname_pass"
az keyvault secret set --vault-name "$kv_name" --name "sqlDatabasePsw" --value "$DB_SQL_PASSWORD"

####################
# APPLICATION INSIGHTS

echo "Retrieving ApplicationInsights information from the deployment."
appinsights_name=$(echo "$arm_output" | jq -r '.properties.outputs.appinsights_name.value')
appinsights_key=$(az monitor app-insights component show \
    --app "$appinsights_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.instrumentationKey')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "applicationInsightsKey" --value "$appinsights_key"


####################
# LOG ANALYTICS 

echo "Retrieving Log Analytics information from the deployment."
loganalytics_name=$(echo "$arm_output" | jq -r '.properties.outputs.loganalytics_name.value')
loganalytics_id=$(az monitor log-analytics workspace show \
    --workspace-name "$loganalytics_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.customerId')
loganalytics_key=$(az monitor log-analytics workspace get-shared-keys \
    --workspace-name "$loganalytics_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.primarySharedKey')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "logAnalyticsId" --value "$loganalytics_id"
az keyvault secret set --vault-name "$kv_name" --name "logAnalyticsKey" --value "$loganalytics_key"


# ###########################
# # RETRIEVE DATABRICKS INFORMATION AND CONFIGURE WORKSPACE

# Note: SP is required because Credential Passthrough does not support ADF (MSI) as of July 2021
echo "Creating Service Principal (SP) for access to ADLA Gen2 used in Databricks mounting"
stor_id=$(az storage account show \
    --name "$azure_storage_account" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.id')
sp_stor_name="${PROJECT}-stor-${ENV_NAME}-${DEPLOYMENT_ID}-sp"
sp_stor_out=$(az ad sp create-for-rbac \
    --role "Storage Blob Data Contributor" \
    --scopes "$stor_id" \
    --name "$sp_stor_name" \
    --output json)

# store storage service principal details in Keyvault
sp_stor_id=$(echo "$sp_stor_out" | jq -r '.appId')
sp_stor_pass=$(echo "$sp_stor_out" | jq -r '.password')
sp_stor_tenant=$(echo "$sp_stor_out" | jq -r '.tenant')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "spStorName" --value "$sp_stor_name"
az keyvault secret set --vault-name "$kv_name" --name "spStorId" --value "$sp_stor_id"
az keyvault secret set --vault-name "$kv_name" --name "spStorPass" --value "$sp_stor_pass"
az keyvault secret set --vault-name "$kv_name" --name "spStorTenantId" --value "$sp_stor_tenant"

echo "Generate Databricks token"
databricks_host=https://$(echo "$arm_output" | jq -r '.properties.outputs.databricks_output.value.properties.workspaceUrl')
databricks_workspace_resource_id=$(echo "$arm_output" | jq -r '.properties.outputs.databricks_id.value')
databricks_aad_token=$(az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --output json | jq -r .accessToken) # Databricks app global id

# Use AAD token to generate PAT token
databricks_token=$(DATABRICKS_TOKEN=$databricks_aad_token \
    DATABRICKS_HOST=$databricks_host \
    bash -c "databricks tokens create --comment 'deployment'" | jq -r .token_value)

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "databricksDomain" --value "$databricks_host"
az keyvault secret set --vault-name "$kv_name" --name "databricksToken" --value "$databricks_token"
az keyvault secret set --vault-name "$kv_name" --name "databricksWorkspaceResourceId" --value "$databricks_workspace_resource_id"

# Configure databricks (KeyVault-backed Secret scope, mount to storage via SP, databricks tables, cluster)
# NOTE: must use AAD token, not PAT token
export DATABRICKS_AAD_TOKEN=$databricks_aad_token \
DATABRICKS_HOST=$databricks_host \
KEYVAULT_DNS_NAME=$kv_dns_name \
KEYVAULT_RESOURCE_ID=$(echo "$arm_output" | jq -r '.properties.outputs.keyvault_resource_id.value') \
    bash -c "./scripts/deploy_dbricks_artifacts.sh"



####################
# SYNAPSE ANALYTICS

echo "Retrieving Synapse Analytics information from the deployment."
synapseworkspace_name=$(echo "$arm_output" | jq -r '.properties.outputs.synapseworskspace_name.value')
synapse_dev_endpoint=$(az synapse workspace show \
    --name "$synapseworkspace_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.connectivityEndpoints | .dev')

synapse_sql_endpoint=$(az synapse workspace show \
    --name "$synapseworkspace_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.connectivityEndpoints | .sql')    


synapse_sparkpool_name=$(echo "$arm_output" | jq -r '.properties.outputs.synapse_output_spark_pool_name.value')
synapse_sqlpool_name=$(echo "$arm_output" | jq -r '.properties.outputs.synapse_sql_pool_output.value.synapse_pool_name')

# The server name of connection string will be the same as Synapse worspace name
synapse_sqlpool_server=$(echo "$arm_output" | jq -r '.properties.outputs.synapseworskspace_name.value')
synapse_sqlpool_admin_username=$(echo "$arm_output" | jq -r '.properties.outputs.synapse_sql_pool_output.value.username')
synapse_sqlpool_admin_password=$(echo "$arm_output" | jq -r '.properties.outputs.synapse_sql_pool_output.value.password')

# the database name of dedicated sql pool will be the same with dedicated sql pool by default
synapse_dedicated_sqlpool_db_name=$(echo "$arm_output" | jq -r '.properties.outputs.synapse_sql_pool_output.value.synapse_pool_name')


# Synapse Sql Pool Connection String
synapse_sqlpool_connstr_nocred=$(az sql db show-connection-string --client ado.net \
    --name "$synapse_dedicated_sqlpool_db_name" --server "$synapse_sqlpool_server" --output json |
    jq -r .)
synapse_sqlpool_connstr_uname=${synapse_sqlpool_connstr_nocred/<username>/$synapse_sqlpool_admin_username}
synapse_sqlpool_connstr_uname_pass=${synapse_sqlpool_connstr_uname/<password>/$SYNAPSE_SQL_PASSWORD}


# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "synapseWorkspaceName" --value "$synapseworkspace_name"
az keyvault secret set --vault-name "$kv_name" --name "synapseDevEndpoint" --value "$synapse_dev_endpoint"
az keyvault secret set --vault-name "$kv_name" --name "synapseSqlEndpoint" --value "$synapse_sql_endpoint"
az keyvault secret set --vault-name "$kv_name" --name "synapseSparkPoolName" --value "$synapse_sparkpool_name"
az keyvault secret set --vault-name "$kv_name" --name "synapseSqlPoolServer" --value "$synapse_sqlpool_server"
az keyvault secret set --vault-name "$kv_name" --name "synapseSQLPoolAdminUsername" --value "$synapse_sqlpool_admin_username"
az keyvault secret set --vault-name "$kv_name" --name "synapseSQLPoolAdminPassword" --value "$SYNAPSE_SQL_PASSWORD"
az keyvault secret set --vault-name "$kv_name" --name "synapseDedicatedSQLPoolDBName" --value "$synapse_dedicated_sqlpool_db_name"
az keyvault secret set --vault-name "$kv_name" --name "sqldwConnectionString" --value "$synapse_sqlpool_connstr_uname_pass"



# Update Synapse LinkedServices to point to newly Databricks workspace URL
synTempDir=.tmp/synapse
mkdir -p $synTempDir && cp -a synapse/ .tmp/

tmpfile=.tmpfile
synLsDir=$synTempDir/workspace/linkedService
jq --arg kvurl "$kv_dns_name" '.properties.typeProperties.baseUrl = $kvurl' $adfLsDir/Ls_KeyVault_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_KeyVault_01.json
jq --arg datalakeUrl "https://$azure_storage_account.dfs.core.windows.net" '.properties.typeProperties.url = $datalakeUrl' $synLsDir/Ls_AdlsGen2_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AdlsGen2_01.json
jq --arg databricksWorkspaceUrl "$databricks_host" '.properties.typeProperties.domain = $databricksWorkspaceUrl' $synLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AzureDatabricks_01.json
jq --arg databricks_workspace_resource_id "$databricks_workspace_resource_id" '.properties.typeProperties.workspaceResourceId = $databricks_workspace_resource_id' $synLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AzureDatabricks_01.json
jq --arg pbitenantid "${PBI_TENANT_ID}" '.properties.typeProperties.tenantID = $pbitenantid' $synLsDir/Ls_PowerBI_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_PowerBI_01.json
jq --arg pbiworkspaceid "${pbi_ws_id}" '.properties.typeProperties.workspaceID = $pbiworkspaceid' $synLsDir/Ls_PowerBI_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_PowerBI_01.json

synScriptsDir=$synTempDir/workspace/scripts
sed "s/<purview_name>/$purview_name/" \
$synScriptsDir/create_purview_user.sql \
> "$tmpfile" && mv "$tmpfile" $synScriptsDir/create_purview_user.json

# Deploy Synapse artifacts
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
RESOURCE_GROUP_NAME=$resource_group_name \
SYNAPSE_WORKSPACE_NAME=$synapseworkspace_name \
SYNAPSE_DEV_ENDPOINT=$synapse_dev_endpoint \
BIG_DATAPOOL_NAME=$synapse_sparkpool_name \
SQL_POOL_NAME=$synapse_sqlpool_name \
LOG_ANALYTICS_WS_ID=$loganalytics_id \
LOG_ANALYTICS_WS_KEY=$loganalytics_key \
KEYVAULT_NAME=$kv_name \
AZURE_STORAGE_ACCOUNT=$azure_storage_account \
    bash -c "./scripts/deploy_synapse_artifacts.sh"


# SERVICE PRINCIPAL IN SYNAPSE INTEGRATION TESTS
# Synapse SP for integration tests 
 sp_synapse_name="${PROJECT}-syn-${ENV_NAME}-${DEPLOYMENT_ID}-sp"
 sp_synapse_out=$(az ad sp create-for-rbac \
     --skip-assignment \
     --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$resource_group_name/providers/Microsoft.Synapse/workspaces/$synapseworkspace_name" \
     --name "$sp_synapse_name" \
     --output json)
 sp_synapse_id=$(echo "$sp_synapse_out" | jq -r '.appId')
 sp_synapse_pass=$(echo "$sp_synapse_out" | jq -r '.password')
 sp_synapse_tenant=$(echo "$sp_synapse_out" | jq -r '.tenant')

# Set Keyvault secrets
 az keyvault secret set --vault-name "$kv_name" --name "spSynapseName" --value "$sp_synapse_name"
 az keyvault secret set --vault-name "$kv_name" --name "spSynapseId" --value "$sp_synapse_id"
 az keyvault secret set --vault-name "$kv_name" --name "spSynapsePass" --value "$sp_synapse_pass"
 az keyvault secret set --vault-name "$kv_name" --name "spSynapseTenantId" --value "$sp_synapse_tenant"

# Grant Synapse Administrator to this SP so that it can trigger Synapse pipelines
wait_service_principal_creation "$sp_synapse_id"
sp_synapse_object_id=$(az ad sp show --id "$sp_synapse_id" --query "objectId" -o tsv)
assign_synapse_role_if_not_exists "$synapseworkspace_name" "Synapse Administrator" "$sp_synapse_object_id"
assign_synapse_role_if_not_exists "$synapseworkspace_name" "Synapse SQL Administrator" "$sp_synapse_object_id"



####################
# DATA FACTORY

echo "Updating Data Factory LinkedService to point to newly deployed resources (KeyVault and DataLake)."
# Create a copy of the ADF dir into a .tmp/ folder.
adfTempDir=.tmp/adf
mkdir -p $adfTempDir && cp -a adf/ .tmp/

# Update ADF LinkedServices to point to newly deployed Datalake URL, KeyVault URL, and Databricks workspace URL
tmpfile=.tmpfile
adfLsDir=$adfTempDir/linkedService
jq --arg kvurl "$kv_dns_name" '.properties.typeProperties.baseUrl = $kvurl' $adfLsDir/Ls_KeyVault_01.json > "$tmpfile" && mv "$tmpfile" $adfLsDir/Ls_KeyVault_01.json
jq --arg databricksWorkspaceUrl "$databricks_host" '.properties.typeProperties.domain = $databricksWorkspaceUrl' $adfLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $adfLsDir/Ls_AzureDatabricks_01.json
jq --arg databricks_workspace_resource_id "$databricks_workspace_resource_id" '.properties.typeProperties.workspaceResourceId = $databricks_workspace_resource_id' $adfLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $adfLsDir/Ls_AzureDatabricks_01.json
jq --arg datalakeUrl "https://$azure_storage_account.dfs.core.windows.net" '.properties.typeProperties.url = $datalakeUrl' $adfLsDir/Ls_AdlsGen2_01.json > "$tmpfile" && mv "$tmpfile" $adfLsDir/Ls_AdlsGen2_01.json

datafactory_name=$(echo "$arm_output" | jq -r '.properties.outputs.datafactory_name.value')
az keyvault secret set --vault-name "$kv_name" --name "adfName" --value "$datafactory_name"

# Deploy ADF artifacts
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
RESOURCE_GROUP_NAME=$resource_group_name \
DATAFACTORY_NAME=$datafactory_name \
ADF_DIR=$adfTempDir \
    bash -c "./scripts/deploy_adf_artifacts.sh"

# ADF SP for integration tests
sp_adf_name="${PROJECT}-adf-${ENV_NAME}-${DEPLOYMENT_ID}-sp"
sp_adf_out=$(az ad sp create-for-rbac \
    --role "Data Factory contributor" \
    --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$resource_group_name/providers/Microsoft.DataFactory/factories/$datafactory_name" \
    --name "$sp_adf_name" \
    --output json)
sp_adf_id=$(echo "$sp_adf_out" | jq -r '.appId')
sp_adf_pass=$(echo "$sp_adf_out" | jq -r '.password')
sp_adf_tenant=$(echo "$sp_adf_out" | jq -r '.tenant')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "spAdfName" --value "$sp_adf_name"
az keyvault secret set --vault-name "$kv_name" --name "spAdfId" --value "$sp_adf_id"
az keyvault secret set --vault-name "$kv_name" --name "spAdfPass" --value "$sp_adf_pass"
az keyvault secret set --vault-name "$kv_name" --name "spAdfTenantId" --value "$sp_adf_tenant"


####################
# BUILD ENV FILE FROM CONFIG INFORMATION

env_file=".env.${ENV_NAME}"
echo "Appending configuration to .env file."
cat << EOF >> "$env_file"

# ------ Configuration from deployment on ${TIMESTAMP} -----------
RESOURCE_GROUP_NAME=${resource_group_name}
AZURE_LOCATION=${AZURE_LOCATION}
AZURE_STORAGE_ACCOUNT=${azure_storage_account}
AZURE_STORAGE_KEY=${azure_storage_key}
SQL_SERVER_NAME={sql_server_name}
SQL_DATABASE_NAME={sql_database_name}
APPINSIGHTS_KEY=${appinsights_key}
KV_URL=${kv_dns_name}
LOG_ANALYTICS_WS_ID=${loganalytics_id}
DATABRICKS_HOST=${databricks_host}
DATABRICKS_TOKEN=${databricks_token}
SYNAPSE_WORKSPACE_NAME=${synapseworkspace_name}
SYNAPSE_SQLPOOL_SERVER=${synapse_sqlpool_name}
SYNAPSE_SQLPOOL_ADMIN_USERNAME=${synapse_sqlpool_admin_username}
SYNAPSE_DEDICATED_SQLPOOL_DATABASE_NAME=${synapse_dedicated_sqlpool_db_name}
SP_SYNAPSE_ID=${sp_synapse_id}
SP_SYNAPSE_NAME=${sp_synapse_name}
DATAFACTORY_NAME=${datafactory_name}
SP_ADF_NAME=${sp_adf_name}
PURVIEW_NAME="${purview_name}"

EOF
echo "Completed deploying Azure resources $resource_group_name ($ENV_NAME)"
