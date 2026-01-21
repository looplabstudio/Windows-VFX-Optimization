<#
.DESCRIPTION
    Group Policies: 
        - Disabled: Allow Cloud Search
        - Enabled: Turn off cloud consumer account state content
        - Enabled: Turn off cloud optimized content

.PARAMETER Version
    2026-01-02

.NOTES
    What disabled these? It is not 'Allow Cloud Search'.
        - Privacy & Security > Search: Microsoft account
        - Privacy & Security > Search: Work or school account
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                        Cloud Content                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Registry Definitions
# =============================================================

$Registry_Defs = @()

# =============================================================
# 2. GROUP POLICES
# =============================================================

# 1. LGPO Paths
$HKLM_Pol_WindowsSearch = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\Windows Search"
}

$HKLM_Pol_CloudContent = @{
    Hive      = "Computer"
    Drive     = "HKLM:\"
    Path      = "SOFTWARE\Policies\Microsoft\Windows\CloudContent"
}

# 3. Define Group Policies
$LGPO_Action = 1

$LGPO_Defs = @(
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_WindowsSearch.Hive
        Drive        = $HKLM_Pol_WindowsSearch.Drive
        Path         = $HKLM_Pol_WindowsSearch.Path
        EditorName   = "Allow Cloud Search"
        Properties   = @{
            "AllowCloudSearch" = 0
        }
        Notes  = @()
    } 
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_CloudContent.Hive
        Drive        = $HKLM_Pol_CloudContent.Drive
        Path         = $HKLM_Pol_CloudContent.Path 
        EditorName   = "Turn off cloud consumer account state content"
        Properties = @{
            "DisableConsumerAccountStateContent" = 1
        }
        Notes = @()
    }
    [PSCustomObject]@{ 
        Action       = $LGPO_Action
        Hive         = $HKLM_Pol_CloudContent.Hive
        Drive        = $HKLM_Pol_CloudContent.Drive
        Path         = $HKLM_Pol_CloudContent.Path 
        EditorName   = "Turn off cloud optimized content"
        Properties = @{
            "DisableCloudOptimizedContent" = 1
        }
        Notes = @()
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
    Write-Log "Cloud Content complete" -Level DETAIL  
}
catch {
    $Detail = $_.Exception.Message
    throw "$Detail"
}
