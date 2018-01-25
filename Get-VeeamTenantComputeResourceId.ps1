Function Get-VeeamTenantComputeResourceId
{
    <#
    .SYNOPSIS
    Get compute resource id of a tenant.

    .DESCRIPTION
    Gets the id of the compute resource of a tenant. Compute resource is the disaster recovery component of a veeam tenant.

    .PARAMETER TenantUid
    Uid of a tenant. Can be retrieved via function: Get-VeeamTenantUid

    .PARAMETER Connection
    Veeam connection object is created by function: Get-VeeamConnection
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Get-VeeamTenantComputeResourceId -TenantUid '1112387663627112' -ConnectionInfo $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param([parameter(Mandatory = $true)]
          [string]$TenantUid,

          [parameter(Mandatory = $true)]
          [object]$Connection
    )

    $response = Invoke-RestMethod -Method Get -Uri "$($Connection['baseURI'])/cloud/tenants/$($TenantUid)/computeResources" -Headers $Connection['header']
    $response.CloudTenantComputeResources.CloudTenantComputeResource.Id
}
