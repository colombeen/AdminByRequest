#region Variables
New-Variable -Scope Script -Visibility Private -Force -Name 'ABR_API_Key' -Value $null
New-Variable -Scope Script -Visibility Private -Force -Name 'ABR_API_URL' -Value $null
New-Variable -Scope Script -Visibility Private -Force -Name 'ABR_API_User' -Value $null
New-Variable -Scope Script -Visibility Private -Force -Name 'ABR_Config_Path' -Value $null
#endregion

#region Load function files
Foreach ($Folder in @('Private', 'Public'))
{
  $FolderPath = Join-Path -Path $PSScriptRoot -ChildPath $Folder

  If (Test-Path -Path $FolderPath)
  {
    $Functions = Get-ChildItem -Path $FolderPath -Filter *.ps1 -Recurse

    Foreach ($Function in $Functions)
    {
      . $Function.FullName

      If ($Folder -notin @('Interal', 'Private'))
      {
        Export-ModuleMember -Function $Function.BaseName
      }
    }
  }
}
#endregion

#region Init default config
Assert-ABRConfig

Try
{
  Select-ABRConfig
}
Catch
{
  Write-Verbose $_
}
#endregion