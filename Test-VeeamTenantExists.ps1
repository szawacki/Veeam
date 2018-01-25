Function Test-VeeamTenantExists
{
    <#
    .SYNOPSIS
    Checks if a tenant exists.

    .DESCRIPTION
    Searvhes for a veeam tenant by name and returns true, or false, weather the tenant exsists, or not.

    .PARAMETER TenantName
    Name of the veeam tenant.

    .PARAMETER Connection
    Veeam connection object is created by function: Get-VeeamConnection
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Test-VeeamTenantExists -TenantName 'Tenant1' -ConnectionInfo $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param([parameter(Mandatory=$true)]
          [string]$TenantName,

          [parameter(Mandatory=$true)]
          [object]$Connection
    )

    $result = $false
    $resources = Invoke-RestMethod -Method Get -Uri "$($Connection['baseURI'])/cloud/tenants" -Headers $Connection['header']
    $tenant = $resources.EntityReferences.Ref | Where-Object {$_.Name -eq $TenantName }

    if ($tenant)
    {
        $result = $true
    }

    $result
}
