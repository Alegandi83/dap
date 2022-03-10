#!/bin/bash

echo "Config Purview"

# Retrive account and key
purview_name=$(echo "$arm_output" | jq -r '.properties.outputs.purview_name.value')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "purviewName" --value "$purview_name"