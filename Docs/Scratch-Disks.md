# VFX Optimization: Scratch and Cache Disks

In a VFX workflow, the OS drive (usually `C:`) is for software, while a scratch/cache disk is an industrial dumpster for high-speed temporary data. Moving this off the `C:` drive prevents OS bottlenecking and avoids premature SSD wear.

Resolve generates massive high-bitrate files (ProRes 422 HQ or DNxHR) to allow smooth playback of complex node graphs.

- A 10-minute 4K project can easily generate 200GB to 500GB of cache.
- If this is on the OS drive, Windows and Resolve fight for the same PCIe lanes, causing the stuttering playhead syndrome.

Substance uses disk-based swapping when baking high-poly meshes or working with 8K textures.

- A single complex Baker session can dump 20GB to 100GB of temporary data that is deleted only when the app closes.
- Writing massive temp files to the OS drive increases system latency and can cause `Application Not Responding` hangs during 4K bakes.


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

5. Create destination folders:

```
CACHE_SSD
    Resolve_Cache
        CacheClip
        Gallery
    Substance_Cache
```
