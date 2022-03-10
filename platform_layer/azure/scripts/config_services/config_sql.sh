#!/bin/bash

echo "Config SQL"

# Retrive account and key
sql_server_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_server_name.value')
sql_database_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_database_name.value')
sql_admin_name=$(echo "$arm_output" | jq -r '.properties.outputs.sql_admin_name.value')

# Sql Pool Connection String
sql_connstr_nocred=$(az sql db show-connection-string --client ado.net \
    --name "$sql_database_name" --server "$sql_server_name" --output json |
    jq -r .)
sql_connstr_uname=${sql_connstr_nocred/<username>/$sql_admin_name}
sql_connstr_uname_pass=${sql_connstr_uname/<password>/$DB_SQL_PASSWORD}

# Set Keyvault secrets
az keyvault secret set --vault-name "$kv_name" --name "sqlServerName" --value "$sql_server_name"
az keyvault secret set --vault-name "$kv_name" --name "sqlDatabaseName" --value "$sql_database_name"
az keyvault secret set --vault-name "$kv_name" --name "sqlConnectionString" --value "$sql_connstr_uname_pass"
az keyvault secret set --vault-name "$kv_name" --name "sqlDatabasePsw" --value "$DB_SQL_PASSWORD"