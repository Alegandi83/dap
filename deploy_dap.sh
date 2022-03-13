#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Connect to Azure 
echo "Connect to Azure"
az login

# Set Resource Group name 
export ENV_NAME=dev
export resource_group_name="$PROJECT-$DEPLOYMENT_ID-$ENV_NAME-rg"

# Set PowerBI workspace name
export pbi_ws_name="$PROJECT-$DEPLOYMENT_ID-$ENV_NAME-ws"

# Set account to where ARM template will be deployed to
echo "Deploying to Subscription: $AZURE_SUBSCRIPTION_ID"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# By default, set all KeyVault permission to deployer
# Retrieve KeyVault User Id
export kv_owner_object_id=$(az ad signed-in-user show --output json | jq -r '.objectId')


# PLATFORM LAYER --------------------------------------------------------------- 

# Deploy Platform Layer - onPrem
echo "Deploy Platform Layer - onPrem"
pushd platform_layer/onprem
./deploy_platform.sh
popd

# Deploy Platform Layer - Azure
echo "Deploy Platform Layer - Azure"
pushd platform_layer/azure
./deploy_platform.sh
popd


# APPLICATION LAYER ------------------------------------------------------------ 

# Deploy Application Layer - Parking Sensor
echo "Deploy Application Layer - Parking Sensor"
pushd application_layer/parking_sensor
. ./deploy_application.sh
popd

# Deploy Application Layer - Healthcare Information Protection
echo "Deploy Application Layer - Healthcare Information Protection"
pushd application_layer/healthcare_infoProtection
./deploy_application.sh
popd

# Deploy Application Layer - Temperature Events - TODO 
echo "Deploy Application Layer - Temperature Events"
pushd application_layer/temperature_events
#./deploy_application.sh
popd