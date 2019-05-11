# Setup fzf
# ---------
if [[ ! "$PATH" == */home/chloe/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/chloe/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/chloe/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/chloe/.fzf/shell/key-bindings.zsh"
