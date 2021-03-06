param(
    [string]$workspaceName,
    [string]$datasetName,
    [string]$sqlDatabaseServer,
    [string]$sqlDatabaseName
)

Write-Host "Start PowerBI Update Dataset"
Write-Host "workspaceName: " $workspaceName
Write-Host "datasetName: " $datasetName
Write-Host "sqlDatabaseServer: " $sqlDatabaseServer
Write-Host "sqlDatabaseName: " $sqlDatabaseName


# get object for target workspace
$workspace = Get-PowerBIWorkspace -Name $workspaceName

# get object for new dataset
$dataset = Get-PowerBIDataset -WorkspaceId $workspace.Id | Where-Object Name -eq $datasetName

# get object for new SQL datasource
$datasource = Get-PowerBIDatasource -WorkspaceId $workspace.Id -DatasetId $dataset.Id

# parse REST to determine gateway Id and datasource Id
$workspaceId = $workspace.Id
$datasetId = $dataset.Id
$datasourceUrl = "groups/$workspaceId/datasets/$datasetId/datasources"

# execute REST call to determine gateway Id, datasource Id and current connection details
$datasourcesResult = Invoke-PowerBIRestMethod -Method Get -Url $datasourceUrl | ConvertFrom-Json

# parse REST URL used to patch datasource credentials
$datasource = $datasourcesResult.value[0]
$gatewayId = $datasource.gatewayId
$datasourceId = $datasource.datasourceId
$sqlDatabaseServerCurrent = $datasource.connectionDetails.server
$sqlDatabaseNameCurrent = $datasource.connectionDetails.database

# parse together REST Url to update connection details
$datasourePatchUrl = "groups/$workspaceId/datasets/$datasetId/Default.UpdateDatasources"

# create HTTP request body to update datasource connection details
$postBody = @{
  "updateDetails" = @(
   @{
    "connectionDetails" = @{
      "server" = "$sqlDatabaseServer"
      "database" = "$sqlDatabaseName"
    }
    "datasourceSelector" = @{
      "datasourceType" = "Sql"
      "connectionDetails" = @{
        "server" = "$sqlDatabaseServerCurrent"
        "database" = "$sqlDatabaseNameCurrent"
      }
      "gatewayId" = "$gatewayId"
      "datasourceId" = "$datasourceId"
    }
  })
}

# convert body contents to JSON
$postBodyJson = ConvertTo-Json -InputObject $postBody -Depth 6 -Compress

# execute POST operation to update datasource connection details
Invoke-PowerBIRestMethod -Method Post -Url $datasourePatchUrl -Body $postBodyJson

# NOTE: dataset credentials must be reset after updating connection details

Write-Host "End PowerBI Update Dataset"