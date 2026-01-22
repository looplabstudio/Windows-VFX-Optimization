# Windows 11 Pro 25H2 Optimizations for VFX Workflows

A technical writer's notes and PowerShell scripts for optimizing a new [Windows 11 Pro PC for VFX workflows](./Docs/Workstation-Specifications.md).


## Approach

1. [Perform initial benchmarks](./Docs/Benchmarks.md)
1. [Manually uninstall middleware](./Docs/Uninstall-Middleware.md)
1. [Run VFX.ps1](./Docs/Run-Script.md)
1. [Perform manual optimizations](./Docs/Manual-Optimizations.md)
1. [Perform midway benchmarks](./Docs/Benchmarks.md)
1. [Install RTX 3060](./Docs/RTX-3060.md)
1. [Set up scratch/cache SSD](./Docs/Scratch-Disks.md)
1. [Configure Substance and Resolve](./Docs/App-Configs.md)
1. [Perform final benchmarks](./Docs/Benchmarks.md)


## What VFX.ps1 Does

The scripts are documented in-place. The best way to understand what optimizations are performed and why is to read the `.ps1` files, starting with `VFX.ps1`.

`VFX.ps1` contains a list of`$Subscripts`. I tried to keep each one tightly focused so they're easy to comment out and skip. Broadly, the subscripts fall into 2 categories:

- Common optimizations for any Windows 11 PC - these are Group Policies and Registry keys. They set/disable many of the controls available in the Settings app. 
- Build-specific optimizations primarily aimed at Intel Core Ultra 7 265K and the Arrow Lake tile architecture. These include Group Policies, Registry keys, Services, and Tasks.

`VFX.ps1` has a few handy features:

- It can backup `.reg` and `.pol` files.
- It can set a System Restore point.
- It has a validation mode that's useful both after running the script for the first time, and after Windows & other updates. 
- It creates human-friendly logs with helpful information about the optimizations performed. 


## What VFX.ps1 Doesn't Do

`VFX.ps1` doesn't perform every optimization needed for the best VFX experience - manual configurations are required. 

`VFX.ps1` does not de-bloat Windows Apps or 3rd-party stubs. Installed middleware varies greatly depending on the vendor and OS build, I decided it was easiest and fastest to simply uninstall what was present on my specific build.

`VFX.ps1` is aimed at a solo VFX workstation with 1 user. It doesn't deal with networking or enterprise-type configurations or optimizations. 


