<#
    .SYNOPSIS
      Get connection information from the ABR config

    .DESCRIPTION
      Get connection information from the config file for Admin by Request

    .PARAMETER Name
      The name of the config information

    .EXAMPLE
      PS C:\> Get-ABRConfig
      Show all config information stored in the Admin by Request config file

    .EXAMPLE
      PS C:\> Get-ABRConfig -Name 'Company 2'
      Show the config information stored in the Admin by Request config file with the name 'Company 2'
#>
Function Get-ABRConfig
{
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name = '*'
  )

  Process
  {
    If ($null -ne $Script:ABR_Config_Path)
    {
      Try
      {
        Import-Clixml -Path $Script:ABR_Config_Path -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $Name } | ForEach-Object {
          $_.APIKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($_.APIKey))
          $_
        }
      }
      Catch
      {
        Write-Verbose $_
      }
    }
  }
}