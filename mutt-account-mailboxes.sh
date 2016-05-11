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
if [ -z "$3" ]
then
    echo "usage $0 mailboxesfile maildir accountfield"
    exit 1
fi
input=$1
dir=$2
field=$3
acc=""
res="mailboxes"
LINES=$(sed -e 's/ /\n/g' -e 's/"\([^"]*\)"/\1/g' .mutt/mailboxes)
for line in $(echo "$LINES")
do
    if [[ "$line" =~ $dir ]]
    then
        nacc=$(echo $line | cut -d / -f $field)
        if [ "$nacc" != "$acc" ]
        then
            acc=$nacc
            res="$res \"+---- $(echo $acc | tr \"[a-z]\" \"[A-Z]\") ----\""
        fi
        res="$res \"$line\""
    fi
done
echo "$res"
