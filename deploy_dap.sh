#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo Start dap deploy
 
export resource_group_name="$PROJECT-$DEPLOYMENT_ID-$ENV_NAME-rg"

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