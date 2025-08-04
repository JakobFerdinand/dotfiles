if status is-interactive
    # Commands to run in interactive sessions can go here
end

function config --description 'git bare repo for dotfiles'
    /usr/bin/git --git-dir="$HOME/dotfiles" --work-tree="$HOME" $argv
end
funcsave config

