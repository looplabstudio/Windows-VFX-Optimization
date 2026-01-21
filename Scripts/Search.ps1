<#
.DESCRIPTION
    GUI Toggles:
        - Turn off: Privacy & Security > Search: Search history  
    Registry Kays:
        - Disabled: Bing web results system-wide
    Group Policies: 
        - Disabled: Allow search highlights
  
.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                          Search                             " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_SearchSettings = "Software\Microsoft\Windows\CurrentVersion\SearchSettings"

# 2. Registry definitions
$Registry_Defs = @(     
    [PSCustomObject]@{  
        GUILocation = "Privacy & Security > Search"
        GUIName     = "Search history"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_SearchSettings
        Name        = "IsDeviceSearchHistoryEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "None"
        GUIName     = "Disable Bing web results system wide"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_SearchSettings
        Name        = "BingSearchEnabled"
        Value       = 0  
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
        Path         = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"
        EditorName   = "Allow search highlights"
        Properties   = @{
            "EnableDynamicContentInWSB" = 0
        }
        Notes  = @(
            "Privacy & Security > Search: Search highlights"
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
    Write-Log "Search complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
