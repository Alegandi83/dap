#!/bin/bash

echo "Config Log Analytics"

echo "Retrieving Log Analytics information from the deployment."
loganalytics_name=$(echo "$arm_output" | jq -r '.properties.outputs.loganalytics_name.value')
loganalytics_id=$(az monitor log-analytics workspace show \
    --workspace-name "$loganalytics_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.customerId')
loganalytics_key=$(az monitor log-analytics workspace get-shared-keys \
    --workspace-name "$loganalytics_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.primarySharedKey')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "logAnalyticsName" --value "$loganalytics_name"
az keyvault secret set --vault-name "$kv_name" --name "logAnalyticsId" --value "$loganalytics_id"
az keyvault secret set --vault-name "$kv_name" --name "logAnalyticsKey" --value "$loganalytics_key"