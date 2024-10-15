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

For using fzf in neovim these tools and settings need to be installed and configured.
```sh
winget install --id=junegunn.fzf  -e
winget install --id=ezwinports.make  -e
```
To install `gcc` download [w64devkit](https://www.mingw-w64.org/downloads/) from [GitHub](https://github.com/skeeto/w64devkit/releases).
Extract it to `C:\tools\w64devkit`.
Add `C:\tools\w64devkit\bin` to the `PATH` Variable.
```sh
$binPath = "C:\tools\w64devkit\bin"
[System.Environment]::SetEnvironmentVariable("Path", $Env:Path + ";" + $binPath, [System.EnvironmentVariableTarget]::Machine)
```

## Starship

Add the following to the end of Microsoft.PowerShell_profile.ps1. 
You can check the location of this file by querying the `$PROFILE` variable in PowerShell. 
Typically the path is ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 or ~/.config/powershell/Microsoft.PowerShell_profile.ps1 on -Nix.

It is already set in my config.

```ps1
Invoke-Expression (&starship init powershell)
```
