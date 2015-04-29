#!/usr/bin/env bash

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

# Helpers
function do_hibernate
{
    xscreensaver-command -lock & \
	dbus-send --system --print-reply --dest=org.freedesktop.UPower  \
		  /org/freedesktop/UPower org.freedesktop.UPower.Hibernate
	exit $?
}

function do_suspend
{
    xscreensaver-command -lock & \
        dbus-send --system --print-reply --dest=org.freedesktop.UPower  \
		  /org/freedesktop/UPower org.freedesktop.UPower.Suspend
	exit $?
}

function do_restart
{
	dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit  \
		  /org/freedesktop/ConsoleKit/Manager                       \
		  org.freedesktop.ConsoleKit.Manager.Restart
	exit $?
}

function do_poweroff
{
	dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit  \
		  /org/freedesktop/ConsoleKit/Manager                       \
		  org.freedesktop.ConsoleKit.Manager.Stop
	exit $?
}

function do_choose
{
	echo "Select action to execute:"
	PS3="Pick an option: "
	select action in suspend hibernate poweroff restart abort;
	do
		case "$action" in
			"suspend" | "hibernate" | "poweroff" | "restart")   do_$action ;;
			"abort")     exit 0 ;;
			*) echo "dbus-pow.sh: internal error" >&2 ; exit 1 ;;
		esac
	done
}

# Parse arguments
PARSED_OPTIONS=$(getopt -o hHRSP \
                       --long help,hibernate,restart,suspend,poweroff \
                       -n 'dbus-pow.sh' -- "$@")

[ $? != 0 ] && exit 1

eval set -- "$PARSED_OPTIONS"

# Choose appropriate operation: we only expect zero or one option
case $1 in
	-H|--hibernate) do_hibernate ;;
	-R|--restart)   do_restart ;;
	-S|--suspend)   do_suspend ;;
	-P|--poweroff)  do_poweroff ;;
	--) do_choose ;;
	*) echo "dbus-pow.sh: internal error" >&2 ; exit 1 ;;
esac
