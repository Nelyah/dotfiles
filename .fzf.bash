# Setup fzf
# ---------
if [[ ! "$PATH" == */home/chloe/.fzf/bin* ]]; then
  export PATH="$PATH:/home/chloe/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/chloe/.fzf/shell/completion.bash" 2> /dev/null

if type fd > /dev/null 2>&1; then
    # Setting fd as the default source for fzf
    export FZF_DEFAULT_COMMAND='fd --type f'
    # To apply the command to CTRL-T as well
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_COMMAND="fd --type file --color=always"
    export FZF_DEFAULT_OPTS="--ansi"
fi

# Key bindings
# ------------
source "/home/chloe/.fzf/shell/key-bindings.bash"
