<#
.DESCRIPTION
    Group Policies: 
        - Enabled, Force deny: Let Windows apps run in the background
            - Apps > Installed apps > App Name > Advanced options: Background app permissions

        Privacy & Security: App permissions > App name: Access toggle

        - Revert: Let Windows apps access location
        - Revert: Force deny: Let Windows apps access the camera
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
# These work differently than other Defs. 
# Action always = 1
$LGPO_Action = 1

# To revert to 'Not Configured), we must set the Property.
# -1 = Not configured (deletes key)
#  1 = Enabled, Force Allow
#  2 = Enabled, Force Deny
$Property_Val = 2

$LGPO_Defs = @(
    # All Apps
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps run in the background"
        Properties = @{
            "LetAppsRunInBackground" = $Property_Val
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
            "LetAppsAccessLocation" = -1
        }
        Notes = @(
            "Privacy & Security > Location"
            "Useful for web browsing"
        )  
    }
    # Camera
    [PSCustomObject]@{ 
        Action       = 0
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access the camera"
        Properties = @{
            "LetAppsAccessCamera" = -1
        }
        Notes = @(
            "Privacy & Security > Camera"
        )  
    }
    # Microphone - Required for gaming headset mic
    [PSCustomObject]@{ 
        Action       = 0
        Hive         = $HKLM_Pol_AppPrivacy.Hive
        Drive        = $HKLM_Pol_AppPrivacy.Drive
        Path         = $HKLM_Pol_AppPrivacy.Path
        EditorName   = "Let Windows apps access the microphone"
        Properties = @{
            "LetAppsAccessMicrophone" = -1
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
            "LetAppsActivateWithVoice" = $Property_Val
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
            "LetAppsActivateWithVoiceAboveLock" = $Property_Val
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
            "LetAppsAccessNotifications" = $Property_Val
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
            "LetAppsAccessAccountInfo" = $Property_Val
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
            "LetAppsAccessContacts" = $Property_Val
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
            "LetAppsAccessCalendar" = $Property_Val
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
            "LetAppsAccessPhone" = $Property_Val
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
            "LetAppsAccessCallHistory" = $Property_Val
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
            "LetAppsAccessEmail" = $Property_Val
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
            "LetAppsAccessTasks" = $Property_Val
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
            "LetAppsAccessMessaging" = $Property_Val
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
            "LetAppsAccessRadios" = $Property_Val
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
            "LetAppsSyncWithDevices" = $Property_Val
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
            "LetAppsAccessTrustedDevices" = $Property_Val
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
            "LetAppsGetDiagnosticInfo" = $Property_Val
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
            "LetAppsAccessGraphicsCaptureWithoutBorder" = $Property_Val
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
            "LetAppsAccessGraphicsCaptureProgrammatic" = $Property_Val
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
            "LetAppsAccessSystemAIModels" = $Property_Val
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
