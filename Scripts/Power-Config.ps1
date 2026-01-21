<#
.DESCRIPTION
    Uses `powercfg` to optimize PC power plan for Arrow Lake VFX environment.

.NOTES
    Related:
        - Performance.ps1 - Registry keys and Group Policies
        - Services.ps1 - Stops background services and sets to Manual
        - Tasks.ps1 - Disables background tasks
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        Power Config                         " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Power Definitions
# =============================================================

$Power_Actions = @(
    # 1. Enforce High Performance Plan
    @{ 
        Name    = "Enforce High Performance Plan"
        Command = { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c }
        Notes   = @(
            "Critical to prevent Windows from parking P-Cores on the 265K."
            "GUI: Edit Power Plan > Change Advanced Power Settings: Plan dropdown"
            "'High Performance' will not be visible until after this command."
        )
    }
    # 2. Disk Timeout
    @{ 
        Name    = "Disable Disk Timeout AC"
        Command = { powercfg /change disk-timeout-ac 0 }
        Notes   = @(
            "Prevent Seagate HDD spin-down latency."
            "GUI: Edit Power Plan > Change Advanced Power Settings: "
            "GUI: Hard Disk > Turn off hard disk after: Never (0)"
        )
    }
    @{ 
        Name    = "Disable Disk Timeout DC"
        Command = { powercfg /change disk-timeout-dc 0 }
    }
    # 3. PCI Link State (Updated to GUIDs)
    # Fixes 'Invalid Parameters' error by replacing the alias with explicit GUIDs.
    @{ 
        Name    = "Turn off PCI Link State AC"
        # Subgroup: PCI Express (501a4d13...) | Setting: Link State (ee12f906...) | Value: 0 (Off)
        Command = { powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 }
        Notes   = @(
            "Prevent NVMe drives and RTX 3060 from going to sleep"
            "GUI: Edit Power Plan > Change Advanced Power Settings: "
            "GUI: PCI Express > Link State Power Management: Off "
        )
    }
    @{ 
        Name    = "Turn off PCI Link State DC"
        Command = { powercfg /setdcvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 }
    }
    # 4. Processor State
    @{ 
        Name    = "Minimum Processor State AC"
        Command = { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 }
        Notes   = @(
            "Prevent OS from turning off Core Ultra 7 P-Cores "
            "GUI: Edit Power Plan > Change Advanced Power Settings: "
            "GUI: Processor Power Management > Minimum Processor State to 100% "
        )
    }
    @{ 
        Name    = "Minimum Processor State DC"
        Command = { powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 }
    }
    @{ 
        Name    = "Maximum Power State AC"
        Command = { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 }
        Notes   = @("GUI: Processor Power Management > Maximum Processor State to 100% ")
    }
    @{ 
        Name    = "Maximum Power State DC"
        Command = { powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 }
    }
    # 5. Sleep & Display
    @{ 
        Name    = "Sleep Timeout"
        Command = { powercfg /change standby-timeout-ac 120 }
        Notes   = @(
            "GUI: Edit Power Plan > Change Advanced Power Settings"
            "GUI: Sleep > Sleep after 120 minutes"
        )
    }
    @{ 
        Name    = "Monitor Timeout"
        Command = { powercfg /change monitor-timeout-ac 15 }
        Notes   = @(
            "GUI: Edit Power Plan > Change Advanced Power Settings"
            "GUI: Display > Turn off display after 15 minutes"
        )
    }
    # 6. Boost Mode (Arrow Lake Fix)
    @{ 
        Name    = "Unhide Processor Performance Boost Mode"
        Command = { powercfg -attributes SUB_PROCESSOR be337238-0d82-4146-a960-4f3749d470c7 -ATTRIB_HIDE }
        Notes   = @("Fix 'Lazy Frequency' scaling where CPU doesn't boost fast enough for Fusion")
    }
    @{ 
        Name    = "Set Boost Mode to Aggressive AC"
        Command = { powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR be337238-0d82-4146-a960-4f3749d470c7 2 }
    }
    @{ 
        Name    = "Set Boost Mode to Aggressive DC"
        Command = { powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR be337238-0d82-4146-a960-4f3749d470c7 2 }
    }
    # 7. USB Suspend (Fixed GUID)
    # The Subgroup GUID must end in 'ba308a3', NOT 'e8f1'.
    @{ 
        Name    = "Disable USB Selective Suspend AC"
        # Subgroup: 2a737441...ba308a3 | Setting: 48e6b7a6... | Value: 0
        Command = { powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 }
    }
    @{ 
        Name    = "Disable USB Selective Suspend DC"
        Command = { powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 }
    }
    # 9. Memory Agent
    @{ 
        Name    = "Disable Memory Compression"
        Command = { Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue }
        Notes   = @("Force raw RAM access for Fusion's cache instead of burning CPU cycles compressing pages.")
    }
    # 10. Hibernation
    @{ 
        Name    = "Disable Hibernation & Fast Startup"
        Command = { powercfg /hibernate off }
        Notes   = @(
            "Recover disk space and ensure clean kernel boots (fixes uptime bugs)."
            "GUI: Control Panel > Power Options: Choose what the power buttons do"
            "GUI: Click: Change settings that are currently unavailable"
            "GUI: Turn on Fast Startup = False"
        )
    }
    # 11. Apply
    @{ 
        Name    = "Apply Changes"
        Command = { powercfg /setactive SCHEME_CURRENT }
    }
)

# =============================================================
# 2. Functions
# =============================================================

function Set_Power_Configs {
    
    # 1. Skip if no defs to process
    if ($null -eq $Power_Actions -or $Power_Actions.Count -eq 0) {
        Write-Log "No power definitions to process" -Level DETAIL
        return
    }

    # 2. Process definitions in bulk
    try {
        Write-Log "Setting power configs..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV

        # BUG FIX: Use $Power_Actions, not $global:Power_Actions
        foreach ($Action in $Power_Actions) {
            Write-Log "$($Action.Name)" -Level INFO

            try {
                # Execute the script block
                & $Action.Command
                
                # Check for EXE failure (powercfg) OR Cmdlet failure
                if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) {
                    throw "Exit Code: $LASTEXITCODE"
                }

                # Log Success & Notes
                Write-Log "Command executed" -Level PASS

                if ($Action.Notes) {
                    foreach ($Note in $Action.Notes) {
                        Write-Log "$Note" -Level DETAIL
                    }
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Command failed to execute" -Level WARN
                Write-Log "$Detail" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
        }
        Write-Log "Power Configs complete" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }
}

function Validate_Power_Configs {    

    Write-Log "Validating Power Configs..." -Level DETAIL
    Write-Log "-------------------------------------------------------------" -Level DIV

    # 1. Note on Granular Settings
    Write-Log "Granular power settings (PCIe, USB, Processor) are" -Level INFO
    Write-Log "validated by Exit Code during configuration." -Level INFO
    Write-Log "-------------------------------------------------------------" -Level DIV

    # 2. Validate Active Power Plan
    $Target_GUID = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    $Current_Scheme = powercfg /getactivescheme

    if ($Current_Scheme -match $Target_GUID) {
        Write-Log "Active Plan: High Performance" -Level PASS
    } else {
        Write-Log "Active Plan: Mismatch" -Level WARN
        Write-Log "Target: $Target_GUID" -Level DETAIL
        Write-Log "Actual: $Current_Scheme" -Level DETAIL
    }
    Write-Log "-------------------------------------------------------------" -Level DIV

    # 3. Validate Hibernation (File Check)
    if (Test-Path "$env:SystemDrive\hiberfil.sys") {
        Write-Log "Hibernation File: Present (Failed)" -Level WARN
        Write-Log "Size: $((Get-Item "$env:SystemDrive\hiberfil.sys").Length / 1GB) GB" -Level DETAIL
    } else {
        Write-Log "Hibernation File: Absent (Success)" -Level PASS
    }
    Write-Log "-------------------------------------------------------------" -Level DIV


    Write-Log "Power Validation complete" -Level DETAIL
}

# =============================================================
# 3. Process
# =============================================================

if ($global:DEBUG -eq 0) { Set_Power_Configs } else { Validate_Power_Configs }

