<#
    .SYNOPSIS
      Remove connection information from the ABR config

    .DESCRIPTION
      Remove connection information from the config file for Admin by Request

    .PARAMETER Name
      The name of the config information

    .EXAMPLE
      PS C:\> Remove-ABRConfig -Name 'Company 2'
      Remove the config information stored in the Admin by Request config file with the name 'Company 2'
#>
Function Remove-ABRConfig
{
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
  [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess = $true)]
  Param
  (
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Name
  )

  Begin
  {
    $Config = @(Get-ABRConfig)
  }

  Process
  {
    $Name | ForEach-Object {
      $ConfigName = $_

      If ($ConfigName -in $Config.Name)
      {
        If ($PSCmdlet.ShouldProcess($ConfigName, 'Remove'))
        {
          $Config = @($Config | Where-Object { $_.Name -ne $ConfigName })
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
    Else
    {
      Set-Content -Path $Script:ABR_Config_Path -Value ''
    }
  }
}