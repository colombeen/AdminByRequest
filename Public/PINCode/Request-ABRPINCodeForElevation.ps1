<#
    .SYNOPSIS
      Request a PIN code for admin elevation

    .DESCRIPTION
      Request a PIN code for admin elevation for the specified inventory item by either Id or ComputerName by providing the PIN1 challenge code

    .PARAMETER Id
      The Id for the inventory item

    .PARAMETER ComputerName
      The ComputerName for the inventory item

    .PARAMETER Pin1
      The PIN 1 challenge code

    .EXAMPLE
      PS C:\> Request-ABRPinCodeForElevation -Id 1234567 -Pin1 000000
      Get a PIN for the inventory item Id 1234567 by providing the Pin1 challenge code

    .EXAMPLE
      PS C:\> Request-ABRPinCodeForElevation -ComputerName $env:ComputerName -Pin1 000000
      Get a PIN for the current computer by providing the Pin1 challenge code

    .EXAMPLE
      PS C:\> Get-ABRInventory -id 1234567 | Request-ABRPinCodeForElevation -Pin1 000000
      Request a PIN by using pipeline support

#>
Function Request-ABRPinCodeForElevation
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
    $ComputerName,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidatePattern('^[0-9]{6}$')]
    [string]
    $Pin1
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
        break
      }

      'Computer'
      {
        $URL += '/{0}/pin' -f $ComputerName
        break
      }
    }

    $Headers.Add('pintype', 'Challenge')
    $Headers.Add('pin1', $Pin1)

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