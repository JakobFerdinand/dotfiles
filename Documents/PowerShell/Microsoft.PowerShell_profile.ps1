Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Ensure Posh-git is installed.
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git

# Ensure Starship is installed.
# https://starship.rs/
Invoke-Expression (&starship init powershell)

# Ensure Nvim is installed.
# https://github.com/neovim/neovim
Set-Alias vim nvim
$Env:homeDrive = [System.Environment]::ExpandEnvironmentVariables("$home")

# Load bin's config and put all relevant dirs on PATH (per session)
$cfgPath = "$HOME\.config\bin\config.json"
if (Test-Path $cfgPath) {
    $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json

    # Collect candidate directories: default_path + each tool's directory
    $candidates =
        @($cfg.default_path) +
        ($cfg.bins.PSObject.Properties.Value |
            ForEach-Object { Split-Path -Path $_.path -Parent })

    $existingDirs = $candidates |
        Where-Object { $_ } |
        ForEach-Object { $_.Trim() } |
        Where-Object { Test-Path $_ } |
        Select-Object -Unique

    $current = $env:PATH -split ';'
    foreach ($dir in $existingDirs) {
        if (-not ($current | Where-Object { $_ -ieq $dir })) {
            $env:PATH = "$dir;$env:PATH"
        }
    }
}

function config {
    git.exe --git-dir=$HOME/dotfiles --work-tree=$HOME $args
}
function lazyconfig {
    lazygit -g $HOME/dotfiles -w $HOME $args
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function getVSDir {
    param (
        [bool]$preview
    )

    $prefix = "C:\Program Files\Microsoft Visual Studio\18\"
    $postfix = "\Common7\IDE\"

    if ($preview -eq 1 -and (Test-Path ($prefix + "Preview" + $postfix))) {
        return $prefix + "Preview" + $postfix;
    }
    elseif (Test-Path ($prefix + "Enterprise" + $postfix)) {
        return $prefix + "Enterprise" + $postfix;
    }
    elseif (Test-Path ($prefix + "Professional" + $postfix)) {
        return $prefix + "Professional" + $postfix;
    }
    elseif (Test-Path ($prefix + "Community" + $postfix)) {
        Set-Alias tf ($prefix + "Community" + $postfix)
    }
}

$vsDir = getVSDir -preview 0
$vsPreviewDir = getVSDir -preview 1

Set-Alias tf ($vsDir + "CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe")
Set-Alias vs ($vsDir + "devenv.exe")
Set-Alias vspreview ($vsPreviewDir + "devenv.exe")

Set-Alias lg lazygit

Set-Alias nuget "C:\Tools\nuget.exe"
Set-Alias speedtest "C:\Tools\speedtest.exe"
Set-Alias infosys "C:\tools\Infosys\Infosystem.lnk"
Set-Alias lamdera "C:\tools\lamdera\lamdera.exe"

function defenderScan {
  Start-MpScan -ScanType FullScan
}

function gitcleanup {
    Get-ChildItem -Recurse -Filter '*.orig' | Remove-Item
}

Remove-Item Alias:ls
function ls {
    eza --icons -a -l --group-directories-first --no-permissions --no-time --ignore-glob=".git|dotfiles" $args
}

Remove-Item Alias:cat
function cat {
    bat --paging=never $args
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })
