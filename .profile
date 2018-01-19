#
# ~/.profile
#
#

[[ "$XDG_CURRENT_DESKTOP" == "KDE" ]] || export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=vim

[[ -f ~/.extend.profile ]] && . ~/.extend.profile

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    export SESSION_TYPE=remote 
fi
