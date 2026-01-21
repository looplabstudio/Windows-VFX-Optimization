# Commands for identifying kes, tasks, and services

# Vew Registry path keys
$Reg_Path = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
Get-ItemProperty -Path $Reg_Path | Select-Object * -ExcludeProperty ps*

# Find the name and path of a task
$Task_Name = "ProactiveScan" 
Get-ScheduledTask | Where-Object { $_.TaskName -match $Task_Name } | Select-Object TaskName, TaskPath, State

# Find the name and path of a service
$Service_Name = "Killer"
Get-Service | Where-Object { $_.Name -match $Service_Name -or $_.DisplayName -match $Service_Name } | Select-Object Name, DisplayName, Status, StartType




