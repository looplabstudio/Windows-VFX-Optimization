<#
.DESCRIPTION
    GUI Toggles:
        - Turn off: Privacy & Security > General: Let websites show me locally relevant content
    Registry Kays:
        - Disabled: Content Delivery Management (CDM)
        - Disabled: Subscriber Content (ads, suggestions)
        - Disabled: Experimental and staged UI changesS
    Group Policies: 
        - Enabled: Turn off Windows Customer Experience Improvement Program
        - Enabled: Turn off Microsoft consumer experiences
        - Enabled: Turn off the Windows Welcome Experience
        - Enabled: Turn off the advertising ID
        - Enabled: Turn off user tracking
        - Enabled: Do not show feedback notifications
        - Enabled: Do not show Windows tips
        - Disabled: Allow Online Tips

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                          Telemetry                          " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_CDM = "Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "Privacy & Security > General"
        GUIName     = "Let websites show me locally relevant content"
        Drive       = "HKCU:\"
        Path        = "Control Panel\International\User Profile" 
        Name        = "HttpAcceptLanguageOptOut" 
        Value       = 1  
    } 
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Disable telemetry about user profile usage"
        Drive       = "HKCU:\"
        Path        = "Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
        Name        = "UserProfileEngagementConfig"  
        Value       = 0  
    }  
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Prevent Microsoft from remotely enabling experimental UI changes"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "FeatureManagementEnabled"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Disable ads in Settings app and system flyouts"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SystemPaneSuggestionsEnabled"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Disable CDM's ability to pull down third-party apps and ads"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "ContentDeliveryAllowed"
        Value       = 0  
    } 
    # Subscriber Content
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Subscriber Content: Welcome Experience and Lock Screen suggestions"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-338387Enabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Subscriber Content: Suggestions in Settings app"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-338393Enabled"
        Value       = 0 
    }
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Subscriber Content: OOBE reminders"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-353696Enabled"
        Value       = 0 
    } 
    # Legacy
    [PSCustomObject]@{  
        GUILocation = "LEGACY System Notifications > Advanced Settings"
        GUIName     = "Suggest ways to get the most out of Windows..."
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-310093Enabled"
        Value       = 0  
    }  
    [PSCustomObject]@{  
        GUILocation = "LEGACY System > Notifications > Additional Settings"
        GUIName     = "Get tips and suggestions when using Windows"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_CDM
        Name        = "SubscribedContent-338389Enabled"
        Value       = 0 
    }
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_CloudContent = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\CloudContent"
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    # Experience
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\SQMClient\Windows"
        EditorName   = "Turn off Windows Customer Experience Improvement Program"
        Properties   = @{
            "CEIPEnable" = 1
        }
        Notes  = @()
    }      
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_CloudContent.Hive
        Drive        = $HKLM_Pol_CloudContent.Drive
        Path         = $HKLM_Pol_CloudContent.Path 
        EditorName   = "Turn off Microsoft consumer experiences"
        Properties = @{
            "DisableWindowsConsumerFeatures" = 1
        }
        Notes = @(
            "Disables: Bluetooth & Devices > Mobile Devices: Mobile devices"
            "Disables: Bluetooth & Devices > Mobile Devices: Phone Link"
            "Disables: Bluetooth & Devices > Mobile Devices: Show me suggestions"
        )
    }  
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "User"
        Drive        = "HKCU:\"
        Path         = "Software\Policies\Microsoft\Windows\CloudContent"
        EditorName   = "Turn off the Windows Welcome Experience"
        Properties   = @{
            "DisableWindowsSpotlightWindowsWelcomeExperience" = 1
        }
        Notes  = @()
    }      
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
        EditorName   = "Turn off the advertising ID"
        Properties   = @{
            "DisabledByGroupPolicy" = 1
        }
        Notes  = @(
            "Privacy & Security > General: Let apps show me personalized ads"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "User"
        Drive        = "HKCU:\"
        Path         = "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        EditorName   = "Turn off user tracking"
        Properties   = @{
            "NoInstrumentation" = 1
        }
        Notes  = @(
            "Privacy & Security > General: Let Windows improve ... by tracking app launches"
        )
    }  
    # Tips
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        EditorName   = "Do not show feedback notifications"
        Properties   = @{
            "DoNotShowFeedbackNotifications" = 1
        }
        Notes  = @(
            "Privacy & Security > Diagnostics & Feedback: Diagnostic Data, Inking and Typing"
        )
    } 
    [PSCustomObject]@{  
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_CloudContent.Hive
        Drive        = $HKLM_Pol_CloudContent.Drive
        Path         = $HKLM_Pol_CloudContent.Path
        EditorName   = "Do not show Windows tips"
        Properties   = @{
            "DisableSoftLanding" = 1
        }
        Notes = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
        EditorName   = "Allow Online Tips"
        Properties   = @{
            "AllowOnlineTips" = 0
        }
        Notes  = @()
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
    Write-Log "Telemetry complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
