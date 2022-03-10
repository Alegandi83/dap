#!/bin/bash


#set -o errexit
#set -o pipefail
#set -o nounset
# set -o xtrace # For debugging

. ./scripts/utils/common.sh
. ./scripts/utils/verify_prerequisites.sh
. ./scripts/utils/init_environment.sh


github_repo_url="https://github.com/$GITHUB_REPO"


# Create resource group
echo "Creating resource group: $resource_group_name"
az group create --name "$resource_group_name" --location "$AZURE_LOCATION" --tags Environment="$ENV_NAME" 


# Validate arm template
echo "Validating deployment"
arm_out=$(az deployment group validate \
    --resource-group "$resource_group_name" \
    --template-file "./infrastructure/main.bicep" \
    --parameters @"./infrastructure/main.parameters.${ENV_NAME}.json" \
    --parameters project="${PROJECT}" keyvault_owner_object_id="${kv_owner_object_id}" deployment_id="${DEPLOYMENT_ID}" synapse_sqlpool_admin_password="${SYNAPSE_SQL_PASSWORD}" sql_administrator_Password="${DB_SQL_PASSWORD}" pbi_tenant_id="${PBI_TENANT_ID}" pbi_ws_name="${pbi_ws_name}"\
    --output json)

# Deploy arm template
echo "Deploying resources into $resource_group_name"
arm_out=$(az deployment group create \
    --resource-group "$resource_group_name" \
    --template-file "./infrastructure/main.bicep" \
    --parameters @"./infrastructure/main.parameters.${ENV_NAME}.json" \
    --parameters project="${PROJECT}" deployment_id="${DEPLOYMENT_ID}" keyvault_owner_object_id="${kv_owner_object_id}" synapse_sqlpool_admin_password="${SYNAPSE_SQL_PASSWORD}" sql_administrator_Password="${DB_SQL_PASSWORD}" pbi_tenant_id="${PBI_TENANT_ID}" pbi_ws_name="${pbi_ws_name}"\
    --output json)

if [[ -z $arm_output ]]; then
    echo >&2 "ARM deployment failed."
    exit 1
fi

# Set global variable for next steps
export arm_output=${arm_out}
export kv_name=$(echo "$arm_output" | jq -r '.properties.outputs.keyvault_name.value')


# Services Configuration
./scripts/config_services/config_keyvault.sh
./scripts/config_services/config_storage.sh
./scripts/config_services/config_powerbi.sh
./scripts/config_services/config_purview.sh
./scripts/config_services/config_sql.sh
./scripts/config_services/config_app_insights.sh
./scripts/config_services/config_log_analytics.sh
./scripts/config_services/config_databricks.sh
./scripts/config_services/config_synapse.sh
./scripts/config_services/config_datafactory.sh





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


# CONFIRM DEPLOYMENT SUCCESSFUL
print_style "DEPLOYMENT SUCCESSFUL
Details of the deployment can be found in local .env.* files.\n\n" "success"

echo "See README > Setup and Deployment for more details and next steps." 

