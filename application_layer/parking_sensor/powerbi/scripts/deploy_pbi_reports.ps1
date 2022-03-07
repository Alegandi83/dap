param(
    [string]$workspaceName,
    [string]$pbixFilePath
)
    

Write-Host "Start PowerBI Report Import"
Write-Host "workspaceName: " $workspaceName
Write-Host "pbixFilePath: " $pbixFilePath


# Retrieve workspace
$workspace = Get-PowerBIWorkspace -Name $workspaceName

# import report into workspace
$import = New-PowerBIReport -Path $pbixFilePath -Workspace $workspace -ConflictAction CreateOrOverwrite


Write-Host "End PowerBI Report Import"