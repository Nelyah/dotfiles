# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="random"
ZSH_THEME="steeef"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git,
  colorize,
  cp,
  dotenv,
  gpg-agent,
  pip
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
export PYTHONPATH=$PYTHONPATH:$HOME/mapping/scripts/lib:~/.local/venvs
export PYMOLPATH=$PYMOLPATH:$HOME/mapping/scripts/lib
export HCMD2PATH=$HOME/mapping/HCMD2
export HEX_ROOT=$HOME/lib/hex
export HEX_VERSION=8.0.0
export HEX_CACHE=$HOME/lib/hex_cache
export PATH="$HOME/bin:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$HEX_ROOT/bin:$HOME/.local/bin:$PATH"

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

# PS1 colours
pink="%F{212}" 
yellow="%F{214}" 
orange="%F{202}" 

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
    PS1_USER="%n"
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
    PS1_HOST="@${orange}$(hostname --short)${pink}"
fi

get_PS1() {
    PS1="$yellow%~ ${pink}${PS1_USER}${PS1_HOST} $ %{${reset_color}%}"
}

setopt prompt_subst
# export PS1="$yellow%~ ${pink}${PS1_USER}${PS1_HOST} $ %{${orange}%}"
autoload -U add-zsh-hook
autoload -Uz vcs_info

export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('%F{blue}`basename $VIRTUAL_ENV`%f') '
}
PR_GIT_UPDATE=1
# enable VCS systems you use
zstyle ':vcs_info:*' enable git svn
PR_RST="%f"
FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
FMT_ACTION="(%{$limegreen%}%a${PR_RST})"
FMT_UNSTAGED="%{$orange%}●"
FMT_STAGED="%{$limegreen%}●"

zstyle ':vcs_info:*:prompt:*' unstagedstr   "${FMT_UNSTAGED}"
zstyle ':vcs_info:*:prompt:*' stagedstr     "${FMT_STAGED}"
zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
zstyle ':vcs_info:*:prompt:*' nvcsformats   ""


function steeef_preexec {
    case "$(history $HISTCMD)" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_GIT_UPDATE=1
}
add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
# check for untracked files or updated submodules, since vcs_info doesn't
        if git ls-files --other --exclude-standard 2> /dev/null | grep -q "."; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="(%{$turquoise%}%b%u%c%{$hotpink%}●${PR_RST})"
        else
            FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
        fi
        zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH} "

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
add-zsh-hook precmd steeef_precmd

PROMPT='$yellow%~ ${pink}${PS1_USER}${PS1_HOST} %{${reset_color}%}$vcs_info_msg_0_$(virtualenv_info)${pink}$ %{${reset_color}%}'

setopt prompt_subst

autoload -U add-zsh-hook
autoload -Uz vcs_info

# ls with color
alias grep="grep --color=always"
alias egrep="egrep --color=always"

if [ "$TERM" != "dumb" ]; then
    export LS_OPTIONS='--color=always --time-style=long-iso -G'
    export LS_DIRFIRST='--group-directories-first'
    eval `dircolors ~/.dircolors`
fi

# Aliases

function llth (){
    if [[ -f $1 ]] || [[ -d $1 ]]; then
        eval "\ls -lht $LS_OPTIONS $1 | head $2"
    else
        eval "\ls -lht $LS_OPTIONS | head $1"
    fi
}

# export LESS_TERMCAP_md="${yellow}";
alias ls="ls -h $LS_OPTIONS $LS_DIRFIRST"
alias ll="ls -lh $LS_OPTIONS $LS_DIRFIRST"
alias lla="ls -lha $LS_OPTIONS $LS_DIRFIRST"
alias llt="ls -lht $LS_OPTIONS"
alias lld="ls -lhd $LS_OPTIONS"
alias llad="ls -lhad $LS_OPTIONS"
alias llda="ls -lhad $LS_OPTIONS"

alias rm="rm -i"
alias rebash="source ~/.bashrc"
alias irssi@freenode="irssi -c chat.freenode.net -p 6667 -n Nelyah"
alias irc="weechat-curses"
alias bc="bc -l"

alias speedtest="wget -O /dev/null http://speed.transip.nl/100mb.bin"
alias tree="tree -A"
alias treed="tree -d"
alias tree1="tree -d -L 1"
alias tree2="tree -d -L 2"

alias cpwd="pwd|tr -d "\n"|xclip" # copy pwd in clipboard

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
regexip="inet ([0-9]{,3}\.[0-9]{,3}\.[0-9]{,3}\.[0-9]{,3})\/.* ([^ ]+)"
alias ipl="ip addr | \grep -E \"$regexip\"| \grep -v 127.0.0.1|sed -r \"s/$regexip/\2 \1/\"|column -t"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

[ -f ~/.config/fzf/key-bindings.zsh ] && source ~/.config/fzf/key-bindings.zsh
[ -f ~/.config/fzf/completion.zsh ] && source ~/.config/fzf/completion.zsh

if type fasd > /dev/null 2>&1; then
    eval "$(fasd --init auto)"

    alias a='fasd -a'        # any
    alias s='fasd -si'       # show / search / select
    alias d='fasd_cd -d'     # directory
    alias f='fasd -f'        # file
    alias sd='fasd -sid'     # interactive directory selection
    alias sf='fasd -sif'     # interactive file selection
fi

e() {
    local dir
    dir=$(fasd -Rdl |\
        sed "s:$HOME:~:" |\
        fzf --no-sort +m -q "$*" |\
        sed "s:~:$HOME:")\
    && pushd "$dir"
}

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
