using namespace System.Net
#Testupdate
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

<# YOU one need this part if you're going to use msgraph functions too
# Get Managed Service Identity info from Azure Functions Application Settings
$msiEndpoint = $env:MSI_ENDPOINT
$msiSecret = $env:MSI_SECRET

# Specify URI and Token AuthN Request Parameters
$apiVersion = "2017-09-01"
$resourceURI = "https://graph.microsoft.com"
$tokenAuthURI = $msiEndpoint + "?resource=$resourceURI&api-version=$apiVersion"

# Authenticate with MSI and get Token
$tokenResponse = Invoke-RestMethod –Method Get –Headers @{"Secret"="$msiSecret"} –Uri $tokenAuthURI
$body = $tokenResponse.access_token
# This response should give us a Bearer Token for later use in Graph API calls
$body = $msiEndpoint
$msToken = $tokenResponse.access_token
#>

$context = Get-AzContext
$aadToken = (Get-AzAccessToken -ResourceTypeName AadGraph).token

#You will need to upload this using Kudu or similar
Import-Module "D:\Home\Site\wwwroot\HttpTrigger1\modules\AzureAD.Standard.Preview\0.0.0.10\AzureAD.Standard.Preview.psd1"
Connect-AzureAD -AadAccessToken $aadToken -AccountId $context.Account.Id -TenantId $context.tenant.id -verbose
$testadconnect = Get-AzureADDomain -ErrorAction SilentlyContinue
if ($testadconnect) { #Check connected Azure AD 
        
    # Write to the Azure Functions log stream.
    Write-Host "PowerShell HTTP trigger function processed a request."

    # this should be found in Azure AD . TODO :: if Application already exists
    $ownersemail = $Request.Query.ownersemail
    if (-not $ownersemail) {
        $ownersemail = $Request.Body.ownersemail
    }
    $body = "This HTTP triggered function executed successfully. However you have not included the ownersemail so no SP has been created"

    if ($ownersemail) {
        $owner = Get-AzADUser -UserPrincipalName $ownersemail 
        if (-not $owner) {
            $body = "$ownersemail was not found in Azure AD. Usually your email is your UPN (Office365 Login). Use your actual UPN if it's not the email"
        }
        if ($owner) {
            $spDisplayName = "RLGDEVSP-" + $ownersemail.split("@")[0].replace(".","")
            $testappexists = Get-AzADApplication -DisplayName $spDisplayName
            if (-not $testappexists) {
                $sp = New-AzADServicePrincipal -SkipAssignment -DisplayName $spDisplayName -EndDate (get-date).AddMinutes(5)
                $body = $sp
                $ServicePrincipalId = (Get-AzADApplication -ApplicationId $sp.ApplicationId).ObjectId
                $OwnerId = $owner.Id
                Add-AzureADApplicationOwner -ObjectId $ServicePrincipalId -RefObjectId $OwnerId
            }
            else {$body = "This app and service principal already exists `n`n To get details : Get-AzADApplication -DisplayName $spDisplayName"}
        }
    }#>

}
else {
    $body = "Something has went wrong and the function failed to connect to AzureAD"
}
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
