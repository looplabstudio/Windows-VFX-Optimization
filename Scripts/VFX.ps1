<#
.SYNOPSIS
    Master Controller for Windows 11 optimization scripts.
.EXAMPLE
    1. PowerShell as administrator.
    2. CD to script directory.
    3. Run script.

CD E:\Windows-VFX-Optimization\Scripts
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\VFX.ps1
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\VFX.ps1 -DebugMode 1
code $env:TEMP\lgpo_batch.txt

.NOTES
    Author: LoopLab Studio
    GitHub: https://github.com/looplabstudio/Windows-VFX-Optimization
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet(0,1)]
    [int]$DebugMode = 0
)

# Replace your global variable with the parameter value
$global:DEBUG = $DebugMode

Write-Host "`n============================================================" 
Write-Host "            Windows 11 Pro 25H2 VFX Optimization            " 
Write-Host "             Intel Core Ultra 7 265K Arrow Lake             "
Write-Host "============================================================" 

# =============================================================
# 1. GLOBAL CONFIGS
# =============================================================

# 1. Capture timestamp for file names
$File_Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# =============================================================
# 2. GENERAL UTILITY FUNCTIONS
# =============================================================

# 1. Restore focus to PowerShell after stop/start processes
# Define the Windows API call to force focus
function Restore_PS_Focus {
    if ($global:DEBUG -ne 0) { return }

    # 1. Define the Win32 API signatures
    $Sig = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c); [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);'
    
    # 2. Add the type (using -ErrorAction SilentlyContinue in case it's already loaded in the session)
    $null = Add-Type -MemberDefinition $Sig -Name "Win32Focus" -Namespace Win32 -PassThru -ErrorAction SilentlyContinue

    # 3. Get the handle for the current PowerShell window
    $hwnd = (Get-Process -Id $pid).MainWindowHandle
    
    # 4. Perform the "Yank": Minimize (6) then Restore (9)
    # This bypasses the Windows Foreground Lock by simulating a user 'restoring' the app
    [Win32.Win32Focus]::ShowWindow($hwnd, 6) | Out-Null
    Start-Sleep -Milliseconds 100
    [Win32.Win32Focus]::ShowWindow($hwnd, 9) | Out-Null
    [Win32.Win32Focus]::SetForegroundWindow($hwnd) | Out-Null
}

# 2. Create a directory if it doesn't exist
function Create_Directory {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    try {
        if (Test-Path $Path) {
            Write-Log "Directory exists: $Path" -Level PASS
            return
        }
        New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null 
        Write-Log "Directory created: $Path" -Level PASS

    } catch {
        $Detail = $_.Exception.Message
        throw "Failed to create directory: $Path`n$Detail"
    }
}

# =============================================================
# 3. PRE-FLIGHT FUNCTIONS
# =============================================================

# 1. Check \LGPO\LGPO.exe exists
function Check_LGPO_Exe {
    param (
        [Parameter(Mandatory=$true)] [string]$Path
    )
    try {
        if (Test-Path $Path) {
            Write-Log "LGPO.exe found: $Path" -Level PASS        
        } else {
            $Details = @(
                "1. Download the Microsoft Security Compliance Toolkit LGPO.zip"
                "   https://www.microsoft.com/en-us/download/details.aspx?id=55319"
                "2. Extract and place contents at: $($PSScriptRoot)\LGPO\"
            )
            throw ($Details -join "`n")
        }
    }
    catch {
        $Detail = $_.Exception.Message
        throw "LGPO.exe is required`n$Detail"
    }
}

# 2. Check BIOS microcode
function Check_Microcode {
    $Reg_Path = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"
    $Key_Name = "Update Revision"
    $Target_Hex = 0x114

    try {
        $Val = (Get-ItemProperty -Path $Reg_Path -ErrorAction Stop).$Key_Name
        
        # Registry returns a Byte Array, convert to Int for comparison
        if ($Val -is [byte[]]) {
            $Int_Val = [System.BitConverter]::ToInt32($Val, 0)
        } else {
            $Int_Val = [int]$Val
        }
        
        $Hex_Val = "{0:X}" -f $Int_Val

        if ($Int_Val -ge $Target_Hex) {
            Write-Log "Microcode Version: 0x$Hex_Val (Safe)" -Level PASS
        } else {
            Write-Log "Microcode Version: 0x$Hex_Val (UNSAFE)" -Level ERROR
            Write-Log "Intel released a critical `microcode update 0x114` to fix `Vmin Shift` instability and scheduler confusion." 
            Write-Log "Update BIOS immediately to prevent physical degradation." -Level DETAIL   
        }
    }
    catch {
        Write-Log "Could not read Microcode version." -Level ERROR
        Write-Log $_.Exception.Message -Level DETAIL
    }
}

# 3. Check for KB5044384 to resolve the 24H2 E-Core scheduler bug.
# This patch specifically tells the Thread Director that `Resolve.exe` requires P-Cores.
function Check_SchedulerPatch {
    
    try {
        # 1. Check OS Version first; if 25H2+, the bug is natively fixed
        $KBID = "KB5044384"
        $Patch_Name = "24H2 Scheduler Patch: $KBID"

        $OSVersion = (Get-ComputerInfo).WindowsVersion

        if ([int]$OSVersion -ge 25) {
            Write-Log "Windows $OSVersion detected. $Patch_Name natively integrated into kernel." -Level PASS
            return
        }

        # 2. Check for the specific KB on 24H2 systems
        $Patch = Get-HotFix -Id $KBID -ErrorAction SilentlyContinue

        if (-not $Patch) {
            Write-Log "Missing $KBID. " -Level ERROR
            Write-Log "Fusion threads may be incorrectly dumped to E-Cores" -Level DETAIL
        }
    }
    catch {
        $Detail = $_.Exception.Message
        Write-Log "$Detail"
    }
}

# 4. Close windows
function Stop_Processes {
    if ($global:DEBUG -ne 0) {
        Write-Log "Skipped stopping processes" -Level DETAIL
        return
    }
    try {
        # 1. File Explorer
        # Note: Stopping explorer.exe cause the taskbar and desktop to disappear temporarily.
        Write-Log "Stopping File Explorer..." -Level INFO
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue  
         
        # 2. Group Policy Editor
        # GP Editor runs as a snap-in within the Microsoft Management Console (mmc).
        Write-Log "Stopping Group Policy Editor..." -Level INFO
        Get-Process -Name "mmc" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

        # 3. Stopping Settings App
        Write-Log "Stopping Settings App..." -Level INFO
        Get-Process -Name "SystemSettings" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2        
    }
    catch {
        $Detail = $_.Exception.Message
        throw "Failed to close active windows: $Detail"
    }
}

# 5. Prompt for and backup .reg and .pol files
function Backup_Registry {
    # 1. Skip if we are debugging
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: Backup Registry" -Level DETAIL
        return
    }

    # 2. Prompt for backup
    Write-Log "Back up Registry (.reg) and Policy (.pol) files?" -Level PROMPT
    $Response = Read-Host "[y] Yes [N] No"

    # 3. Skip if user declines
    if ($Response -notmatch "Y") {
        Write-Log "User declined backup" -Level DETAIL
        return
    }

    # 4. Create \Backups\ directory
    $Backup_Dir = Join-Path -Path $PSScriptRoot -ChildPath "Backups"
    Create_Directory -Path $Backup_Dir

    # 5. Backup .reg
    try {
        # Check $LASTEXITCODE because 'reg.exe' is an external tool. 
        # External tools don't always trigger 'catch' blocks.
        reg export "HKLM" "$Backup_Dir\$($File_Timestamp)_HKLM.reg" /y | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "HKLM export failed with exit code $LASTEXITCODE" }

        reg export "HKCU" "$Backup_Dir\$($File_Timestamp)_HKCU.reg" /y | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "HKCU export failed with exit code $LASTEXITCODE" }

        Write-Log "Registry (.reg) backup complete" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        throw "Registry (.reg) backup failed`n$Detail"
    }

    # 6. Backup .pol
    try {
        $Pol_Files = @(
            @{ Path = "$env:windir\System32\GroupPolicy\Machine\registry.pol"; Scope = "Machine" },
            @{ Path = "$env:windir\System32\GroupPolicy\User\registry.pol";    Scope = "User" }
        )

        foreach ($Entry in $Pol_Files) {
            if(-not (Test-Path $Entry.Path)) { 
                Write-Log "$($Entry.Scope) local policy file not found" -Level WARN
                Write-Log "This is normal with a fresh OS. Continuing..." -Level WARN
                continue 
            }

            $Dest = Join-Path $Backup_Dir "$($File_Timestamp)_$($Entry.Scope).pol"
            Copy-Item -Path $Entry.Path -Destination $Dest -Force -ErrorAction Stop
        }
        Write-Log "Policy (.pol) backup complete" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        throw "Policy (.pol) backup failed`n$Detail"
    }
}

# 6. Prompt for and set a System Restore point
function Set_Restore_Point {
    # 1. Skip if we are debugging
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: System Restore point" -Level DETAIL
        return
    }

    # 2. Prompt for Restore Point
    Write-Log "Set a System Restore point?" -Level PROMPT
    $Response = Read-Host "[y] Yes [N] No"

    # 3. Skip if user declines
    if ($Response -notmatch "Y") {
        Write-Log "User declined setting System Restore point" -Level DETAIL
        return
    }

    # 4. Prompt for description
    Write-Log "Enter a custom description or [Enter] for default" -Level PROMPT
    $Point_Desc = Read-Host "Description"
    
    # 5. Sanitize: Replace spaces/hyphens with underscores to prevent WMI errors
    if ([string]::IsNullOrWhiteSpace($Point_Desc)) { 
        $Point_Desc = "Pre_VFX_Optimization" 
    } else {
        $Point_Desc = $Point_Desc -replace '[^a-zA-Z0-9]', '_'
    }

    # 6. Set Restore point
    try {
        # Bypass the 24-hour limit for restore point creation
        $Reg_Path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
        if (-not (Test-Path $Reg_Path)) { 
            New-Item -Path $Reg_Path -Force | Out-Null 
        }
        Set-ItemProperty -Path $Reg_Path -Name "SystemRestorePointCreationFrequency" -Value 0 -Force -ErrorAction Stop

        Write-Log "Creating Restore point. This may take a minute..." -Level DETAIL
        
        # Ensure protection is enabled on the System Drive
        # We use $env:SystemDrive to be safe if Windows isn't on C:
        Enable-ComputerRestore -Drive $env:SystemDrive -ErrorAction Stop
        
        # Checkpoint-Computer triggers the actual snapshot
        Checkpoint-Computer -Description $Point_Desc -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        
        Write-Log "System Restore point created: $Point_Desc" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        # Provide specific advice for common "Disabled by Admin" errors
        if ($Detail -match "disabled by group policy") {
            $Detail += "`nCheck: Computer Configuration > Administrative Templates > System > System Restore"
        }
        throw "Failed to set System Restore point`n$Detail"
    } 
}

# =============================================================
# 4. IN-FLIGHT REGISTRY FUNCTIONS
# =============================================================

# 1. Process Registry definitions
function Process_Registry_Defs {
    param ( [array]$Defs ) 
    if ($global:DEBUG -ne 0) { return }

    # 1. Skip if no definitions
    if ($null -eq $Defs -or $Defs.Count -eq 0) {
        Write-Log "No Registry definitions to process." -Level DETAIL
        return
    }  

    # 2. Process definitions in bulk
    try {
        Write-Log "Processing Registry definitions..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
       foreach ($Def in $Defs) {
            try {
                Write-Log "$($Def.GUILocation): $($Def.GUIName)" -Level INFO

                # 2.1 Validation: Path Variable
                if ([string]::IsNullOrWhiteSpace($Def.Path)) {
                    throw "Definition is missing 'Path'"
                }

                # 2.2 Construct Path
                $Reg_Path = Join-Path -Path $Def.Drive -ChildPath $Def.Path

                # 2.3 STRICT PATH POLICY: Parent path must exist.
                # We do NOT create registry keys (folders) blindly.
                if (-not (Test-Path $Reg_Path)) {
                    throw "Path not found: $($Reg_Path)"
                }

                # 2.4 Determine Value & Type
                if ($null -ne $Def.Value) {
                    $Reg_Value = $Def.Value
                    $Reg_Type  = "DWord"
                }
                else {
                    $Reg_Value = $Def.String
                    $Reg_Type  = "String"
                } 

                # 2.5 Set Item (Property)
                # -Force creates the PROPERTY if missing, but relies on Path existing (Step C)
                Set-ItemProperty -Path $Reg_Path -Name $Def.Name -Value $Reg_Value -Type $Reg_Type -Force -ErrorAction Stop

                # 2.6 Verify
                $Verify = (Get-ItemProperty -Path $Reg_Path -Name $Def.Name).$($Def.Name)
                
                if ($Verify -eq $Reg_Value) {
                    Write-Log "Set: $($Def.Name) = $Verify" -Level PASS
                } else {
                    throw "Mismatch: Write [$Reg_Value] != Read [$Verify]"
                }

                # 2.7 Notes
                if ($null -ne $Def.Notes -and $Def.Notes.Count -gt 0) {
                    foreach ($Note in $Def.Notes) {
                        Write-Log "$Note" -Level DETAIL
                    }
                }
                Write-Log "-------------------------------------------------------------" -Level DETAIL
            }
            catch {
                # INNER CATCH: Logs the specific error, then CONTINUES to the next item
                Write-Log "Failed to set: $($Def.Name)" -Level ERROR
                Write-Log "$($_.Exception.Message)" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DETAIL
                continue
            }
        }

        # 3. Complete
        Write-Log "Registry definitions complete" -Level DETAIL

    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

# 2. Validate Registry definitions in .reg
function Validate_Registry_Defs {
    param ( [array]$Defs )
    if ($global:DEBUG -ne 1) { return }

    # 1. Skip if no policies to process
    if ($null -eq $Defs -or $Defs.Count -eq 0) {
        Write-Log "No Registry definitions to validate" -Level DETAIL
        return
    }
    try {
        # 2. Process definitions in bulk
        Write-Log "Validating Registry definitions..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV

        foreach ($Def in $Defs) {
            Write-Log "Check: $($Def.GUILocation): $($Def.GUIName)" -Level INFO

            # 2.1 Determine expected value and type (Detect String vs Value)
            if ($null -ne $Def.String) {
                $Expected_Value = $Def.String
            } else {
                $Expected_Value = $Def.Value
            }
            
            # 2.2 Get the actual value from .reg
            $Reg_Path = "$($Def.Drive)$($Def.Path)"
            $Current_Value = (Get-ItemProperty -Path $Reg_Path -Name $Def.Name -ErrorAction SilentlyContinue).$($Def.Name)

            # 2.3 Make null results display-ready
            $Display_Expected = if ($null -eq $Expected_Value) { "NULL" } else { $Expected_Value }
            # For keys that don't exist yet, show "MISSING" instead of just "NULL"
            $Display_Current  = if ($null -eq $Current_Value) { "MISSING" } else { $Current_Value }

            # 2.4 Compare and Log
            if ($null -ne $Current_Value -and $Expected_Value.ToString() -eq $Current_Value.ToString()) {
                Write-Log "$($Def.Name) = $($Display_Expected)" -Level PASS
            } else {
                Write-Log "$($Def.Name) = $($Display_Current) (expected $($Display_Expected))" -Level ERROR
            }
            Write-Log "-------------------------------------------------------------" -Level DIV
        }

        # 3. Complete
        Write-Log "Registry validation complete" -Level DETAIL
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

# =============================================================
# 5. IN-FLIGHT LGPO FUNCTIONS
# =============================================================

# 1. Process Group Policy definitions
function Process_LGPO_Defs {
    param ( [array]$Defs ) 
    if ($global:DEBUG -ne 0) { return }

    # 1. Skip if no policies to process
    if ($null -eq $Defs -or $Defs.Count -eq 0) {
        Write-Log "No LGPO definitions to process" -Level DETAIL
        return
    }

    # 2. Collect definitions
    try {
        Write-Log "Collecting LGPO definitions..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV

        foreach ($Def in $Defs) {
            # 2.1 Skip if Action is not 0 or 1
            if ($Def.Action -eq 0) {
                Write-Log "Delete: $($Def.Hive): $($Def.EditorName)" -Level INFO
            } elseif ($Def.Action -eq 1) {
                Write-Log "Set: $($Def.Hive): $($Def.EditorName)" -Level INFO
            } else {
                Write-Log "Skip: $($Def.Hive): $($Def.EditorName)" -Level INFO
                Write-Log "Action = $($Def.Action) (expected 0 or 1)" -Level ERROR
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue                
            }
            
            # 2.2 Collect properties
            foreach ($Property in $Def.Properties.Keys) {
                $Value = $Def.Properties[$Property]
                $Status = if ($Def.Action -eq 1) { "DWORD:$Value" } else { "DELETE" }

                $global:LGPO_Lines.Add("$($Def.Hive)")
                $global:LGPO_Lines.Add("$($Def.Path)")
                $global:LGPO_Lines.Add("$Property")
                $global:LGPO_Lines.Add("$Status")

                if ($($Def.Action -eq 0)) {
                    Write-Log "$($Property)" -Level WARN
                } else {
                    Write-Log "$($Property) = $($Value)" -Level PASS
                }
            }

            # 2.3 Display notes
            if ($null -ne $Def.Notes -and $Def.Notes.Count -gt 0) {
                foreach ($Note in $Def.Notes) {
                    Write-Log "$Note" -Level DETAIL
                }
            }
            Write-Log "-------------------------------------------------------------" -Level DIV
        }

        # DEBUG
        $global:LGPO_Lines | ForEach-Object { Write-Log "LINE: $_" -Level DETAIL }

        # 3. Complete
        Write-Log "LGPO collection complete" -Level DETAIL
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

# 2. Update LGPO with Group Policy definitions
function Update_LGPO {
    param (
        [array]$LGPO_Lines
    )
    if($global:DEBUG -ne 0) { return }

    # 1. Skip if no lines were collected
    if ($null -eq $LGPO_Lines -or $LGPO_Lines.Count -eq 0) {
        Write-Log "No LGPO Group Polices to update." -Level DETAIL
        return
    }

    # 2. LGPO.exe
    try {
        Write-Log "Updating LGPO..." -Level DETAIL
        Write-Log "LGPO_Lines.Count = $($LGPO_Lines.Count)" -Level DETAIL

        # 2.1 Create the temp file path
        $Temp_Config = Join-Path $env:TEMP "lgpo_batch.txt"

        # 2.2 Use Out-File with the list
        # We use 'Default' (ANSI) because 'Unicode' often breaks the DELETE keyword in LGPO.exe
        $LGPO_Lines | Out-File -FilePath $Temp_Config -Encoding Default -Force

        # 2.3 (Optional) Ensure clean slate
        # If your policies are stuck, uncomment the line below to reset the Machine policy file BEFORE writing new ones.
        # Remove-Item "$env:SystemRoot\System32\GroupPolicy\Machine\registry.pol" -ErrorAction SilentlyContinue

        # 2.4 Run LGPO.exe against the temp file
        $LGPO_Output = & $LGPO_Path /t $Temp_Config 2>&1

        # 2.5 Check for success/failure
        if ($LGPO_Output -match "Success" -or $LASTEXITCODE -eq 0) {
            Remove-Item $Temp_Config -ErrorAction SilentlyContinue
            gpupdate /force | Out-Null
            Write-Log "LGPO update complete" -Level PASS
        } else {
            $LGPO_Output | ForEach-Object { Write-Log "  -> $_" -Level DETAIL }
            Remove-Item $Temp_Config -ErrorAction SilentlyContinue
            throw "LGPO update failed"            
        }
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

# 3. Validate Group Policy definitions in .reg
function Validate_LGPO_Defs {
    param ( [array]$Defs )
    if ($global:DEBUG -ne 1) { return }

    # 1. Skip if no policies to process
    if ($null -eq $Defs -or $Defs.Count -eq 0) {
        Write-Log "No LGPO definitions to validate" -Level DETAIL
        return
    }

    # 2. Validate definitions in bulk
    try {
        Write-Log "Validating LGPO definitions..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV

        foreach ($Def in $Defs) { 
            # 2.1 Skip if Action is not 0 or 1
            if ($Def.Action -eq 0 -or $Def.Action -eq 1) {
                Write-Log "Check: $($Def.Hive): $($Def.EditorName)" -Level INFO
            } else {
                Write-Log "Skip: $($Def.Hive): $($Def.EditorName)" -Level INFO
                Write-Log "Action = $($Def.Action) (expected 0 or 1)" -Level ERROR
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue                
            }

            foreach ($Property in $Def.Properties.Keys) {
                # 2.2 Get expected value
                $Expected_Value = if ($Def.Action -eq 0) { $null } else { $Def.Properties[$Property] }
                
                # 2.3 Get the actual value from .reg
                $Reg_Path = "$($Def.Drive)$($Def.Path)"
                $Current_Value = (Get-ItemProperty -Path $Reg_Path -ErrorAction SilentlyContinue).$Property

                # 2.4 Make null results display-ready
                $Display_Expected = if ($null -eq $Expected_Value) { "NULL" } else { $Expected_Value }
                $Display_Current = if ($null -eq $Current_Value) { "NULL" } else { $Current_Value }

                # 2.5 Complete
                if ($null -eq $Expected_Value -and $null -eq $Current_Value -or $Expected_Value -eq $Current_Value) {
                    Write-Log "$($Property) = $($Display_Expected)" -Level PASS
                } else {
                    Write-Log "$($Property) = $($Display_Current) (expected $($Display_Expected))" -Level ERROR
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
        }

        # 3. Complete
        Write-Log "LGPO validation complete" -Level DETAIL
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

# =============================================================
# 5. POST-FLIGHT FUNCTIONS
# =============================================================

# 1. Flush DNS caches
function Flush_DNS_Cache {
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: Flush DNS cache" -Level DETAIL
        return
    }
    try {
        ipconfig /flushdns | Out-Null
        Write-Log "DNS cache flushed" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        Write-Log "Failed: Flush DNS cache" -Level WARN
        Write-Log "$Detail" -Level DETAIL
    }
}

# 2. Flush Windows Temp directories
function Flush_Win_Temp_Dirs {
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: Flush Windows Temp directories" -Level DETAIL
        return
    }
    try {
        $Temp_Dirs = "C:\Windows\Temp", "$env:LOCALAPPDATA\Temp"
        foreach ($Dir in $Temp_Dirs) {
            if (Test-Path $Dir) {
                # Process each item individually to prevent locked files
                # from stopping the entire directory clean
                $Items = Get-ChildItem -Path $Dir -ErrorAction SilentlyContinue
                foreach ($Item in $Items) {
                    try {
                        # Exclude workstation-specific directories
                        if ($Item.FullName -match "Dell|CommandUpdate") { continue }
                        Remove-Item -Path $Item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                    } catch { 
                        # Ignore individual file locks
                        continue 
                    }
                }
            }
        }
        Write-Log "Windows Temp directories flushed " -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        Write-Log "Failed to flush Windows Temp directories`n$Detail" -Level WARN
        Write-Log "$Detail" -Level DETAIL
    }
}

# 3. Restart Explorer
function Restart_Explorer {
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: Restart explorer.exe" -Level DETAIL
        return
    }
    try {
        Write-Log "Restarting File Explorer and Taskbar..." -Level DETAIL
        Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue 
        Start-Process "explorer" 
        Start-Sleep -Seconds 2
    }
    catch {
        $Detail = $_.Exception.Message
        Write-Log "Failed: Restart explorer.exe" -Level WARN
        Write-Log "$Detail" -Level DETAIL
    }
}

# 4. Prompt for system restart and finish script
function Prompt_Restart {
    # 1. Skip if we are debugging
    if($global:DEBUG -ne 0) {
        Write-Log "Skipped: System restart" -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
        Write-Log "Validation complete`n" -Level PASS
        return
    }

    # 2. Prompt for restart
    Write-Log "A system restart is recommended. Restart now?" -Level PROMPT
    $Response = Read-Host "[y] Yes [N] No"

    # 3. Skip if user declines
    if ($Response -notmatch "Y") {
        Write-Log "User declined restart" -Level DETAIL
        Write-Log "Please restart manually to apply changes" -Level WARN
        Write-Log "-------------------------------------------------------------" -Level DIV
        Write-Log "Script complete`n" -Level PASS
        return
    } 
    
    # 4. Finish and restart
    Write-Log "Restarting computer..." -Level PASS
    Write-Log "-------------------------------------------------------------" -Level DIV
    Write-Log "Script complete`n" -Level PASS
    Start-Sleep -Seconds 2 
    Restart-Computer -Force
}

# =============================================================
# 6. MAIN CONTROLLER
# =============================================================

function Controller {
    try {
        #-------------------------------------------------------------
        # 0. LOGGING
        #-------------------------------------------------------------
        # 1. Logging paths
        $Log_Dir  = Join-Path -Path $PSScriptRoot -ChildPath "Logs"
        $Log_Prefix = if($global:DEBUG -eq 0) { "Run_" } else { "Validate_" }
        $Log_File = Join-Path -Path $Log_Dir -ChildPath "$($Log_Prefix)$($File_Timestamp).txt"

        # 2. Private logging function
        function Write-Log {
            param (
                [Parameter(Mandatory=$true)] [string]$Message,
                [ValidateSet("SECT", "INFO", "DETAIL", "DIV", "PROMPT", "PASS", "WARN", "ERROR")]
                [string]$Level = "INFO"
            )
            try {
                $Log_Entry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
                $Log_Entry | Out-File -FilePath $Log_File -Append -Encoding utf8

                $Color = switch($Level) {
                    "SECT" { "Gray" }
                    "INFO" { "Gray" }
                    "DETAIL" {"DarkGray"}
                    "DIV" {"DarkGray"}
                    "PROMPT" { "Yellow" }
                    "PASS" { "Green" }
                    "WARN"  { "Yellow" }
                    "ERROR" { "Red" }
                    default { "Gray" }
                }

                Write-Host $Message -ForegroundColor $Color

                } catch {
                    $Detail = $_.Exception.Message
                    # Do not alter this message - match in Controller's catch
                    throw "Could not write to log: $Log_File`n$Detail"
                }
        }

        # 3. Create log directory 
        # Must come after Write_Log function and before subsequent use
        Create_Directory -Path $Log_Dir
        Write-Log "Log file started: $Log_File" -Level PASS

        #-------------------------------------------------------------
        # 1. PREFLIGHT
        #-------------------------------------------------------------  
        # 1. Validate LGPO
        $LGPO_Dir   = "$($PSScriptRoot)\LGPO"
        $LGPO_Path  = Join-Path -Path $LGPO_Dir -ChildPath "LGPO.exe"
        Check_LGPO_Exe -Path $LGPO_Path
        Write-Log "DEBUG level = $global:DEBUG" -Level INFO

        # 2. Temporary storage for LGPO
        # $LGPO_Lines = @()
        $global:LGPO_Lines = New-Object System.Collections.Generic.List[string]

        # 3. Microcode
        Check_Microcode
        # 4. Scheduler Patch
        Check_SchedulerPatch
        # 5. Stop active windows
        Stop_Processes
        Restore_PS_Focus
        # 6. Registry Backup
        Backup_Registry
        # 7. System Restore
        Set_Restore_Point

        # 8. Complete
        Write-Log "Pre-flight complete. Starting subscripts..." -Level DETAIL

        #-------------------------------------------------------------
        # 2. SUBSCRIPTS
        #-------------------------------------------------------------
        # 1. Define subscripts
        $Subscripts = @(
            # # VFX and Arrow Lake Specific Optimizations
            # "Performance.ps1"  
            # "Services.ps1"     
            # "Tasks.ps1"        
            # "Power-Config.ps1" 
            # # Broad Optimizations
            "Activity-Feed.ps1"     
            # "App-Permissions.ps1"   
            # "Clipboard-History.ps1" 
            # "Cloud-Content.ps1"     
            # "Copilot-AI.ps1"        
            # "Diagnostic-Data.ps1" 
            # "File-Explorer.ps1"   
            # "Gaming.ps1"          
            # "Ink-Workspace.ps1"   
            # "MS-Edge.ps1"         
            # "Notifications.ps1"   
            # "OneDrive.ps1"        
            # "Personalization.ps1" 
            # "Search.ps1"          
            # "Spotlight.ps1"       
            # "Start-Menu.ps1"      
            # "Taskbar.ps1"         
            # "Telemetry.ps1"       
            # "Widgets.ps1"         
        )

        # 2. Execute subscripts in current scope
        foreach ($Script in $Subscripts) {
            try {
                # 1. Skip missing script files 
                $Script_Path = Join-Path -Path $PSScriptRoot -ChildPath $Script

                if (-not (Test-Path $Script_Path)) {
                    Write-Log "Subscript not found: $Script_Path" -Level WARN
                    Write-Log "Continuing to next subscript..." -Level INFO
                    continue
                } 

                # 2. Call script, child scope
                # Using & (Call Operator) runs it in a CHILD scope.
                & $Script_Path
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Error in $Script`n$Detail" -Level WARN
                Write-Log "Continuing to next script..." -Level INFO
                continue
            }
        }        

        # 3. Complete
        Write-Log "-------------------------------------------------------------" -Level DIV
        Write-Log "Subscripts complete" -Level DETAIL

        #-------------------------------------------------------------
        # 3. POST-FLIGHT
        #-------------------------------------------------------------
        # 1. Update LGPO
        Update_LGPO -LGPO_Lines $global:LGPO_Lines
        # 3. Flush DNS cache
        Flush_DNS_Cache
        # 4. Flush Windows Temp directories
        Flush_Win_Temp_Dirs
        # 5. Restart explorer.exe
        Restart_Explorer
        Restore_PS_Focus
        # 5. Prompt for restart and finish
        Prompt_Restart
    }
    catch {
        $Detail = $_.Exception.Message

        if ($Detail -like "*Could not write to log*") {
            Write-Host "-------------------------------------------------------------"
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "Script terminated" -ForegroundColor Red
        }
        elseif (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "-------------------------------------------------------------" -Level INFO
            Write-Log "FATAL ERROR: $Detail" -Level ERROR
            Write-Log "Script terminated" -Level ERROR
        } else {
            Write-Host "-------------------------------------------------------------"
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "Script terminated" -ForegroundColor Red
        }
        return 
    }
}

# 0. Run this puppy
Controller
