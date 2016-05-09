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

# Usage: $0 mailboxfile account name
if [ -z "$2" ]
then
    echo "usage $0 mailboxfile accountname"
    exit 1
fi
input=$1
acc=$2
# Reads mailbox file and return only directorys belonging to account
echo 'unmailboxes *'
res=$(sed 's/ /\n/g' $input | grep -e "\(^[^\"]\|$acc\)")
# Print only if some mailboxes are found
if [[ $(echo $res | sed 's/ /\n/g' | wc -l) -gt 1 ]]
then
    echo $res
fi
