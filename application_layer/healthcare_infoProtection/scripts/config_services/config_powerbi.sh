#!/bin/bash

echo "Config PowerBI"

# Retrieve info from KeyVault
pbi_ws_name=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsname" --query value -o tsv)
syn_db_name=$(az keyvault secret show --vault-name "$kv_name" --name "synapseDedicatedSQLPoolDBName" --query value -o tsv)
syn_endpoint=$(az keyvault secret show --vault-name "$kv_name" --name "synapseSqlEndpoint" --query value -o tsv)

# Import PowerBI Reports and Update related Datasets
pwsh ./powerbi/scripts/deploy_pbi_app.ps1 -workspaceName ${pbi_ws_name} -synEndpoint ${syn_db_name} -synDbName ${syn_endpoint}
