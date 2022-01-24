param(
    [string]$workspaceName,
    [string]$userEmail
)
    

Write-Host "Start PowerBI Workspace Setup"

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


Write-Host "End PowerBI Workspace Setup"