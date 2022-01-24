Write-Host

$workspaceName = "hpi_my_ws"
$userEmail = "agandini_microsoft.com#EXT#@agandini.onmicrosoft.com"
$pbixFilePath = "C:\code\dap\application_layer\healthcare_infoProtection\reports\1 HealthCare Dynamic Data Masking (Azure Synapse).pbix"

# Connect to PowerBI
Connect-PowerBIServiceAccount | Out-Null

# Check if Workspace exists
$workspace = Get-PowerBIWorkspace -Name $workspaceName

if($workspace) {
  Write-Host "The workspace named $workspaceName already exists"
}
else {
  Write-Host "Creating new workspace named $workspaceName"
  $workspace = New-PowerBIGroup -Name $workspaceName
}

# add user as workspace member
Add-PowerBIWorkspaceUser -Id $workspace.Id -UserEmailAddress $userEmail -AccessRight Member

# update script with file path to PBIX file
$import = New-PowerBIReport -Path $pbixFilePath -WorkspaceId $workspace.Id -ConflictAction CreateOrOverwrite

$import | select *