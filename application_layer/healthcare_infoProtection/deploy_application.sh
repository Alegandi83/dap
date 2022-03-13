#!/bin/bash 

# Retrieve KeyVault information
echo "Retrieving KeyVault information from the deployment."
export kv_name="$PROJECT-kv-$ENV_NAME-$DEPLOYMENT_ID"
export kv_dns_name=$(az keyvault secret show --vault-name "$kv_name" --name "kvUrl" --query value -o tsv)


# Services Configuration
./scripts/config_services/config_powerbi.sh


# Deploy Artifacts
#./scripts/deploy_artifacts/deploy_hostDataSources.sh
./scripts/deploy_artifacts/deploy_dockDataSources.sh
./scripts/deploy_artifacts/deploy_adf_artifacts.sh
./scripts/deploy_artifacts/deploy_synapse_artifacts.sh
