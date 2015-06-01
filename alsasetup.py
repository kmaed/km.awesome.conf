#!/usr/bin/python

import os

if os.path.exists('/dev/snd/controlC1'):
    print('''pcm.!default {
type hw
card 1
}''')
