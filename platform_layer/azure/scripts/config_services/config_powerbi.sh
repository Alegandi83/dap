#!/bin/bash

echo "Config PowerBI"

# Create PowerBI workspace
pwsh ./powerbi/deploy_pbi_artifacts.ps1 -kvName ${kv_name} -workspaceName ${pbi_ws_name} -userEmail ${PBI_DAP_USR_MAIL}

# Retrieve PowerBI workspace id
pbi_ws_id=$(az keyvault secret show --vault-name "$kv_name" --name "pbiwsid" --query value -o tsv)