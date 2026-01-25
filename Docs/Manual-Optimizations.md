# VFX Manual Optimizations

## 1. Set Fixed Page File

Prevent VFX apps from crashing when RAM fills up.

1. Windows+R > `sysdm.cpl` 
1. System Options: Advanced tab > Performance Settings button
1. Performance Options: Advance tab
1. Virtual Memory section > Change button
1. Uncheck `Automatically manage paging file size for all drives`
1. Select the OS drive (`C:`)
1. Select `Custom size`.
1. `Initial size (MB): 32768` (32GB)
1. `Maximum size (MB): 32768` (32GB)
1. Click `Set`, then `OK`.


## 2. BIOS Optimizations

For my build, these are the only BIOS changes I made: 

- Power > Thermal Management = Ultra Performance
- Performance > Enable C-State Control = Off

For reference, here is a more comprehensive list of things to check. Options will vary by vendor and BIOS version.

| Category  | Sidebar Menu       | Setting                        | Target Value              |
| --------- | ------------------ | ------------------------------ | ------------------------- |
| Stability | System Information | Microcode Revision             | 0x114 or Higher           |
| Stability | Performance        | Multi-Core Enhancement (MCE)   | Disabled / Enforce Limits |
| Power     | Performance        | PL1 (Long Duration)            | 250W                      |
| Power     | Performance        | PL2 (Short Duration)           | 250W                      |
| Power     | Performance        | Core Current Limit (IccMax)    | 347A                      |
| Logic     | Virtualization     | Intel Virtualization Tech (VT) | Enabled                   |
| Logic     | Virtualization     | VT-d                           | Enabled                   |
| Logic     | Performance        | Intel Dynamic Tuning (DTT)     | Enabled                   |
| Latency   | Performance        | C-States Control               | Disabled / C1 Only        |

**Enable Virtualization & VT-d**

The optimization script disables the software-side Memory Integrity (HVCI). Even so, Arrow Lake needs the hardware-level virtualization active for proper voltage management.

- Thread Director 2.0: Arrow Lake uses a hardware-level "Internal Service" to communicate with the Windows 11 Scheduler. This handoff relies on virtualization extensions to map P-core and E-core tasks with low latency.

- Voltage Management (The Loud Fan Fix): On Dell Tower Plus boards, the Intel Dynamic Tuning Technology (DTT) often uses virtualization pathways to manage the power envelope. Disabling VT in BIOS can blind the OS to certain thermal sensors, causing the fans to default to 100% speed as a fail-safe.

- Ring Overhead is Negligible: The ring transition overhead of having VT on in the BIOS is now measured in nanoseconds—far outweighed by the performance loss of a confused scheduler or thermal throttling.

**Enforce Power Limits**

Without these locks, the CPU might boost to 5.5GHz for 30 seconds of a render, hit a thermal/power wall, and then crash down to 3.9GHz, causing stuttering in your DaVinci Resolve render times.

- Switch to Core Current Limit (IccMax) 400A (Performance) if Cinebench scores are significantly below 2000 pts at 347A

**Disable "Enhanced C-States" (or C1E)**

C-States allow the CPU to drop to near-zero voltage when idle. In high-end VFX, the constant "waking up" of a P-Core from a deep C-State causes DPC latency spikes (the micro-stutter).

**Verify Intel Dynamic Tuning Technology (DTT)**

DTT is the brain that communicates with the Windows Thread Director. Dell sometimes hides this under `Performance Mode`.

**Disable Multi-Core Enhancement (MCE)**

MCE is a factory overclock that ignores Intel's safety limits to push all cores to max turbo. This is the primary culprit for the Vmin Shift degradation issues.


## 3. Time Check

The `VFX.ps1` script unhides the `Processor performance time check interval` option located at:

- Start > Edit Power Plan > Change advanced power setting: Processor power management

Think of Processor Performance Time Check as the refresh rate for your CPU's internal decision-making.

**The Mechanism:** Every 15ms (Windows default), the OS interrupts the CPU to ask: Are you busy? Do we need to boost the clock speed? Or should we throttle down to save power?

**The Problem:** In a VFX workflow, these constant interruptions (polling) create a heartbeat of system overhead. If this heartbeat coincides with a critical audio buffer or a frame render, you get a micro-stutter or audio crackle (DPC Latency spike).

**The Fix:** We tune this manually to stop the nagging.

Since we are using the High Performance Power Plan, we have already told the CPU to stay at 100% clock speed (Min Processor State = 100%). We know it doesn't need to throttle down. Therefore, asking it Do you need to change speed? every 15ms is wasted energy and unnecessary interrupt latency.

**Tuning Ranges: Responsiveness vs Overhead**

| MS        | Use Case                    | Behavior |
|-----------|-----------------------------|----------|
| 15        | Balanced, general computing | Default. Checks constantly. High overhead. |
| 100 - 200 | Workstation + safe VFX      | Reduces overhead significantly but catches runaway thermals quickly. | 
| 5000      | Pure VFX + audio            | Aggressive. Lowest possible DPC latency. |


**Arrow Lake Recommendation**

- Time Check = 5000
- If the system feels sluggish to wake up from an idle state, lower this to 1000ms.

Why?

- Arrow Lake's tile architecture already has higher-than-average latency, we want to remove every possible OS bottleneck. 
- The script enforces the High Performance Plan and sets Minimum Processor State = 100%
- Net result is that clock speed never throttles down, so any time check is an unnecessary interruption.

Risk: If cooling fails and the CPU thermal throttles, 

- The OS might take 5 seconds to realize it needs to adjust the power plan logic.
- Hardware thermal protection will still kick in instantly at the bios level.
 
