# ADMX PowerShell Scripts

For Group Policies, Microsoft publishes this spreadsheet: 

- [Group Policy Settings Reference Spreadsheet for Windows 11 2025 Update (25H2)](https://www.microsoft.com/en-us/download/details.aspx?id=108395)

To help with scripting tasks, I wanted:

- A spreadsheet with each !property on its own row.
- A log file that closely matches how I've defined `$Policy_Defs`.

There are 2 ADMX PowerShell scripts: 

1. `ADMX-Inventory.ps1` is a quick helper utility that gets a list of the ADMX files on a PC and prints them to Console. This list is used to populate `$$ADMX_Files` in `ADMX-Tool`.
2. `ADMX-Tool` parses ADMX files and outputs them as both a CSV file and text log file.


```PowerShell
# 1. PowerShell as administrator.
# 2. CD to script directory.
# 3. Run command.

CD C:\Windows-VFX-Optimization\ADMX
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\ADMX-Inventory.ps1
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\ADMX-Tool.ps1

```
