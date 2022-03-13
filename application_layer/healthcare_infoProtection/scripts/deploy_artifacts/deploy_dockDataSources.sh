#!/bin/bash

# following command is for interactive cli:
#mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD}

echo "Start create dock SQL Server Tables"
# create tables
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -Q "DROP DATABASE IF EXISTS hpi"
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -Q "CREATE DATABASE hpi"
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createSchema_hpi.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Campaign_Analytics_New.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Campaign_Analytics.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Healthcare-FactSales.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_HospitalEmpPIIData.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_Mkt_CampaignAnalyticsLatest.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_PatientInformation.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_RoleNew.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/createTables/createTable_ControlTableForTemplate.sql

echo "Start load dock SQL Server Tables"
# load tables
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_Campaign_Analytics_New.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_Campaign_Analytics.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_Healthcare-FactSales.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_HospitalEmpPIIData.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_Mkt_CampaignAnalyticsLatest.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_PatientInformation.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/dock_loadTables/loadTable_RoleNew.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${DOCK_SQLSERVER_PASSWORD} -i ./sqlServer/host_loadTables/loadTable_ControlTableForTemplate.sql

echo "Completed dock SQL Server Tables deploy"