<#
.DESCRIPTION
    Group Policies: 
        - Enabled: Prevent the usage of OneDrive for file storage
        - Enabled: Prevent OneDrive from generating network traffic until the user signs in to OneDrive

.PARAMETER Version
    2026-01-02

.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                          OneDrive                           " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. GROUP POLICES
# =============================================================

# 1. LGPO Paths

# 3. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Policies\Microsoft\Windows\OneDrive"
        EditorName   = "Prevent the usage of OneDrive for file storage"
        Properties   = @{
            "DisableFileSyncNGSC" = 1
        }
        Notes  = @()
    }     
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = "Computer"
        Drive        = "HKLM:\"
        Path         = "SOFTWARE\Microsoft\OneDrive"
        EditorName   = "Prevent OneDrive from generating network traffic until the user signs in to OneDrive"
        Properties   = @{
            "PreventNetworkTrafficPreUserSignIn" = 1
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
    Write-Log "OneDrive complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
