# VFX Optimization: Adobe Substance & DaVinci Resolve


## 1. Adobe Substance 3D Designer 

Map folders to [dedicated scratch/cache drive](Scratch-Disks.md): 

1.  Substance Designer > Edit > Preferences > General: Temporary Files
1.  [TODO]


## 2. DaVinci Resolve Render Cache & Optimized Media

Map folders to [dedicated scratch/cache drive](Scratch-Disks.md): 

1. Resolve Preferences > Media Storage > Mount Locations.
1. Right-click the SSD location and select `Set as First Scratch Disk`.
1. [TODO] Gallery

Further optimize: 

1. Resolve > Preferences > Memory and GPU.
1. `System Memory:` Allow maximum available.
1. `Fusion Memory Cache:` Limit to 75% of reserved memory.
1. `GPU Configuration:` Uncheck "Auto". Manually select `CUDA` and the `RTX 3060`.
1. Disable `Pre-Render` in Fusion settings to prevent fighting with the Edit page for RAM.


## 3. NVIDIA Control Panel

Use the `Studio Driver` branch and perform a `Clean Install` to remove legacy telemetry.

Do not install `Game Ready` drivers. Specifically, DaVinci Resolve 19 has severe conflict issues with certain recent drivers. 


| Setting                     | Target Value                  | Why?     |
| --------------------------- | ----------------------------- | -------- |
| Power management mode       | Prefer maximum performance    | Keeps GPU clocks high to prevent laggy playback during color work. |
| Texture filtering - Quality | High performance              | Bypasses redundant driver filtering to speed up frame processing.  |
| Threaded optimization       | On                            | Improves communication between Arrow lake CPU and the GPU.|
| Vertical sync               | Off                           | Prevents the 60fps cap; essential for smooth Fusion UI responsiveness. |
| Low Latency Mode            | On                            | Reduces the render queue to make timeline scrubbing feel instant. |
| Open GL GDI compatibility   | Prefer Performance            | Accelerates 2D UI overlays on top of 3D viewports. |
| Multi-Frame Sampled AA      | Off                           | Prevents artificial smoothing that can mask noise or render artifacts. |
| Background Application Max Frame Rate | Off                 | Ensures background renders (Resolve/Media Encoder) run at full speed.  |
| Output color format         | RGB                           | Ensures the most accurate color reproduction for PC monitors. |
| Output color depth          | 10 bpc (if avail)             | Critical for 10-bit grading in Resolve to prevent banding.    |
| Output dynamic range        | Full (0-255)                  | Fixes the gamma shift bug where blacks appear as dark grey. |

**Viewport Stutter:** If the `G-Sync` or `Variable Refresh` Rate is active in Windows Graphics settings, Substance viewports can flicker. Force `Fixed Refresh` for Substance in the NVIDIA Control Panel.

