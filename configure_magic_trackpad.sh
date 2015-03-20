#!/bin/bash

DEVICE='Apple Wireless Trackpad'

xinput set-prop "${DEVICE}" 'Device Accel Constant Deceleration' 1.5

# Increase acceleration and decrease minimum vertical movement speed
# <min> <max> <accel> <trackstick>
xinput set-prop "${DEVICE}" 'Synaptics Move Speed' 0.1, 3, 0.035374, 0.00

# Decrease the time between a "tap" event and it's application
xinput set-prop "${DEVICE}" 'Synaptics Tap Time' 600

# Invert scroll direction for "natural scrolling"
# <Vertical movement per scroll event> <Horizontal movement per scroll event>
xinput set-prop "${DEVICE}" 'Synaptics Scrolling Distance' -50, -50

# Turn off inertial scrolling
xinput set-prop "${DEVICE}" 'Synaptics Coasting Speed' 0, 0
