#-- SQL Server installed onPrem
sqlcmd -S localhost,1433 -U SA -P 'Spacecow_83'
sqlcmd -S localhost,1433 -i ./sqlServer/createTables/createTable_PatientInformation.sql -o ./output.txt

#-- SQL Server Docker Container

# docker-in-docker overview
# https://devopscube.com/run-docker-in-docker/

# https://docs.microsoft.com/it-it/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&preserve-view=true&pivots=cs1-powershell
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Sqladminpswag83!' -p 1533:1433 --name sql1 -d mcr.microsoft.com/mssql/server:2019-latest
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -Q "DROP DATABASE IF EXISTS hpi"
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -Q "CREATE DATABASE hpi"
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createSchema_hpi.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_Campaign_Analytics_New.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_Campaign_Analytics.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_Healthcare-FactSales.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_HospitalEmpPIIData.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_Mkt_CampaignAnalyticsLatest.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_PatientInformation.sql
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!' -i ./sqlServer/createTables/createTable_RoleNew.sql


# Psw Change
docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U SA -P 'Sqladminpswag83!' `
  -Q 'ALTER LOGIN SA WITH PASSWORD='Sqladminpswag22!''

# Connection inside container
docker exec -it sql1 "bash" 
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P Sqladminpswag83!

# Connection outside container
ipconfig
sqlcmd -S localhost,1533 -U SA -P 'Sqladminpswag83!'

# Stop container
docker stop sql1
docker rm sql1

# Monitoring  
docker ps -a

SELECT @@SERVERNAME,
    SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
    SERVERPROPERTY('MachineName'),
    SERVERPROPERTY('ServerName')

az keyvault secret set --vault-name ag83-kv-dev-00004 --name "sqlConnectionString" --value "Sqladminpswag83!"