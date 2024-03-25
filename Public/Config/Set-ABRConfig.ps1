<#
    .SYNOPSIS
      Update connection information in the ABR config

    .DESCRIPTION
      Update connection information in the config file for Admin by Request

    .PARAMETER Name
      The current name for this specific config information

    .PARAMETER NewName
      The new name for this specific config information

    .PARAMETER APIKey
      The API key that will be used for authentication

    .PARAMETER Region
      The region from where you are connecting to Admin by Request (Either US or EU)

    .PARAMETER UserMail
      The e-mail address for a known user in the Admin by Request portal. If not a match this will be ignored

    .PARAMETER Default
      Set this config information as the default one used by the module

    .EXAMPLE
      PS C:\> Set-ABRConfig -Name 'Company' -NewName 'Company 2' -Default
      Update the config information for 'Company' and rename it to 'Company 2' in the Admin by Request config file and make it the default config when the module gets loaded

    .EXAMPLE
      PS C:\> Set-ABRConfig -Name 'Company 2' -APIKey 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Region 'EU'
      Update the config information for 'Company 2' in the Admin by Request config file with a new API key and change the region to Europe
#>
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