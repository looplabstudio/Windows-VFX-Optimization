<#
.DESCRIPTION

.PARAMETER Version
    2026-01-02

.NOTES

#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "Scriptname" -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

# 1. Registry paths
$HKLM_Reg = ""

# 2. Registry definitions
$Registry_Defs = @(
    [PSCustomObject]@{  
        GUILocation = ""
        GUIName     = ""
        Drive       = "HKLM:|"
        Path        = $HKLM_Reg.Path
        Name        = ""
        Value       = 0
        Notes       = @()  
    } 
)

# =============================================================
# 2. Group Policies
# =============================================================

# 1. LGPO Paths
$HKLM_ = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = ""
}

$HKCU_ = @{
    Hive      = "User"
    Drive     = "HKCU:\"
    Path      = ""
}

# 2. LGPO definitions
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_.Hive
        Drive        = $HKLM_.Drive
        Path         = $HKLM_.Path
        EditorName   = ""
        Properties   = @{
            "" = 0
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKCU_.Hive
        Drive = "$($HKCU_.Drive)$($HKCU_.Path)"
        Path     = $HKCU_.Path
        EditorName   = ""
        Properties   = @{
            "" = 0
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
    Write-Log "Scriptname complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
