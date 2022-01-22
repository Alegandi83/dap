#!/usr/bin/env bash

# Configure az devops cli
az devops configure --defaults organization="$AZDO_ORGANIZATION_URL" project="$AZDO_PROJECT"

# Install requirements depending if devcontainer was openned at root or in parking_sensor folder.
if [ -f "../platform_layer/src/ddo_transform/requirements_dev.txt" ]; then
    pip install -r ../platform_layer/src/ddo_transform/requirements_dev.txt
elif [ -f "platform_layer/src/ddo_transform/requirements_dev.txt" ]; then
    pip install -r platform_layer/src/ddo_transform/requirements_dev.txt
fi
