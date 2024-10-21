# This sets a bunch of variables like brew path, BREW_PREFIX
# and MANPATH specifically for brew
_brew_bin=/opt/homebrew/bin/brew
if [ -f "$_brew_bin" ]; then
    eval "$("$_brew_bin" shellenv)"
fi

# Required initialisation for pyenv. I noticed that it was often slowing things
# down when directly in the `.zshrc` so this now lives here.
if hash pyenv &> /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi
