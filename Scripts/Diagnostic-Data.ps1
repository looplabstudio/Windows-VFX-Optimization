<#
.DESCRIPTION
    Group Policies: 
        - Disabled: Allow Diagnostic Data
        - Disabled: Allow device name to be sent in Windows diagnostic data
        - Enabled: Limit Diagnostic Log Collection
        - Enabled: Limit Dump Collection
        - Enabled: Limit optional diagnostic data for Desktop Analytics
        - Enabled: Do not use diagnostic data for tailored experiences

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                       Diagnostic Data                       " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_DataCollection = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\DataCollection"
}

$HKCU_Pol_CloudContent = @{
    Hive      = "User"
    Drive     = "HKCU:\"
    Path      = "Software\Policies\Microsoft\Windows\CloudContent"
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_DataCollection.Hive
        Drive        = $HKLM_Pol_DataCollection.Drive
        Path         = $HKLM_Pol_DataCollection.Path
        EditorName   = "Allow Diagnostic Data"
        Properties   = @{
            "AllowTelemetry" = 0
        }
        Notes  = @(
            "Privacy & Security > Diagnostics & Feedback: Feedback Frequency (hidden)"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_DataCollection.Hive
        Drive        = $HKLM_Pol_DataCollection.Drive
        Path         = $HKLM_Pol_DataCollection.Path
        EditorName   = "Allow device name to be sent in Windows diagnostic data"
        Properties   = @{
            "AllowDeviceNameInTelemetry" = 0
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_DataCollection.Hive
        Drive        = $HKLM_Pol_DataCollection.Drive
        Path         = $HKLM_Pol_DataCollection.Path
        EditorName   = "Limit Diagnostic Log Collection"
        Properties   = @{
            "LimitDiagnosticLogCollection" = 1
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_DataCollection.Hive
        Drive        = $HKLM_Pol_DataCollection.Drive
        Path         = $HKLM_Pol_DataCollection.Path
        EditorName   = "Limit Dump Collection"
        Properties   = @{
            "LimitDumpCollection" = 1
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_DataCollection.Hive
        Drive        = $HKLM_Pol_DataCollection.Drive
        Path         = $HKLM_Pol_DataCollection.Path
        EditorName   = "Limit optional diagnostic data for Desktop Analytics"
        Properties   = @{
            "LimitEnhancedDiagnosticDataWindowsAnalytics" = 1
        }
        Notes  = @(
            "Use in combination with 'Allow Diagnostic Data'"
        )
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_Pol_CloudContent.Hive
        Drive        = $HKCU_Pol_CloudContent.Drive
        Path         = $HKCU_Pol_CloudContent.Path
        EditorName   = "Do not use diagnostic data for tailored experiences"
        Properties   = @{
            "DisableTailoredExperiencesWithDiagnosticData" = 1
        }
        Notes = @(
            "Disables: Privacy & Security > Diagnostics & Feedback: Tailored Experiences"
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
    Write-Log "Diagnostic Data complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
