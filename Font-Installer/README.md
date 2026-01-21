# Windows Font Installer PowerShell Script

`Font-Installer.ps1` installs all fonts in a given directory, including child directories. 

This is a simple installer for existing, organized font libraries:

- Fonts are unzipped
- Fonts are in the parent asset directory, or in an immediate child directory
- Fonts are one of these file formats: `.ttf`, `.otf`, `.fon`, `.ttc`
- For fonts with more than one format, unwanted formats have been deleted

```PowerShell
# 1. PowerShell as administrator.
# 2. CD to script directory.
# 3. Run script.

CD C:\Windows-VFX-Optimization\Font-Installer
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\Font-Installer.ps1 -FontDir "C:\Test-Fonts"

```
