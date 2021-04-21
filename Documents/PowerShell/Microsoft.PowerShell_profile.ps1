# Set-PoshPrompt  ~/.poshthemes/jakobferdinand.omp.json

Invoke-Expression (&starship init powershell)

# Set-Alias --Name config --Value 'git.exe --git-dir=$HOME/dotfiles --work-tree=$HOME'

function config {
    git.exe --git-dir=$HOME/dotfiles --work-tree=$HOME $args
}