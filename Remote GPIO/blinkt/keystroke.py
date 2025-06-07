#!/usr/bin/env python

import sys
import os

import time
import random

try:
    import evdev
except ImportError:
    sys.exit('This script requires the evdev module. \nInstall with: pip install evdev')

from remote_blinkt import blinkt

blinkt.set_clear_on_exit(False)
blinkt.set_brightness(0.1)

def get_keyboards():
    devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
    keyboards = []
    # Filter out devices unlikely to be keyboard
    for device in devices:
        if not any(name in device.name for name in ['pwr_button', 'hdmi', 'generic']):
            keyboards.append(device)
    return keyboards

def on_key_press(key):
    #print(f"{key} pressed")
    blinkt.set_pixel(random.randint(0, 7), random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
    blinkt.show()

def on_key_release(key):
    #print(f"{key} released")
    blinkt.clear()
    blinkt.show()

def get_key_name(code):
    """Get human-readable key name from key code"""
    try:
        return evdev.ecodes.KEY[code].replace('KEY_', '')
    except KeyError:
        return f"UNKNOWN_{code}"

if 'DEVICE_PATH' not in os.environ:
    options = get_keyboards()
    message = 'Which device is your keyboard?\n'
    for index, item in enumerate(options):
        message += f'{index+1}) {item.name} ({item.path})\n'
    message += 'Your keyboard: '
    while True:
        user_device = input(message)
        if user_device in map(str, range(1, len(options)+1)):
            os.environ['DEVICE_PATH'] = options[int(user_device)-1].path
            break
        else:
            if str(user_device) == 'cat':
                print('｡＾･ｪ･＾｡ Yes but also no. Try again.\n')
            else:
                print(f'(•_•) No. Try again.\n')

try:
    keyboard = evdev.InputDevice(os.environ.get('DEVICE_PATH'))
    for event in keyboard.read_loop():
        if event.type == evdev.ecodes.EV_KEY:
            key_name = get_key_name(event.code)
            if event.value == 1:  # Key press
                on_key_press(key_name)
            elif event.value == 0:  # Key release
                on_key_release(key_name)
            elif event.value == 2:  # Key repeat
                pass
except KeyboardInterrupt:
    keyboard.close()
    time.sleep(0.5)
finally:
    blinkt._exit()
