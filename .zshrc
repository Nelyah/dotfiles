
# LS_colors for macos
if [[ $(uname) == "Darwin" ]]; then
    export CLICOLOR=1
else
    eval `dircolors ~/.dircolors`
fi

zmodload zsh/zle
export ZSH=$HOME/.oh-my-zsh
# Environnement variables
source ~/.profile
source ~/.aliases
source ~/.oh-my-zsh/oh-my-zsh.sh

autoload -U add-zsh-hook

#{{{ VCS

# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%F{green}●%f" # default 'S'
zstyle ':vcs_info:*' unstagedstr "%F{red}●%f" # default 'U'
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:git+set-message:*' hooks git-untracked
zstyle ':vcs_info:git*:*' formats '[%b%m%c%u] ' # default ' (%s)-[%b]%c%u-'
zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u] ' # default ' (%s)-[%b|%a]%c%u-'
zstyle ':vcs_info:hg*:*' formats '[%m%b] '
zstyle ':vcs_info:hg*:*' actionformats '[%b|%a%m] '
zstyle ':vcs_info:hg*:*' branchformat '%b'
zstyle ':vcs_info:hg*:*' get-bookmarks true
zstyle ':vcs_info:hg*:*' get-revision true
zstyle ':vcs_info:hg*:*' get-mq false
zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks
zstyle ':vcs_info:hg*+set-message:*' hooks hg-message

function +vi-hg-bookmarks() {
  emulate -L zsh
  if [[ -n "${hook_com[hg-active-bookmark]}" ]]; then
    hook_com[hg-bookmark-string]="${(Mj:,:)@}"
    ret=1
  fi
}

function +vi-hg-message() {
  emulate -L zsh

  # Suppress hg branch display if we can display a bookmark instead.
  if [[ -n "${hook_com[misc]}" ]]; then
    hook_com[branch]=''
  fi
  return 0
}

function +vi-git-untracked() {
  emulate -L zsh
  if [[ -n $(git ls-files --exclude-standard --others 2> /dev/null) ]]; then
    hook_com[unstaged]+="%F{blue}●%f"
  fi
}

add-zsh-hook precmd vcs_info

#}}}

#{{{ PS1


# PS1 colours
pink="%F{212}" 
yellow="%F{214}" 
orange="%F{202}" 
t="%F{0}" 

RPROMPT_BASE="\${vcs_info_msg_0_}"
setopt prompt_subst

# Anonymous function to avoid leaking NBSP variable.
function () {
  if [[ -n "$TMUX" ]]; then
    local LVL=$(($SHLVL - 1))
  else
    local LVL=$SHLVL
  fi
  if [[ $EUID -eq 0 ]]; then
    local SUFFIX=$(printf '#%.0s' {1..$LVL})
  else
    local SUFFIX=$(printf '\$%.0s' {1..$LVL})
  fi
  if [[ -n "$TMUX" ]]; then
    # Note use a non-breaking space at the end of the prompt because we can use it as
    # a find pattern to jump back in tmux.
    local NBSP=' '
    export PS1="%F{blue}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b${yellow}%~%f %F{red}%(?..!)%b%f${pink}%B${SUFFIX}%b%f${NBSP}"
    export ZLE_RPROMPT_INDENT=0
  else
    # Don't bother with ZLE_RPROMPT_INDENT here, because it ends up eating the
    # space after PS1.
    export PS1="%F{blue}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b${yellow}%~%f %F{red}%(?..!)%b%f${pink}%B${SUFFIX}%b%f "
  fi
}

export RPROMPT=$RPROMPT_BASE
export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "
#}}}

# {{{Record command time

typeset -F SECONDS
function record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}


add-zsh-hook preexec record-start-time

function report-start-time() {
  emulate -L zsh
  if [ $ZSH_START_TIME ]; then
    local DELTA=$(($SECONDS - $ZSH_START_TIME))
    local DAYS=$((~~($DELTA / 86400)))
    local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
    local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
    local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
    
    if [ $((~~SECS)) -lt 3 ]; then
        export RPROMPT="$RPROMPT_BASE"
        unset ZSH_START_TIME
        return
    fi

    local ELAPSED=''
    test "$DAYS" != '0' && ELAPSED="${DAYS}d"
    test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
    test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"
    if [ "$ELAPSED" = '' ]; then
      SECS="$(print -f "%.2f" $SECS)s"
    elif [ "$DAYS" != '0' ]; then
      SECS=''
    else
      SECS="$((~~$SECS))s"
    fi
    ELAPSED="${ELAPSED}${SECS}"
    local ITALIC_ON=$'\e[3m'
    local ITALIC_OFF=$'\e[23m'
    RPROMPT="%F{cyan}%{$ITALIC_ON%}${ELAPSED}%{$ITALIC_OFF%}%f $RPROMPT_BASE"
    unset ZSH_START_TIME
  else
    RPROMPT="$RPROMPT_BASE"
  fi
}

add-zsh-hook precmd report-start-time

# }}}

#{{{ Virtual environment
function virtual_env_info() {
    if [ $VIRTUAL_ENV ]; then
        export RPROMPT="$RPROMPT%F{1}$(basename $VIRTUAL_ENV)%f"
    else
        export RPROMPT="$RPROMPT"
    fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
add-zsh-hook precmd virtual_env_info
export RPROMPT="$RPROMPT $(virtual_env_info)"

# }}}

#{{{ fzf

[ -f ~/.config/fzf/key-bindings.zsh ] && source ~/.config/fzf/key-bindings.zsh
[ -f ~/.config/fzf/completion.zsh ] && source ~/.config/fzf/completion.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


function fzf-fasd-goto-dir() {
    local dir
    local query
    [ -n "$@" ] && query="--query='$@'" || query=""
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
    dir=$(fasd -Rdl |\
        sed "s:$HOME:~:" |\
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index $query --reverse --no-sort +m" $(__fzfcmd) |\
        sed "s:~:$HOME:")
    pushd "$dir"
    ret=$?
    # zle reset-prompt
    return $ret
}

export FZF_DEFAULT_OPTS="--reverse"


export FZF_CTRL_T_COMMAND="rg --files --hidden 2> /dev/null"
export FZF_ALT_C_COMMAND="fd --hidden -t d -t l 2> /dev/null"
export FZF_DEFAULT_COMMAND="rg --files --hidden"

zle     -N   fzf-file-widget
bindkey '^F' fzf-file-widget
zle     -N    fzf-cd-widget
bindkey '^T' fzf-cd-widget
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget
#}}}

#{{{ Functions

function calc() {
  echo "$*" | bc -l;
}

function meteo() {
	local LOCALE=`echo ${LANG:-en} | cut -c1-2`
	if [ $# -eq 0 ]; then
		local LOCATION=`curl -s ipinfo.io/loc`
	else
		local LOCATION=$1
	fi
	curl -s "$LOCALE.wttr.in/$LOCATION"
}

# From https://github.com/SidOfc/dotfiles/blob/d07fa3862ed065c2a5a7f1160ae98416bfe2e1ee/zsh/kp
### PROCESS
# mnemonic: [K]ill [P]rocess
# show output of "ps -ef", use [tab] to select one or multiple entries
# press [enter] to kill selected processes and go back to the process list.
# or press [escape] to go back to the process list. Press [escape] twice to exit completely.

function kp (){
    local pid=$(ps -ef | sed 1d | eval "fzf ${FZF_DEFAULT_OPTS} -m --header='[kill:process]'" | awk '{print $2}')

    if [ "x$pid" != "x" ]
    then
      echo $pid | xargs kill -${1:-9}
      kp
    fi
}
alias pk="kp"

# Clear zombie processes
function clear-zombie() {
    ps -eal | awk '{ if ($2 == "Z") {print $4}}' | kill -9
}


# determine local IP address
function getip() {
    if (( ${+commands[ip]} )); then
        ip addr | grep "inet " | grep -v '127.0.0.1' | awk '{print $2}'
    else
        ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'
    fi
}

function apt-list-ppa () {
    {
        echo "Type URIs Suites Components";
        echo "";
        grep -r --include '*.list' '^deb ' /etc/apt/ | \
            sed -re 's/^\/etc\/apt\/sources\.list((\.d\/)?|(:)?)//' \
            -e 's/(.*\.list):/\[\1\] /' \
            -e 's/deb http:\/\/ppa.launchpad.net\/(.*?)\/ubuntu .*/ppa:\1/'
    } | \
        column -t
}

function sc () {
    if [ "${1}" = "--user" ]; then
        local is_user="--user"
        shift
    fi

    case "${1}" in
        st|status)
            shift
            systemctl ${is_user} status "${@}"
            ;;
        r|rst|restart)
            shift
            systemctl ${is_user} restart "${@}"
            ;;
        s|start)
            shift
            systemctl ${is_user} start "${@}"
            ;;
        sp|stop)
            shift
            systemctl ${is_user} stop "${@}"
            ;;
        ls|list-unit-files)
            shift
            echo $@
            systemctl ${is_user} list-unit-files "${@}"
            ;;
    esac
}

function scu () {
    sc --user "${@}"
}

#}}}
