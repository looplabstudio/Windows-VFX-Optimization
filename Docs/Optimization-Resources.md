## Optimization Resources

Vetted, high-quality, authoritative resources that are specific to this PC's architecture and priority applications. 

## 1. Official Intel Core Ultra 7 (Arrow Lake) Resources

1. [Intel Core Ultra 7 265K Specifications (ARK)](https://ark.intel.com/content/www/us/en/ark/products/241063/intel-core-ultra-7-processor-265k-30m-cache-up-to-5-50-ghz.html)

    - Ensure Dell BIOS isn't aggressively throttling
    - Verify the exact T-Junction max temperature (105°C) 
    - Verify Turbo Power limits (PL1/PL2)

1. [Intel 64 and IA-32 Architectures Optimization Reference Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

    - Definitive information about how the scheduler interacts with the hardware
    - Volume 1 contains the specific Hybrid Architecture tuning guides
    - Explains exactly how the OS decides to park a thread on an E-Core vs a P-Core 
    - Explains why stutter occurs. 

1. [Arrow Lake-S Processor Specification Update (Errata)](https://edc.intel.com/content/www/us/en/design/products/platforms/details/arrow-lake-s/processor-specification-update/)

    - PDF list of every known engineering defect in the silicon. 
    - 'Errata' list can help confirm known hardware behavior that no driver update fixes
    - Troubleshoot inexplicable crashes in DaVinci Resolve 


## 2. Official NVIDIA RTX 3060 Resources

1. [NVIDIA Video Codec SDK Support Matrix](https://developer.nvidia.com/video-encode-and-decode-gpu-support-matrix-new)

    - Definitive guide to what the GPU can render
    - DaVinci Resolve relies heavily on NVENC (Encoding) and NVDEC (Decoding)
    - Confirm exactly which codecs (H.265, AV1, ProRes raw) the RTX 3060 supports in hardware
    - If a format isn't listed here, it will hit your CPU

1. [NVIDIA Studio Driver Release Notes](https://www.nvidia.com/en-us/geforce/drivers/)

    - The changelog for stability
    - 'Studio' release notes specifically list fixed bugs in creative apps 
    - e.g. 'Fixed crash in DaVinci Resolve 19 when using Magic Mask' 
    - Always read the PDF release note before updating drivers

1. [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html)

    - Understanding compute capability 8.6 (Ampere)
    - Defines the memory limitations of the Ampere architecture 
    - Helps explain why a 3D render might crash with 'Out of Memory' 


## 3. Workstation Architecture Websites

1. [Puget Systems](https://www.pugetsystems.com/all-articles/)

    - Hardware validation for content creation
    - The gold standard for VFX benchmarking
    - Test hardware specifically for DaVinci Resolve, After Effects, and rendering engines.
    - Specific benchmarks for Intel Core Ultra (Arrow Lake) processors in DaVinci Resolve, 
    - Highlights where the NPU and iGPU provide tangible benefits over raw CPU grunt.

1. [Level1Techs](https://forum.level1techs.com/)

    - Workstation architecture & stability 
    - Deep dive into PCIe lane distribution, ECC memory, and OS scheduling anomalies
    - Obscure Arrow Lake scheduling bugs
    - Thunderbolt conflicts
    - Motherboard chipset limitations that affect NVMe throughput

1. [Guru3D](https://www.guru3d.com/)

    - Driver management & GPU utilities
    - Home of DDU (Display Driver Uninstaller)
    - Deep technical analysis of NVIDIA Studio Drivers 
    - Often identifies specific version regressions

1. [Resplendence](https://www.resplendence.com/latencymon)

    - Real-time system latency
    - Developers of LatencyMon
    - Definitive documentation on DPC (Deferred Procedure Calls) and ISR (Interrupt Service Routines) 

1. [Lift Gamma Gain](https://liftgammagain.com/forum/index.php)

    - Professional Colorist Community populated by working Hollywood colorists and DITs.
    - Go here when standard tech support fails. 
    - If a specific Windows update breaks Fusion caching or Blackmagic I/O output, this community will identify the fix first.


## 4. GitHub Repositories

1. [ChrisTitusTech / winutil](https://github.com/ChrisTitusTech/winutil)

    - Comprehensive setup & package management
    - The most production-safe utility available. 
    - Uses a less aggressive, tweaks approach. 
    - Features a GUI that allows you to selectively apply optimizations.
    - Includes specific performance profiles that align with Arrow Lake power plan requirements.
    - 'MicroWin' feature allows you to create a custom restore ISO 

2. [Raphire / Win11Debloat](https://github.com/Raphire/Win11Debloat)

    - Script specifically designed for Windows 11 UI cleanup & Start Menu logic
    - Excels at removing the visual clutter that distracts creatives 
    - Targets Start Menu 'Recommended' section 
    - Targets Start Menu 'Search the web' results
    - Targets the 'Search Highlights' and 'Widgets' services, which consume valuable RAM and background CPU cycles.
    - 'Custom' mode allows you to preserve specific Appx packages (like Photos or Calculator) while removing the rest

3. [hellzerg / optimizer](https://github.com/hellzerg/optimizer)

    - Powerful C# application for granular telemetry and service control
    - Provides deepest level of control over background telemetry 
    - Offers toggle switches for extremely specific services that cause DPC latency
    - Includes specific fixes for Microsoft Office telemetry
    - Includes a Registry Fixer and Startup Manager that are more aggressive than Task Manager


## 5. Adobe Substance 3D Designer: Official Docs & Community Support

1. [Substance 3D Designer Performance Optimization Guidelines](https://helpx.adobe.com/substance-3d-designer/best-practices/performance-optimization-guidelines.html)

    - Definitive source for node graph efficiency
    - Explicitly advises on 'Graph Granularity'
    - Explicitly advises how to structure your graphs to avoid CPU bottlenecks. 
    - Substance Designer uses a hybrid processing model. For Arrow Lake tuning, it's critical to know which notes are:
        - Atomic (CPU-bound) 
        - Hardware Accelerated (GPU-bound) is critical for your Arrow Lake tuning.
    - Also critical when deciding if a heavy process should be a:
        - Complex node (P-Core heavy) 
        - Split into smaller nodes (easier for Thread Director to schedule)

1. [Performances and Optimizations | Substance 3D Bakers](https://helpx.adobe.com/substance-3d-bake/guides/performances-and-optimizations.html)

    - Confirms that heavy baking tasks (like Ambient Occlusion from Mesh) can trigger Windows TDR (Timeout Detection Recovery) resets.
    - Validates the need to increase TDR Delay via the Registry
    - Validates that without tweak, a complex bake on RTX 3060 will cause Windows to think the GPU has frozen and reset the driver, crashing the app.

1. [Substance 3D Designer System Requirements](https://helpx.adobe.com/substance-3d-designer/getting-started/system-requirements.html)

    - Generic, baseline compatibility check
    - Complex 4K graphs will likely spill over from RAM to disk
    - Confirms that 32GB of RAM is the 'Recommended' tier, not 'Optimal' 
    - Validates the decision to monitor Page File usage 

1. [Adobe Support Community: Substance 3D Designer](https://community.adobe.com/t5/substance-3d-designer/ct-p/ct-substance-3d-designer)

    - Direct access to Adobe QA Engineering
    - First place to check if your Arrow Lake CPU causes silent crashes during startup
    - Search 'Hybrid Architecture' or 'E-Core' threads to see 'Process Lasso' setting recommendations for Designer

1. [r/Substance3D (Reddit)](https://www.reddit.com/r/Substance3D/)

    - Best place to find users with identical hardware (RTX 3060 + Modern Intel CPUs). 
    - Threads often discuss baking benchmarks
    - Compare render times against similar rigs to verify if your CPU is throttling.

1. [Polycount Forum: Technical Talk](https://polycount.com/categories/technical-talk)

    - Industry-veteran workarounds
    - Specific NVIDIA Control Panel overrides for Substance
    - Python scripts to batch-process bakes externally to avoid UI lag


## 6. DaVinci Resolve: Official Docs & Community Support

1. [DaVinci Resolve 19 Reference Manual](https://documents.blackmagicdesign.com/UserManuals/DaVinci_Resolve_19_Reference_Manual.pdf)

    - Chapter 2 'System Configuration' explicitly defines the hardware order of operations.
    - Documents the exact priority of GPU vs. CPU for Fusion nodes.
    - Critical for knowing which nodes (Optical Flow vs. Fast Noise) will hammer the GPU or CPU.

1. [Hardware Selection & Configuration Guide](https://www.blackmagicdesign.com/support/)

    - Official system building advice
    - Provides the 'Column' vs 'Row' memory mapping rules for Fusion Connect
    - Validates 32GB RAM minimum for Fusion 
    - If we see 'Render Failed' on your 4K timeline, this document helps calculate the math to prove if we're hitting the RAM ceiling.

1. [We Suck Less (Steakunderwater)](https://www.steakunderwater.com/wesuckless/)

    - Elite Fusion compositor community where Hollywood compositors hang out
    - Lua scripts and Fuses to fix stuttering node graphs on Arrow Lake CPU
    - Home of [Reactor](https://gitlab.com/WeSuckLess/Reactor), package manager for Fusion used to install Krokodove and other optimization tools

1. [Blackmagic Forum: DaVinci Resolve](https://forum.blackmagicdesign.com/viewforum.php?f=21)

    - Bug reporting and Beta feedback
    - Direct line to Blackmagic developers like Dwaine Maggart
    - With the Core Ultra 7 265K, you may encounter specific scheduler bugs in Resolve 19
    - The first place to check if a new NVIDIA Studio Driver has introduced regressions

1. [Puget Systems: Intel Core Ultra 200S (Arrow Lake) Content Creation Review](https://www.pugetsystems.com/labs/articles/intel-core-ultra-200s-content-creation-review/)

    - Specific benchmarks for Ultra 7 265K in DaVinci Resolve
    - Validates that the NPU in Arrow Lake can offload some AI tasks (like Magic Mask), but raw clock speed still rules Fusion.
    - Validates using Windows 'High Performance' power plan to prevent P-Core parking.

1. [PugetBench for DaVinci Resolve](https://www.pugetsystems.com/pugetbench/creators/davinci-resolve/)

    - The standard Fusion GPU test suite
    - Separate 'Fusion' an 'GPU Effects' scores
    - Helps test GPU optimizations without needing to render a full project

