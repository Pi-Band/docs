#!/usr/bin/env python

from time import localtime, sleep

from remote_blinkt import blinkt # so we can talk to our blinkt lights!

print('Hour = Red, Minute = Green, Second = Blue')

blinkt.set_clear_on_exit()

blinkt.set_brightness(0.2)

on_value = 64

while True:
    t = localtime()
    h, m, s = t.tm_hour, t.tm_min, t.tm_sec

    print('{h:2d}:{m:02d}:{s:02d}'.format(h=h, m=m, s=s))

    blinkt.clear()

    # Blink LED 0
    v = on_value * (s % 2)
    blinkt.set_pixel(0, v, v, v)

    for n in range(6):
        # Grab the n'th bit from hour, min and second
        bit_h = (h & (1 << n)) > 0
        bit_m = (m & (1 << n)) > 0
        bit_s = (s & (1 << n)) > 0

        r, g, b = [int(c * on_value) for c in (bit_h, bit_m, bit_s)]

        blinkt.set_pixel(7 - n, r, g, b)

    blinkt.show()

    sleep(1)
