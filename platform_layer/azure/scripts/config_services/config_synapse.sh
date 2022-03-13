#!/bin/bash

echo "Config Synapse"


# Retrieve info from KeyVault
echo "Retrieve info from KeyVault"
azure_storage_account=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)
kv_dns_name=$(az keyvault secret show --vault-name "$kv_name" --name "kvUrl" --query value -o tsv)
databricks_host=$(az keyvault secret show --vault-name "$kv_name" --name "databricksDomain" --query value -o tsv)
databricks_workspace_resource_id=$(az keyvault secret show --vault-name "$kv_name" --name "databricksWorkspaceResourceId" --query value -o tsv)
pbi_ws_id=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsid" --query value -o tsv)
purview_name=$(az keyvault secret show --vault-name "$kv_name" --name "purviewName" --query value -o tsv)

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
az keyvault secret set --vault-name "$kv_name" --name "synapseSqlPoolName" --value "$synapse_sqlpool_name"
az keyvault secret set --vault-name "$kv_name" --name "synapseSparkPoolName" --value "$synapse_sparkpool_name"
az keyvault secret set --vault-name "$kv_name" --name "synapseSqlPoolServer" --value "$synapse_sqlpool_server"
az keyvault secret set --vault-name "$kv_name" --name "synapseSQLPoolAdminUsername" --value "$synapse_sqlpool_admin_username"
az keyvault secret set --vault-name "$kv_name" --name "synapseSQLPoolAdminPassword" --value "$SYNAPSE_SQL_PASSWORD"
az keyvault secret set --vault-name "$kv_name" --name "synapseDedicatedSQLPoolDBName" --value "$synapse_dedicated_sqlpool_db_name"
az keyvault secret set --vault-name "$kv_name" --name "sqldwConnectionString" --value "$synapse_sqlpool_connstr_uname_pass"



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


 # Update Synapse LinkedServices to point to newly Databricks workspace URL
synTempDir=.tmp/synapse
mkdir -p $synTempDir && cp -a synapse/ .tmp/

tmpfile=.tmpfile
synLsDir=$synTempDir/linkedService
jq --arg kvurl "$kv_dns_name" '.properties.typeProperties.baseUrl = $kvurl' $synLsDir/Ls_KeyVault_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_KeyVault_01.json
jq --arg datalakeUrl "https://$azure_storage_account.dfs.core.windows.net" '.properties.typeProperties.url = $datalakeUrl' $synLsDir/Ls_AdlsGen2_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AdlsGen2_01.json
jq --arg databricksWorkspaceUrl "$databricks_host" '.properties.typeProperties.domain = $databricksWorkspaceUrl' $synLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AzureDatabricks_01.json
jq --arg databricks_workspace_resource_id "$databricks_workspace_resource_id" '.properties.typeProperties.workspaceResourceId = $databricks_workspace_resource_id' $synLsDir/Ls_AzureDatabricks_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_AzureDatabricks_01.json
jq --arg pbitenantid "${PBI_TENANT_ID}" '.properties.typeProperties.tenantID = $pbitenantid' $synLsDir/Ls_PowerBI_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_PowerBI_01.json
jq --arg pbiworkspaceid "${pbi_ws_id}" '.properties.typeProperties.workspaceID = $pbiworkspaceid' $synLsDir/Ls_PowerBI_01.json > "$tmpfile" && mv "$tmpfile" $synLsDir/Ls_PowerBI_01.json

synScriptsDir=$synTempDir/sqlscript
sed "s/<purview_name>/$purview_name/" \
$synScriptsDir/setup/create_purview_user.sql \
> "$tmpfile" && mv "$tmpfile" $synScriptsDir/create_purview_user.json