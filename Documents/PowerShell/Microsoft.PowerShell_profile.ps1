Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

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

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

$prefix = "C:\Program Files\Microsoft Visual Studio\2022\"
$postfix = "\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"

if (Test-Path ($prefix + "Enterprise" + $postfix)) {
    Set-Alias tf ($prefix + "Enterprise" + $postfix)
} elseif (Test-Path ($prefix + "Professional" + $postfix)) {
    Set-Alias tf ($prefix + "Professional" + $postfix)
} elseif (Test-Path ($prefix + "Community" + $postfix)) {
    Set-Alias tf ($prefix + "Community" + $postfix)
}

Set-Alias nuget "C:\Tools\nuget.exe"
