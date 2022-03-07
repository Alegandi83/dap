#!/bin/bash

# create tables
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD}
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -Q "DROP DATABASE IF EXISTS hpi"
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -Q "CREATE DATABASE hpi"
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createSchema_hpi.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_Campaign_Analytics_New.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_Campaign_Analytics.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_Healthcare-FactSales.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_HospitalEmpPIIData.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_Mkt_CampaignAnalyticsLatest.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_PatientInformation.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/createTables/createTable_RoleNew.sql

# load tables
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_Campaign_Analytics_New.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_Campaign_Analytics.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_Healthcare-FactSales.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_HospitalEmpPIIData.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_Mkt_CampaignAnalyticsLatest.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_PatientInformation.sql
mssql-cli -S "host.docker.internal,1533" -U SA -P ${SQLSERVER_PASSWORD} -i ../sqlServer/loadTables/loadTable_RoleNew.sql
