#!/bin/bash

#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2015 Beniamine, David <David@Beniamine.net>
# Author: Beniamine, David <David@Beniamine.net>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

# Ugly settings for mouse input, must be called each time a mouse is added
# (using udev rules for instance)

reverse_scrolling()
{
    list=$(xinput get-button-map $1)
    list=${list/ 4 5/ 5 4 }
    xinput set-button-map $1 $list
}

#Use Wheel emulation for all mouse with button 3
xinput --list | grep "id=" | cut -d "=" -f 2 | sed -e 's/^\([0-9]*\).*$/\1/'\
    | while read id
do
    xinput list-props $id | grep "Evdev Wheel Emulation"
    if [ $? -eq 0 ]
    then
        xinput --set-prop $id "Evdev Wheel Emulation" 1
        xinput --set-prop $id "Evdev Wheel Emulation Button" 3
        xinput --set-prop $id "Evdev Wheel Emulation Axes" 6 7 4 5
        reverse_scrolling $id
    fi
done

#Touchpad settings
id=$(xinput list | grep TouchPad | cut -d "=" -f 2 \
    | sed -e 's/^\([0-9]*\).*$/\1/')
# pad corners rt rb lt lb notinh fingers 1 2
# 0: disable, 1 left, 2 middle, 3 right
xinput --set-prop $id "Synaptics Tap Action" 0 0 0 0 1 2
# Allow scrolling with two finger vertically and horizontally
xinput --set-prop $id "Synaptics Two-Finger Scrolling" 1 1
xinput --set-prop $id "Synaptics Palm Detection" 1
xinput --set-prop $id "Synaptics Palm Dimensions" 10 0
reverse_scrolling $id
