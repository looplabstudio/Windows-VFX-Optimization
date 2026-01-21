<#
.DESCRIPTION
    Group Policies: 
        - Disabled: Allow Recall to be enabled
        - Enabled: Turn off saving snapshots for use with Recall
        - Disabled: Allow export of Recall and snapshot information
        - Enabled: Disable Click to Do
        - Enabled: Disable Settings agentic search experience
        - Enabled: Turn off Windows Copilot

.PARAMETER Version
    2026-01-02

.NOTES
    - The Core Ultra 7 has an NPU. 
    - Resolve 19 tries to use it for Magic Mask. 
    - If Windows Recall or Copilot is using the NPU, Resolve will hang. 
    - Disabling at the Group Policy level is mandatory to give Resolve exclusive access.

#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                    Windows Copilot & AI                     " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_WindowsAI = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
}

$HKCU_Pol_WindowsCopilot = @{
    Hive      = "User"
    Drive     = "HKCU:\"
    Path      = "Software\Policies\Microsoft\Windows\WindowsCopilot"
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    # Recall
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsAI.Hive
        Drive        = $HKLM_Pol_WindowsAI.Drive
        Path         = $HKLM_Pol_WindowsAI.Path
        EditorName   = "Allow Recall to be enabled"
        Properties   = @{
            "AllowRecallEnablement" = 0
        }
        Notes  = @()
    }     
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsAI.Hive
        Drive        = $HKLM_Pol_WindowsAI.Drive
        Path         = $HKLM_Pol_WindowsAI.Path
        EditorName   = "Allow export of Recall and snapshot information"
        Properties   = @{
            "AllowRecallExport" = 0
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsAI.Hive
        Drive        = $HKLM_Pol_WindowsAI.Drive
        Path         = $HKLM_Pol_WindowsAI.Path
        EditorName   = "Turn off saving snapshots for use with Recall"
        Properties   = @{
            "DisableAIDataAnalysis" = 1
        }
        Notes  = @()
    } 
    # Other
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsAI.Hive
        Drive        = $HKLM_Pol_WindowsAI.Drive
        Path         = $HKLM_Pol_WindowsAI.Path
        EditorName   = "Disable Click to Do"
        Properties   = @{
            "DisableClickToDo" = 1
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsAI.Hive
        Drive        = $HKLM_Pol_WindowsAI.Drive
        Path         = $HKLM_Pol_WindowsAI.Path
        EditorName   = "Disable Settings agentic search experience"
        Properties   = @{
            "DisableSettingsAgent" = 1
        }
        Notes  = @()
    } 
    # Copilot
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_WindowsCopilot.Hive
        Drive        = $HKCU_Pol_WindowsCopilot.Drive
        Path         = $HKCU_Pol_WindowsCopilot.Path
        EditorName   = "Turn off Windows Copilot"
        Properties   = @{
            "TurnOffWindowsCopilot" = 1
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
    Write-Log "Windows Copilot & AI complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
