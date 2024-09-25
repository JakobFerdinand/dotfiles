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

    $prefix = "C:\Program Files\Microsoft Visual Studio\2022\"
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
