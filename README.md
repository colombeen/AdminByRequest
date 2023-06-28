# Admin By Request PowerShell module

![Admin by Request PowerShell module](/Images/AdminByRequestPowershellHeader.png)

## Introduction

This repository contains a full Windows PowerShell/Powershell Core module with functions that help you interact with the Admin by Request APIs.
API information can be found on https://www.adminbyrequest.com/docs/api-overview

## Requirements

| Requirement        | Version |
| ------------------ | ------- |
| Windows PowerShell | 5.1+    |
| PowerShell Core    | 6.0+    |

## Installation

The module is available on the [PowerShell gallery](https://www.powershellgallery.com/packages/AdminByRequest).

```powershell
PS C:\> # Install the module
PS C:\> Install-Module -Name 'AdminByRequest'
```

## How to use

PowerShell supports autloading of modules so normally you shouldn't need to import the module manually, I just include it to be thorough.

```powershell
PS C:\> # Import the module
PS C:\> Import-Module -Name 'AdminByRequest'
```

The first thing that is needed at this point is setting up the connection information. 2 out of the 3 parameters are required:

- APIKey
- Region

You are able add the **MailUser** param if you want the audit logs to reflect which user has approved/denied a request.

```powershell
PS C:\> # Setup the connection information
PS C:\> Set-ABRConnection -APIKey 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -Region 'EU' -MailUser 'john.doe@company.tld'
```

At this point you should be able to use any of the available functions to interact with the API.

### Auditlog

```powershell
PS C:\> # Get a list with audit logs
PS C:\> Get-ABRAuditlog | Format-Table

installs        uninstalls      elevatedApplications scanResults id
--------        ----------      -------------------- ----------- --
{}              {@{applicati... {@{name=Microsoft... {}          123456
{@{applicati... {}              {@{name=Microsoft... {}          123457
{}              {}              {@{name=Microsoft... {}          123458
...
```

### Events

```powershell
PS C:\> # Get a list with events
PS C:\> Get-ABREvent | Format-Table

      id eventCode eventLevel eventText                              eventTime
      -- --------- ---------- ---------                              ---------
12345678         6          1 Unaudited administrator logged on      2023-01-...
12345679        40          0 Admin By Request Workstation installed 2023-02-...
12345680         5          0 Audited administrator logged on        2023-03-...
...

PS C:\> # Get a list with all event codes and their text values
PS C:\> Get-ABREventCode | Format-Table

EventCode EventText
--------- ---------
1         User added to local admins group
2         User downgraded from administrator to user
...
```

### Inventory

```powershell
PS C:\> # Get a list with inventory computers
PS C:\> Get-ABRInventory | Format-Table

id        name      inventoryAvailable InventoryDate       abrClientVersion
--        ----      ------------------ -------------       ----------------
123456    Computer1               True 01/02/2023 00:00:00 8.0.1
123457    Computer2               True 02/03/2023 00:00:00 8.0.1
...
```

### Requests

```powershell
PS C:\> # Get a list with requests
PS C:\> Get-ABRRequest | Format-Table

scanResults     id traceNo   type         status  application
-----------     -- -------   ----         ------  -----------
{}          123456 123456789 Run As Admin Pending @{file=wt.exe;...
{}          123457 123456790 Run As Admin Denied  @{file=wt.exe;...
...

PS C:\> # Approve a specific request
PS C:\> Approve-ABRRequest -Id 123456

PS C:\> # Check the status for the approved request
PS C:\> Get-ABRRequest -Id 123456 | Format-Table
scanResults     id traceNo   type         status  application
-----------     -- -------   ----         ------  -----------
{}          123456 123456789 Run As Admin Aproved @{file=wt.exe;...

PS C:\> # Deny a specific request
PS C:\> Deny-ABRRequest -Id 123457 -Reason 'Not allowed by our company policy'
```

### PIN codes

```powershell
PS C:\> # Request an uninstall PIN for a specific device by using the Inventory Id
PS C:\> Request-ABRPinCodeForUninstall -Id 123456
9876543210

PS C:\> # Request an elevation PIN for a specific device by using the ComputerName
PS C:\> Request-ABRPinCodeForElevation -ComputerName Computer1 -Pin1 000000
9876543210
```

## ToDo

- This module has only just been created and could contain alot of bugs, so create an issue if you have any problems.
- Write functions to store config locally.
- I still need to create Pester tests.
- I've tried to add pipeline support to the best of my knowledge but I haven't tested everything yet...
