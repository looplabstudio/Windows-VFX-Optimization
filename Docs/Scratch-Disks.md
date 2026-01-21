# VFX Optimization: Scratch and Cache Disks


In a VFX workflow, the OS drive (usually `C:`) is for software, while a scratch/cache disk is an industrial dumpster for high-speed temporary data. Moving this off the `C:` drive prevents OS bottlenecking and avoids premature SSD wear.


## Scratch / Cache SSD

1. Use a dedicated 1TB SSD formatted as NTFS (not exFAT). NTFS is superior for handling thousands of tiny cache files. 

2. Use a Thunderbolt connection. Alternatively, plug in to a Blue (USB 3.1) port on back of computer using the thickest, shortest USB cable available. 

3. Disable Windows Search Indexing on the dedicated external SSD to prevent IO contention.
   - File Explorer > Right-Click `DRIVE_NAME` > Properties
   - General tab > Uncheck: Allow files on this drive to have contents indexed in addition to file properties
   - Select: Apply changes to drive, subfolders, and files

4. Enable the `Better Performance` policy to unlock full write speeds.

    - Start > Device Manager > Disk Drives
    - Right-click drive > Properties
    - Select `Properties > Policies` tab
    - Select `Better performance`
    - Check `Enable write caching on the device`
    - Click `OK`
   - **IMPORTANT:** Always use `Safely remove hardware`  disk before disconnecting.

5. Create destination folders

```
CACHE_SSD
    Resolve_Cache
        CacheClip
        Gallery
    Substance_Cache
```


## DaVinci Resolve Render Cache & Optimized Media

Resolve generates massive high-bitrate files (ProRes 422 HQ or DNxHR) to allow smooth playback of complex node graphs.

- A 10-minute 4K project can easily generate 200GB to 500GB of cache.
- If this is on the OS drive, Windows and Resolve fight for the same PCIe lanes, causing the stuttering playhead syndrome.

Optimize and map folders to dedicated drive: 

1. Open Resolve > `Preferences` > `Memory and GPU`.
    * `System Memory:` Allow maximum available.
    * `Fusion Memory Cache:` Limit to 75% of reserved memory.
    * `GPU Configuration:` Uncheck "Auto". Manually select `CUDA` and your `RTX 3060`.
1. Go to `Media Storage` > `Mount Locations`
1. Right-click the SSD location and select `"Set as First Scratch Disk"`.


**Fusion Memory Mapping:** Fusion caches frames to RAM. With 32GB, you are on the razor's edge for 4K. You should disable `Pre-Render` in Fusion settings to prevent it from fighting the `Edit` page for RAM.


## Adobe Substance 3D Temporary Files

Substance uses disk-based swapping when baking high-poly meshes or working with 8K textures.

- A single complex Baker session can dump 20GB to 100GB of temporary data that is deleted only when the app closes.
- Writing massive temp files to the OS drive increases system latency and can cause `Application Not Responding` hangs during 4K bakes.

Map folders to dedicated drive:

1.  Open Substance Designer > `Edit > Preferences`.
1.  `General > Temporary Files`: 

## 4. Substance 3D Designer

**Hybrid Architecture Lag:** Users report that Substance Designer sometimes launches on the E-Cores, causing the UI to feel sluggish while the 3D viewport flies.

This often requires a Process Priority tweak or using `Process Lasso` to permanently assign `Adobe Substance 3D Designer.exe` to P-Cores 0-16.

**Viewport Stutter:** If the `G-Sync` or `Variable Refresh` Rate is active in Windows Graphics settings, Substance viewports can flicker. Force `Fixed Refresh` for Substance in the NVIDIA Control Panel.
