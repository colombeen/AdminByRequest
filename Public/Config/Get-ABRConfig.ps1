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