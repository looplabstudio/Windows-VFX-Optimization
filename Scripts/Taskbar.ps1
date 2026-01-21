<#
.DESCRIPTION
    GUI toggles:
        - Turn on: System > Advanced: End Task (in the Taskbar context menu)
        - Set: Personalization > Taskbar > Taskbar behaviors: Taskbar Alignment
    Group Policies:
        - Enabled, Hide: Configures search on the taskbar
        - Enabled: Hide the TaskView button

.PARAMETER Version
    2026-01-02

.NOTES
    - Taskbar widgets disabled in Widgets.ps1

#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                           Taskbar                           " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_Explorer_Advanced = "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "Personalization > Taskbar > Taskbar behaviors"
        GUIName     = "Taskbar alignment"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Advanced
        Name        = "TaskbarAl"
        Value       = 1  # 0 left | 1 center
    } 
    [PSCustomObject]@{  
        GUILocation = "System > Advanced"
        GUIName     = "End Task"
        Drive       = "HKCU:\"
        Path        = "$($HKCU_MS_Explorer_Advanced)\TaskbarDeveloperSettings"
        Name        = "TaskbarEndTask"
        Value       = 1
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
        Path         = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
        EditorName   = "Hide the TaskView button"
        Properties   = @{
            "HideTaskViewButton" = 1
        }
        Notes  = @(
            "Personalization > Taskbar: Task view"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        EditorName   = "Configures search on the taskbar"
        Properties   = @{
            "SearchOnTaskbarMode" = 0
        }
        Notes  = @(
            "Personalization > Taskbar: Search"
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
    Write-Log "Taskbar complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
