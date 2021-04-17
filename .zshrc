#
#      ██ ███████ ██     ██ 
#      ██ ██      ██     ██  Jakob Ferdinand Wegenschimmel
#      ██ █████   ██  █  ██  https://github.com/JakobFerdinand
# ██   ██ ██      ██ ███ ██ 
#  █████  ██       ███ ███  
#
# A customized zsh configuration (http://zsh.sourceforge.net/)
#

alias vim="nvim"
export TERM="xterm-256color"
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export EDITOR="nvim"

# ------------------------
# git bare repository config for dotfiles
# ------------------------
alias config='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'


# ------------------------
# Plugins
# ------------------------
# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
         colorize)

ZSH_COLORIZE_TOOL="chroma"
ZSH_COLORIZE_STYLE="dracula"
alias cat="ccat"
export PATH=~/go/bin:$PATH

# ------------------------
# oh-my-zsh
# ------------------------

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="af-magic"

source $ZSH/oh-my-zsh.sh


# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
