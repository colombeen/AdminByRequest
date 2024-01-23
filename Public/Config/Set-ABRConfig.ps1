Function Set-ABRConfig
{
  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name,

    [Parameter(Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $NewName,

    [Parameter(Position = 2)]
    [ValidateNotNullOrEmpty()]
    [string]
    $APIKey,

    [Parameter(Position = 3)]
    [ValidateSet('EU', 'US')]
    [string]
    $Region,

    [Parameter(Position = 4)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $UserMail,

    [Parameter(Position = 5)]
    [switch]
    $Default
  )

  Begin
  {
    $Config = @(Get-ABRConfig)
  }

  Process
  {
    $ConfigName = $Name

    If ($ConfigName -in $Config.Name)
    {
      If ($PSCmdlet.ShouldProcess($ConfigName, 'Set'))
      {
        If ($Default.IsPresent)
        {
          $Config | ForEach-Object {
            $_.Default = $false
          }
        }

        $Config | Where-Object {
          $_.Name -eq $ConfigName
        } | ForEach-Object {
          If ($PSBoundParameters.ContainsKey('NewName'))
          {
            If ($NewName -in $Config.Name)
            {
              Throw ('Can''t change the name of {0} to {1} because it is already in use' -f $ConfigName, $NewName)
            }

            $_.Name = $NewName
          }
          If ($PSBoundParameters.ContainsKey('APIKey'))
          {
            $_.APIKey = $APIKey
          }
          If ($PSBoundParameters.ContainsKey('Region'))
          {
            $_.Region = $Region
          }
          If ($PSBoundParameters.ContainsKey('UserMail'))
          {
            $_.UserMail = $UserMail
          }
          If ($Default.IsPresent)
          {
            $_.Default = $true
          }
        }
      }
    }
  }

  End
  {
    If ($Config.Count -gt 0)
    {
      $Config | ForEach-Object {
        $_.APIKey = ConvertTo-SecureString -AsPlainText $_.APIKey -Force
        $_
      } | Export-Clixml -Path $Script:ABR_Config_Path -Force
    }
  }
}