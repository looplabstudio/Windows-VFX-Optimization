<#
.DESCRIPTION
    GUI Toggles
        - [TODO] Privacy & Security > Inking & typing personalization: Customize dictionary
    Registry: 
        - Disabled: Pen press and hold for right-click
        - Disabled: Pen flicks
    Group Policies:
        - Disabled: Allow Windows Ink Workspace

.PARAMETER Version
    2026-01-02

.NOTES
    Related: 
        - Diagnostic-Data.ps1: Privacy & Security > Diagnostics & feedback: Improve Inking and typing 
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        Ink Workspace                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_SysEventParameters = "Software\Microsoft\Wisp\Pen\SysEventParameters"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Pen: Press and hold for right-click"
        Drive       = "HKCU:\"
        Path        = $HKCU_SysEventParameters
        Name        = "HoldMode"
        Value       = 3
        Notes       = @(
            "Removes the blue circle animation that causes brush lag."
        )  
    }
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Pen: Flicks "
        Drive       = "HKCU:\"
        Path        = $HKCU_SysEventParameters
        Name        = "FlickMode"
        Value       = 0
        Notes       = @(
            "Prevents rapid pen strokes from being interpreted as navigation gestures."
        )  
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
        Path         = "SOFTWARE\Policies\Microsoft\WindowsInkWorkspace"
        EditorName   = "Allow Windows Ink Workspace"
        Properties   = @{
            "AllowWindowsInkWorkspace" = 0
        }
        Notes  = @(
            "Prevents Whiteboard and Snip overlays from interfering with tablet focus."
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
    Write-Log "Ink Workspace complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
