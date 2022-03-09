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

# Set account to where ARM template will be deployed to
echo "Deploying to Subscription: $AZURE_SUBSCRIPTION_ID"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# PLATFORM LAYER ---------------------------------------------------------------

# Deploy Platform Layer - Azure
. ./platform_layer/azure/deploy_platform.sh

# Deploy Platform Layer - onPrem
. ./platform_layer/onprem/deploy_platform.sh


# APPLICATION LAYER ------------------------------------------------------------

# Deploy Application Layer - Parking Sensor
. ./application_layer/parking_sensor/deploy_application.sh

# Deploy Application Layer - Healthcare Information Protection
. ./application_layer/healthcare_infoProtection/deploy_application.sh

# Deploy Application Layer - Temperature Events - TODO 
#. ./application_layer/temperature_events/deploy_application.sh