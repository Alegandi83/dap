#!/bin/bash

echo "Config Storage"

# Retrieve info from KeyVault
datalakeAccountName=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeAccountName" --query value -o tsv)
datalakeAccountKey=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeKey" --query value -o tsv)
datalakeContainerName=$(az keyvault secret show --vault-name "$kv_name" --name "datalakeContainerName" --query value -o tsv)


# Create folders for SQL external tables
echo "Create Folders"
az storage fs directory create -n '/data/dw/fact_parking' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_st_marker' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_parking_bay' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"
az storage fs directory create -n '/data/dw/dim_location' -f $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey"


# Upload seed data
echo "Uploading seed data to data/seed"
az storage blob upload --container-name $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey" \
    --file data/dim_date.csv --name "data/seed/dim_date/dim_date.csv"
az storage blob upload --container-name $datalakeContainerName --account-name "$datalakeAccountName" --account-key "$datalakeAccountKey" \
    --file data/dim_time.csv --name "data/seed/dim_time/dim_time.csv"