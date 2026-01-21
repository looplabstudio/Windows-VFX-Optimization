<#
.DESCRIPTION
    GUI toggles:
        - Turn off: Gaming > Game Bar: Allow your controller to open Game Bar
        - Turn off: Gaming > Captures: Record what happened
        - Turn off: Gaming > Captures: Capture audio when recording a game
        - Turn off: Gaming > Game Mode: Game Mode

.PARAMETER Version
    2026-01-02

.NOTES

#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                           Gaming                            " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKCU_MS_GameBar = "Software\Microsoft\GameBar"
$HKCU_MS_GameDVR = "Software\Microsoft\Windows\CurrentVersion\GameDVR"

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = "Gaming > Game Mode"
        GUIName     = "Game Mode"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameBar
        Name        = "AutoGameModeEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Gaming > Game Bar "
        GUIName     = "Allow your controller to open Game Bar"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameBar
        Name        = "UseNexusForGameBarEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Gaming > Captures"
        GUIName     = "Record what happened"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameDVR
        Name        = "AppCaptureEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Gaming > Captures"
        GUIName     = "Record what happened"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameDVR
        Name        = "HistoricalCaptureEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Gaming > Captures"
        GUIName     = "Capture audio when recording a game"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameDVR
        Name        = "AudioCaptureEnabled"
        Value       = 0 
    } 
    [PSCustomObject]@{  
        GUILocation = "Gaming > Captures"
        GUIName     = "Capture mouse cursor when recording a game"
        Drive       = "HKCU:\"
        Path        = $HKCU_MS_GameDVR
        Name        = "CursorCaptureEnabled"
        Value       = 0 
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
    Write-Log "Gaming complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
