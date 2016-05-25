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

# This script searches contacts using two engines for mutt contact complete
# The results of the first engine are removed from the one of the second
#
# It is usefull to append the known email address to the actual contact list
# fromm a pycard addressbok for instance.
#
# By default it uses pc_query than mu_cfind, but it can easily be adapted to
# other tools

if [ -z $2 ]
then
    echo "Usage $0 query muhome"
    echo "Search contacts matching query, using pc_query and mu cfind"
    exit 1
fi

query="$1"
echo "Searching for '$query' ..."

# Initial query
main_cmd="pc_query -m"
# Additional find
additional_cmd="mu cfind --format=mutt-ab --muhome=$2"
# Function to format additional command
additional_cmd_format(){
    grep '@' | sed -e 's/\(.*\t.*\)$/\1mu-cfind/' -e 's/\t\t/\t \t/'
}

# Retrieve initial contact list
RESULTS=$($main_cmd $query | grep '@' )
# Extract known addresses and prepare regex for grep
ADDR=$(echo "$RESULTS"  | awk '{print $1}' | tr '\n' '|' \
    | sed -e 's/|/\\|/g' -e 's/\\|$//')
# Get additional command and format results
ADDITIONAL_RESULTS=$($additional_cmd $query | grep -v "($ADDR)" \
    | additional_cmd_format)
# Display results
echo "$RESULTS"
echo "$ADDITIONAL_RESULTS"

