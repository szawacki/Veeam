Function Enable-IgnoreInvalidCert
{
    <#
    .SYNOPSIS
    Ignores invalid certificates.

    .DESCRIPTION
    Ignore invalid certificate (such as self-signed certificates).

    .EXAMPLE 
    Enable-IgnoreInvalidCert
    #>

Add-Type @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
"@
[ServerCertificateValidationCallback]::Ignore();

}
Function Get-VeeamConnectionInfo
{
    <#
    .SYNOPSIS
    Creates veeam connection info object.

    .DESCRIPTION
    Creates veeam connection info object used to authenticate against veeam enterpise manager.

    .PARAMETER EnterpriseManager
    Name or ip address of veeam enterpise manager..

    .PARAMETER Port
    Port of veeam enterprise manager.

    .PARAMETER Username
    Veeam username.
    
    .PARAMETER Password
    Password as veeam user. (Type of securestring)

    .EXAMPLE 
    Get-VeeamConnectionInfo -EnterpriseManager 'Servername' -Port 1234 -Username 'User1' -Password 'xw34nj33'
    #>

    param([ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [string]$EnterpriseManager,

          [ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [int]$Port,

          [ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [string]$Username,

          [ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [securestring]$Password
    )

    # create ps credential object
    $credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)

    # build connection info object
    $connectionInfo = @{}
    $connectionInfo["EnterpriseManagerServer"] = $EnterpriseManager
    $connectionInfo["Port"] = $Port
    $connectionInfo["credentials"] =  $credentials
    $connectionInfo["ignoreCert"] = $true

    $connectionInfo
}
Function Get-VeeamConnection
{
    <#
    .SYNOPSIS
    Creates veeam connection and returns connection object.

    .DESCRIPTION
    Authenticates at veeam enterprise manager and return a session object for the current connection.
    Object can be used to perfom actions on the server via rest api.

    .PARAMETER ConnectionInfo
    Veeam connection info object is created by function: Get-VeeamConnectionInfo

    .EXAMPLE 
    Get-VeeamConnection -ConnectionInfo $connectionInfo

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param([ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [object]$ConnectionInfo
    )

	# Build the base URI for the REST calls
	$baseURI = "https://$($ConnectionInfo['EnterpriseManagerServer']):$($ConnectionInfo['Port'])/api"

	# Build header for REST calls
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Accept", "application/xml")
	$headers.Add("Content-Type", "application/xml")

	# If requested, ignore self-signed or otherwise invalid certificates 
	if ($ConnectionInfo['ignoreCert'] -eq $true)
	{
		Enable-IgnoreInvalidCert
	}
	
	# Send authentication request
	try 
	{			
		Write-Host $("Sending authentication request")
		$loginResponse = Invoke-WebRequest -Method Post -Uri "${baseURI}/sessionMngr/?v=v1_3" -Credential $ConnectionInfo['credentials'] -Headers $headers -UseBasicParsing
    } 
    catch 
	{
		# request unsuccessful
		throw "Error connecting to Veeam Enterprise Manager. Error Message: $($_.Exception.Message)"
	}
	
    $loginXml = [xml]$loginResponse.Content
    # Save login href, needed later for log out
    $sessionUri = $loginXml.LogonSession.Href

    # Add session id from login response to header, so session id is send with all further requests
    $headers.Add("X-RestSvcSessionId", $loginResponse.Headers["X-RestSvcSessionId"])
	
	Write-Host $("Successfully authenticated")
	
	# Build connection object
	$connection = @{  
		header = $headers
		baseURI = $baseURI
        sessionUri = $sessionUri
	}
	
	$connection
}

$connectionInfo = Get-VeeamConnectionInfo -EnterpriseManager 'Servername or IP' -Port 'Port' -Username 'Username' -Password 'Password as securestring'
$connection = Get-VeeamConnection -ConnectionInfo $connectionInfo

# Perform your actions ...
