Function Assert-ABRConfig
{
  Process
  {
    $Path = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)

    'AdminByRequest', 'PowerShell' | ForEach-Object {
      $Path = Join-Path -Path $Path -ChildPath $_
    }

    If (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue))
    {
      New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }

    $Path = Join-Path -Path $Path -ChildPath 'config.xml'

    If (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue))
    {
      New-Item -Path $Path -ItemType File -Force | Out-Null
    }

    If (Test-Path -Path $Path -ErrorAction SilentlyContinue)
    {
      $Script:ABR_Config_Path = $Path
    }
  }
}