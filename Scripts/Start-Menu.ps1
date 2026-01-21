<#
.DESCRIPTION
    GUI toggles:
        - Turn off: Personalization > Start: Show account-related notifications
        - Turn off: Personalization > Start: Show recommendations for tips, shortcuts, new apps, and more
        - Turn off: Personalization > Start: Show mobile device in start
    Group Policies:
        - Enabled: Do not keep history of recently opened documents
        - Enabled: Remove "Recently added" list from Start Menu
        - Enabled: Remove All Programs list from the Start menu
        - Enabled: Remove Personalized Website Recommendations from the Recommended section in the Start Menu
        - Enabled, Hide: Show or hide "Most used" list from Start menu
        - Enabled: Continue experiences on this device
        - Enabled: Turn off display of recent search entries in the File Explorer search box

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                         Start Menu                          " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_Explorer_Advanced = "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "System > Start"
        GUIName     = "Show mobile devices in Start"
        Drive       = "HKCU:\"
        Path        = "Software\Microsoft\Windows\CurrentVersion\Start\Companions\Microsoft.YourPhone_8wekyb3d8bbwe"
        Name        = "IsEnabled"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "Personalization > Start"
        GUIName     = "Show recommendations for tips, shortcuts, new apps, and more"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Advanced
        Name        = "Start_IrisRecommendations"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "Personalization > Start"
        GUIName     = "Show account-related notifications"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Advanced
        Name        = "Start_AccountNotifications"
        Value       = 0 
    } 
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_Explorer = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
}

$HKCU_Pol_Explorer = @{
    Hive      = "User"
    Drive     = "HKCU:\"
    Path      = "Software\Policies\Microsoft\Windows\Explorer"
}

$HKLM_MS_Explorer = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
}


# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_MS_Explorer.Hive
        Drive        = $HKLM_MS_Explorer.Drive
        Path         = $HKLM_MS_Explorer.Path
        EditorName   = "Do not keep history of recently opened documents"
        Properties   = @{
            "NoRecentDocsHistory" = 1
        }
        Notes  = @(
            "Personalization > Start: Show recommended files in Start, recent files in Explorer, items in Jump Lists "
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_MS_Explorer.Hive
        Drive        = $HKLM_MS_Explorer.Drive
        Path         = $HKLM_MS_Explorer.Path
        EditorName   = "Remove All Programs list from the Start menu"
        Properties   = @{
            "NoStartMenuMorePrograms" = 1
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Explorer.Hive
        Drive        = $HKLM_Pol_Explorer.Drive
        Path         = $HKLM_Pol_Explorer.Path
        EditorName   = "Remove 'Recently added' list from Start Menu"
        Properties   = @{
            "HideRecentlyAddedApps" = 1
        }
        Notes  = @(
            "Personalization > Start: Show recently added apps"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Explorer.Hive
        Drive        = $HKLM_Pol_Explorer.Drive
        Path         = $HKLM_Pol_Explorer.Path
        EditorName   = "Remove Personalized Website Recommendations from the Recommended section in the Start Menu"
        Properties   = @{
            "HideRecommendedPersonalizedSites" = 1
        }
        Notes  = @(
            "Personalization > Start: Show websites from browsing history "
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Explorer.Hive
        Drive        = $HKLM_Pol_Explorer.Drive
        Path         = $HKLM_Pol_Explorer.Path
        EditorName   = "Show or hide 'Most used' list from Start menu"
        Properties   = @{
            "ShowOrHideMostUsedApps" = 2 # Hide
        }
        Notes  = @(
            "Personalization > Start: Show most used apps"
        )
    }
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_Explorer.Hive
        Drive        = $HKCU_Pol_Explorer.Drive
        Path         = $HKCU_Pol_Explorer.Path
        EditorName   = "Turn off display of recent search entries in the File Explorer search box"
        Properties   = @{
            "DisableSearchBoxSuggestions" = 1
        }
        Notes  = @(
            "Start menu 'Search the web' results"
        )
    }     
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\System"
        EditorName   = "Continue experiences on this device"
        Properties   = @{
            "EnableCdp" = 0
        }
        Notes  = @(
            "System > Nearby Sharing: Nearby Sharing"
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
    Write-Log "Start Menu complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
