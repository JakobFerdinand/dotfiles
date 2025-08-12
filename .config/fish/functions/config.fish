function config --description 'git bare repo for dotfiles'
    /usr/bin/git --git-dir="$HOME/dotfiles" --work-tree="$HOME" $argv
end
