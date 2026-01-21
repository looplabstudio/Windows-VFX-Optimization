<#
.DESCRIPTION
    GUI Toggles:
        - Set: Personalization > Colors: Dark mode
        - Turn off: Personalization > Colors: Transparency Effects
        - Turn off: Accessibility > Keyboard > Sticky keys: Keyboard shortcut for Sticky keys
        - Turn off: Mouse Options > Pointer Options: Enhance pointer precision
        - Turn off: Mouse Options > Pointer Options: Display pointer trails
    Group Policies:
        - Disabled: Allow users to connect remotely by using Remote Desktop Services
            - System > Remote Desktop: Remote Desktop

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                       Personalization                       " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_Personalize = "Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" 
$HKCU_CP = "Control Panel"
$HKCU_CP_Desktop = "$($HKCU_CP)\Desktop"
$HKCU_CP_Mouse = "$($HKCU_CP)\Mouse"

# 2. Registry definitions
$Registry_Defs = @(
    # Colors
    [PSCustomObject]@{  
        GUILocation = "Personalization > Colors"
        GUIName     = "Dark mode (system)"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Personalize
        Name        = "SystemUsesLightTheme"
        Value       = 0
    } 
    [PSCustomObject]@{  
        GUILocation = "Personalization > Colors"
        GUIName     = "Dark mode (apps)"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Personalize
        Name        = "AppsUseLightTheme"
        Value       = 0
    } 
    [PSCustomObject]@{  
        GUILocation = "Personalization > Colors"
        GUIName     = "Transparency effects"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Personalize
        Name        = "EnableTransparency"
        Value       = 0
    } 
    # Mouse
    [PSCustomObject]@{  
        GUILocation = "Bluetooth & Devices > Mouse: Additional mouse settings"
        GUIName     = "Mouse Options > Pointer Options: Enhance pointer precision"
        Drive       = "HKCU:\"
        Path        = $HKCU_CP_Mouse
        Name        = "MouseSpeed"
        Value       = 0
        Notes       = @(
            "Ensures cursor movement is 1:1 with physical hand movement"
        )  
    } 
    [PSCustomObject]@{  
        GUILocation = "Bluetooth & Devices > Mouse: Additional mouse settings"
        GUIName     = "Mouse Options > Pointer Options: Enhance pointer precision"
        Drive       = "HKCU:\"
        Path        = $HKCU_CP_Mouse
        Name        = "MouseThreshold1"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "Bluetooth & Devices > Mouse: Additional mouse settings"
        GUIName     = "Mouse Options > Pointer Options: Enhance pointer precision"
        Drive       = "HKCU:\"
        Path        = $HKCU_CP_Mouse
        Name        = "MouseThreshold2"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "Bluetooth & Devices > Mouse: Additional mouse settings"
        GUIName     = "Mouse Options > Pointer Options: Display pointer trails"
        Drive       = "HKCU:\"
        Path        = $HKCU_CP_Mouse
        Name        = "MouseTrails"
        Value       = 0  
    }     
    # STRINGS
    [PSCustomObject]@{  
        GUILocation = "Accessibility > Keyboard > Sticky keys"
        GUIName     = "Keyboard shortcut for Sticky keys"
        Drive       = "HKCU:\"
        Path        = "$($HKCU_CP)\Accessibility\StickyKeys"
        Name        = "Flags"
        String      = "506"
    } 
    # Animations
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Windows: Min/max/close animation"
        Drive       = "HKCU:\"
        Path        = "$($HKCU_CP_Desktop)\WindowMetrics"
        Name        = "MinAnimate"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Display: Multi-monitor mode change animations"
        Drive       = "HKCU:\"
        Path        = "$($HKCU_CP_Desktop)"
        Name        = "W8OnStopScreenModeChange"
        Value       = 0
    }
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    # Remote Desktop
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "Software\Policies\Microsoft\Windows\System"
        EditorName   = "Continue experiences on this device"
        Properties   = @{
            "EnableCdp" = 0
        }
        Notes  = @(
            "System > Remote Desktop: Remote Desktop"
        )
    }
)

# =============================================================
# 3. Process
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
    Write-Log "Personalization complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
