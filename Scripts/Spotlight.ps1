<#
.DESCRIPTION
    Group Policies:
        - Enabled: Turn off all Windows spotlight features
        - Enabled: Do not suggest third-party content in Windows spotlight
        - Enabled: Turn off Spotlight collection on Desktop
        - Enabled: Turn off Windows Spotlight on Action Center
        - Enabled: Turn off Windows Spotlight on Settings

.PARAMETER Version
    2026-01-02

.NOTES      
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                      Windows Spotlight                      " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. GROUP POLICES
# =============================================================

# 1. LGPO Paths
$HKCU_Pol_CloudContent = @{
    Hive      = "User"
    Drive     = "HKCU:\"
    Path      = "Software\Policies\Microsoft\Windows\CloudContent"
}


# 3. Define Group Policies
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Turn off all Windows spotlight features"
        Properties   = @{
            "DisableWindowsSpotlightFeatures" = 1
        }
        Notes = @(
            "Disables: Start Menu search: Windows Spotlight content"
            "Removes: Personalize > Background: Windows Spotlight option"
        )
    }
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Turn off Spotlight collection on Desktop"
        Properties   = @{
            "DisableSpotlightCollectionOnDesktop" = 1
        }
        Notes  = @()
    }  
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Turn off Windows Spotlight on Action Center"
        Properties   = @{
            "DisableWindowsSpotlightOnActionCenter" = 1
        }
        Notes  = @()
    }
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Turn off Windows Spotlight on Settings"
        Properties   = @{
            "DisableWindowsSpotlightOnSettings" = 1
        }
        Notes  = @()
    }    
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Do not suggest third-party content in Windows spotlight"
        Properties   = @{
            "DisableThirdPartySuggestions" = 1
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
    Write-Log "Windows Spotlight complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
