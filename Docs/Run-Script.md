# Run VFX.ps1

## 1. Unplug External Drives

1. Use `Safely Remove Hardware and Eject Media`. 
1. Physically disconnect all external storage.
1. Leave devices disconnected until computer is restarted and validated.


## 2. Suspend BitLocker

Prevent encryption lockouts triggered by kernel or boot policy changes. 

1. Open `Start` and type `Manage BitLocker`.
1. Select `Suspend Protection` (do not decrypt, just suspend).
1. Bitlocker will auto-restart on next boot. 


## 3. PowerShell

1. Open Terminal or PowerShell as an Admin.
2. CD to the script directory.
3. Run the script:

```PowerShell
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\VFX.ps1
```

4. Restart computer and validate by running script in debug mode:

```PowerShell
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\VFX.ps1 -DebugMode 1
```
