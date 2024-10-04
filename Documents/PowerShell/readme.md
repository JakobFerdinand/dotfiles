# Windows Configuration

The tools I need for my workflows on a windows device are definded in the [tool-list.json](tool-list.json) file.
To install the tools execute the following command:

```sh
winget import --accept-package-agreements --accept-source-agreements -i .\tool-list.json
```

## Neovim

To use the provided config for [neovim](https://neovim.io/) add that symlinc.

```sh
New-Item -ItemType SymbolicLink -Path $env:LOCALAPPDATA\nvim -value $env:USERPROFILE\.config\nvim\
```

## Helix Editor

To use the provided config in [helix](https://helix-editor.com/) add that link.

```sh
New-Item -ItemType HardLink -Path $env:APPDATA\helix\config.toml -value $env:USERPROFILE\.config\helix\config.toml
```

## Starship

Add the following to the end of Microsoft.PowerShell_profile.ps1. 
You can check the location of this file by querying the `$PROFILE` variable in PowerShell. 
Typically the path is ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 or ~/.config/powershell/Microsoft.PowerShell_profile.ps1 on -Nix.

It is already set in my config.

```ps1
Invoke-Expression (&starship init powershell)
```
