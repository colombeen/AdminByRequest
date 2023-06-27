<#
    .SYNOPSIS
      Deny a specific request

    .DESCRIPTION
      Deny a specific request by providing the request Id

    .PARAMETER Id
      The Id for the request that you want to deny

    .PARAMETER Reason
      The reason why the request was denied

    .PARAMETER DeniedBy
      Add the denier information to the audit logging. This has to be an email address that matches a portal user, otherwise it will be ignored

    .EXAMPLE
      PS C:\> Deny-ABRRequest -Id 1234567
      Deny request with Id 1234567

    .EXAMPLE
      PS C:\> Deny-ABRRequest -Id 1234567 -Reason 'This isn''t allowed by our company policy' -DeniedBy 'John.Doe@company.tld'
      Deny request with Id 1234567 and add a reason why you denied it and who denied it

    .EXAMPLE
      PS C:\> Get-ABRRequest -Id 1234567 | Deny-ABRRequest -Reason 'This isn''t allowed by our company policy' -DeniedBy 'John.Doe@company.tld'
      Deny a request by using pipeline support
#>
Function Deny-ABRRequest
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
    $Reason = $null,

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DeniedBy = $Script:ABR_API_User
  )

  Process
  {
    $URL = '/requests'
    $Headers = @{}

    If ($Id -gt 0)
    {
      $URL += '/{0}' -f $Id
    }

    If (-not [string]::IsNullOrEmpty($DeniedBy))
    {
      $Headers.Add('deniedby', $DeniedBy)
    }

    If ($PSBoundParameters.ContainsKey('Reason'))
    {
      $Headers.Add('reason', $Reason)
    }

    $InvokeABRRequest_Splat = @{
      Method = 'Delete'
      URI    = $URL
    }

    If ($Headers.Count -gt 0)
    {
      $InvokeABRRequest_Splat.Add('Headers', $Headers)
    }

    Invoke-ABRRequest @InvokeABRRequest_Splat
  }
}