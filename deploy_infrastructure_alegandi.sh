# Useful variables
export ENV_NAME=dev
export kv_owner_object_id=20b8fb52-db34-40c0-858a-3024a4dc8bd5
export DEPLOYMENT_ID=00008
export kv_name="ag83-kv-dev-00008"



#--------------------------------------------------------------------------------
# Purview Setup script

Connect-AzAccount -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47

#--------------------------------------------------------------------------------
# Docked SQL Server commands

# show databases
SELECT name, database_id, create_date FROM sys.databases; GO

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