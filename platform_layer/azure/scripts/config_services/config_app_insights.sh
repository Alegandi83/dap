#!/bin/bash

echo "Config App Insights"

echo "Retrieving ApplicationInsights information from the deployment."
appinsights_name=$(echo "$arm_output" | jq -r '.properties.outputs.appinsights_name.value')
appinsights_key=$(az monitor app-insights component show \
    --app "$appinsights_name" \
    --resource-group "$resource_group_name" \
    --output json |
    jq -r '.instrumentationKey')

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "applicationInsightsName" --value "$appinsights_name"
az keyvault secret set --vault-name "$kv_name" --name "applicationInsightsKey" --value "$appinsights_key"