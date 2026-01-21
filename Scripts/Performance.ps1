<#
.DESCRIPTION

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                         Performance                         " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry Paths
$HKLM_GraphicDrivers = "SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$HKLM_TimeCheck = "SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\4d2b0152-7d5c-498b-88e2-34345392a2c5"
$HKLM_USBSuspend = "SYSTEM\CurrentControlSet\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\48e6b7a6-50f5-4782-a5d4-53bb8f07e226"


# 2. Registry definitions
$Registry_Defs = @(  
    # GPU 
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "Increase GPU timeout detection to 60 seconds"
        Drive       = "HKLM:\"
        Path        = $HKLM_GraphicDrivers
        Name        = "TdrDelay"
        Value       = 60
        Notes       = @("Prevent driver timeouts during heavy Substance bakes or Fusion renders.")
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "Increase GPU thread timeout to 60 seconds"
        Drive       = "HKLM:\"
        Path        = $HKLM_GraphicDrivers
        Name        = "TdrDdiDelay"
        Value       = 60
        Notes       = @("Prevent driver timeouts during heavy Substance bakes or Fusion renders.")
    }
    [PSCustomObject]@{
        GUILocation = "System > Display > Graphics > Change default graphics settings"
        GUIName     = "Hardware-accelerated GPU scheduling"
        Drive       = "HKLM:\"
        Path        = $HKLM_GraphicDrivers
        Name        = "HwSchMode"
        Value       = 2
        Notes       = @(
            "Not visible until GPU is installed."
            "Offloads VRAM management to GPU to reduce CPU overhead."
        )
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "Disable Energy Estimation"
        Drive       = "HKLM:\"
        Path        = $HKLM_GraphicDrivers
        Name        = "MainSession.EnergyEstimationEnabled"
        Value       = 0
        Notes       = @("Prevents micro-stutters caused by power polling.")
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "Disable Multi-Plane Overlay (MPO)"
        Drive       = "HKLM:\"
        Path        = "SOFTWARE\Microsoft\Windows\Dwm"
        Name        = "OverlayTestMode"
        Value       = 5
        Notes       = @("Critical: Fix UI flickering & artifacts.")
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "Force DirectX apps to prefer the dGPU (RTX) globally"
        Drive       = "HKCU:\"
        Path        = "Software\Microsoft\DirectX\UserGpuPreferences"
        Name        = "DirectXUserGlobalSettings"
        String      = "ActiveGpuSelection=1;"
        Notes       = @()
    }
    # CPU
    [PSCustomObject]@{
        GUILocation = "Core Isolation > Memory Integrity"
        GUIName     = "Memory Integrity (HVCI)"
        Drive       = "HKLM:\"
        Path        = "SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        Name        = "Enabled"
        Value       = 0
        Notes       = @("Reduce memory latency by removing virtualization overhead for Arrow Lake.")
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "System profile: Reserve 100% CPU for multimedia"
        Drive       = "HKLM:\"
        Path        = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Name        = "NetworkThrottlingIndex"
        Value       = 4294967295 # Decimal for 0xFFFFFFFF (Required for UInt32 match)
        Notes       = @("Unlock full bandwidth and improve system responsiveness.")
    }
    [PSCustomObject]@{
        GUILocation = "Registry"
        GUIName     = "System profile: Reserve 0% CPU for background tasks"
        Drive       = "HKLM:\"
        Path        = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
        Name        = "SystemResponsiveness"
        Value       = 0
        Notes       = @("Unlock full bandwidth and improve system responsiveness.")
    }
    [PSCustomObject]@{
        GUILocation = "System Properties > Advanced > Performance Settings > Advanced"
        GUIName     = "Processor Scheduling"
        Drive       = "HKLM:\"
        Path        = "SYSTEM\CurrentControlSet\Control\PriorityControl"
        Name        = "Win32PrioritySeparation"
        Value       = 38
        Notes       = @("Custom hybrid setting that tells CPU to hold on to threads a bit longer.")
    }
    [PSCustomObject]@{
        GUILocation = "System Properties > Advanced > Startup and Recovery Settings"
        GUIName     = "Automatically restart"
        Drive       = "HKLM:\"
        Path        = "SYSTEM\CurrentControlSet\Control\CrashControl"
        Name        = "AutoReboot"
        Value       = 0
        Notes       = @("Stop auto-reboot on BSOD so we can read error codes (RAM vs GPU).")
    }
    [PSCustomObject]@{
        GUILocation = "Edit Power Plan > Change advance power settings > Processor Performance"
        GUIName     = "Time Check"
        Drive       = "HKLM:\"
        Path        = $HKLM_TimeCheck
        Name        = "Attributes"
        Value       = 2
        Notes       = @("GUI: Unhides Time Check for manual config")
    } 
    [PSCustomObject]@{
        GUILocation = "Edit Power Plan > Change advanced power settings > USB settings "
        GUIName     = "Selective Suspend"
        Drive       = "HKLM:\"
        Path        = $HKLM_USBSuspend
        Name        = "Attributes"
        Value       = 2
        Notes       = @("GUI: Unhides Selective Suspend for visual validation")
    } 
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "System\CurrentControlSet\Control\Power\PowerThrottling"
        EditorName   = "Turn off Power Throttling"
        Properties   = @{
            "PowerThrottlingOff" = 1
        }
        Notes        = @("Prevents EcoQoS from throttling background renders.")
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\Task Scheduler\Maintenance"
        EditorName   = "Automatic Maintenance WakeUp Policy"
        Properties   = @{
            "WakeUp" = 0
        }
        Notes        = @("Prevents OS from waking PC for maintenance.")
    } 
)

# =============================================================
# 3. Process Definitions
# =============================================================

try {
    if ($global:DEBUG -eq 0) {
        # 1. Process definitions
        Process_Registry_Defs -Defs $Registry_Defs
        Process_LGPO_Defs -Defs $LGPO_Defs
    } else {
        # 2. Validate definitions
        Validate_Registry_Defs -Defs $Registry_Defs
        Validate_LGPO_Defs -Defs $LGPO_Defs
    }

    # 3. Subscript Complete
    Write-Log "Performance complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}

