#!/bin/bash

echo "Start create host SQL Server Tables"
# create tables
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -Q "DROP DATABASE IF EXISTS hpi"
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -Q "CREATE DATABASE hpi"
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createSchema_hpi.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Campaign_Analytics_New.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Campaign_Analytics.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Healthcare-FactSales.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_HospitalEmpPIIData.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Mkt_CampaignAnalyticsLatest.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_PatientInformation.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_RoleNew.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_ControlTableForTemplate.sql

echo "Start load host SQL Server Tables"
# load tables
# TODO - modificare script TSQL bulk insert perchè hanno path cablato
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_Campaign_Analytics_New.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_Campaign_Analytics.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_Healthcare-FactSales.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_HospitalEmpPIIData.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_Mkt_CampaignAnalyticsLatest.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_PatientInformation.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_RoleNew.sql
sqlcmd -S "host.docker.internal,1433" -U SA -P ${HOST_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_ControlTableForTemplate.sql

echo "Completed host SQL Server Tables deploy"