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