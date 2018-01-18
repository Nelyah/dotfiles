#! /bin/bash

exec xautolock -detectsleep
    -time 15 -locker "i3lock -c 000000 -n && sleep 1" \
    -notify 30 \
    -notifier "notify-send -u critical -t 10000 --  'LOCKING screend in 30 seconds'"
