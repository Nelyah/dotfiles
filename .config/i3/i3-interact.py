#!/usr/bin/env python

import i3ipc


def on(i3, e):
    with open('/home/chloe/test_log', 'w') as fw:
        fw.write(f'{e.container.window_class}\n')

    if e.container.window_class in ['Alacritty']:
        e.container.command('resize set 66 ppt')

i3 = i3ipc.Connection()
i3.on('window::focus', on)

try:
    i3.main()
finally:
    i3.main_quit()

