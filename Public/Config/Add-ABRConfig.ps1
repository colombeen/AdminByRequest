Function Add-ABRConfig
{
  [CmdletBinding(ConfirmImpact = 'Low', SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]
    $APIKey,

    [Parameter(Mandatory = $true, Position = 2)]
    [ValidateSet('EU', 'US')]
    [string]
    $Region,

    [Parameter(Position = 3)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]
    $UserMail,

    [Parameter(Position = 4)]
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

    If ($PSCmdlet.ShouldProcess($ConfigName, 'Add'))
    {
      If ($ConfigName -in $Config.Name)
      {
        Throw ('Can''t use the name {0} because it is already in use' -f $ConfigName)
      }

      If ($Default.IsPresent)
      {
        $Config | ForEach-Object {
          $_.Default = $false
        }
      }

      $Config += [PSCustomObject]@{
        Name     = $ConfigName
        APIKey   = $APIKey
        Region   = $Region
        UserMail = $UserMail
        Default  = ($Default.IsPresent -or $Config.Count -eq 0)
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