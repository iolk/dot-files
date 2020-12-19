# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="gallois"

# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13

# DISABLE_MAGIC_FUNCTIONS=true
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

# DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"

plugins=(git gitignore docker chucknorris extract zsh-interactive-cd zsh_reload)

zstyle ':completion:*:*:docker:*' option-stacking yes

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

# export PATH="$PATH:ADD_HERE_YOUR_PATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

alias opt_gpp="g++ -std=c++17 -Wall -pedantic -O3 main.cpp -o main"

# SSH INIT
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

export WECHALLUSER="iolk"
export WECHALLTOKEN="70FE3-9AAA2-C4E62-66863-9709B-6456F"

# system aliases
alias pc="sudo pacman"
alias sc="sudo systemctl"
alias iwc="iwctl station wlan0"

# kubectl aliases
alias k="sudo kubectl"
alias kgx="sudo kubectl config get-contexts"

# docker aliases
alias d="sudo docker"
alias dc="sudo docker-compose"
alias dockerd="~/.scripts/dockermgr"