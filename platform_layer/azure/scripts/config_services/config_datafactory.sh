#!/bin/bash

echo "Config Data Factory"


# Retrieve info from KeyVault
echo "Retrieve info from KeyVault"
azure_storage_account=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)
kv_dns_name=$(az keyvault secret show --vault-name "$kv_name" --name "kvUrl" --query value -o tsv)
databricks_host=$(az keyvault secret show --vault-name "$kv_name" --name "databricksDomain" --query value -o tsv)
databricks_workspace_resource_id=$(az keyvault secret show --vault-name "$kv_name" --name "databricksWorkspaceResourceId" --query value -o tsv)


datafactory_name=$(echo "$arm_output" | jq -r '.properties.outputs.datafactory_name.value')

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
az keyvault secret set --vault-name "$kv_name" --name "adfName" --value "$datafactory_name"
az keyvault secret set --vault-name "$kv_name" --name "spAdfName" --value "$sp_adf_name"
az keyvault secret set --vault-name "$kv_name" --name "spAdfId" --value "$sp_adf_id"
az keyvault secret set --vault-name "$kv_name" --name "spAdfPass" --value "$sp_adf_pass"
az keyvault secret set --vault-name "$kv_name" --name "spAdfTenantId" --value "$sp_adf_tenant"


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