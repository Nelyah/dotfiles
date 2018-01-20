# Environnement variable
source ~/.profile

if [[ -z $OLDPATH ]];
then
    export OLDPATH=$PATH
else
    export PATH=$OLDPATH
fi

export JET2_HOME=$HOME/JET2/
export ATTRACTDIR=$HOME/lib/attract/bin/ 
export ATTRACTTOOLS=$ATTRACTDIR/../tools
export PYTHONPATH=$PYTHONPATH:/usr/share/pdb2pqr:$HOME/mapping/scripts/lib
export PYMOLPATH=$PYMOLPATH:$HOME/mapping/scripts/lib
export HEX_ROOT=/home/chloe/lib/hex
export HEX_VERSION=8.0.0
export HEX_CACHE=$HOME/lib/hex_cache
export PATH="$HOME/bin:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$HEX_ROOT/bin:$PATH"

export EDITOR=nvim
export SOFT_MANAGER=trizen


if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
    source /usr/share/fzf/completion.bash
fi

/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh > /dev/null
export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK

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
LIST_PC=(lcqb0001 chloe-pc chloe-laptop chloe-desktop_lcqb)
LIST_USER=(chloe Chloe dequeker Dequeker nelyah Nelyah)

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
alias vim='nvim'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
