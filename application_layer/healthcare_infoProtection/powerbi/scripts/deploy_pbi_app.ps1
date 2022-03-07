param(
    [string]$workspaceName,
    [string]$synEndpoint,
    [string]$synDbName
)

Write-Host "Start PowerBI Deploy"
Write-Host "workspaceName: " $workspaceName
Write-Host "synEndpoint: " $synEndpoint
Write-Host "synDbName: " $synDbName
Write-Host "PSScriptRoot: " $PSScriptRoot

# Connect to Power BI
Connect-PowerBIServiceAccount | Out-Null


$datasetName = "1 HealthCare DDM"
$pbixFilePath = "/workspace/application_layer/healthcare_infoProtection/powerbi/reports/$datasetName.pbix"
./powerbi/scripts/deploy_pbi_reports.ps1 -workspaceName ${workspaceName} -pbixFilePath ${pbixFilePath}
./powerbi/scripts/update_pbi_dataset.ps1 -workspaceName ${workspaceName} -datasetName ${datasetName} -sqlDatabaseServer ${synEndpoint} -sqlDatabaseName ${synDbName}

$datasetName = "2 HealthCare RLS"
$pbixFilePath = "/workspace/application_layer/healthcare_infoProtection/powerbi/reports/$datasetName.pbix"
./powerbi/scripts/deploy_pbi_reports.ps1 -workspaceName ${workspaceName} -pbixFilePath ${pbixFilePath}
./powerbi/scripts/update_pbi_dataset.ps1 -workspaceName ${workspaceName} -datasetName ${datasetName} -sqlDatabaseServer ${synEndpoint} -sqlDatabaseName ${synDbName}

$datasetName = "3 HealthCare CLS"
$pbixFilePath = "/workspace/application_layer/healthcare_infoProtection/powerbi/reports/$datasetName.pbix"
./powerbi/scripts/deploy_pbi_reports.ps1 -workspaceName ${workspaceName} -pbixFilePath ${pbixFilePath}
./powerbi/scripts/update_pbi_dataset.ps1 -workspaceName ${workspaceName} -datasetName ${datasetName} -sqlDatabaseServer ${synEndpoint} -sqlDatabaseName ${synDbName}