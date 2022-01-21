#!/bin/bash

# Create folders for SQL external tables
az storage fs directory create -n '/data/dw/fact_parking' -f $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"
az storage fs directory create -n '/data/dw/dim_st_marker' -f $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"
az storage fs directory create -n '/data/dw/dim_parking_bay' -f $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"
az storage fs directory create -n '/data/dw/dim_location' -f $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key"

echo "Uploading seed data to data/seed"
az storage blob upload --container-name $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key" \
    --file data/seed/dim_date.csv --name "data/dim_date/dim_date.csv"
az storage blob upload --container-name $storage_file_system --account-name "$azure_storage_account" --account-key "$azure_storage_key" \
    --file data/seed/dim_time.csv --name "data/dim_time/dim_time.csv"