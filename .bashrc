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

# Check if the current session is a SSH session or not
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

LS_GROUPDIR='--group-directories-first'
if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=always --time-style=long-iso -G'
    eval `dircolors ~/.dircolors`
fi

# Aliases

function llth (){
    if [[ -f $1 ]] || [[ -d $1 ]]; then
        ls -lht $LS_OPTIONS $1 | head $2
    else
        ls -lht $LS_OPTIONS | head $1
    fi
}

export LESS_TERMCAP_md="${yellow}";

alias ll='ls -lh $LS_OPTIONS $LS_GROUPDIR'
alias lla='ls -lha $LS_OPTIONS $LS_GROUPDIR'
alias llt='ls -lht $LS_OPTIONS'
alias lld='ls -lhd $LS_OPTIONS'
alias llad='ls -lhad $LS_OPTIONS'
alias llda='ls -lhad $LS_OPTIONS'

alias rm='rm -i'
alias rebash='source ~/.bashrc'
alias irssi@freenode='irssi -c chat.freenode.net -p 6667 -n Nelyah'
alias irc='weechat-curses'
alias bc='bc -l'

alias speedtest='wget -O /dev/null http://speed.transip.nl/100mb.bin'
alias tree='tree -A'
alias treed='tree -d'
alias tree1='tree -d -L 1'
alias tree2='tree -d -L 2'

alias cpwd="pwd|tr -d '\n'|xclip" # copy pwd in clipboard

alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
regexip='inet ([0-9]{,3}\.[0-9]{,3}\.[0-9]{,3}\.[0-9]{,3})\/.* ([^ ]+)'
alias ipl='ip addr | \grep -E "$regexip"| \grep -v 127.0.0.1|sed -r "s/$regexip/\2 \1/"|column -t'

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

calc() {
  echo "$*" | bc -l;
}

meteo() {
	local LOCALE=`echo ${LANG:-en} | cut -c1-2`
	if [ $# -eq 0 ]; then
		local LOCATION=`curl -s ipinfo.io/loc`
	else
		local LOCATION=$1
	fi
	curl -s "$LOCALE.wttr.in/$LOCATION"
}
