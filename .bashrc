# Environnement variable
source ~/.profile
source ~/.aliases
source ~/.shell-functions

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
~/.miniconda3/etc/profile.d/conda.sh

# Couleurs du préfix du terminal
NONE="\[\033[0;33m\]"
NM="\[\033[0;38m\]"
HI="\[\033[00;38;5;212m\]"
HII="\[\033[0;36m\]"
SI="\[\033[00;38;5;214m\]"
IN="\[\033[0m\]"


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




if [ -f ~/.pm/pm.bash ]; then
    # PM functions
    source ~/.pm/pm.bash
    alias pma="pm add"
    alias pmg="pm go"
    alias pmrm="pm remove"
    alias pml="pm list"
fi

if type fzf &> /dev/null; then
    [ -f ~/.config/fzf/key-bindings.bash ] && source ~/.config/fzf/key-bindings.bash
    [ -f ~/.config/fzf/completion.bash ] && source ~/.config/fzf/completion.bash

    [ -f ~/.fzf.bash ] && source ~/.fzf.bash

    e() {
        local dir
        dir=$(fasd -Rdl |\
            sed "s:$HOME:~:" |\
            fzf --no-sort +m -q "$*" |\
            sed "s:~:$HOME:")\
        && pushd "$dir"
    }
fi
