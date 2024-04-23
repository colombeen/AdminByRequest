<#
    .SYNOPSIS
      Request an uninstall PIN code

    .DESCRIPTION
      Request an uninstall PIN code for the specified inventory item by either Id or ComputerName

    .PARAMETER Id
      The Id for the inventory item

    .PARAMETER ComputerName
      The ComputerName for the inventory item

    .EXAMPLE
      PS C:\> Request-ABRPinCodeForUninstall -Id 1234567
      Get an uninstall PIN for the inventory item Id 1234567

    .EXAMPLE
      PS C:\> Request-ABRPinCodeForUninstall -ComputerName $env:ComputerName
      Get an uninstall PIN for the current computer

    .EXAMPLE
      PS C:\> Get-ABRInventory -id 1234567 | Request-ABRPinCodeForUninstall
      Request an uninstall PIN by using pipeline support

#>
Function Request-ABRPinCodeForUninstall
{
  [CmdletBinding(DefaultParameterSetName = 'Id')]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [int]
    $Id,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ComputerName
  )

  Process
  {
    $URL = '/inventory'
    $Headers = @{}

    Switch ($PSCmdlet.ParameterSetName)
    {
      'Id'
      {
        If ($Id -gt 0)
        {
          $URL += '/{0}/pin' -f $Id
        }
        Break
      }

      'Computer'
      {
        $URL += '/{0}/pin' -f ([System.Uri]::EscapeUriString($ComputerName))
        Break
      }
    }

    $Headers.Add('pintype', 'UninstallPIN')

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