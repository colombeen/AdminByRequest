<#
    .SYNOPSIS
      Retrieve a list of inventory computers

    .DESCRIPTION
      Retrieve a list of inventory computers with computer/user/operating system/hardware/network/location/software information 

    .PARAMETER Id
      Returns one computer’s inventory by id

    .PARAMETER ComputerName
      Returns one computer’s inventory by computer name

    .PARAMETER StartId
      The starting ID you wish to receive. Can be used for incremental offload of data to your own system

    .PARAMETER Take
      Maximum number of resources to return. Default is 50 to preserve bandwidth, maximum is 10000. For queries with more than 10000 records, pagination is mandatory

    .PARAMETER WantSoftware
      Use this filter, if you wish to receive lists of installed software. The default is to not return installed software

    .PARAMETER WantGroups
      Use this filter, if you wish to receive user and computer groups. The default is to not return groups

    .EXAMPLE
      PS C:\> Get-ABRInventory
      Get all requests

    .EXAMPLE
      PS C:\> Get-ABRInventory -Id 1234567 -WantSoftware
      Get the inventory data for Id 1234567 including all software

    .EXAMPLE
      PS C:\> Get-ABRInventory -ComputerName $env:ComputerName -WantGroups
      Get the inventory data for the current computer including all group memberships for the user and computer

    .EXAMPLE
      PS C:\> Get-ABRInventory -StartId 1234567 -Take 10
      Get the inventory data for 10 computers, starting with Id 1234567

#>
Function Get-ABRInventory
{
  [CmdletBinding(DefaultParameterSetName = 'Id')]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [int]
    $Id,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ComputerName,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Filter')]
    [ValidateNotNullOrEmpty()]
    [int]
    $StartId,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Filter')]
    [Alias('Limit')]
    [ValidateRange(1, 10000)]
    [int]
    $Take,

    [switch]
    $WantSoftware,

    [switch]
    $WantGroups
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
          $URL += '/{0}' -f $Id
        }
        Break
      }

      'Computer'
      {
        $URL += '/{0}' -f ([System.Uri]::EscapeUriString($ComputerName))
        Break
      }

      'Filter'
      {
        If ($PSBoundParameters.ContainsKey('StartId'))
        {
          $Headers.Add('startid', $StartId)
        }

        If ($PSBoundParameters.ContainsKey('Take'))
        {
          $Headers.Add('take', $Take)
        }
        Break
      }
    }

    If ($WantSoftware.IsPresent)
    {
      $Headers.Add('wantsoftware', 1)
    }

    If ($WantGroups.IsPresent)
    {
      $Headers.Add('wantgroups', 1)
    }

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