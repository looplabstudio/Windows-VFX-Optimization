<#
.DESCRIPTION
    GUI Toggles:
        - Turn off: System > Notifications > Additional Settings: Get tips and suggestions when using Windows
        - Turn off: System > Notifications > Additional Settings: Show the Windows Welcome Experience after...
        - Turn off: System > Notifications > Additional Settings: Suggest ways to get the most out of Windows...
        - Turn off: Privacy & Security > General: Show me notification is the settings app

    Group Policies: 
        - Enabled: Turn off Toast notifications 
            - System > Notifications: Notifications
            - System > Notifications: Notifications from apps and other senders

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        Notifications                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_CDM = "Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$HKCU_MS_UserProfileEngagement = "Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{ 
        GUILocation = "System > Notifications > Additional Settings"
        GUIName     = "Get tips and suggestions when using Windows"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SoftLandingEnabled"
        Value       = 0  
    }   
    [PSCustomObject]@{  
        GUILocation = "System > Notifications > Additional Settings"
        GUIName     = "Show the Windows Welcome Experience after..."
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-353694Enabled"
        Value       = 0 
    }  
    [PSCustomObject]@{  
        GUILocation = "System > Notifications > Additional Settings"
        GUIName     = "Suggest ways to get the most out of Windows..."
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_UserProfileEngagement
        Name        = "ScoobeSystemSettingEnabled"
        Value       = 0 
    }
    [PSCustomObject]@{  
        GUILocation = "Privacy & Security > General"
        GUIName     = "Show me notification is the settings app"
        Drive       = "HKCU:\"
        Path        = "Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications"
        Name        = "EnableAccountNotifications" 
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
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
        EditorName   = "Turn off Toast Notifications"
        Properties   = @{
            "NoToastApplicationNotification" = 1
        }
        Notes  = @(
            "System > Notifications: Notifications"
            "System > Notifications: Notifications from apps and other senders"
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
    Write-Log "Notifications complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
