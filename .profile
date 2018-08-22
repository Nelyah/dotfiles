#
# ~/.profile
#
#

[[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || export QT_QPA_PLATFORMTHEME="qt5ct"

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
    export SOFT_MANAGER=yay
fi

if [ -f /usr/bin/gnome-keyring-daemon ]; then 
    /usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh > /dev/null
    export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK
fi

# Those are the PC names and user names I use
# most of the time
LIST_PC=(lcqb0001 chloe-pc chloe-laptop desktop_lcqb)
LIST_USER=(chloe Chloe dequeker Dequeker nelyah Nelyah)
