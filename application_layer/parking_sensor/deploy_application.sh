#!/bin/bash

# Retrieve KeyVault information
echo "Retrieving KeyVault information from the deployment."
export kv_name="$PROJECT-kv-$ENV_NAME-$DEPLOYMENT_ID"
export kv_dns_name=https://${kv_name}.vault.azure.net/


# STORAGE 

# Retrieve info from KeyVault
datalakeAccountName=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)
datalakeAccountKey=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeKey" --query value -o tsv)
datalakeContainerName=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeContainerName" --query value -o tsv)


# Create folders for SQL external tables
az storage fs directory create -n '/data/dw/fact_parking' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_st_marker' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_parking_bay' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_location' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"

echo "Uploading seed data to data/seed"
az storage blob upload --container-name $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey" \
    --file data/seed/dim_date.csv --name "data/dim_date/dim_date.csv"
az storage blob upload --container-name $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey" \
    --file data/seed/dim_time.csv --name "data/dim_time/dim_time.csv"


# POWER BI 

# Retrieve info from KeyVault
pbi_ws_name=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsname" --query value -o tsv)
syn_db_name=$(az keyvault secret show --vault-name "$kv_name" --name "synapseDedicatedSQLPoolDBName" --query value -o tsv)
syn_sql_endpoint=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSqlEndpoint" --query value -o tsv)


# Import PowerBI Reports and Update related Datasets
pwsh ./powerbi/scripts/deploy_pbi_app.ps1 -workspaceName ${pbi_ws_name} -synEndpoint ${syn_db_name} -synDbName ${syn_sql_endpoint}


# SYNAPSE

# Retrieve info from KeyVault
ADLSLocation="abfss://datalake@${datalakeAccountName}.dfs.core.windows.net"
syn_ws_name=$(az keyvault secret show --vault-name "$kv_name" --name "synapseWorkspaceName" --query value -o tsv)
syn_sql_usr=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSQLPoolAdminUsername" --query value -o tsv)
syn_sql_psw=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSQLPoolAdminPassword" --query value -o tsv)
syn_dev_endpoint=$(az keyvault secret show --vault-name "$kv_name" --name "synapseDevEndpoint" --query value -o tsv)
syn_spark_name=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSparkPoolName" --query value -o tsv)
loganalytics_id=$(az keyvault secret show --vault-name "$kv_name" --name "logAnalyticsId" --query value -o tsv)
loganalytics_key=$(az keyvault secret show --vault-name "$kv_name" --name "logAnalyticsKey" --query value -o tsv)

# Deploy DACPAC on Synapse
# https://docs.microsoft.com/it-it/sql/tools/sqlpackage/sqlpackage-publish?view=sql-server-ver15
sqlpackage /Action:Publish /SourceFile:"./sql/ddo_azuresqldw_dw/ddo_azuresqldw_dw/bin/Debug/ddo_azuresqldw_dw.dacpac" /TargetDatabaseName:${syn_db_name} /TargetServerName:${syn_sql_endpoint} /TargetUser:${syn_sql_usr} /TargetPassword:${syn_sql_psw} /Variables:ADLSCredentialKey=${datalakeAccountKey} /Variables:ADLSLocation=${ADLSLocation}


# Update Synapse LinkedServices to point to newly Databricks workspace URL
synTempDir=.tmp/synapse
mkdir -p $synTempDir && cp -a synapse/ .tmp/

# Deploy Synapse artifacts
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
RESOURCE_GROUP_NAME=$resource_group_name \
SYNAPSE_WORKSPACE_NAME=$syn_ws_name \
SYNAPSE_DEV_ENDPOINT=$syn_dev_endpoint \
BIG_DATAPOOL_NAME=$syn_spark_name \
SQL_POOL_NAME=$syn_db_name \
LOG_ANALYTICS_WS_ID=$loganalytics_id \              
LOG_ANALYTICS_WS_KEY=$loganalytics_key \
KEYVAULT_NAME=$kv_name \
AZURE_STORAGE_ACCOUNT=$datalakeAccountName \
    bash -c "./scripts/deploy_synapse_artifacts.sh"