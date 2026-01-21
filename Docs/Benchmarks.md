# Windows 11 Pro: Benchmarks

| Test          | Preflight       | Pre RTX | Post RTX |
|---------------|-----------------|---------|----------|
| DPC Latency   | 616.664776µs    |||
| CPU Clocking  | 1941 pts        |||
| Storage I/O   | Read 62.6 MB/s  |||
|               | Write 43.3 MB/s |||
| GPU Stability | NA              | NA ||


## 1. Benchmarking Tools

Safe, official direct download links.

[LatencyMon (Free Home Edition)](https://www.resplendence.com/downloads)

Scroll down to the System Monitoring Tools section and look for LatencyMon 7.31 (or newer). Click Download Free Home Edition.

[Cinebench 2024](https://www.maxon.net/en/downloads/cinebench-2024-downloads)

Maxon now encourages the Maxon App to manage installs, but you can likely find the standalone Cinebench 2024 offline installer on this page or via the app.

- Alternative: [Microsoft Store Link](https://apps.microsoft.com/detail/9pgzkjc81q7j)

[CrystalDiskMark](https://crystalmark.info/en/download/)

This site runs ads that look like download buttons. Ensure you click the small, gray/blue buttons specifically in the Standard Edition row.

- Under CrystalDiskMark, look for the Standard Edition.
- Click the button labeled ZIP (XP-) or INSTALLER.


## 2. DPC Latency: The Stutter Test

High latency results in audio pops and viewport stuttering, regardless of GPU power.

Here, high spikes in `wdf01000.sys` or `ndis.sys` confirms a need to target background telemetry and Dell support drivers.

```
Tool: LatencyMon 
Method: 2-minute text with PC idle
Metric: Highest reported DPC routine execution time
Target: Spikes < 500µs, no red bars in the interface

Preflight: 616.664776µs, no red bars
Pre RTX:
Post RTX: 

```

## 3. CPU Clocking: The Arrow Lake Test

Verifies if the Windows power plan is correctly unparking P-cores on the Core Ultra 7 265K.

A fail here is usually caused by a lazy power plan that's throttling boost clocks.

```
Tool: Cinebench 2024
Test: CPU (Multi Core)
Method: Run test, monitor fans for first 30 seconds
Target: Fans ramp up immediately.
        Score averages ~2000-2200 pts

Preflight: 1941 pts
Pre RTX:
Post RTX: 

```

## 4. Storage I/O (Page File Impact)

With 32GB RAM, DaVinci Resolve Fusion will heavily utilize the Page File. We must ensure the NVMe is not a bottleneck.

Low scores here indicate that virtual memory swapping will cause significant lag in the node graph.

```
Tool: CrystalDiskMark
Method: Default 1GiB run
Metric: Random 4K Q1T1 (Read)
Target: > 60 MB/s

Preflight: Random Read 62.6 MB/s
           Random Write 43.3 MB/s
Pre RTX:
Post RTX:

```

## 5. GPU Stability: TdrDelay Verification

Windows resets drivers if they hang for 2 seconds. Heavy Fusion flows often exceed this.

```
- Verification: Open Registry Editor or use Script
- Path: `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers`
- Key: `TdrDelay` (REG_DWORD)
- Target: 60 (decimal)
- Method: Load a heavy Substance texture or Fusion flow; ensure no "GPU Driver Crash" errors occur.

Preflight: NA
Pre RTX: NA
Post RTX: 

```

## 6. Subjective Snappiness

- Boot Time: Power button press to usable Desktop.
- Search Indexing: Hit Windows Key, type "DaVinci", measure delay to result.
- Context Menu: Right-click desktop; verify classic menu appears instantly (no "Show more options").

