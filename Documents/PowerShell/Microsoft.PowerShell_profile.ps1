
# Ensure Starship is installed.
# https://starship.rs/
Invoke-Expression (&starship init powershell)

# Ensure Nvim is installed.
# https://github.com/neovim/neovim
Set-Alias -Name vim -Value nvim

function config {
    git.exe --git-dir=$HOME/dotfiles --work-tree=$HOME $args
}


$prefix = "C:\Program Files (x86)\Microsoft Visual Studio\2019\"
$postfix = "\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe"

if (Test-Path ($prefix + "Enterprise" + $postfix)) {
    Set-Alias tf ($prefix + "Enterprise" + $postfix)
} elseif (Test-Path ($prefix + "Professional" + $postfix)) {
    Set-Alias tf ($prefix + "Professional" + $postfix)
} elseif (Test-Path ($prefix + "Community" + $postfix)) {
    Set-Alias tf ($prefix + "Community" + $postfix)
}

Set-Alias nuget "C:\Tools\nuget.exe"