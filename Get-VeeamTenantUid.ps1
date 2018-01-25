Function Get-VeeamTenantUid
{
    <#
    .SYNOPSIS
    Get uid of a veeam tenant.

    .DESCRIPTION
    Gets the uid of a veeam tenant. Uid is used in rest api calls.

    .PARAMETER TenantName
    Name of the veeam tenant.

    .PARAMETER Connection
    Veeam connection object is created by function: Get-VeeamConnection
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Get-VeeamTenantUid -TenantName 'Tenant1' -ConnectionInfo $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param(
        [parameter(Mandatory=$true)]
        [string]$TenantName,

        [parameter(Mandatory=$true)]
        [object]$Connection
    )

    $resources = Invoke-RestMethod -Method Get -Uri "$($Connection['baseURI'])/cloud/tenants" -Headers $Connection['header']
    ($resources.EntityReferences.Ref | Where-Object {$_.Name -eq $TenantName }).UID
}
