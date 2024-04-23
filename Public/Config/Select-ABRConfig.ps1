<#
    .SYNOPSIS
      Select which connection information to load from the ABR config

    .DESCRIPTION
      Select which connection information to load from the config file for Admin by Request

    .PARAMETER Name
      The name of the config information

    .EXAMPLE
      PS C:\> Select-ABRConfig
      Get the default connection information from the Admin by Request config file and load it

    .EXAMPLE
      PS C:\> Select-ABRConfig -name 'Company 2'
      Get the connection information with the name 'Company 2' from the Admin by Request config file and load it
#>
Function Select-ABRConfig
{
  [CmdletBinding(DefaultParameterSetName = 'Default')]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Name', Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name
  )

  Begin
  {
    $Config = @(Get-ABRConfig)
  }

  Process
  {
    $ConfigName = $Name

    $ConfigToLoad = $null

    Switch ($PSCmdlet.ParameterSetName)
    {
      'Default'
      {
        $ConfigToLoad = $Config | Where-Object { $_.Default -eq $true }
      }

      'Name'
      {
        $ConfigToLoad = $Config | Where-Object { $_.Name -eq $ConfigName }
      }
    }

    If ($null -ne $ConfigToLoad)
    {
      $ConfigToLoad | Set-ABRConnection
    }
    Else
    {
      Throw 'No config to load'
    }
  }
}