<#
.DESCRIPTION
    Group Policies:
        - Disabled: Allow widgets
        - Enabled: Disable Widgets Board
        - Enabled: Disable Widgets On Lock Screen

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                           Widgets                           " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_Widgets = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Dsh"
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    # Widgets
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Widgets.Hive
        Drive        = $HKLM_Pol_Widgets.Drive
        Path         = $HKLM_Pol_Widgets.Path
        EditorName   = "Allow widgets"
        Properties   = @{
            "AllowNewsAndInterests" = 0
        }
        Notes  = @(
            "Personalization > Taskbar: Widgets"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Widgets.Hive
        Drive        = $HKLM_Pol_Widgets.Drive
        Path         = $HKLM_Pol_Widgets.Path
        EditorName   = "Disable Widgets Board"
        Properties   = @{
            "DisableWidgetsBoard" = 1
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_Widgets.Hive
        Drive        = $HKLM_Pol_Widgets.Drive
        Path         = $HKLM_Pol_Widgets.Path
        EditorName   = "Disable Widgets On Lock Screen"
        Properties   = @{
            "DisableWidgetsOnLockScreen" = 1
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
    Write-Log "Widgets complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
