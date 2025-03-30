# {{{ Edit mode
set -o emacs
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line
#}}}

export XDG_CONFIG_HOME="${HOME}/.config"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000
export SAVEHIST=100000

setopt appendhistory hist_ignore_dups inc_append_history extended_history hist_ignore_all_dups hist_ignore_space share_history

# Server aliases
if [ -f ~/.homeserver ]; then
    source ~/.homeserver
else
    # Work commands
    [ -f "${HOME}/.work" ] && source "${HOME}/.work"
fi

# Environnement variables
source ~/.env
source ~/.profile
source ~/.aliases

bindkey "\e[3~" delete-char

zmodload zsh/zle
autoload -U add-zsh-hook


autoload -Uz compinit
compinit


#{{{ Bindings
_git_tl () {
    echo ""
    git tl
    zle reset-prompt
}
zle -N widget-git-tl _git_tl
bindkey '\C-o' widget-git-tl

_git_status () {
    echo ""
    git status
    zle reset-prompt
}
zle -N widget-git-status _git_status
bindkey '\C-k' widget-git-status
#}}}

#{{{ Zplug
export ZPLUG_HOME="${XDG_CONFIG_HOME}/zplug"

[ -d "$ZPLUG_HOME" ] && REPLY=yes || read -q "REPLY?Clone Zplug to '$ZPLUG_HOME'? [yN] "

if [[ $REPLY =~ ^([Yy]|yes)$ ]]; then

    [ ! -d "$ZPLUG_HOME" ] && mkdir -p "$ZPLUG_HOME"
    [ ! -f "$ZPLUG_HOME/init.zsh" ] && git clone https://github.com/zplug/zplug "$ZPLUG_HOME"

    source "${ZPLUG_HOME}/init.zsh"

    zplug 'zplug/zplug', hook-build:'zplug --self-manage'
    zplug "mafredri/zsh-async", from:"github", use:"async.zsh"
    zplug "lib/clipboard", from:"oh-my-zsh"
    zplug "lib/compfix", from:"oh-my-zsh"
    zplug "lib/completion", from:"oh-my-zsh"
    zplug "lib/git", from:"oh-my-zsh"
    zplug "Nelyah/bee", use:'completion'


    # Install plugins if there are plugins that have not been installed
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    fi

    zplug load
    ZPLUG_LOADED=yes
fi
#}}}

#{{{ LS_colors
if [[ $(uname) == "Darwin" ]]; then
    eval `gdircolors ~/.dircolors`
else
    eval `dircolors ~/.dircolors`
fi
#}}}

#{{{ VCS

# PS1 colours
pink="%F{212}"
yellow="%F{214}"
orange="%F{202}"
light_red="%F{9}"
light_blue="%F{75}"
t="%F{0}"

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
    hook_com[unstaged]+="${light_blue}●%f"
  fi
}

_vbe_vcs_info() {
    cd -q $1
    vcs_info
    print ${vcs_info_msg_0_}
}

if [[ -n "$ZPLUG_LOADED" ]]; then
    async_init
    async_start_worker vcs_info
    async_register_callback vcs_info _vbe_vcs_info_done

    _vbe_vcs_info_done() {
        local stdout=$3
        vcs_info_msg_0_=$stdout
        zle reset-prompt
    }

    _vbe_async_worker () {
        # Restart the worker if it died for some reason
        async_job vcs_info _vbe_vcs_info $PWD || {
            async_init
            async_start_worker vcs_info
            async_register_callback vcs_info _vbe_vcs_info_done
        }
    }

    add-zsh-hook precmd _vbe_async_worker
fi

#}}}

#{{{ PS1


RPROMPT_BASE="\${vcs_info_msg_0_}"
setopt prompt_subst

# If in a git repo, remove path that's outside of it
# and highlights the basename of the git repo
# Else behaves like a normal path in prompt
function custom_path ()
{
    typeset dir=${1-$PWD}

    [[ -d $dir ]] || return 0

    git_repo_path=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ -n "$git_repo_path" ]; then

        type readlink &> /dev/null && dir=$(readlink -f "$dir")
        if [[ "$dir" == "$git_repo_path"* ]]; then
            dir=${light_red}$(basename "$git_repo_path")${yellow}${dir#${git_repo_path}}
        fi
    fi

    dir=${dir/#$HOME/\~}
    echo $dir
}

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
    export PS1="${light_blue}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b${yellow}"'$(custom_path)'" %F{red}%(?..!)%b%f${pink}%B${SUFFIX}%b%f${NBSP}"
    export ZLE_RPROMPT_INDENT=0
  else
    # Don't bother with ZLE_RPROMPT_INDENT here, because it ends up eating the
    # space after PS1.
    export PS1="${light_blue}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b${yellow}"'$(custom_path)'" %F{red}%(?..!)%b%f${pink}%B${SUFFIX}%b%f "
  fi
}

export RPROMPT=$RPROMPT_BASE
export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "
#}}}

# {{{ Record command time

typeset -F SECONDS
function _record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}


add-zsh-hook preexec _record-start-time

function _report-start-time() {
  emulate -L zsh
  if [ $ZSH_START_TIME ]; then
    local DELTA=$(($SECONDS - $ZSH_START_TIME))
    local DAYS=$((~~($DELTA / 86400)))
    local HOURS=$((~~( ($DELTA - $DAYS * 86400) / 3600)))
    local MINUTES=$((~~( ($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
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

add-zsh-hook precmd _report-start-time

# }}}

#{{{ Virtual environment
function _virtual_env_info() {
    if [ $VIRTUAL_ENV ]; then
        export RPROMPT="$RPROMPT%F{1}$(basename $VIRTUAL_ENV)%f"
    else
        export RPROMPT="$RPROMPT"
    fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
add-zsh-hook precmd _virtual_env_info
export RPROMPT="$RPROMPT $(_virtual_env_info)"
# }}}

#{{{ fzf

[ -f ~/.config/fzf/key-bindings.zsh ] && source ~/.config/fzf/key-bindings.zsh
[ -f ~/.config/fzf/completion.zsh ] && source ~/.config/fzf/completion.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if hash fzf &> /dev/null; then
    source <(fzf --zsh)
fi


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

# Return relative path from canonical absolute dir path $1 to canonical
# absolute dir path $2 ($1 and/or $2 may end with one or no "/").
# Does only need POSIX shell builtins (no external command)
_relPath () {
    local common path up
    common=${1%/} path=${2%/}/
    while test "${path#"$common"/}" = "$path"; do
        common=${common%/*} up=../$up
    done
    path=$up${path#"$common"/}; path=${path%/}; printf %s "${path:-.}"
}

# Return relative path from dir $1 to dir $2 (Does not impose any
# restrictions on $1 and $2 but requires GNU Core Utility "readlink"
# HINT: busybox's "readlink" does not support option '-m', only '-f'
#       which requires that all but the last path component must exist)
relpath () { _relPath "$(readlink -m "$1")" "$(readlink -m "$2")"; }

# Taken from OMZ function library
function op() {
  local open_cmd

  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   [[ "$(uname -r)" != *icrosoft* ]] && open_cmd='nohup xdg-open' || {
                open_cmd='cmd.exe /c start ""'
                [[ -e "$1" ]] && { 1="$(wslpath -w "${1:a}")" || return 1 }
              } ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac

  ${=open_cmd} "$@" &>/dev/null
}
#}}}
