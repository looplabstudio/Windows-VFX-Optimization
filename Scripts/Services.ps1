<#
.DESCRIPTION
    Stops services that send telemetry and consume resources we need for VFX. 

.PARAMETER Version
    2026-01-02

.NOTES
    Dell Data Vault (The DPC Spike)

    Dell pre-installs `DDVDataCollector` (Dell Data Vault) and `Dell Instrumentation`. 
    These run at the kernel level to log fan speeds.

    In audio/video apps, these services are the #1 cause of `wdf01000.sys` latency spikes (audio crackling). 
    They persist even after uninstalling `SupportAssist`.

    These specific services must be disabled in `services.msc` or via script, 
    and not just uninstalled via Settings.

#>

Write-Log "-------------------------------------------------------------" -Level SECT
Write-Log "                          Services                           " -Level SECT
Write-Log "-------------------------------------------------------------" -Level SECT

# =============================================================
# 1. Define Services
# =============================================================

$Target_Services = @(
    "DiagTrack"                           # Connected User Experiences and Telemetry
    "WbioSrvc"                            # Windows Biometric Service (If not using Hello)
    "edgeupdate"                          # Microsoft Edge Update Service (Manual)
    "edgeupdatem"                         # Microsoft Edge Update Service (Manual)
    "KAPSService"                         # Killer Smart AP Selection Service
    "Killer Analytics Service"            # Killer Analytics (Telemetry)
    "Killer Network Service"              # Killer Network (DPC Latency source)
    "Killer Provider Data Helper Service" # Killer Data Helper
    "KNDBWM"                              # Killer Dynamic Bandwidth Management
    "WavesAudioService"                   # Waves Audio (Spatial processing)
    "WavesSysSvc"                         # Waves Audio (Background service)
    # --- Expanded Dell Infrastructure (DPC/Telemetry) ---
    "Dell TechHub",                       # Modern telemetry and hardware logging
    "DDVDataCollector",                   # Dell Data Vault Collector
    "DDVRulesProcessor",                  # Dell Data Vault Rules Processor
    "Dell Data Vault Service API",        # API interface for Data Vault
    "DellClientManagementService",        # Handles Dell-specific update logic
    "DellDigitalDeliveryService",         # Background downloader for factory apps
    "DellOptimizer",                      # AI/Network optimization middleware
    "dsmsvc",                             # Dell System Measurement (Telemetry)
    "DCU64Service"                        # Dell Command | Update service
)

# =============================================================
# 2. Functions
# =============================================================

# 1. Stop running services
function Stop_Services {
    try {
        Write-Log "Stopping and configuring services..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
        
        foreach ($SvcName in $Target_Services) {
            try {

                $Svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
                Write-Log "Service: $($Svc.DisplayName) ($SvcName)" -Level INFO

                # 1. Skip missing services
                if ($null -eq $Svc) {
                    Write-Log "Skipped: Service not found" -Level DETAIL
                    Write-Log "-------------------------------------------------------------" -Level DIV
                    continue
                }

                # 2. Stop if running
                if ($Svc.Status -eq 'Running') {
                    Stop-Service -Name $SvcName -Force -ErrorAction Stop
                    Write-Log "Service stopped" -Level PASS
                } else {
                    Write-Log "Service already stopped" -Level PASS
                }

                # 3. Set to Manual
                if ($Svc.StartType -ne 'Manual') {
                    Set-Service -Name $SvcName -StartupType Manual -ErrorAction Stop
                    Write-Log "Startup type set to Manual" -Level PASS
                } else {
                    Write-Log "Startup type already Manual" -Level PASS
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Failed to configure service" -Level ERROR
                Write-Log "$Detail" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue
            } 
        }
        Write-Log "Services processing complete" -Level DETAIL  
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }    
}

# 2. Validate stopped services

function Validate_Services {
    try {
        Write-Log "Validating services..." -Level DETAIL
        Write-Log "-------------------------------------------------------------" -Level DIV
        
        foreach ($SvcName in $Target_Services) {
            try {

                $Svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
                Write-Log "Service: $($Svc.DisplayName) ($SvcName)" -Level INFO

                # 1. Skip missing services
                if ($null -eq $Svc) {
                    Write-Log "Skipped: Service not found" -Level DETAIL
                    Write-Log "-------------------------------------------------------------" -Level DIV
                    continue
                }

                # 2. Check if running
                if ($Svc.Status -eq 'Running') {
                    Write-Log "Service state: $($Svc.State)" -Level ERROR
                } else {
                    Write-Log "Service state: $($Svc.State)" -Level PASS
                }

                # 3. Check if Manual
                if ($Svc.StartType -ne 'Manual') {
                    Write-Log "Startup type: $($Svc.StartType)" -Level ERROR
                } else {
                    Write-Log "Startup type: $($Svc.StartType)" -Level PASS
                }
                Write-Log "-------------------------------------------------------------" -Level DIV
            }
            catch {
                $Detail = $_.Exception.Message
                Write-Log "Failed to configure service" -Level ERROR
                Write-Log "$Detail" -Level DETAIL
                Write-Log "-------------------------------------------------------------" -Level DIV
                continue
            } 
        }
        Write-Log "Services validation complete" -Level DETAIL  
    }
    catch {
        $Detail = $_.Exception.Message
        throw "$Detail"
    }    
}

# =============================================================
# 3. Process
# =============================================================

if ($global:DEBUG -eq 0) { Stop_Services } else { Validate_Services}

