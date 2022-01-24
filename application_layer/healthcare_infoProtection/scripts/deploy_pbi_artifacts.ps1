param(
    [string]$workspaceName,
    [string]$userEmail
)

Write-Host "Start PowerBI Reports Setup"

# Set Report Path
$pbixFilePath = "C:\code\dap\application_layer\healthcare_infoProtection\reports\1 HealthCare Dynamic Data Masking (Azure Synapse).pbix"

# Check if Workspace exists
$workspace = Get-PowerBIWorkspace -Name $workspaceName

if($workspace) {
  Write-Host "Import Reports into the Workspace: $workspaceName ."

  # update script with file path to PBIX file
  $import = New-PowerBIReport -Path $pbixFilePath -WorkspaceId $workspace.Id -ConflictAction CreateOrOverwrite
  $import | select *

}
else {
  Write-Host "Workspace: $workspaceName does not exist"
  
}

Write-Host "End PowerBI Reports Setup"