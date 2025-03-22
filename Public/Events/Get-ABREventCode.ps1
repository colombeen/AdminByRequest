<#
    .SYNOPSIS
      Get a list with event codes and text

    .DESCRIPTION
      Get a (filtered) list with event codes and text. You can filter on the code or the text with wildcard support

    .PARAMETER EventCode
      Filter the list by event code(s)

    .PARAMETER EventText
      Filter the list on event text

    .EXAMPLE
      PS C:\> Get-ABREventCode
      Get a list with all event codes and text values

    .EXAMPLE
      PS C:\> Get-ABREventCode -EventCode 5, 6
      Get a list with event codes 5 and 6 and their text values

    .EXAMPLE
      PS C:\> Get-ABREventCode -EventText '*Local administrator*'
      Get a list with event codes which have a text value that matches 'Local administrator'
#>
Function Get-ABREventCode
{
  [CmdletBinding(DefaultParameterSetName = 'EventCode')]
  Param
  (
    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'EventCode', Position = 0)]
    [Alias('Code')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $EventCode = '*',

    [Parameter(ValueFromPipelineByPropertyName = $true, ParameterSetName = 'EventText', Position = 0)]
    [Alias('Text')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $EventText = '*'
  )

  Begin
  {
    $Events = @'
      EventCode;EventText
      1;User added to local admins group
      2;User downgraded from administrator to user
      3;Group removed from local adminstrators group
      5;Audited administrator logged on
      6;Unaudited administrator logged on
      8;Support assist initiated
      10;Password changed for local user
      11;Local user disabled
      12;Local user enabled
      13;Local user created
      14;Local user deleted
      20;Policy registry key changed
      21;Policy registry key added
      30;Uninstall attempted
      31;Uninstalled by PIN code
      32;PIN code uninstall attempted unsuccessfully
      40;Admin By Request Workstation installed
      41;Admin By Request Workstation uninstalled
      42;Admin By Request Server installed
      43;Admin By Request Server uninstalled
      50;Diagnostics submitted
      60;User restored to local administrators group
      61;Group restored to local administrators group
      70;Break Glass Account created
      71;Break Glass Account removed
      72;Break Glass Account logged on
      73;Clock tampering using Break Glass account
      80;Azure Device Administrator restored
      81;Azure Company Administrator restored
      90;Admin Session denied by policy
      91;Clock tampering during Admin Session
      92;Execution of file blocked by policy
      93;Execution of file blocked due to detected malware
      94;Execution of file blocked due to suspected malware
      95;Admin Session PIN code used
      97;Application block PIN code used
      98;Elevated application block PIN code used
      100;Application block PIN 2 issued
      101;Uninstall PIN issued
      102;Break Glass Account issued
      103;Admin Session PIN 2 issued
      110;Local administrator account revoke issued
      111;Local administrator group revoke issued
      112;Local administrator account revoke cancelled
      113;Local administrator group revoke cancelled
      114;Local administrator account restore issued
      115;Local administrator group restore issued
      116;Local administrator account restore cancelled
      117;Local administrator group restore cancelled
      120;Device owner set
      121;Device ownership released
      122;Device owner set by administrator
      123;Admin Session denied by lack of ownership
      124;Execution of file blocked by lack of ownership
      130;Admin Session denied by lack of Intune compliance
      131;Execution of file blocked by lack of Intune compliance
      140;Remote desktop account revoke issued
      141;Remote desktop group revoke issued
      142;Remote desktop account revoke cancelled
      143;Remote desktop group revoke cancelled
      144;Remote desktop account restore issued
      145;Remote desktop group restore issued
      146;Remote desktop account restore cancelled
      147;Remote desktop group restore cancelled
      150;User removed from remote desktop users
      151;Group removed from remote desktop users
      152;User restored to remote desktop users
      153;Group restored to remote desktop users
      160;Local administrator account addition issued
      161;Local administrator group addition issued
      162;Local administrator account addition cancelled
      163;Local administrator group addition cancelled
      170;Remote desktop account addition issued
      171;Remote desktop group addition issued
      172;Remote desktop account addition cancelled
      173;Remote desktop group addition cancelled
      180;Rotating admin account created
      181;Rotating admin account removed
      182;Rotating admin account logged on
'@ | ConvertFrom-Csv -Delimiter ';'
  }

  Process
  {
    Switch ($PSCmdlet.ParameterSetName)
    {
      'EventCode'
      {
        $EventCode | ForEach-Object {
          $Code = $_
          $Events | Where-Object { $_.EventCode -like $Code }
        }
        Break
      }

      'EventText'
      {
        $EventText | ForEach-Object {
          $Text = $_
          $Events | Where-Object { $_.EventText -like $Text }
        }
        Break
      }
    }
  }
}