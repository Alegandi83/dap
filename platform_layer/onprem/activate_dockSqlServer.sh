#!/bin/bash

# docker-in-docker overview
# https://devopscube.com/run-docker-in-docker/

# SQL Server Docker Container
# https://docs.microsoft.com/it-it/sql/linux/quickstart-install-connect-docker?view=sql-server-ver15&preserve-view=true&pivots=cs1-powershell
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD='${SQLSERVER_PASSWORD} -p 1533:1433 -v ${DAP_PROJECT_PATH}/application_layer/healthcare_infoProtection/data:/my_dap_data --name sql1 -d mcr.microsoft.com/mssql/server:2019-latest