#!/bin/bash

# Copyright (C) 2015  Beniamine, David <David@Beniamine.net>
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

#
# Settings modify thoses values to fit your needs
#

#
# By default no interaction and don't use dmenu
# Relies on script prompt_user.sh for interaction
#
interactive=false
dmenu=false
# Path to script (of user choice)
PREFIX=$(dirname $0)

# Default wallpaper (set with feh command)
background=$HOME/Wallpapers/default.jpg
# Default wallpeper settings
defbgopt="bg-scale"
defxinmod="yes"

# Position of secondaries screen relatively to the main
# Default position when docked
dockPos="below"
# Default position when not docked
noDockPos="right-of"

do_help(){
    echo "Usage $0 [-dhim]"
    echo "-i        Interactive mode"
    echo "-d        Interactive mode via dmenu"
    echo "-h        Show this help and exit"
    echo "-p pos    Set the default relative position to pos"
    echo "-d img    set the background image, default $background"
}

# Default screen position
set_default_pos()
{
    if [ ! -z $defaultPos]
    then
        return # DefaultPos already manually set
    fi
    # Are we docked ?
    file=$(find /sys/devices/platform/ -name dock*)
    if [ ! -z "$file" ]
    then
        dock=$(cat $file)
    else
        dock=0
    fi
    if [ $dock -eq 0 ]
    then
        defaultPos=$noDockPos
    else
        defaultPos=$dockPos
    fi
    # Prepare choices
    AvailPos="left-of\nright-of\nabove\nbelow\ncopy\noff"
    Positions="$defaultPos\n$(echo -e $AvailPos | grep -v $defaultPos)"
}

# Set the main screen (ask user if required)
set_main_screen()
{
    # Auto main screen
    MaxRes=0
    xrandr | grep " connected" -A 1 | sed -e '/--/d' > $0-$$.tmp
    while read line
    do
        nline=$(echo $line | grep " connected")
        if [ -z "$nline" ]
        then
            #resolution
            res=$(echo $line | cut -d 'x' -f 1)
            if [ $res -gt $MaxRes ]
            then
                MaxRes=$res
                MAIN_SCREEN="$scr"
            fi
        else
            #screen
            scr=$(echo $line | cut -d ' ' -f 1)
        fi
    done < $0-$$.tmp
    rm $0-$$.tmp
    screens=$(xrandr | grep " connected" | cut -f 1 -d ' ')
    if $interactive
    then
        #User choice
        source $PREFIX/prompt_user.sh "$MAIN_SCREEN \n $(echo "$screens" \
            | sed -e 's/ /\n/g' | grep -v $MAIN_SCREEN)" \
            "Main screen (auto : $MAIN_SCREEN) ?" $dmenu
        MAIN_SCREEN=$USER_CHOICE
    fi
    screens=$(echo $screens | sed -e 's/ /\n/g' | grep -v $MAIN_SCREEN)
}

# Ask or choose the position of s compared to prev_s and set prev_s
# s and prev_s must be set
set_next_pos()
{
    if $interactive
    then
        # User choice
        source $PREFIX/prompt_user.sh "$Positions"  \
            "$s compared to $prev_s (auto: $defaultPos)" $dmenu
    else
        USER_CHOICE=$defaultPos
    fi
    case "$USER_CHOICE" in
        "copy")
            cmd="$cmd --output $s --auto --same-as $prev_s --rotate normal"
            ;;
        "off")
            cmd="$cmd --output $s --$USER_CHOICE"
            ;;
        *)
            cmd="$cmd --output $s --auto --$USER_CHOICE $prev_s \
                --rotate normal"
            ;;
    esac
    prev_s="$s"
}

# Prepare xrandr (screen position) command
set_xrandr_cmd()
{
    # Prepare all settings
    set_main_screen
    set_default_pos
    # Init the command
    cmd="xrandr --output $MAIN_SCREEN --auto --rotate normal --primary"
    # Place all screens
    prev_s=$MAIN_SCREEN
    for s in $(echo -e $screens)
    do
        set_next_pos
    done
    # Remove output from disconnected screens
    disconnected_screens=$(xrandr | grep disconnected | cut -d " " -f 1)
    for s in $(echo -e $disconnected_screens )
    do
        cmd="$cmd --output $s --off"
    done
}

# Prepare background command
set_feh_cmd()
{
    # set the background options
    if $interactive
    then
        # Background type
        allbgopts="bg-scale\nbg-fill\nbg-max\nbg-center"
        bgopts="$defbgopt\n$(echo -e $allbgopts | grep -v $defbgopt)"
        source $PREFIX/prompt_user.sh "$bgopts" \
            "Background type (auto : $defbgopt) ?" $dmenu
        bgopt=$USER_CHOICE
        # Xinemara mode
        allxinmods="yes\nno"
        xinmods="$defxinmod\n$(echo -e $allxinmods | grep -v $defxinmod)"
        source $PREFIX/prompt_user.sh "$xinmods" \
            "Background xinemara (auto: $defxinmod)" $dmenu
        xinmod=$USER_CHOICE
    else
        # Auto choice
        bgopt=$defbgopt
        xinmod=$defxinmod
    fi
    # Translate xinerama to feh option
    if [ "$xinmod" = "no" ]
    then
        xinerama=--no-xinerama
    fi
    fehcmd="feh --$bgopt $xinerama $background"
}

# Options
while getopts ":Adhp:b:i" opt; do
    case $opt in
        i)
            interactive=true
            ;;
        d)
            interactive=true
            dmenu=true
            ;;
        h)
            do_help
            exit 0;
            ;;
        p)
            defaultPos="$OPTARG"
            ;;
        b)
            background=$OPTARG
            ;;
        *)
            echo "Invalid option : -$opt" >&2
            do_help
            exit 1
            ;;
    esac
done

# Prepare commands
set_xrandr_cmd
set_feh_cmd
# Apply commands
echo $cmd
$cmd
# Wait for settings to be applied
sleep 2
echo $fehcmd
$fehcmd
