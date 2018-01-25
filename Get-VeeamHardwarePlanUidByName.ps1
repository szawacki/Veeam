Function Get-VeeamHardwarePlanUidByName
{
    <#
    .SYNOPSIS
    Get uid of veeam hardware paln by name.

    .DESCRIPTION
    Gets the uid of a veeam hardware plan by name. Uid is used in rest api calls to manage hardware plans.

    .PARAMETER Name
    Name of the hardware plan.
    
    .PARAMETER Connection
    Connection object creted by Get-VeeamConnection function.
    See: https://github.com/szawacki/Veeam/blob/master/Get-VeeamConnection.ps1

    .EXAMPLE 
    Get-VeeamHardwarePlanUidByName -Name 'HardwarePlan1' -Connection $connection

    .LINK
    Veeam rest api documentation: https://helpcenter.veeam.com/docs/backup/rest/overview.html?ver=95
    #>

    param
    ([parameter(Mandatory=$true)]
     [string]$Name,

     [parameter(Mandatory=$true)]
     [object]$Connection
    )

    $response = Invoke-RestMethod -Method Get -Uri "$($Connection['baseURI'])/cloud/hardwarePlans" -Headers $Connection['header']
    ($response.EntityReferences.Ref | Where-Object {$_.Name -eq $Name}).UID
}
