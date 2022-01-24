#!/bin/bash
#####################
# DEPLOY ARM TEMPLATE

export GITHUB_REPO=Alegandi83/modern-data-warehouse-dataops
export GITHUB_PAT_TOKEN=null
export AZURE_SUBSCRIPTION_ID=272f5f06-6693-48ae-975b-b5c7553539c2
export AZURE_LOCATION=westeurope
export ENV_NAME=dev
export SYNAPSE_SQL_PASSWORD=Sql_Adminpswag83!
export DB_SQL_PASSWORD=Sqladminpswag83!
export kv_owner_object_id=20b8fb52-db34-40c0-858a-3024a4dc8bd5
export DEPLOYMENT_ID=00006
export PROJECT=ag83
export resource_group_name="$PROJECT-$DEPLOYMENT_ID-$ENV_NAME-rg"
export PBI_TENANT_ID=0856a07c-daf4-44cf-acd9-12b9ba5ad6f0
export PBI_DAP_USR_MAIL=agandini_microsoft.com#EXT#@agandini.onmicrosoft.com

--------------------------------------------------------------------------------
-- Purview Setup script

.\purview\deploy_purview_artifacts.ps1 -project ag83 -env dev -deployment_id 00004 -tenant_id 72f988bf-86f1-41af-91ab-2d7cd011db47 -subscriptionId /subscriptions/272f5f06-6693-48ae-975b-b5c7553539c2 -resourceGroupName ag83-00004-dev-rg -location westeurope -user_id 20b8fb52-db34-40c0-858a-3024a4dc8bd5 -purview_account ag83pviewdev00004 -vault_uri https://ag83-kv-dev-00004.vault.azure.net/ -admin_login sqladminuserag83 -sql_secret_name Sqladminpswag83! -sql_server_name ag83sqldev00004 -sql_db_name ag83sqldbdev00004 -storage_account_name ag83stdev00004 -adf_name ag83-adf-dev-00004 -adf_principal_id a89db750-6be0-4a2e-80d3-c7b282699ad6 -syn_name ag83-syws-dev-00004 -syn_principal_id 48cfe20f-1a51-45c7-80c7-47f7f5ec7f49 -managed_identity 73ec0606-8f2f-4df3-bbe3-3dbeba209408
.\powerbi\deploy_pbi_artifacts.ps1 -project ag83 -env_name dev -deployment_id 00006 -userEmail agandini_microsoft.com#EXT#@agandini.onmicrosoft.com

$project = "ag83" 
$env = "dev" 
$deployment_id = "00004"
$tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"
$subscriptionId = "/subscriptions/272f5f06-6693-48ae-975b-b5c7553539c2"
$user_id = "20b8fb52-db34-40c0-858a-3024a4dc8bd5"
$resourceGroupName = "ag83-00004-dev-rg"
$location = "westeurope"
$purview_account = "ag83pviewdev00004"
$vault_name = "ag83-kv-dev-00004"
$vault_uri = "https://ag83-kv-dev-00004.vault.azure.net/"
$sql_server_name = "ag83sqldev00004"
$sql_db_name = "ag83sqldbdev00004"
$admin_login = "sqladminuserag83"
$sql_secret_name = "Sqladminpswag83!"
$storage_account_name = "ag83stdev00004"
$managed_identity = "73ec0606-8f2f-4df3-bbe3-3dbeba209408"
$adf_principal_id = "a89db750-6be0-4a2e-80d3-c7b282699ad6"
$syn_name = "sywsdev00004"


$scan_endpoint = "https://${purview_account}.scan.purview.azure.com"
$catalog_endpoint = "https://${purview_account}.catalog.purview.azure.com"
$pv_endpoint = "https://${purview_account}.purview.azure.com"
$pv_service_principal_name = "${project}-pview-${env}-${deployment_id}-sp"

Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

