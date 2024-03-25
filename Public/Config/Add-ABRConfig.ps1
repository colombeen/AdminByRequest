<#
    .SYNOPSIS
      Add connection information to the ABR config

    .DESCRIPTION
      Add connection information to the config file for Admin by Request

    .PARAMETER Name
      The name for this specific config information

    .PARAMETER APIKey
      The API key that will be used for authentication

    .PARAMETER Region
      The region from where you are connecting to Admin by Request (Either US or EU)

    .PARAMETER UserMail
      The e-mail address for a known user in the Admin by Request portal. If not a match this will be ignored

    .PARAMETER Default
      Set this config information as the default one used by the module

    .EXAMPLE
      PS C:\> Add-ABRConfig -Name 'Company' -APIKey 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Region 'EU' -UserMail 'john.doe@company.tld' -Default
      Add the config information for 'Company' to the Admin by Request config file and make it the default config when the module gets loaded

    .EXAMPLE
      PS C:\> Add-ABRConfig -Name 'Company 2' -APIKey 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Region 'US'
      Add the config information for 'Company 2' to the Admin by Request config file
#>
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