# VFX Optimization: Adobe Substance & DaVinci Resolve


## 1. Adobe Substance 3D Designer 

Map folders to [dedicated scratch/cache drive](Scratch-Disks.md): 

1.  Substance Designer > Edit > Preferences > General: Temporary Files


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

