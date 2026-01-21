<#
.DESCRIPTION
    Group Policies: 
        - Enabled, Force deny: Let Windows apps run in the background
            - Apps > Installed apps > App Name > Advanced options: Background app permissions

        Privacy & Security: App permissions > App name: Access toggle

        - Revert: Let Windows apps access location
        - Enabled, Force deny: Let Windows apps access the camera
        - Revert: Let Windows apps access the microphone
        - Enabled, Force deny: Let Windows apps access account information
        - Enabled, Force deny: Let Windows apps access call history
        - Enabled, Force deny: Let Windows apps access contacts
        - Enabled, Force deny: Let Windows apps access diagnostic information about other apps
        - Enabled, Force deny: Let Windows apps access email
        - Enabled, Force deny: Let Windows apps access messaging
        - Enabled, Force deny: Let Windows apps access notifications
        - Enabled, Force deny: Let Windows apps access Tasks
        - Enabled, Force deny: Let Windows apps access the calendar
        - Enabled, Force deny: Let Windows apps access trusted devices
        - Enabled, Force deny: Let Windows apps activate with voice
        - Enabled, Force deny: Let Windows apps activate with voice while the system is locked
        - Enabled, Force deny: Let Windows apps communicate with unpaired devices
        - Enabled, Force deny: Let Windows apps control radios
        - Enabled, Force deny: Let Windows apps make phone calls
        - Enabled, Force deny: Let Windows apps make use of Text and image generation features of Windows
        - Enabled, Force deny: Let Windows apps take screenshots of various windows or displays
        - Enabled, Force deny: Let Windows apps turn off the screenshot border

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                       App Permissions                       " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_AppPrivacy = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
}

# 2. LGPO definitions
$LGPO_Action = 1

# -1 = Not configured (deletes key)
#  1 = Enabled, Force Allow
#  2 = Enabled, Force Deny

$LGPO_Defs = @(
    # Al Apps
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps run in the background"
        Properties = @{
            "LetAppsRunInBackground" = 2
        }
        Notes = @(
            "Apps > Installed apps > App Name > Advanced options: Background app permissions"
        ) 
    }
    # Location - Useful for web browsing
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access location"
        Properties = @{
            "LetAppsAccessLocation" = 2
        }
        Notes = @(
            "Privacy & Security > Location"
            "Useful for web browsing"
        )  
    }
    # Camera
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access the camera"
        Properties = @{
            "LetAppsAccessCamera" = 2
        }
        Notes = @(
            "Privacy & Security > Camera"
        )  
    }
    # Microphone - Required for gaming headset mic
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access the microphone"
        Properties = @{
            "LetAppsAccessMicrophone" = 2
        }
        Notes = @(
            "Privacy & Security > Microphone"
            "Required for gaming headset mic"
        ) 
    }
    # Voice Activation
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps activate with voice"
        Properties = @{
            "LetAppsActivateWithVoice" = 2
        }
        Notes = @(
            "Privacy & Security > Voice activation"
        )  
    }
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps activate with voice while the system is locked"
        Properties = @{
            "LetAppsActivateWithVoiceAboveLock" = 2
        }
        Notes = @(
            "Privacy & Security > Voice activation"
        )  
    }
    # Notifications
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access notifications"
        Properties = @{
            "LetAppsAccessNotifications" = 2
        }
        Notes = @(
            "Privacy & Security > Notifications"
        )  
    }    
    # Account Info
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access account information"
        Properties = @{
            "LetAppsAccessAccountInfo" = 2
        }
        Notes = @(
            "Privacy & Security > Account info"
        )        
    }
    # Contacts
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access contacts"
        Properties = @{
            "LetAppsAccessContacts" = 2
        }
        Notes = @(
            "Privacy & Security > Contacts"
        )  
    }
    # Calendar
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access the calendar"
        Properties = @{
            "LetAppsAccessCalendar" = 2
        }
        Notes = @(
            "Privacy & Security > Calendar"
        ) 
    }
    # Phone Calls
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps make phone calls"
        Properties = @{
            "LetAppsAccessPhone" = 2
        }
        Notes = @(
            "Privacy & Security > Phone calls"
        ) 
    }
    # Call History
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access call history"
        Properties = @{
            "LetAppsAccessCallHistory" = 2
        }
        Notes = @(
            "Privacy & Security > Call history"
        )  
    }
    # Email
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access email"
        Properties = @{
            "LetAppsAccessEmail" = 2
        }
        Notes = @(
            "Privacy & Security > Email"
        ) 
    }
    # Tasks
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access Tasks"
        Properties = @{
            "LetAppsAccessTasks" = 2
        }
        Notes = @(
            "Privacy & Security > Tasks"
        ) 
    }
    # Messaging
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access messaging"
        Properties = @{
            "LetAppsAccessMessaging" = 2
        }
        Notes = @(
            "Privacy & Security > Messaging "
        )  
    }
    # Radios
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps control radios"
        Properties = @{
            "LetAppsAccessRadios" = 2
        }
        Notes = @(
            "Privacy & Security > Radios"
        ) 
    }
    # Other Devices
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps communicate with unpaired devices"
        Properties = @{
            "LetAppsSyncWithDevices" = 2
        }
        Notes = @(
            "Privacy & Security > Other devices"
        ) 
    }    
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access trusted devices"
        Properties = @{
            "LetAppsAccessTrustedDevices" = 2
        }
        Notes = @(
            "Privacy & Security > Other devices"
        )  
    }
    # App Diagnostics
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access diagnostic information about other apps"
        Properties = @{
            "LetAppsGetDiagnosticInfo" = 2
        }
        Notes = @(
            "Privacy & Security > App diagnostics"
        )  
    }
    # Screenshot Borders
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps turn off the screenshot border"
        Properties = @{
            "LetAppsAccessGraphicsCaptureWithoutBorder" = 2
        }
        Notes = @(
            "Privacy & Security > Screenshot borders"
        )   
    }
    # Screenshots and Screen Recording
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps take screenshots of various windows or displays"
        Properties = @{
            "LetAppsAccessGraphicsCaptureProgrammatic" = 2
        }
        Notes = @(
            "Privacy & Security > Screenshots and screen recording"
        ) 
    }
    # Text and Image Generation
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps make use of Text and image generation features of Windows"
        Properties = @{
            "LetAppsAccessSystemAIModels" = 2
        }
        Notes = @(
            "Privacy & Security > Text xnd image generation"
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
    Write-Log "App Permissions complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
