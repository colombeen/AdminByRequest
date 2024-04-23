<#
    .SYNOPSIS
      Approve a specific request

    .DESCRIPTION
      Approve a specific request by providing the request Id

    .PARAMETER Id
      The Id for the request that you want to approve

    .PARAMETER ApprovedBy
      Add the approver information to the audit logging. This has to be an email address that matches a portal user, otherwise it will be ignored

    .EXAMPLE
      PS C:\> Approve-ABRRequest -Id 1234567
      Approve request with Id 1234567

    .EXAMPLE
      PS C:\> Approve-ABRRequest -Id 1234567 -ApprovedBy 'John.Doe@company.tld'
      Approve request with Id 1234567 and add the e-mail address John.Doe@company.tld to the audit logging for this approval

    .EXAMPLE
      PS C:\> Get-ABRRequest -Id 1234567 | Approve-ABRRequest -ApprovedBy 'John.Doe@company.tld'
      Approve a request by using pipeline support
#>
Function Approve-ABRRequest
{
  [CmdletBinding(DefaultParameterSetName = 'Id')]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [int]
    $Id,

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ApprovedBy = $Script:ABR_API_User
  )

  Process
  {
    $URL = '/requests'
    $Headers = @{}

    If ($Id -gt 0)
    {
      $URL += '/{0}' -f $Id
    }

    If (-not [string]::IsNullOrEmpty($ApprovedBy))
    {
      $Headers.Add('approvedby', $ApprovedBy)
    }

    $InvokeABRRequest_Splat = @{
      Method = 'Put'
      URI    = $URL
    }

    If ($Headers.Count -gt 0)
    {
      $InvokeABRRequest_Splat.Add('Headers', $Headers)
    }

    Invoke-ABRRequest @InvokeABRRequest_Splat
  }
}