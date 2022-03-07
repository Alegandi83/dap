#!/bin/bash 


set -o errexit
set -o pipefail
set -o nounset

# Retrieve KeyVault information
echo "Retrieving KeyVault information from the deployment."
export kv_name="$PROJECT-kv-$ENV_NAME-$DEPLOYMENT_ID"
export kv_dns_name=https://${kv_name}.vault.azure.net/


# DATA SOURCES
. ./scripts/deploy_dockDataSources.sh

# POWER BI  

# Retrieve info from KeyVault
pbi_ws_name=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsname" --query value -o tsv)
syn_db_name=$(az keyvault secret show --vault-name "$kv_name" --name "synapseDedicatedSQLPoolDBName" --query value -o tsv)
syn_endpoint=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSqlEndpoint" --query value -o tsv)

# Import PowerBI Reports and Update related Datasets
pwsh ./powerbi/scripts/deploy_pbi_app.ps1 -workspaceName ${pbi_ws_name} -synEndpoint ${syn_db_name} -synDbName ${syn_endpoint}


# ADF

# SYNAPSE
# Update Synapse LinkedServices to point to newly Databricks workspace URL
synTempDir=.tmp/synapse
mkdir -p $synTempDir && cp -a synapse/ .tmp/