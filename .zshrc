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

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Flutter path
export PATH="$PATH:/home/iolk/.local/share/flutter/bin:/home/iolk/Android/Sdk/platform-tools:/home/iolk/Android/Sdk/emulator:/home/iolk/Android/Sdk/build-tools:/home/iolk/.local/bin"
#export PATH="$PATH:/snap/bin/:/var/lib/snapd/desktop/applications"
#export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/snapd/desktop"
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

alias kuumo_on="sudo systemctl start php7.3-fpm.service; sudo systemctl start fail2ban.service; sudo systemctl start postgresql.service; sudo systemctl start nginx.service; sudo systemctl start freeswitch.service"
alias kuumo_off="sudo systemctl stop php7.3-fpm.service; sudo systemctl stop fail2ban.service; sudo systemctl stop nginx.service; sudo systemctl stop freeswitch.service; sudo systemctl stop postgresql.service;"

alias dock="sudo dockerd"
alias laradock="sudo docker-compose up mysql nginx phpmyadmin workspace"
alias laradock_exec="sudo docker exec -it laradock_workspace_1 bash"
alias kalidocker="sudo docker run -ti --rm --mount src=kali-root,dst=/root --mount src=kali-postgres,dst=/var/lib/postgresql my-kali"
alias opt_gpp="g++ -std=c++17 -Wall -pedantic -O3 main.cpp -o main"

alias natan_hotspot='sudo nmcli d wifi connect "iPhone di Natan" bssid 56:DA:3F:51:11:16 password "nemesis3"'

# SSH INIT
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

export WECHALLUSER="iolk"
export WECHALLTOKEN="70FE3-9AAA2-C4E62-66863-9709B-6456F"
