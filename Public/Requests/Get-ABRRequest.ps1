<#
    .SYNOPSIS
      Retrieve a list of approval requests

    .DESCRIPTION
      Retrieve a list of all approval requests with information like status, application, user, computer, ...

    .PARAMETER Id
      Returns one request

    .PARAMETER Status
      Only get request of a certain type (possible values: Pending, Denied, Approved, Quarantined)

    .PARAMETER StartId
      The starting ID you wish to receive. Can be used for incremental offload of data to your own system

    .PARAMETER Take
      Maximum number of resources to return. Default is 50 to preserve bandwidth, maximum is 1000. For queries with more than 1000 records, pagination is mandatory

    .PARAMETER Last
      Entries are retrieved in ascending order. Last returns the latest X number of entries in descending order. Maximum is 1000. Take and StartId cannot be combined with Last

    .PARAMETER WantScanDetails
      Use this filter, if you wish to receive detailed lists of scan results. The default is to give you the overall result only

    .EXAMPLE
      PS C:\> Get-ABRRequest
      Get all requests

    .EXAMPLE
      PS C:\> Get-ABRRequest -Id 1234567
      Get the request with the Id 1234567

    .EXAMPLE
      PS C:\> Get-ABRRequest -Status Denied -Last 5
      Get the last 5 requests that were denied

    .EXAMPLE
      PS C:\> Get-ABRRequest -Status Denied -WantScanDetails
      Get all the requests that were denied with scan details

#>
Function Get-ABRRequest
{
  [CmdletBinding(DefaultParameterSetName = 'Id')]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [int]
    $Id,

    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName = 'Filter')]
    [ValidateSet('Approved', 'Denied', 'Pending', 'Quarantined')]
    [string]
    $Status,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Filter')]
    [ValidateNotNullOrEmpty()]
    [int]
    $StartId,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Filter')]
    [Alias('Limit')]
    [ValidateRange(1, 1000)]
    [int]
    $Take,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Filter')]
    [ValidateRange(1, 1000)]
    [int]
    $Last,

    [switch]
    $WantScanDetails
  )

  Process
  {
    $URL = '/requests'
    $Headers = @{}

    Switch ($PSCmdlet.ParameterSetName)
    {
      'Id'
      {
        If ($Id -gt 0)
        {
          $URL += '/{0}' -f $Id
        }
        break
      }

      'Filter'
      {
        @('Status', 'StartId', 'Take', 'Last') | ForEach-Object {
          If ($PSBoundParameters.($_) -ne 0 -and -not [string]::IsNullOrEmpty($PSBoundParameters.($_)))
          {
            $Headers.Add($_.ToLower(), $PSBoundParameters.($_))
          }
        }
        break
      }
    }

    If ($WantScanDetails.IsPresent)
    {
      $Headers.Add('wantscandetails', 1)
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