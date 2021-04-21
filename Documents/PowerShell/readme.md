# Powershell Configuration

For using the powershell configuration [Starship](https://github.com/starship/starship) has to be installed.

On Windows:
```
choco install starship
```

> Add the following to the end of Microsoft.PowerShell_profile.ps1. You can check the location of this file by querying the $PROFILE variable in PowerShell. Typically the path is ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 or ~/.config/powershell/Microsoft.PowerShell_profile.ps1 on -Nix.
> ```ps1
> Invoke-Expression (&starship init powershell)
> ```