<#
.SYNOPSIS
    Extract data from Windows ADMX files to help script Group Policies.

.EXAMPLE
    1. PowerShell as administrator.
    2. CD to script directory. 
    3. Run command.

    CD C:\Windows-VFX-Optimization\ADMX
    Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\ADMX-Tool.ps1

.NOTES
    Author: LoopLab Studio
    GitHub: https://github.com/looplabstudio/Windows-VFX-Optimization
#>

#Requires -RunAsAdministrator

Write-Host ""
Write-Host "============================================================" 
Write-Host "                     Windows ADMX Tool                      " 
Write-Host "============================================================" 

# =============================================================
# 1. GLOBAL CONFIGS
# =============================================================

# 1. Capture timestamp for file names
$File_Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"

# 2. Root of all ADMX files on this device
$ADMX_Root = "$env:windir\PolicyDefinitions"

# 3. ADMX files (ADMX-Inventory.ps1)
# We could script this, but this lets us comment out files to skip.
$ADMX_Files = @(
    "AccountNotifications.admx"
    "ActiveXInstallService.admx"
    "AddRemovePrograms.admx"
    "AllowBuildPreview.admx"
    "AppCompat.admx"
    "AppDeviceInventory.admx"
    "AppPrivacy.admx" 
    "appv.admx"
    "AppxPackageManager.admx"
    "AppXRuntime.admx"
    "AttachmentManager.admx"
    "AuditSettings.admx"
    "AutoPlay.admx"
    "AVSValidationGP.admx"
    "Biometrics.admx"
    "Bits.admx"
    "Camera.admx"
    "CEIPEnable.admx"
    "CipherSuiteOrder.admx"
    "CloudContent.admx" 
    "COM.admx"
    "Conf.admx"
    "ControlPanel.admx"
    "ControlPanelDisplay.admx" 
    "Cpls.admx"
    "CredentialProviders.admx"
    "CredSsp.admx"
    "CredUI.admx"
    "CtrlAltDel.admx"
    "DataCollection.admx"
    "DCOM.admx"
    "DeliveryOptimization.admx"
    "Desktop.admx" 
    "DesktopAppInstaller.admx"
    "DeviceCompat.admx"
    "DeviceCredential.admx"
    "DeviceGuard.admx"
    "DeviceInstallation.admx"
    "DeviceSetup.admx"
    "DFS.admx"
    "DigitalLocker.admx"
    "DiskDiagnostic.admx"
    "DiskNVCache.admx"
    "DiskQuota.admx"
    "Display.admx"
    "DistributedLinkTracking.admx"
    "DmaGuard.admx"
    "DnsClient.admx"
    "DPAPI.admx"
    "DWM.admx"
    "EAIME.admx"
    "EarlyLaunchAM.admx"
    "EdgeUI.admx"
    "EncryptFilesonMove.admx"
    "EnhancedStorage.admx"
    "ErrorReporting.admx"
    "EventForwarding.admx"
    "EventLog.admx"
    "EventLogging.admx"
    "EventViewer.admx"
    "ExploitGuard.admx"
    "Explorer.admx"
    "ExternalBoot.admx"
    "FeedbackNotifications.admx"
    "FileHistory.admx"
    "FileRecovery.admx"
    "FileRevocation.admx"
    "FileServerVSSProvider.admx"
    "FileSys.admx"
    "filtermanager.admx"
    "FindMy.admx"
    "FolderRedirection.admx"
    "FramePanes.admx"
    "fthsvc.admx"
    "GameDVR.admx"
    "Globalization.admx"
    "GroupPolicy.admx"
    "Handwriting.admx"
    "Help.admx"
    "HelpAndSupport.admx"
    "hotspotauth.admx"
    "ICM.admx"
    "IIS.admx"
    "inetres.admx"
    "iSCSI.admx"
    "kdc.admx"
    "Kerberos.admx"
    "KeyboardFilterPolicy.admx"
    "LanmanServer.admx"
    "LanmanWorkstation.admx"
    "LAPS.admx"
    "LeakDiagnostic.admx"
    "LinkLayerTopologyDiscovery.admx"
    "LocalSecurityAuthority.admx"
    "LocationProviderAdm.admx"
    "Logon.admx"
    "MDM.admx"
    "messaging.admx"
    "MicrosoftEdge.admx"
    "MMC.admx"
    "MMCSnapins.admx"
    "MobilePCMobilityCenter.admx"
    "MobilePCPresentationSettings.admx"
    "MSAPolicy.admx"
    "msched.admx"
    "MSDT.admx"
    "MSI.admx"
    "Msi-FileRecovery.admx"
    "Multitasking.admx"
    "nca.admx"
    "NCSI.admx"
    "Netlogon.admx"
    "NetworkConnections.admx"
    "NetworkIsolation.admx"
    "NetworkProvider.admx"
    "NewsAndInterests.admx"
    "Ntlm.admx"
    "OfflineFiles.admx"
    "OOBE.admx"
    "OSPolicy.admx" 
    "Passport.admx"
    "pca.admx"
    "PeerToPeerCaching.admx"
    "PenTraining.admx"
    "PerformanceDiagnostics.admx"
    "Power.admx"
    "PowerShellExecutionPolicy.admx"
    "PreviousVersions.admx"
    "Printing.admx"
    "Printing2.admx"
    "Programs.admx"
    "PushToInstall.admx"
    "QOS.admx"
    "RacWmiProv.admx"
    "Radar.admx"
    "ReAgent.admx"
    "refs.admx"
    "Reliability.admx"
    "RemoteAssistance.admx"
    "RemovableStorage.admx"
    "RPC.admx"
    "sam.admx"
    "Scripts.admx"
    "sdiageng.admx"
    "sdiagschd.admx"
    "Search.admx"
    "SecureBoot.admx"
    "Securitycenter.admx"
    "Sensors.admx"
    "ServerManager.admx"
    "ServiceControlManager.admx"
    "Servicing.admx"
    "SettingSync.admx"
    "Setup.admx"
    "SharedFolders.admx"
    "Sharing.admx"
    "Shell-CommandPrompt-RegEditTools.admx"
    "ShellWelcomeCenter.admx"
    "Sidebar.admx"
    "SkyDrive.admx"
    "Smartcard.admx"
    "SmartScreen.admx"
    "Snmp.admx"
    "SoundRec.admx"
    "Speech.admx"
    "srm-fci.admx"
    "StartMenu.admx"
    "StorageHealth.admx"
    "StorageSense.admx"
    "Sudo.admx"
    "SystemRestore.admx"
    "TabletPCInputPanel.admx"
    "TabletShell.admx"
    "Taskbar.admx"
    "TaskScheduler.admx"
    "tcpip.admx"
    "TenantRestrictions.admx"
    "TerminalServer.admx"
    "TextInput.admx"
    "Thumbnails.admx"
    "TouchInput.admx"
    "TPM.admx"
    "UserExperienceVirtualization.admx"
    "UserProfiles.admx"
    "VolumeEncryption.admx"
    "W32Time.admx"
    "WCM.admx"
    "WDI.admx"
    "WebThreatDefense.admx"
    "WinCal.admx"
    "Windows.admx"
    "WindowsAnytimeUpgrade.admx"
    "WindowsBackup.admx"
    "WindowsColorSystem.admx"
    "WindowsConnectNow.admx"
    "WindowsCopilot.admx"
    "WindowsDefender.admx"
    "WindowsDefenderSecurityCenter.admx"
    "WindowsExplorer.admx"
    "WindowsFileProtection.admx"
    "WindowsFirewall.admx"
    "WindowsInkWorkspace.admx"
    "WindowsMediaDRM.admx"
    "WindowsMediaPlayer.admx"
    "WindowsMessenger.admx"
    "WindowsProducts.admx"
    "WindowsRemoteManagement.admx"
    "WindowsRemoteShell.admx"
    "WindowsSandbox.admx"
    "WindowsStore.admx"
    "WindowsUpdate.admx"
    "WinInit.admx"
    "WinLogon.admx"
    "WinMaps.admx"
    "Winsrv.admx"
    "WirelessDisplay.admx"
    "wlansvc.admx"
    "WordWheel.admx"
    "WorkFolders-Client.admx"
    "WorkplaceJoin.admx"
    "WPN.admx"
    "wwansvc.admx"
)

# =============================================================
# 2. GENERAL UTILITY FUNCTIONS
# =============================================================

# 1. Create a direcotry if it doen't exist
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

# 2. Bool check if a path exists
function Check_Path {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (Test-Path $Path) {
        Write-Log "Path exists: $Path" -Level PASS
        return $true
    } else {
        Write-Log "Path not found: $Path" -Level WARN
        return $false
    }    
}

# =============================================================
# 3. ADMX UTILITY FUNCTIONS
# =============================================================

# 1. Get 2 levels of GP Editor directory names (EditorDir)
function Get_Editor_Dir {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Entry
    )

    $Cat_Ref = $Entry.parentCategory.ref
    $Child_Cat = "Unknown"
    $Parent_Cat = $null
    $Editor_Dir = "Unknown"

    if ($null -ne $Cat_Ref) {
        # 1. Clean prefix and find Child Category
        $Clean_Cat_Ref = $Cat_Ref.Split(':')[-1]
        $Cat_Def = $ADMX_XML.policyDefinitions.categories.category | Where-Object { $_.name -eq $Clean_Cat_Ref }
        $Current_ADML = $ADML_XML

        # 2. Fallback to Windows.admx if category is external
        if ($null -eq $Cat_Def) {
            $Cat_Def = ([xml](Get-Content (Join-Path $ADMX_Root "Windows.admx"))).policyDefinitions.categories.category | Where-Object { $_.name -eq $Clean_Cat_Ref }
            $Current_ADML = [xml](Get-Content (Join-Path $ADMX_Root "en-US\Windows.adml"))
        }

        # 3. Get that Category's Parent (e.g., 'System')
        if ($null -ne $Cat_Def) {
            $Cat_String_ID = $Cat_Def.displayName.Replace('$(string.', '').Replace(')', '')
            $Child_Cat = $Current_ADML.policyDefinitionResources.resources.stringTable.string | 
                            Where-Object { $_.id -eq $Cat_String_ID } | Select-Object -ExpandProperty '#text'
            
            $Parent_Ref = $Cat_Def.parentCategory.ref
            if ($null -ne $Parent_Ref) {
                $Clean_Parent_Ref = $Parent_Ref.Split(':')[-1]

                # Look in Windows.admx for top-level parents
                $Parent_Def = ([xml](Get-Content (Join-Path $ADMX_Root "Windows.admx"))).policyDefinitions.categories.category | Where-Object { $_.name -eq $Clean_Parent_Ref }
                $Win_ADML = [xml](Get-Content (Join-Path $ADMX_Root "en-US\Windows.adml"))
                
                if ($null -ne $Parent_Def) {
                    $P_String_ID = $Parent_Def.displayName.Replace('$(string.', '').Replace(')', '')
                    $Parent_Cat = $Win_ADML.policyDefinitionResources.resources.stringTable.string | 
                                    Where-Object { $_.id -eq $P_String_ID } | Select-Object -ExpandProperty '#text'
                }
            }
        }

        # 4. Concat results
        $Editor_Dir = if ($null -ne $Parent_Cat) { "$Parent_Cat > $Child_Cat" } else { $Child_Cat }
    }

    return $Editor_Dir
}

# 2. Get policy's GP Editor display name (EditorName)
function Get_Editor_Name {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Entry
    )

    $Lang_ID = $Entry.displayName.Replace('$(string.', '').Replace(')', '')
    $Editor_Name = $ADML_XML.policyDefinitionResources.resources.stringTable.string | 
            Where-Object { $_.id -eq $Lang_ID } | 
            Select-Object -ExpandProperty '#text'

    return $Editor_Name
}

# 3. Get the policy's GP Editor 'Requirements' text (SupportedOn)
function Get_Supported_On {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Entry
    )

    $Support_Node = $Policy_Entry.SelectSingleNode("./*[local-name()='supportedOn']")
    $Supported_On = "Unknown"

    if ($null -ne $Support_Node) {
        # Access the 'ref' attribute using the GetAttribute method
        $Support_Ref = $Support_Node.GetAttribute("ref")
        
        if (-not [string]::IsNullOrWhiteSpace($Support_Ref)) {
            $Clean_Support_Ref = $Support_Ref.Split(':')[-1]
            
            # 1. Search current ADMX for the definition (using local-name for safety)
            $Support_Def = $ADMX_XML.SelectSingleNode("//*[local-name()='definition'][@name='$Clean_Support_Ref']")
            $Target_ADML = $ADML_XML

            # 2. FALLBACK: Search Windows.admx (Most common for OS requirements)
            if ($null -eq $Support_Def) {
                $Win_ADMX_Path = Join-Path $ADMX_Root "Windows.admx"
                if (Test-Path $Win_ADMX_Path) {
                    $Win_ADMX = [xml](Get-Content $Win_ADMX_Path)
                    $Support_Def = $Win_ADMX.SelectSingleNode("//*[local-name()='definition'][@name='$Clean_Support_Ref']")
                    $Target_ADML = [xml](Get-Content (Join-Path $ADMX_Root "en-US\Windows.adml"))
                }
            }
            
            # 3. Extract the final text from the ADML
            if ($null -ne $Support_Def) {
                # Get the display name string ID (e.g., $(string.SUPPORTED_Windows10))
                $S_String_Raw = $Support_Def.GetAttribute("displayName")
                $S_String_ID = $S_String_Raw.Replace('$(string.', '').Replace(')', '')
                
                $String_Node = $Target_ADML.SelectSingleNode("//*[local-name()='string'][@id='$S_String_ID']")
                if ($null -ne $String_Node) {
                    $Supported_On = $String_Node.'#text'
                }
            }
        }
    }

    return $Supported_On
}

# 4. Get all !Property names and type
function Get_Properties {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Entry
    )

    $Prop_Collector = @()
    
    # Top-level policies are usually simple toggles
    if ($null -ne $Entry.valueName) { 
        $Prop_Collector += "$($Entry.valueName) (toggle)" 
    }
    
    # If Elements exist, loop through and find every valueName and its Type
    if ($null -ne $Entry.elements) {
        $Entry.elements.ChildNodes | ForEach-Object {
            if ($null -ne $_.valueName) { 
                # .LocalName identifies the XML tag (e.g., 'text', 'decimal', 'enum')
                $ElementType = $_.LocalName
                $Prop_Collector += "$($_.valueName) ($ElementType)" 
            }
        }
    }

    $Properties = ($Prop_Collector | Select-Object -Unique) -join ", "
    return $Properties
}

# =============================================================
# 4. MAIN CONTROLLER
# =============================================================
function Controller {
    try {
        #-------------------------------------------------------------
        # 0. LOGGING
        #-------------------------------------------------------------
        # 1. Define logging paths
        $Log_Dir = Join-Path -Path $PSScriptRoot -ChildPath "Logs"
        $Log_File = Join-Path -Path $Log_Dir -ChildPath "$($File_Timestamp).txt"

        # 2. Define private logging function
        function Write-Log {
            param (
                [Parameter(Mandatory=$true)] [string]$Message,
                [ValidateSet("SECT", "INFO", "PROMPT", "PASS", "WARN", "ERROR")]
                [string]$Level = "INFO"
            )
            try {
                $Log_Entry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
                $Log_Entry | Out-File -FilePath $Log_File -Append -Encoding utf8

                $Color = switch($Level) {
                    "SECT" { "Cyan" }
                    "INFO" { "White" }
                    "PROMPT" { "Cyan" }
                    "PASS" { "Green" }
                    "WARN"  { "Yellow" }
                    "ERROR" { "Red" }
                    default { "White" }
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
        # Write-Log "DEBUG level = $DEBUG" -Level INFO

        #-------------------------------------------------------------
        # 1. VALIDATE $ADMX_Root and  $ADMX_Files
        #-------------------------------------------------------------
        # 1. ADMX_Root
        if (-not (Check_Path -Path $ADMX_Root)) {
            throw "ADMX root directory not found"
        }
        # 2. ADMX_Files
        if ($null -eq $ADMX_Files -or $ADMX_Files.Count -eq 0) {
            throw "No ADMX_Files defined in script"
        } 

        #-------------------------------------------------------------
        # 2. CSV COLLECTION
        #-------------------------------------------------------------
        # 1. Create directory
        $CSV_Dir = Join-Path -Path $PSScriptRoot -ChildPath "CSV"
        Create_Directory -Path $CSV_Dir
        
        # 2. Create file
        $CSV_File = Join-Path -Path $CSV_Dir -ChildPath "$($File_Timestamp).csv"
        Write-Log "CSV file started: $CSV_File" -Level PASS

        # 3. Temporary data storage
        $CSV_Collection = @()

        Write-Log "Processing files..." -Level INFO
        Write-Log "-------------------------------------------------------------" -Level INFO

        #-------------------------------------------------------------
        # 3. PRCESS FILES
        #-------------------------------------------------------------
        foreach ($File_Name in $ADMX_Files) {
            #
            # 1. Validate file paths
            $ADMX_File_Path = Join-Path -Path $ADMX_Root -ChildPath $File_Name
            $Lang_File_Path = Join-Path -Path $ADMX_Root -ChildPath "en-US\$($File_Name.Replace('.admx','.adml'))"

            if (-not (Check_Path -Path $ADMX_File_Path)) {
                Write-Log "ADMX file not found. Continuing..." -Level WARN
                continue 
            }
            if (-not (Check_Path -Path $Lang_File_Path)) {
                Write-Log "Language file not found. Continuing..." -Level WARN
                continue 
            }

            #
            # 2. Load XML into memory
            [xml]$ADMX_XML = Get-Content -Path $ADMX_File_Path
            [xml]$ADML_XML = Get-Content -Path $Lang_File_Path # ignore warning

            #
            # 3. Loop policies
            $Policy_List = $ADMX_XML.policyDefinitions.policies.policy

            foreach ($Policy_Entry in $Policy_List) {

                # 1. Convert class (Machine, User, Both) to Hive names
                $Hive = if($Policy_Entry.class -eq "Machine") {
                    "Computer"
                } else {
                    $Policy_Entry.class
                }

                # 2. Convert class (Machine, User, Both) to drives
                $Drive = if($Policy_Entry.class -eq "Machine") {
                    "HKLM:\"
                } elseif ($Policy_Entry.class -eq "User") {
                    "HKCU:\"
                } else {
                    $Policy_Entry.class
                }               

                # 3. Get GP Ediotr display 
                $Editor_Dir = Get_Editor_Dir -Entry $Policy_Entry
                $Editor_Name = Get_Editor_Name -Entry $Policy_Entry
                $Supported_On = Get_Supported_On -Entry $Policy_Entry

                # 4. Get !Property names and types
                $Properties = Get_Properties -Entry $Policy_Entry

                # 5. Log object formatted to halp write $LGPO_Defs
                $Log_Data = [PSCustomObject]@{
                    Scope         = $Policy_Entry.Class
                    Hive          = $Hive
                    Drive         = $Drive
                    Path          = $Policy_Entry.key
                    EditorDir     = $Editor_Dir
                    EditorName    = $Editor_Name
                    Properties    = $Properties
                    SupportedOn   = $Supported_On
                }

                # 6. CSV object formatted to help documentation
                $CSV_Data = [PSCustomObject]@{
                    SupportedOn   = $Supported_On
                    Hive          = $Hive
                    EditorDir     = $Editor_Dir
                    EditorName    = $Editor_Name
                    Properties    = $Properties
                    Drive         = $Drive
                    Path          = $Policy_Entry.key
                    ADMX          = $File_Name
                }

                # 7. Write to log
                $Log_Data.PSObject.Properties | ForEach-Object {
                    Write-Log "$($_.Name.PadRight(14)): $($_.Value)" -Level INFO
                }

                # 8. Prep for CSV
                $CSV_Collection += $CSV_Data

                Write-Log "-------------------------------------------------------------" -Level INFO
            } # foreach Policy_Entry
        } # foreach File_Name

        #-------------------------------------------------------------
        # 4. FINALIZE
        #-------------------------------------------------------------
        # 1. CSV Export
        if ($CSV_Collection.Count -gt 0) {
            $CSV_Collection | Export-Csv -Path $CSV_File -NoTypeInformation -Delimiter "," -Encoding utf8
            Write-Log "CSV: $CSV_File" -Level INFO
        }

        # 2. Logging
        Write-Log "Log: $Log_File" -Level INFO
        Write-Log "-------------------------------------------------------------" -Level INFO
        Write-Log "Script complete" -Level PASS
    }
    catch {
        $Detail = $_.Exception.Message

        if ($Detail -like "*Could not write to log*") {
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "-------------------------------------------------------------"
            Write-Host "Script terminated" -ForegroundColor Red
        }
        elseif (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "FATAL ERROR: $Detail" -Level ERROR
            Write-Log "-------------------------------------------------------------" -Level INFO
            Write-Log "Script terminated" -Level ERROR
        } else {
            Write-Host "FATAL ERROR: $Detail" -ForegroundColor Red
            Write-Host "-------------------------------------------------------------"
            Write-Host "Script terminated" -ForegroundColor Red
        }
        return 
    }
}

# 0. Run this puppy
Controller
