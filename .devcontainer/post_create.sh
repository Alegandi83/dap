#!/bin/bash
 
# Configure az devops cli
az devops configure --defaults organization="$AZDO_ORGANIZATION_URL" project="$AZDO_PROJECT"

# Install Powershell MicrosoftPowerBIMgmt Module
# https://martinschoombee.com/2020/09/22/automating-power-bi-deployments-connecting-to-the-service/
pwsh -Command Install-Module -Name MicrosoftPowerBIMgmt -Force

# Install Powershell Az Module
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-7.3.0
pwsh -Command Install-Module -Name Az -Force

# Install requirements depending if devcontainer was openned at root or in parking_sensor folder.
if [ -f "../platform_layer/src/ddo_transform/requirements_dev.txt" ]; then
    pip install -r ../platform_layer/src/ddo_transform/requirements_dev.txt
elif [ -f "platform_layer/src/ddo_transform/requirements_dev.txt" ]; then
    pip install -r platform_layer/src/ddo_transform/requirements_dev.txt
fi