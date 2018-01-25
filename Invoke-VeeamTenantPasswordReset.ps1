Function Invoke-VeeamTenantPasswordReset
{
    <#
    .SYNOPSIS
    Rest the password of a veeam tenant.

    .DESCRIPTION
    Performs a reset of the password of a veeam tenant.

    .PARAMETER TenantUid
    Uid of the veeam tenant.
    
    .PARAMETER NewPwd
    New password for the veeam tenant.
    
    .PARAMETER Connection
    Connection object creted by Get-VeeamConnection function.
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Invoke-VeeamTenantPasswordReset -TenantUid '12445634334' -NewPwd '2344j213j2' -Connection $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param ([parameter(Mandatory=$true)]
           [string]$TenantUid,

           [parameter(Mandatory=$true)]
           [string]$NewPwd,

           [parameter(Mandatory=$true)]
           [object]$Connection
    )
     
$modifyVeeamTenantXml = [xml]  @"
<?xml version="1.0" encoding="utf-8"?>
<CloudTenant Type="CloudTenant" Href="http://localhost:9399/api/cloud/tenants/$($TenantUid)?format=Entity" Name="$($TenantName)" UID="urn:veeam:CloudTenant:$($TenantUid)" xmlns="http://www.veeam.com/ent/v1.0" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Password>$NewPwd</Password>
</CloudTenant>
"@
    
    Invoke-RestMethod -Method Put -Uri "$($Connection['baseURI'])/cloud/tenants/$($TenantUid)" -Headers $connection['header'] -Body $modifyVeeamTenantXml
}
