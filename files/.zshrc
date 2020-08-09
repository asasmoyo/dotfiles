# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
)

# needed to ignore completion errors
ZSH_DISABLE_COMPFIX=true source $ZSH/oh-my-zsh.sh

# disable globbing
# https://github.com/robbyrussell/oh-my-zsh/issues/433#issuecomment-434813442
unsetopt nomatch

alias vim=nvim
alias vi=nvim
export EDITOR='vim'

# load more configs
for f in $(ls ~/.dotfiles/*.sh); do
  source $f
done
