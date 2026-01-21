<#
.SYNOPSIS
    Master Controller for Windows 11 optimization scripts.
.EXAMPLE
    1. PowerShell as administrator.
    2. CD to script directory.
    3. Run script.

CD C:\Windows-VFX-Optimization\Font-Installer
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\Font-Installer.ps1 -FontDir "C:\Test-Fonts"

.NOTES
    Author: LoopLab Studio
    GitHub: https://github.com/looplabstudio/Windows-VFX-Optimization
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$FontDir
)

Write-Host "`n============================================================" 
Write-Host "                       Font Installer                       " 
Write-Host "============================================================" 

# =============================================================
# 1. GLOBAL CONFIGS
# =============================================================

# 1. Capture timestamp for file names
$File_Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# =============================================================
# 2. GENERAL UTILITY FUNCTIONS
# =============================================================

# 1. Create a directory if it doesn't exist
function Create_Directory {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    try {
        if (Test-Path $Path) {
            Write-Log "Directory exists: $Path" -Level PASS
            return
        }
        New-Item -ItemType Directory -Path $Path -ErrorAction Stop | Out-Null 
        Write-Log "Directory created: $Path" -Level PASS

    } catch {
        $Detail = $_.Exception.Message
        throw "Failed to create directory: $Path`n$Detail"
    }
}

# =============================================================
# 1. CONTROLLER
# =============================================================

function Controller {
    try {
        #-------------------------------------------------------------
        # 0. LOGGING
        #-------------------------------------------------------------
        # 1. Logging paths
        $Log_Dir  = Join-Path -Path $PSScriptRoot -ChildPath "Logs"
        $Log_File = Join-Path -Path $Log_Dir -ChildPath "$($File_Timestamp).txt"

        # 2. Private logging function
        function Write-Log {
            param (
                [Parameter(Mandatory=$true)] [string]$Message,
                [ValidateSet("SECT", "INFO", "DETAIL", "DIV", "PROMPT", "PASS", "WARN", "ERROR")]
                [string]$Level = "INFO"
            )
            try {
                $Log_Entry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
                $Log_Entry | Out-File -FilePath $Log_File -Append -Encoding utf8

                $Color = switch($Level) {
                    "SECT" { "Gray" }
                    "INFO" { "Gray" }
                    "DETAIL" {"DarkGray"}
                    "DIV" {"DarkGray"}
                    "PROMPT" { "Yellow" }
                    "PASS" { "Green" }
                    "WARN"  { "Yellow" }
                    "ERROR" { "Red" }
                    default { "Gray" }
                }

                Write-Host $Message -ForegroundColor $Color

                } catch {
                    $Detail = $_.Exception.Message
                    # Do not alter this message - match in Controller's catch
                    throw "Could not write to log: $Log_File`n$Detail"
                }
        }

        # 3. Create log directory 
        # Must come after Write_Log function and before subsequent use
        Create_Directory -Path $Log_Dir
        Write-Log "Log file started: $Log_File" -Level PASS

        #-------------------------------------------------------------
        # 2. Pre-Flight
        #------------------------------------------------------------- 
        
        # 1. Validate font directory
        if (-not (Test-Path $FontDir)) {
            throw "Directory not found`n$($FontDir)"
        }
        Write-Log "Font directory found: $($FontDir)" -Level PASS

        # 2. Filter for Font Files
        $FontExtensions = "*.ttf", "*.otf", "*.fon", "*.ttc"
        $Fonts = foreach ($Ext in $FontExtensions) {
            Get-ChildItem -Path $FontDir -Filter $Ext -Recurse -ErrorAction SilentlyContinue
        }

        # 3. Keep Track of Results
        $InstalledCount = 0
        $SkippedCount = 0
        $FailedCount = 0
        Write-Log "-------------------------------------------------------------" -Level DIV

        #-------------------------------------------------------------
        # 3. Install Fonts (Improved)
        #------------------------------------------------------------- 

        $ShellApp = New-Object -ComObject Shell.Application
        $FontsFolder = $ShellApp.Namespace(0x14) # 0x14 is the hex code for the Fonts folder

        foreach ($Font in $Fonts) {
            $FontName = $Font.Name
            $DestinationPath = "C:\Windows\Fonts\$FontName"
            
            # 1. Strict File Check to avoid the "Overwrite" prompt
            if (Test-Path $DestinationPath) {
                Write-Log "Skipped (File Exists): $FontName" -Level WARN
                $SkippedCount++
                continue
            }

            try {
                # 2. Use Shell CopyHere to install
                # The '16' flag tells Windows to answer "Yes to All" for any dialogs, 
                # though our Test-Path should catch most duplicates first.
                $FontsFolder.CopyHere($Font.FullName, 16)
                
                Write-Log "Installed: $FontName" -Level PASS
                $InstalledCount++
            } catch {
                Write-Log "Failed: $FontName - $($_.Exception.Message)" -Level ERROR
                $FailedCount++
            }
        }

        #-------------------------------------------------------------
        # 3. Log Tally
        #------------------------------------------------------------- 

        Write-Log "-------------------------------------------------------------" -Level DIV
        Write-Log "$InstalledCount fonts installed" -Level PASS
        Write-Log "$SkippedCount duplicate fonts skipped" -Level WARN
        Write-Log "$FailedCount fonts failed to install" -Level ERROR
        Write-Log "-------------------------------------------------------------" -Level DIV
        Write-Log "Font installation complete`n" -Level INFO

    }
    catch {
        $Detail = $_.Exception.Message

        if ($Detail -like "*Could not write to log*") {
            Write-Host "-------------------------------------------------------------"
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "Script terminated" -ForegroundColor Red
        }
        elseif (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "-------------------------------------------------------------" -Level INFO
            Write-Log "FATAL ERROR: $Detail" -Level ERROR
            Write-Log "Script terminated" -Level ERROR
        } else {
            Write-Host "-------------------------------------------------------------"
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "Script terminated" -ForegroundColor Red
        }
        return 
    }    
}

# Run this puppy 
Controller
