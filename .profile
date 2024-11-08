function __linux_profile() {

    [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || export QT_QPA_PLATFORMTHEME="qt5ct"

    if hash setxkbmap &>/dev/null; then
        setxkbmap -layout us -variant intl -option caps:escape
    fi

    ~/bin/export-x-info

    if [ -f /usr/bin/gnome-keyring-daemon ]; then
        /usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh &>/dev/null
        export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
    fi
}

function __macos_profile() {
    # This sets a bunch of variables like brew path, BREW_PREFIX
    # and MANPATH specifically for brew
    local _brew_bin=/opt/homebrew/bin/brew
    if [ -f "$_brew_bin" ]; then
        eval "$("$_brew_bin" shellenv)"
    fi
}

if [[ "$(uname)" != "Darwin" ]]; then
    __linux_profile
else
    __macos_profile
fi

export LANG=en_GB.UTF-8

# Required initialisation for pyenv. I noticed that it was often slowing things
# down when directly in the `.zshrc` so this now lives here.
if hash pyenv &>/dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi
