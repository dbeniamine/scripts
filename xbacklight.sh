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

# Change backlight values

#Define the default val
if [ $(hostname) = "pipin" ]
then
    val=20
    Initval=60
else
    val=5
    Initval=30
fi
if [ ! -z "$(ps aux | grep i3blocks)" ]
then
    sigcmd="pkill -RTMIN+11 i3blocks"
fi

act=""
defVal=false
function usage
{
    echo "Usage $0 [options]"
    echo "i         Increase the brightness"
    echo "d         Decreasea the brightness"
    echo "v         Set the value use for the action"
    echo "I         Set to the Initial brightness"
}
while getopts "idIv:" opt; do
    case $opt in
        d)
            #decrease the backlight
            act="dec"
            ;;
        i)
            #set the default backlight
            act="inc"
            ;;
        v)
            val=$OPTARG
            defVal=true
            ;;
        I)
            act="set"
            if ! $defVal
            then
                val=$Initval
            fi
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
if [ -z $act ]
then
    usage
    exit 1
fi
cmd="/usr/bin/xbacklight -$act $val"
echo $cmd
$cmd
$sigcmd
