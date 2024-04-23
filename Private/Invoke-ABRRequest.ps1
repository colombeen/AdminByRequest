<#
    .SYNOPSIS
      Query the API

    .DESCRIPTION
      Query the API service from Admin by Request

    .PARAMETER URI
      The specific URI that you want to target

    .PARAMETER Method
      The rest method required for the query (GET, POST, PUT, DELETE, ...)

    .PARAMETER Body
      The body that accompanies the POST method query

    .PARAMETER Headers
      The headers required to authenticate, enrich or filter the query

    .PARAMETER Timeout
      The timeout setting for retrieving data from the API

    .EXAMPLE
      PS C:\> Invoke-ABRRequest -URI '/requests' -Method 'Get' -Headers @{ status = 'Denied' }
#>
Function Invoke-ABRRequest
{
  [CmdletBinding()]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $URI,

    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [Microsoft.PowerShell.Commands.WebRequestMethod]
    $Method = 'Get',

    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 2)]
    [ValidateNotNullOrEmpty()]
    [object]
    $Body,

    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 3)]
    [ValidateNotNullOrEmpty()]
    [hashtable]
    $Headers,

    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 4)]
    [ValidateNotNullOrEmpty()]
    [int32]
    $Timeout = 0
  )

  Process
  {
    #region Connection Requirements
    If ($null -eq $Script:ABR_API_URL)
    {
      Throw 'Missing connection information. You need to setup the connection settings first by using the Set-ABRConnection function or store the connection information by using the Add-ABRConfig function.'
    }

    If ($PSBoundParameters.ContainsKey('Headers'))
    {
      If (-not $Headers.ContainsKey('apikey'))
      {
        $Headers.Add('apikey', $Script:ABR_API_key)
      }
    }
    Else
    {
      $Headers = @{
        apikey = $Script:ABR_API_key
      }
    }
    #endregion

    #region Verbose headers
    $Headers.GetEnumerator() | ForEach-Object { Write-Verbose -Message ('{0} => {1}' -f $_.Key, $_.Value) }
    #endregion

    #region Splat
    $ABR_InvokeRestMethod_Splat = @{
      Method     = $Method
      Headers    = $Headers
      TimeoutSec = $Timeout
      URI        = $Script:ABR_API_URL + $URI
    }
    #endregion

    #region Body check
    If ($PSBoundParameters.ContainsKey('Body'))
    {
      $ABR_InvokeRestMethod_Splat.Add('Body', $Body)
    }
    #endregion

    #region Query API
    $Result = Invoke-RestMethod @ABR_InvokeRestMethod_Splat
    $Result
    #endregion
  }
}