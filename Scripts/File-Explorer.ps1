<#
.DESCRIPTION
    GUI Toggles:
        - Turn on: System > Advanced > File Explorer: Show file extensions
        - Turn on: System > Advanced > File Explorer: Show hidden and system files
        - Set: File Explorer > Options: Open to 'This PC'
        - Turn off: File Explorer > Options: Show recently used files
        - Turn off: File Explorer > Options: Show frequently used folders
        - Turn off: File Explorer > Options: Show Office.com files
        - Enabled: File Explorer: Restore Windows 10 context menu
        - Disabled: File Explorer > Navigation pane: Home directory
        - Disabled: File Explorer > Navigation pane: Gallery directory        

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        File Explorer                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_CLSID             = "Software\Classes\CLSID"
$HKCU_CLSID_ContextMenu = "$($HKCU_CLSID)\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
$HKCU_CLSID_Home        = "$($HKCU_CLSID)\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"
$HKCU_CLSID_Gallery     = "$($HKCU_CLSID)\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"

$HKCU_MS_Explorer     = "Software\Microsoft\Windows\CurrentVersion\Explorer"
$HKCU_MS_Explorer_Adv = "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "File Explorer > Navigation pane"
        GUIName     = "Home directory"
        Drive       = "HKCU:\"
        Path        = $HKCU_CLSID_Home
        Name        = "System.IsPinnedToNameSpaceTree"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "File Explorer > Navigation pane"
        GUIName     = "Gallery directory"
        Drive       = "HKCU:\"
        Path        = $HKCU_CLSID_Gallery
        Name        = "System.IsPinnedToNameSpaceTree"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "File Explorer > Options"
        GUIName     = "Open to 'This PC'"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Adv
        Name        = "LaunchTo"
        Value       = 1  
    } 
    [PSCustomObject]@{  
        GUILocation = "File Explorer > Options"
        GUIName     = "Show recent files / frequent folders"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer
        Name        = "ShowFrequent"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "File Explorer > Options"
        GUIName     = "Show Office.com files"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer
        Name        = "ShowCloudFilesInQuickAccess"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "System > Advanced > File Explorer"
        GUIName     = "Show file extensions"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Adv
        Name        = "HideFileExt"
        Value       = 0  
    } 
    [PSCustomObject]@{  
        GUILocation = "System > Advanced > File Explorer"
        GUIName     = "Show hidden and system file"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Adv
        Name        = "ShowSuperHidden"
        Value       = 1  
    }     
    [PSCustomObject]@{  
        GUILocation = "System > Advanced > File Explorer"
        GUIName     = "Show hidden and system file"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_Explorer_Adv
        Name        = "Hidden"
        Value       = 1  
    } 
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths

# 2. LGPO definitions
# $LGPO_Action = 1

$LGPO_Defs = @()

# =============================================================
# 3. Process
# =============================================================

try {
    if ($global:DEBUG -eq 0) {     
        # 1. Process GUI definitions
        Process_Registry_Defs -Defs $Registry_Defs

        # File Explorer: Restore Windows 10 context menu 
        # Does not use Dword. Must set manually. No scripted validation.
        Set-ItemProperty -Path "HKCU:\$($HKCU_CLSID_ContextMenu)" -Name "(default)" -Value ""
        Write-Log "File Explorer: Restore Windows 10 context menu" -Level PASS

        # Process Group Policy definitions
        Process_LGPO_Defs -Defs $LGPO_Defs

    } else {
        # 2. Validate definitions
        Validate_Registry_Defs -Defs $Registry_Defs
        Validate_LGPO_Defs -Defs $LGPO_Defs
    }

    # 3. Subscript Complete
    Write-Log "File Explorer complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
