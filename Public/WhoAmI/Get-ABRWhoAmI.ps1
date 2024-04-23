<#
    .SYNOPSIS
      Shows details about your tenant on Admin by Request

    .DESCRIPTION
      Shows details about your tenant like licensing usage and expiry information, ...

    .EXAMPLE
      PS C:\> Get-ABRWhoAmI
      Shows details about your tenant on Admin by Request
#>
Function Get-ABRWhoAmI
{
  [CmdletBinding()]
  Param
  ()

  Process
  {
    $URL = '/whoami'
    $Headers = @{}

    $InvokeABRRequest_Splat = @{
      URI = $URL
    }

    If ($Headers.Count -gt 0)
    {
      $InvokeABRRequest_Splat.Add('Headers', $Headers)
    }

    Invoke-ABRRequest @InvokeABRRequest_Splat
  }
}