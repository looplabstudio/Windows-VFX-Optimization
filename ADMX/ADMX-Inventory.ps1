<#
.SYNOPSIS
    Get a list of all ADMX files on this PC. 

.EXAMPLE
    1. PowerShell as administrator.
    2. CD to script directory.
    3. Run command.

    CD C:\Windows-VFX-Optimization\ADMX
    Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\ADMX-Inventory.ps1

.NOTES
    Author: LoopLab Studio
    GitHub: https://github.com/looplabstudio/Windows-VFX-Optimization
#>


$ADMX_Root = "$env:windir\PolicyDefinitions"

if (Test-Path $ADMX_Root) {
    Write-Host "ADMX directory found: $ADMX_Root" 
} else {
    Write-Host "ADMX directory not found: $ADMX_Root" 
    Write-Host "-------------------------------------------------------------" 
    Write-Host "Script complete" 
    return
}

$Files = Get-ChildItem -Path $ADMX_Root -Filter "*.admx" | Sort-Object Name

Write-Host "Found $($Files.Count) ADMX files."
Write-Host "-------------------------------------------------------------"

foreach ($File in $Files) {
    Write-Host "$($File.Name)" 
}

Write-Host "-------------------------------------------------------------" 
Write-Host "Script complete" 

