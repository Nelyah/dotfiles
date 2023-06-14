#! /bin/sh

if hash bat 2> /dev/null > /dev/null; then
    bat --color always "$1"
else
    cat "$@"
fi
