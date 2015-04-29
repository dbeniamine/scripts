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

# Find the next workspace number for i3
cur=1
for i in $(i3-msg -t get_workspaces | tr '{' '\n' | grep num | \
    cut -d : -f 2 | cut -c 1| sed -e 's/\"//g'| sort -n )
do
    if [ $i -gt $cur ]
    then
        echo $cur
        exit
    fi
    cur=$(($cur +1 ))
done
echo $cur
