#!/bin/bash

echo "Config keyVault"


kv_dns_name=https://${kv_name}.vault.azure.net/
 

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "kvUrl" --value "$kv_dns_name"
az keyvault secret set --vault-name "$kv_name" --name "subscriptionId" --value "$AZURE_SUBSCRIPTION_ID"