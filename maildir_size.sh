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

# Display the size of maildir, nice integration with mutth
if [ -z "$1" ]
then
    echo "Usage $0 folder"
    exit 1
fi
folder=$(echo $1 | sed s'/\//\\\//g')
account=$(basename $1 | tr [:lower:] [:upper:])
du -hd 1 $1 | sed -e "s/\(.*\)$folder\/\(.*\)/|--\2:\1/" | sort | \
    sed -e 's/[A-Z][a-Z0-9]*\./|--/g' -e "s/^\([0-9]*[A-Z]\).*/$account:\1/" | \
    column -t -n -s ":"
