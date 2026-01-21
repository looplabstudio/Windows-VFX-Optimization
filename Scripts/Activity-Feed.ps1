<#
.DESCRIPTION
    Group Policies: 
        - Disabled: Enables Activity Feed
            - 'Recent' lists in Start menu, Explorer
        - Enabled: Allow publishing of User Activities
        - Enabled: Allow upload of User Activities

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        Activity Feed                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_System = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\System"
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    # Activity Feed
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_System.Hive
        Drive        = $HKLM_Pol_System.Drive
        Path         = $HKLM_Pol_System.Path   
        EditorName   = "Enables Activity Feed"
        Properties   = @{
            "EnableActivityFeed" = 0
        }
        Notes  = @(
            "Recent lists in Start Menu"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_System.Hive
        Drive        = $HKLM_Pol_System.Drive
        Path         = $HKLM_Pol_System.Path
        EditorName   = "Allow publishing of User Activities"
        Properties   = @{
            "PublishUserActivities" = 0
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_System.Hive
        Drive        = $HKLM_Pol_System.Drive
        Path         = $HKLM_Pol_System.Path
        EditorName   = "Allow upload of User Activities"
        Properties   = @{
            "UploadUserActivities" = 0
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
    Write-Log "Activity Feed complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
