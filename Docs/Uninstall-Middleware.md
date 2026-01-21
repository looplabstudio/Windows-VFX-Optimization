# Windows 11 Pro: Uninstall Middleware

I used a combination of `Settings > Apps > Installed apps` and Revo Uninstaller to remove problematic middleware.

## 1. Keep These Apps if Present

1. Realtek Audio Driver
1. Intel Graphics Software
    - Newer version of Command Center
    - Drivers and detailed GPU tuning
1. Intel Rapid Storage Technology Application
    - Uninstalling the Intel Rapid Storage Technology Driver can cause a boot failure.


## 2. Uninstall 

1. 3rd-party anti-virus
1. Dell Core Services
    - An aggregating installer for Dell’s software ecosystem. It 
    - Dell Tech Hub, Dell Telemetry Management, Notification Manager, Update Service
1. Dell Connected Service Delivery
1. Dell Optimizer
    - Unnecessary middleware
1. Dell SupportAssist
    - Aggressive middleware that interferes with kernel-level operations
    - Causes DPU spikes
    - Consumes CPU cycles and RAM
    - Update conflicts can overwrite Intel and NVIDIA Studio drivers
1. Intel Killer Performance Suite
    - Runs the Killer Network Service (KNS)
    - Software meant to prioritize network traffic for gamers and streamers
    - Notorious for high CPU usage and background traffic analysis
1. Killer Ethernet Performance Suite
    - DPC latency issues
    - High CPU overhead
    - Stability issues
