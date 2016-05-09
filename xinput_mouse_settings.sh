#!/bin/bash

# Copyright (C) 2016  Beniamine, David <David@Beniamine.net>
# Author: Beniamine, David <David@Beniamine.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Ugly settings for mouse input, using libinput if avaialable or
# Synpatics/Evdev

ugly_reverse_scrolling()
{
    list=$(xinput get-button-map $1)
    list=${list/ 4 5/ 5 4 }
    xinput set-button-map $1 $list
}

xinput --list | grep "slave.*pointer" | grep -v XTEST | \
    sed -e 's/.*id=\([0-9]*\).*/\1/' | while read id
do
    device=$(xinput list-props $id | head -n 1 | sed -e "s/.*'\(.*\)'/\1/")
    echo "Seting input $device $id"
    if [ ! -z "$(xinput list-props $id | grep libinput)" ]
    then
        echo "Using libinput"
        xinput --set-prop $id "libinput Tapping Enabled" 1
        xinput --set-prop $id "libinput Middle Emulation Enabled" 1
        xinput --set-prop $id "libinput Natural Scrolling Enabled" 1
        xinput --set-prop $id "libinput Button Scrolling Button" 3
    else
        echo "Using synaptics / Evdev"
        xinput --set-prop $id "Evdev Wheel Emulation" 1
        xinput --set-prop $id "Evdev Wheel Emulation Button" 3
        xinput --set-prop $id "Evdev Wheel Emulation Axes" 6 7 4 5
        # pad corners rt rb lt lb notinh fingers 1 2
        # 0: disable, 1 left, 2 middle, 3 right
        xinput --set-prop $id "Synaptics Tap Action" 0 0 0 0 1 2
        # Allow scrolling with two finger vertically and horizontally
        xinput --set-prop $id "Synaptics Two-Finger Scrolling" 1 1
        xinput --set-prop $id "Synaptics Palm Detection" 1
        xinput --set-prop $id "Synaptics Palm Dimensions" 10 0
        ugly_reverse_scrolling $id
    fi
done
