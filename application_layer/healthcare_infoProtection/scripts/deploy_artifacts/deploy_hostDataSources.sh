#!/bin/bash

# create tables
sqlcmd -S localhost,1433 -Q "DROP DATABASE IF EXISTS hpi"
sqlcmd -S localhost,1433 -Q "CREATE DATABASE hpi"
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createSchema_hpi.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_Campaign_Analytics_New.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_Campaign_Analytics.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_Healthcare-FactSales.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_HospitalEmpPIIData.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_Mkt_CampaignAnalyticsLatest.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_PatientInformation.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_RoleNew.sql
sqlcmd -S localhost,1433 -i ../sqlServer/createTables/createTable_ControlTableForTemplate.sql

# load tables
# TODO - modificare script TSQL bulk insert perchè hanno path cablato
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_Campaign_Analytics_New.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_Campaign_Analytics.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_Healthcare-FactSales.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_HospitalEmpPIIData.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_Mkt_CampaignAnalyticsLatest.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_PatientInformation.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_RoleNew.sql
sqlcmd -S localhost,1433 -i ../sqlServer/loadTables/loadTable_ControlTableForTemplate.sql