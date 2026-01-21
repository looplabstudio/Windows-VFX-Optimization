<#
.DESCRIPTION
    Disables background maintenance tasks that cause I/O contention.
.NOTES
#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                      Scheduled Tasks                        " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Define Tasks
# Note `Path` is not used in functions - here for documentation
# =============================================================

$Target_Tasks = @(
    @{ Name = "ProactiveScan"; Path = "\Microsoft\Windows\Chkdsk\" }
)

# =============================================================
# 2. Functions
# =============================================================

# 1. Disable running tasks
function Disable_Tasks {
    try {
        Write-Log "Disabling background tasks..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
        
        foreach ($Task in $Target_Tasks) {
            try {
                Write-Log "Task: $($Task.Name)" -Level INFO

                # 1. Get task by Name only (ignore Path entirely)
                $CurrentTask = Get-ScheduledTask -TaskName $Task.Name -ErrorAction Stop | Select-Object -First 1
                
                # 2. Disable it 
                if ($CurrentTask.State -ne 'Disabled') {
                    Disable-ScheduledTask -InputObject $CurrentTask
                    Write-Log "Disabled task" -Level PASS
                } else {
                    Write-Log "Task already disabled" -Level PASS
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Failed to disable task" -Level WARN
                Write-Log "$Detail" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue
            }
        }
        Write-Log "Tasks complete" -Level DETAIL  
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }    
}


# 2. Validate tasks have been disabled
function Validate_Tasks {
    try {
        Write-Log "Validating background tasks..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
        
        foreach ($Task in $Target_Tasks) {
            try {
                Write-Log "Task: $($Task.Name)" -Level INFO

                # 1. Get task by Name only (ignore Path entirely)
                $CurrentTask = Get-ScheduledTask -TaskName $Task.Name -ErrorAction Stop | Select-Object -First 1
                
                # 2. Report
                if ($CurrentTask.State -ne 'Disabled') {
                    Write-Log "Task is not disabled" -Level WARN
                } else {
                    Write-Log "Task is disabled" -Level PASS
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Failed to validate task" -Level WARN
                Write-Log "$Detail" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue
            }
        }
        Write-Log "Tasks validation complete" -Level DETAIL  
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }    
}

# =============================================================
# 3. Process
# =============================================================

if ($global:DEBUG -eq 0) { Disable_Tasks } else { Validate_Tasks }

