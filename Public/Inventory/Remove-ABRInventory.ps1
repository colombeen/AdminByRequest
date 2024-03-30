<#
    .SYNOPSIS
      Remove a computer from the inventory

    .DESCRIPTION
      Remove a computer from the inventory by id or computer name 

    .PARAMETER Id
      Remove one computer’s inventory by id

    .PARAMETER ComputerName
      Remove one computer’s inventory by computer name

    .EXAMPLE
      PS C:\> Remove-ABRInventory -Id 1234567
      Remove the computer's inventory data with Id 1234567

    .EXAMPLE
      PS C:\> Remove-ABRInventory -ComputerName $env:ComputerName
      Remove the computer's inventory data from the current computer by name
#>
Function Remove-ABRInventory
{
  [CmdletBinding(DefaultParameterSetName = 'Id', ConfirmImpact = 'High', SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [int]
    $Id,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ComputerName
  )

  Process
  {
    $URL = '/inventory'
    $Device = $null
    $Headers = @{}

    Switch ($PSCmdlet.ParameterSetName)
    {
      'Id'
      {
        If ($Id -gt 0)
        {
          $URL += '/{0}' -f $Id
          $Device = 'Id {0}' -f $Id
        }
        Break
      }

      'Computer'
      {
        $URL += '/{0}' -f ([System.Uri]::EscapeUriString($ComputerName))
        $Device = 'ComputerName {0}' -f $ComputerName
        Break
      }
    }

    $InvokeABRRequest_Splat = @{
      Method = 'Delete'
      URI    = $URL
    }

    If ($Headers.Count -gt 0)
    {
      $InvokeABRRequest_Splat.Add('Headers', $Headers)
    }

    If ($PSCmdlet.ShouldProcess($Device, 'Remove'))
    {
      Invoke-ABRRequest @InvokeABRRequest_Splat
    }
  }
}