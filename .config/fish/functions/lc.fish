function lc --description 'open lazygit for dotfiles'
    env GIT_DIR="$HOME/dotfiles" GIT_WORK_TREE="$HOME" lazygit
end
