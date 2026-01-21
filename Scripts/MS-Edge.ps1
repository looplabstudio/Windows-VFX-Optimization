<#
.DESCRIPTION
    Registry:
        - Disabled: Chromium-based Edge: Disable Startup Boost
        - Disabled: Chromium-based Edge: Disable Background Apps
        - Disabled: Chromium-based Edge: Quick Sleep Tabs (Performance)

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                       Microsoft Edge                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKLM_MS_Edge = "SOFTWARE\Policies\Microsoft\Edge"

# 2. Registry definitions
$Registry_Defs += @(
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Chromium-based Edge: Disable Startup Boost"
        Drive       = "HKLM:\"
        Path        = $HKLM_MS_Edge
        Name        = "StartupBoostEnabled"
        Value       = 0
    }
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Chromium-based Edge: Disable Background Apps"
        Drive       = "HKLM:\"
        Path        = $HKLM_MS_Edge
        Name        = "BackgroundModeEnabled"
        Value       = 0
    }
    [PSCustomObject]@{  
        GUILocation = "Registry"
        GUIName     = "Chromium-based Edge: Quick Sleep Tabs (Performance)"
        Drive       = "HKLM:\"
        Path        = $HKLM_MS_Edge
        Name        = "SleepingTabsTimeout"
        Value       = 30 # Sleeps tabs after 30 seconds of inactivity
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
        # 1. Process definitions
        Process_Registry_Defs -Defs $Registry_Defs
        Process_LGPO_Defs -Defs $LGPO_Defs
    } else {
        # 2. Validate definitions
        Validate_Registry_Defs -Defs $Registry_Defs
        Validate_LGPO_Defs -Defs $LGPO_Defs
    }

    # 3. Subscript Complete
    Write-Log "Microsoft Edge complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
