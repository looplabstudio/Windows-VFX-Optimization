<#
.DESCRIPTION
    Group Policies: 
        - Disabled: Allow Clipboard History
        - Disabled: Allow Clipboard synchronization across devices

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                      Clipboard History                      " -Level SECT
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
    [PSCustomObject]@{ 
        Action       = $LGPO_Action 
        Hive         = $HKLM_Pol_System.Hive
        Drive        = ($HKLM_Pol_System.Drive)
        Path         = $HKLM_Pol_System.Path
        EditorName   = "Allow Clipboard History"
        Properties   = @{
            "AllowClipboardHistory" = 0
        }
        Notes  = @(
            "System > Clipboard: Clipboard history"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action 
        Hive         = $HKLM_Pol_System.Hive
        Drive        = ($HKLM_Pol_System.Drive)
        Path         = $HKLM_Pol_System.Path
        EditorName   = "Allow Clipboard synchronization"
        Properties   = @{
            "AllowCrossDeviceClipboard" = 0
        }
        Notes  = @(
            "System > Clipboard: Clipboard history across your devices"
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
    Write-Log "Clipboard History complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
