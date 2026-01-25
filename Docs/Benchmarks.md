# Windows 11 Pro: Benchmarks

| Category       | Tool            | Preflight       | Pre RTX          | Post RTX |
|----------------|-----------------|-----------------|------------------|----------|
| DPC Latency    | LatencyMon      | 616.664776µs    | 112.511604µs     ||
| CPU Clocking   | Cinebench       | 1941 pts        | 7823 pts         ||
| Random 4K I/O  | CrystalDiskMark | Read 62.6 MB/s  | Read 79 MB/s     ||
|                |                 | Write 43.3 MB/s | Write 143.1 M


## 1. Benchmarking Tools

Safe, official direct download links.

[LatencyMon (Free Home Edition)](https://www.resplendence.com/downloads)

Scroll down to the System Monitoring Tools section and look for LatencyMon 7.31 (or newer). Click Download Free Home Edition.

[Cinebench 2024](https://www.maxon.net/en/downloads/cinebench-2024-downloads)

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
Pre RTX: 112.511604µs
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

