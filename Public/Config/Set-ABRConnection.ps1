<#
    .SYNOPSIS
      Define connection information

    .DESCRIPTION
      Define connection information: API key and region

    .PARAMETER APIKey
      The API key that will be used for authentication

    .PARAMETER Region
      The region from where you are connecting to Admin by Request (Either US or EU)

    .PARAMETER UserMail
      The e-mail address for a known user in the Admin by Request portal. If not a match this will be ignored

    .EXAMPLE
      PS C:\> Set-ABRConnection -APIKey '01234A56-7890-1B23-CDEF-4567890GH12I' -Region EU
      Set the API key from the portal and set the region to europe

    .EXAMPLE
      PS C:\> Set-ABRConnection -APIKey '01234A56-7890-1B23-CDEF-4567890GH12I' -Region US -UserMail 'John.Doe@company.tld'
      Set the API key and usermail from the portal and set the region to the US
#>
Function Set-ABRConnection
{
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $APIKey,

    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidateSet('EU', 'US')]
    [string]
    $Region,

    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 2)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $UserMail = $null
  )

  Process
  {
    $URL = $null

    Switch ($Region)
    {
      'US'
      {
        $URL = 'https://dc2api.adminbyrequest.com'
        Break
      }

      'EU'
      {
        $URL = 'https://dc1api.adminbyrequest.com'
        Break
      }

      Default
      {
        Throw ('The region {0} isn''t defined' -f $_)
      }
    }

    $Script:ABR_API_Key = $APIKey
    $Script:ABR_API_URL = $URL
    $Script:ABR_API_User = $UserMail

    Get-Variable -Scope Script -Name 'ABR*' | ForEach-Object { Write-Verbose -Message ('{0} => {1}' -f $_.Name, $_.Value) }
  }
}