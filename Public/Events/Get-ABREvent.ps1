<#
    .SYNOPSIS
      Retrieve a list of events

    .DESCRIPTION
      Retrieve a list of all events with information like event code, event text, user, computer, ...

    .PARAMETER Id
      Returns one event

    .PARAMETER ComputerName
      Returns an array of events for a certain computer

    .PARAMETER UserName
      Returns an array of events for a certain user (user account or full name)

    .PARAMETER StartId
      The starting ID you wish to receive. Can be used for incremental offload of data to your own system

    .PARAMETER Take
      Maximum number of resources to return. Default is 50 to preserve bandwidth, maximum is 10000. For queries with more than 10000 records, pagination is mandatory

    .PARAMETER Last
      Entries are retrieved in ascending order by default. Last returns the latest X number of entries in descending order. Maximum is 10000

    .PARAMETER Code
      Only return entries with a certain event code; see Get-ABREventCode for a list

    .PARAMETER Days
      By default, entries up to 30 days are returned, unless specied otherwise. If startdate is specified, days is not used

    .PARAMETER StartDate
      Only return entries after the specified start date

    .PARAMETER EndDate
      Only return entries before and including the specified end date

    .EXAMPLE
      PS C:\> Get-ABREvent
      Get all events (either from the last 30 days or 50 results)

    .EXAMPLE
      PS C:\> Get-ABREvent -Id 1234567
      Get the event with the Id 1234567

    .EXAMPLE
      PS C:\> Get-ABREvent -ComputerName 'Computer1' -Last 10
      Get the last 10 events from Computer1

    .EXAMPLE
      PS C:\> Get-ABREvent -UserName 'Doe John' -StartDate '2023-01-01'
      Get all the events for user 'Doe John' starting from 2023-01-01

#>
Function Get-ABREvent
{
  [CmdletBinding(DefaultParameterSetName = 'All')]
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

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $UserName,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateNotNullOrEmpty()]
    [int]
    $StartId,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [Alias('Limit')]
    [ValidateRange(1, 10000)]
    [int]
    $Take,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateRange(1, 10000)]
    [int]
    $Last,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [Alias('EventCode')]
    [ValidateRange(1, 150)]
    [int]
    $Code,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateRange(1, 10000)]
    [int]
    $Days,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateNotNullOrEmpty()]
    [datetime]
    $StartDate,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateNotNullOrEmpty()]
    [datetime]
    $EndDate
  )

  Process
  {
    $URL = '/events'
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
        $URL = '/computers/{0}/events' -f ([System.Uri]::EscapeUriString($ComputerName))
        Break
      }

      'User'
      {
        $URL = '/users/{0}/events' -f ([System.Uri]::EscapeUriString($UserName))
        Break
      }
    }

    If ($PSCmdlet.ParameterSetName -ne 'Id')
    {
      If ($PSBoundParameters.ContainsKey('StartId'))
      {
        $Headers.Add('startid', $StartId)
      }

      If ($PSBoundParameters.ContainsKey('Take'))
      {
        $Headers.Add('take', $Take)
      }

      If ($PSBoundParameters.ContainsKey('Last'))
      {
        $Headers.Add('last', $Last)
      }

      If ($PSBoundParameters.ContainsKey('Code'))
      {
        $Headers.Add('code', $Code)
      }

      If ($PSBoundParameters.ContainsKey('Days'))
      {
        $Headers.Add('days', $Days)
      }

      If ($PSBoundParameters.ContainsKey('StartDate'))
      {
        $Headers.Add('startdate', $StartDate.ToString('yyyy-MM-dd'))
      }

      If ($PSBoundParameters.ContainsKey('EndDate'))
      {
        $Headers.Add('enddate', $EndDate.ToString('yyyy-MM-dd'))
      }
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