[[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || export QT_QPA_PLATFORMTHEME="qt5ct"


if [[ "$(uname)" != "Darwin" ]]; then
    setxkbmap -layout us -variant intl -option caps:escape
fi

export PATH="$HOME/bin:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin:$HEX_ROOT/bin:$HOME/.local/bin:$HOME/Library/Python/3.7/bin/:$PATH"

~/bin/export-x-info

if [ -f /usr/bin/gnome-keyring-daemon ]; then 
    /usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh > /dev/null
    export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
fi
