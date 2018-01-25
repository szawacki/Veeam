Function Remove-VeeamConnection
{
    <#
    .SYNOPSIS
    Disconnects from veeam server.

    .DESCRIPTION
    Disconnect from veeam server. Terminates the running session created by function: Get-VeeamConnection

    .PARAMETER Connection
    Veeam connection object is created by function: Get-VeeamConnection
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Remove-VeeamConnection -Connection $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param([ValidateNotNullOrEmpty()]
          [Parameter(Mandatory=$true)]
          [object]$Connection
    )

    Write-Host $("Logging out of Veeam Server")
    Invoke-WebRequest -Method Delete -Uri $Connection['sessionUri'] -Headers $Connection['header'] -UseBasicParsing
}
