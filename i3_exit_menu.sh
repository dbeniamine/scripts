#!/bin/bash

# Copyright (C) 2015  Beniamine, David <David@Beniamine.net>
# Author: Beniamine, David <David@Beniamine.net>
# Author: Bleuse, Raphael <Raphael.Bleuse@gmail.com>
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


# A nice exit menu for i3 based on dmenu
usage()
{
    echo "$0 [-nodmenu]"
    echo "dmenu:    a boolean switch to use or not dmenu default: true"
}
# set -x

if [ -z "$1" ]
then
    # Use dmenu only if available and xserver is started
    xset -q  > /dev/null  2>&1 && which dmenu > /dev/null  2>&1
    if [  $? -eq 0 ]
    then
        dmenu=true
    else
        dmenu=false
    fi
else
    if [ "$1" == "true" ] || [ "$1" == "false" ]
    then
        dmenu=$1
    else
        usage
        exit 1
    fi
fi

# This settings can/ must be adapted to your configuration
CHOICES='LockScreen\nExit\nSuspend\nHibernate\nPoweroff\nReboot'
LOCKCMD="mate-screensaver-command  --lock"
EXITCMD="mate-session-save --logout-dialog"
PROMPT="Exit i3 ?"
PREFIX=$HOME/scripts

# Actions corresponding to the user choice
declare -A ARGUMENTS
declare -A PREACTIONS

if [ "$(pstree | head -n 1 | cut -d '-' -f 1)" == "systemd" ]
then
    # Using systemd
    CMD="systemctl"
    ARGUMENTS=([Suspend]="suspend" [Hibernate]="hibernate" \
        [Poweroff]="poweroff" [Reboot]="reboot")
else
    # Systemd is not the init program, we use dbus
    CMD="dbus-send --system --print-reply"
    # Dbus arguments
    ConsoleKit="--dest=org.freedesktop.ConsoleKit \
        /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager"
    UPower="--dest=org.freedesktop.UPower \
        /org/freedesktop/UPower org.freedesktop.UPower"
    ARGUMENTS=([Suspend]="$UPower.Suspend" [Hibernate]="$UPower.Hibernate" \
        [Poweroff]="$ConsoleKit.Stop" [Reboot]="$ConsoleKit.Restart")
fi
PREACTIONS=([Suspend]=$LOCKCMD [Hibernate]=$LOCKCMD)


# Ask the user
source $PREFIX/prompt_user.sh "$CHOICES" "$PROMPT" $dmenu

# Actually do stuff
case "$USER_CHOICE" in
    "Exit")
        $EXITCMD
        ;;
    "LockScreen")
        $LOCKCMD
        ;;
    "Suspend" | "Hibernate" | "Poweroff" | "Reboot")
        (sleep 1; $CMD ${ARGUMENTS[$USER_CHOICE]} ) & ${PREACTIONS[$USER_CHOICE]}
        ;;
    *)
        exit 1
        ;;
esac
