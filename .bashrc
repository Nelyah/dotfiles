# Environnement variable
source ~/.profile

if [[ -z $OLDPATH ]];
then
    export OLDPATH=$PATH
else
    export PATH=$OLDPATH
fi

export ATTRACTDIR=$HOME/lib/attract/bin/ 
export ATTRACTTOOLS=$ATTRACTDIR/../tools
export PYTHONPATH=$PYTHONPATH:$HOME/mapping/scripts/lib
export PYMOLPATH=$PYMOLPATH:$HOME/mapping/scripts/lib
export HEX_ROOT=$HOME/lib/hex
export HEX_VERSION=8.0.0
export HEX_CACHE=$HOME/lib/hex_cache
export PATH="$HOME/bin:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$HEX_ROOT/bin:$PATH"

if type nvim &> /dev/null; then
    export EDITOR=nvim
    alias vim='nvim'
fi

if type trizen &> /dev/null; then
    export SOFT_MANAGER=trizen
fi


if [ -f /usr/bin/gnome-keyring-daemon ]; then 
    /usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh > /dev/null
    export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
fi

if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=auto'
    eval `dircolors ~/.dircolors`
fi

# Couleurs du préfix du terminal
NONE="\[\033[0;33m\]" 
NM="\[\033[0;38m\]" 
HI="\[\033[00;38;5;212m\]" 
HII="\[\033[0;36m\]" 
SI="\[\033[00;38;5;214m\]"
IN="\[\033[0m\]"

# Those are the PC names and user names I use 
# most of the time
LIST_PC=(lcqb0001 chloe-pc chloe-laptop desktop_lcqb)
LIST_USER=(chloe Chloe dequeker Dequeker nelyah Nelyah)


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export SESSION_TYPE=remote 
else
    export SESSION_TYPE=
fi

# Testing if this user is a common one
KNOWN_USER=1 
for e in ${LIST_USER[@]}; 
do 
    [[ $e == $(whoami) ]] && KNOWN_USER=0 && break
done

if [[ $KNOWN_USER == 0 ]]
then
    PS1_USER="Chloé"
else
    PS1_USER=$(whoami)
fi

# Testing if this hostname is a known one
KNOWN_HOST=1 
for e in ${LIST_PC[@]}; 
do 
    [[ $e == $(hostname --short) ]] && KNOWN_HOST=0 && break
done

if [[ $KNOWN_HOST == 0 ]] && [[ $SESSION_TYPE != remote ]]
then
    PS1_HOST=""
else
    PS1_HOST="@$(hostname --short)"
fi
export PS1="$SI\w$HI ${PS1_USER}${PS1_HOST} $ $IN"


# ls with color
alias ls="ls --color=always" 
alias grep="grep --color=always"
alias egrep="egrep --color=always"


# Aliases
alias ll='ls -lh'
alias lla='ls -lha'
alias llth='ls -lht|head'
alias llt='ls -lht'
alias rm='rm -i'
alias rebash='source ~/.bashrc'
alias irssi@freenode="irssi -c chat.freenode.net -p 6667 -n Nelyah"
alias irc='weechat-curses'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if type fasd > /dev/null 2>&1; then
    eval "$(fasd --init auto)"

    alias a='fasd -a'        # any
    alias s='fasd -si'       # show / search / select
    alias d='fasd -d'        # directory
    alias f='fasd -f'        # file
    alias sd='fasd -sid'     # interactive directory selection
    alias sf='fasd -sif'     # interactive file selection
    alias z='fasd_cd -d'     # cd, same functionality as j in autojump
    alias zz='fasd_cd -d -i' # cd with interactive selection
fi


if [ -f ~/.pm/pm.bash ]; then
    # PM functions
    source ~/.pm/pm.bash
    alias pma="pm add"
    alias pmg="pm go"
    alias pmrm="pm remove"
    alias pml="pm list"
fi
