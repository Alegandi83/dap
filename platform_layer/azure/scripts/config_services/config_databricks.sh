#!/bin/bash

echo "Config Databricks"

# RETRIEVE DATABRICKS INFORMATION AND CONFIGURE WORKSPACE

# Retrieve info from KeyVault
azure_storage_account=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)

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

#export DATABRICKS_AAD_TOKEN=$databricks_aad_token \
#DATABRICKS_HOST=$databricks_host \
#KEYVAULT_DNS_NAME=$kv_dns_name \
#KEYVAULT_RESOURCE_ID=$(echo "$arm_output" | jq -r '.properties.outputs.keyvault_resource_id.value') \
#    bash -c "./scripts/deploy_dbricks_artifacts.sh"