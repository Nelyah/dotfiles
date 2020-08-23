#! /usr/bin/env python

import time
from i3ipc.aio import Connection

import asyncio
import subprocess
from sys import argv
import os
async def main(i3_focus_direction, keybind):
    i3 = await Connection(auto_reconnect=True).connect()

    tree = await i3.get_tree()

    focused = tree.find_focused()
    if focused.name in ['Alacritty']:
        with open('/home/chloe/logs.i3' ,'w') as fw:
            fw.write(f'{focused.name}\n')
            fw.write(f'{keybind}\n')
            fw.write(f"{os.system('xdotool getactivewindow getwindowname')}")
        # xdotool_cmd = f'xdotool  keyup alt h'
        # subprocess.Popen(xdotool_cmd.split())
        xdotool_cmd = f'xdotool keyup  --window $(xdotool getactivewindow) h alt && xdotool key --window $(xdotool getactivewindow) alt+h ; xdotool keyup  --window $(xdotool getactivewindow) h alt'
        subprocess.Popen(xdotool_cmd.split())
    else:
        await i3.cmd(f'focus {i3_focus_direction}')

i3_focus_direction=argv[1]
keybind=argv[2]

asyncio.get_event_loop().run_until_complete(main(i3_focus_direction, keybind))
