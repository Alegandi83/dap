param(
    [string]$project,
    [string]$env,
    [string]$deployment_id,
    [string]$tenant_id,
    [string]$subscriptionId,
    [string]$resourceGroupName,
    [string]$location,    
    [string]$user_id,
    [string]$purview_account,
    [string]$vault_name,
    [string]$vault_uri,
    [string]$admin_login,
    [string]$sql_secret_name,
    [string]$sql_server_name,
    [string]$sql_db_name,
    [string]$storage_account_name,
    [string]$adf_name,
    [string]$adf_principal_id,
    [string]$syn_name,
    [string]$syn_principal_id,
#    [string]$adf_pipeline_name,
    [string]$managed_identity
)


Write-Host "--- Start Purview DataPlane Test ---"
whoami

# Variables
$scan_endpoint = "https://${purview_account}.scan.purview.azure.com"
$catalog_endpoint = "https://${purview_account}.catalog.purview.azure.com"
$pv_endpoint = "https://${purview_account}.purview.azure.com"
$pv_service_principal_name = "${project}-pview-${env}-${deployment_id}-sp"

# Create Service Principal
function createServicePrincipal([string]$subscriptionId, [string]$resourceGroupName, [string]$pv_service_principal_name) {
    $scope = "${subscriptionId}/resourceGroups/${resourceGroupName}"
    $sp = New-AzADServicePrincipal -DisplayName $pv_service_principal_name -Role "Owner" -Scope $scope
    Return $sp
}


# [POST] Token
function getToken([string]$tenant_id, [string]$client_id, [string]$client_secret) {
    $uri = "https://login.windows.net/${tenant_id}/oauth2/token"
    $body = @{
        "grant_type" = "client_credentials"
        "client_id" = $client_id
        "client_secret" = $client_secret
        "resource" = "https://purview.azure.net"
    }
    $params = @{
        ContentType = "application/x-www-form-urlencoded"
        Headers = @{"accept"="application/json"}
        Body = $body
        Method = "POST"
        URI = $uri
    }
    
    $token = Invoke-RestMethod @params
    
    Return "Bearer " + ($token.access_token).ToString()
}

# [PUT] Data Source
function putSource([string]$token, [hashtable]$payload) {
    $dataSourceName = $payload.name
    $uri = "${scan_endpoint}/datasources/${dataSourceName}?api-version=2018-12-01-preview"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json)
        Method = "PUT"
        URI = $uri
    }
    $retryCount = 0
    $response = $null
    while (($null -eq $response) -and ($retryCount -lt 3)) {
        try {
            $response = Invoke-RestMethod @params
        }
        catch {
            Write-Host "[Error] Unable to putSource."
            Write-Host "Token: ${token}"
            Write-Host "URI: ${uri}"
            Write-Host ($payload | ConvertTo-Json)
            Write-Host "Response:" $_.Exception.Response
            Write-Host "Exception:" $_.Exception

            $result = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Host $responseBody

            $retryCount += 1
            $response = $null
        }
    }
    Return $response
}

# [PUT] Key Vault
function putVault([string]$token, [string]$vault_name, [hashtable]$payload) {
    #$randomId = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 3 |ForEach-Object{[char]$_})
    #$keyVaultName = "keyVault-${randomId}"
    $keyVaultName = $vault_name
    $uri = "${scan_endpoint}/azureKeyVaults/${keyVaultName}"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json)
        Method = "PUT"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [PUT] Credential
function putCredential([string]$token, [hashtable]$payload) {
    $credentialName = $payload.name
    $uri = "${pv_endpoint}/proxy/credentials/${credentialName}?api-version=2020-12-01-preview"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json -Depth 9)
        Method = "PUT"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [PUT] Scan
function putScan([string]$token, [string]$dataSourceName, [hashtable]$payload) {
    $scanName = $payload.name
    $uri = "${scan_endpoint}/datasources/${dataSourceName}/scans/${scanName}"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json -Depth 9)
        Method = "PUT"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [PUT] Run Scan
function runScan([string]$token, [string]$datasourceName, [string]$scanName) {
    $uri = "${scan_endpoint}/datasources/${datasourceName}/scans/${scanName}/run?api-version=2018-12-01-preview"
    $payload = @{ scanLevel = "Full" }
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json)
        Method = "POST"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [POST] Create Glossary
function createGlossary([string]$token) {
    $uri = "${catalog_endpoint}/api/atlas/v2/glossary"
    $payload = @{
        name = "Glossary"
        qualifiedName = "Glossary"
    }
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Method = "POST"
        URI = $uri
        Body = ($payload | ConvertTo-Json -Depth 4)
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [POST] Import Glossary Terms
function importGlossaryTerms([string]$token, [string]$glossaryGuid, [string]$glossaryTermsTemplateUri) {
    $glossaryTermsFilename = "import-terms-sample.csv"
    Invoke-RestMethod -Uri $glossaryTermsTemplateUri -OutFile $glossaryTermsFilename
    $glossaryImportUri = "${catalog_endpoint}/api/atlas/v2/glossary/${glossaryGuid}/terms/import?includeTermHierarchy=true&api-version=2021-05-01-preview"
    $fieldName = 'file'
    $filePath = (Get-Item $glossaryTermsFilename).FullName
    Add-Type -AssemblyName System.Net.Http
    $client = New-Object System.Net.Http.HttpClient
    $content = New-Object System.Net.Http.MultipartFormDataContent
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $fileContent = New-Object System.Net.Http.StreamContent($fileStream)
    $content.Add($fileContent, $fieldName, $glossaryTermsFilename)
    $access_token = $token.split(" ")[1]
    $client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $access_token)
    $result = $client.PostAsync($glossaryImportUri, $content).Result
    return $result
}

# [GET] Metadata Policy
function getMetadataPolicy([string]$token, [string]$collectionName) {
    $uri = "${pv_endpoint}/policystore/collections/${collectionName}/metadataPolicy?api-version=2021-07-01"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Method = "GET"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

# [PUT] Metadata Policy
function putMetadataPolicy([string]$token, [string]$metadataPolicyId, [object]$payload) {
    $uri = "${pv_endpoint}/policystore/metadataPolicies/${metadataPolicyId}?api-version=2021-07-01"
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json -Depth 10)
        Method = "PUT"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}

function addRoleAssignment([object]$policy, [string]$principalId, [string]$roleName) {
    Foreach ($attributeRule in $policy.properties.attributeRules) {
        if (($attributeRule.name).StartsWith("purviewmetadatarole_builtin_${roleName}:")) {
            Foreach ($conditionArray in $attributeRule.dnfCondition) {
                Foreach($condition in $conditionArray) {
                    if ($condition.attributeName -eq "principal.microsoft.id") {
                        $condition.attributeValueIncludedIn += $principalId
                    }
                 }
            }
        }
    }
}

# [PUT] Collection
function putCollection([string]$token, [string]$collectionFriendlyName, [string]$parentCollection) {
    $collectionName = -join ((97..122) | Get-Random -Count 6 | ForEach-Object {[char]$_})
    $uri = "${pv_endpoint}/account/collections/${collectionName}?api-version=2019-11-01-preview"
    $payload = @{
        "name" = $collectionName
        "parentCollection"= @{
            "type" = "CollectionReference"
            "referenceName" = $parentCollection
        }
        "friendlyName" = $collectionFriendlyName
    }
    $params = @{
        ContentType = "application/json"
        Headers = @{ Authorization = "Bearer $token" }
        Body = ($payload | ConvertTo-Json -Depth 10)
        Method = "PUT"
        URI = $uri
    }
    $response = Invoke-RestMethod @params
    Return $response
}


#------------------------------------------------------------------------------------------------------------
# ADD Managed Identity TO COLLECTION ADMINISTRATOR ROLE
#------------------------------------------------------------------------------------------------------------

#Call Control Plane API to add UAMI as Collection Administrator

$token = (Get-AzAccessToken -Resource "https://management.azure.com").Token
$headers = @{ Authorization = "Bearer $token" }

$uri = "https://management.azure.com/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Purview/accounts/$purview_account/addRootCollectionAdmin?api-version=2021-07-01"

$body = "{
  objectId: ""$managed_identity""
}"

$retrycount = 1
$completed = $false

while (-not $completed) {
  try {
    Invoke-RestMethod -Method Post -ContentType "application/json" -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
    $completed = $true
  }
  catch {
    if ($retrycount -ge $retries) {
        Write-Host "Metadata policy update failed the maximum number of $retryCount times."
        throw
    } else {
        Write-Host "Metadata policy update failed $retryCount time(s). Retrying in $secondsDelay seconds."
        Write-Warning $Error[0]
        Start-Sleep $secondsDelay
        $retrycount++
    }
  }
}

#------------------------------------------------------------------------------------------------------------
# ADD Managed Identity TO DATA SOURCE ADMINISTRATOR ROLE
#------------------------------------------------------------------------------------------------------------

#Call Data Plane API to add UAMI as Data Source Administrator
$token = (Get-AzAccessToken -Resource "https://purview.azure.net").Token
$headers = @{ Authorization = "Bearer $token" }

$PolicyId = ""
$uri = "https://$purview_account.purview.azure.com/policystore/metadataPolicies/`?api-version=2021-07-01-preview"

$retrycount = 1
$completed = $false

while (-not $completed) {
    try {
      #Retrieve Purview default metadata policy ID
      Write-Host "List Metadata Policies..."
      $result = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
      $PolicyId = $result.values.Id
  
      Write-Host "Retrieve metadata policy (ID $PolicyId) details..."
      $uri = "https://$purview_account.purview.azure.com/policystore/metadataPolicies/$PolicyId`?api-version=2021-07-01-preview"
  
      #Retrieve Metadata Policy details 
      $result = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
  
  
      foreach ($attributeRule in $result.properties.attributeRules) {
        #Add Deployment Script UAMI PrincipalID to Data Source Administrator Role.
        if ($attributeRule.id -like "*data-source-administrator*") {
          if (-not ($attributeRule.dnfCondition[0][0].attributeValueIncludedIn -contains $managed_identity)) {
            $attributeRule.dnfCondition[0][0].attributeValueIncludedIn += $managed_identity  
          }
        #Add Data Share PrincipalID to Data Curator Role.
        } 
      }
  
      #Update Metadata Policy
      Write-Host "Update metadata policy (ID $PolicyId)..."
      $body = ConvertTo-Json -InputObject $result -Depth 10
      Invoke-RestMethod -Method Put -ContentType "application/json" -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
      $completed = $true
    }
    catch {
      if ($retrycount -ge $retries) {
          Write-Host "Metadata policy update failed the maximum number of $retryCount times."
          throw
      } else {
          Write-Host "Metadata policy update failed $retryCount time(s). Retrying in $secondsDelay seconds."
          Write-Warning $Error[0]
          Start-Sleep $secondsDelay
          $retrycount++
      }
    }
  }

Write-Host "--- End Purview DataPlane Test ---"