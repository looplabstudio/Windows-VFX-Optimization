# Windows 11 Pro 25H2: Workstation Specifications

## 1. PC Specifications

```
Dell Tower Plus EBT2250
1000W Power supply

Windows 11 Pro 25H2
OS build 26200.7462
Windows Feature Experience Pack 1000.26100.275.0

Intel Core Ultra 7 265K - 20-Core, 3.90 GHz
Intel UHD Graphics

32GB DDR5, 2 x 16 GB, 5200 MT/s 
64-bit operating system, x64-based processor
512GB M.2 PCIe NVMe SSD

Intell Micronode: 114
Windows Scheduler Patch: 2025-11 KB5071430
```

### Intel Microcode (BIOS)

Prevent physical chip degradation caused by `Vmin Shift` instability. Dell's custom BIOS doesn't display this info. Instead, we query the kernel and pull the `Update Revision` version from the registry.

```PowerShell
# As Admin
# Must return hex for 114 or higher (11A)
$val = (Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0)."Update Revision"; "{0:X}" -f ([System.BitConverter]::ToInt32($val, 0))

```

### Windows Scheduler Patch

Ensure Windows Thread Director correctly assigns DaVinci Resolve to P-Cores.

1. Go to Settings > Windows Update > Update History.
1. Check `Quality Updates`.
1. Confirm `KB5044384` (or newer) is listed.
1. Manually check for updates if this patch is missing.


## 2. Graphics Card

Once primary configurations are complete, I will be installing a RTX taken from my old Dell XPS 8650 (i9).

```
NVIDIA GeForce RTX 3060 12GB (LHR)
```

## 3. Anti-Virus Software

- Windows Defender (no other anti-virus)


## 4. Priority Applications

We are optimizing for a VFX environment. Rendering applications are:

- Adobe Substance 3D Designer
- DaVinci Resolve Fusion


## 5. External Storage Devices

- Seagate HHD
- Multiple SSD

## 6. Pen Tablet

- XPen 

## 7. Cloud Services

- Google Drive for Desktop

## 8. Microsoft Products

Broadly, I don't use Microsoft products, including: 

- Office
- Outlook
- OneDrive
- Edge

## 9. Environment, Preferences, Habits

- This PC is my primary device. 
- This is a solo rig - I am the only user / admin.
- I usually leave my PC powered on, including overnight.
- During work hours, I'm rarely away from PC for more than 2 hours at a time.
- I do not need to run overnight, unattended renders. 
- I'm legally blind. I prefer dark mode. I prefer a flat, unanimated UI.
- I play Steam games on my PC using an Xbox-like controller and gaming headset.
- I do not connect my phone or other mobile devices to my PC.
- I do not make phone calls from my PC.
- I do make Zoom calls using my gaming headset to listen and talk.
- I use Keeper Password manager. I don't need Windows or my browsers to remember autofill information, passwords, or passkeys.
