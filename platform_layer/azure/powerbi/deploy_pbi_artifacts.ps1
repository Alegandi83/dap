param(
    [string]$kvName,
    [string]$workspaceName,
    [string]$userEmail
)
    

Write-Host "Start PowerBI Workspace Setup"
Write-Host "kvName: " $kvName
Write-Host "workspaceName: " $workspaceName
Write-Host "userEmail: " $userEmail

# Connect to Power BI
Connect-PowerBIServiceAccount | Out-Null

# Check if Workspace exists
$workspace = Get-PowerBIWorkspace -Name $workspaceName

if($workspace) {
  Write-Host "The workspace named $workspaceName already exists"
}
else {
  
  # Create workspace
  Write-Host "Creating new workspace named $workspaceName"
  $workspace = New-PowerBIGroup -Name $workspaceName

  # Store workspace id on key vault
  Write-Host "Store workspace name, id on key-vault"
  az keyvault secret set --vault-name $kvName --name "pbiwsname" --value $workspaceName
  az keyvault secret set --vault-name $kvName --name "pbiwsid" --value $workspace.id

  # add user as workspace member
  Write-Host "Add user as workspace member: $userEmail" 
  Add-PowerBIWorkspaceUser -Id $workspace.Id -UserEmailAddress $userEmail -AccessRight Member

}

Write-Host "End PowerBI Workspace Setup"
