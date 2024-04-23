<#
    .SYNOPSIS
      Retrieve a list of auditlogs

    .DESCRIPTION
      Retrieve a list of all auditlogs with information like installs, uninstalls, elevated application, computer, ...

    .PARAMETER Id
      Returns one auditlog entry

    .PARAMETER ComputerName
      Returns an array of auditlog entries for a certain computer

    .PARAMETER UserName
      Returns an array of auditlog entries for a certain user (user account or full name)

    .PARAMETER Delta
      Returns an array of changed auditlog entries since last call

    .PARAMETER StartId
      The starting ID you wish to receive. Can be used for incremental offload of data to your own system

    .PARAMETER Take
      Maximum number of resources to return. Default is 50 to preserve bandwidth, maximum is 10000. For queries with more than 10000 records, pagination is mandatory

    .PARAMETER Last
      Entries are retrieved in ascending order by default. Last returns the latest X number of entries in descending order. Maximum is 10000

    .PARAMETER WantScanDetails
      Use this filter, if you wish to receive detailed lists of scan results. The default is to give you the overall result only

    .PARAMETER Type
      Only return either 'Run As Admin' (-Type App) or 'Admin Sessions' (-Type Session) entries

    .PARAMETER Status
      Only return entries from Requests (possible values: Pending, Denied, Approved, Quarantined)

    .PARAMETER Days
      By default, entries up to 30 days are returned, unless specied otherwise. If startdate is specified, days is not used

    .PARAMETER StartDate
      Only return entries after the specified start date

    .PARAMETER EndDate
      Only return entries before and including the specified end date

    .PARAMETER DeltaTime
      Use -Delta without parameters one time to get an initial 'timeNow'. Use this time to get delta data since last call

    .EXAMPLE
      PS C:\> Get-ABRAuditlog
      Get all auditlogs (either from the last 30 days or 50 results)

    .EXAMPLE
      PS C:\> Get-ABRAuditlog -Id 1234567
      Get the auditlog with the Id 1234567

    .EXAMPLE
      PS C:\> Get-ABRAuditlog -ComputerName 'Computer1' -Last 10
      Get the last 10 auditlogs from Computer1

    .EXAMPLE
      PS C:\> Get-ABRAuditlog -UserName 'Doe John' -StartDate '2023-01-01'
      Get all the auditlogs for user 'Doe John' starting from 2023-01-01

    .EXAMPLE
      PS C:\> Get-ABRAuditlog -Delta -DeltaTime '637795099840708375'
      Get all the auditlogs since the latest change (DeltaTime)
#>
Function Get-ABRAuditlog
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

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Delta', Position = 0)]
    [switch]
    $Delta,

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
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Id')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [switch]
    $WantScanDetails,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateSet('App', 'Session')]
    [string]
    $Type,

    [Parameter(ValueFromPipelineByPropertyName = $True, ParameterSetName = 'All')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'User')]
    [ValidateSet('Approved', 'Denied', 'Pending', 'Quarantined')]
    [string]
    $Status,

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
    $EndDate,

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Delta')]
    [ValidateNotNullOrEmpty()]
    [string]
    $DeltaTime
  )

  Process
  {
    $URL = '/auditlog'
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
        $URL = '/computers/{0}/auditlog' -f ([System.Uri]::EscapeUriString($ComputerName))
        Break
      }

      'User'
      {
        $URL = '/users/{0}/auditlog' -f ([System.Uri]::EscapeUriString($UserName))
        Break
      }

      'Delta'
      {
        $URL += '/delta'
        Break
      }
    }

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

    If ($WantScanDetails.IsPresent)
    {
      $Headers.Add('wantscandetails', 1)
    }

    If ($PSBoundParameters.ContainsKey('Type'))
    {
      $Headers.Add('type', $Type.toLower())
    }

    If ($PSBoundParameters.ContainsKey('Status'))
    {
      $Headers.Add('status', $status.toLower())
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

    If ($PSBoundParameters.ContainsKey('DeltaTime'))
    {
      $Headers.Add('deltaTime', $DeltaTime)
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