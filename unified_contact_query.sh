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

muhome="$HOME/mu"
main_cmd=pq_cmd_plain
additional_cmd=mu_cmd_plain
filter_cmd=pq_filter_plain


# pc_query query functions
pq_cmd_mutt(){
    pc_query -m $@ | grep '@'
}

pq_cmd_plain(){
    pc_query $@
}

# Functions extract addresses from pq results
pq_filter_mutt(){
    awk '{print $1}'
}

pq_filter_plain(){
    grep "EMAIL" | sed 's/^.*: //'
}

# mu cfind query functions
mu_cmd_mutt(){
    mu cfind --format=mutt-ab --muhome=$muhome $@ | grep '@' \
        | sed -e 's/\(.*\t.*\)$/\1mu-cfind/' -e 's/\t\t/\t \t/'
}
mu_cmd_plain(){
    mu cfind --format=plain --muhome=$muhome $@ | \
        sed -e 's/^\([^@]*\) \(\S*@\S*\)$/\nNAME: \1\nEMAIL (mu-cfind): \2/' \
        -e 's/^\(\S*\)$/\nNAME: \1\nEMAIL (mu-cfind): \1/'
}

usage(){
    echo "Usage $(basename $0) [options] query"
    echo "  Options:"
    echo "      -h              Display this help and exit"
    echo "      -H dir          Set muhome dir, default $muhome"
    echo "      -m              Show mail only and format for mutt"
}

while getopts "hmH:" opt
do
    case $opt in
        h)
            usage
            exit
            ;;
        H)
            muhome="$OPTARG"
            ;;
        m)
            main_cmd=pq_cmd_mutt
            additional_cmd=mu_cmd_mutt
            filter_cmd=pq_filter_mutt
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $(($OPTIND -1 ))
echo $muhome

query="$@"
echo "Searching for '$query' ..."

# Retrieve initial contact list
RESULTS=$($main_cmd $query | sed 1d)
# Extract known addresses and prepare regex for grep
ADDR=$(echo "$RESULTS"  | $filter_cmd | tr '\n' '|' \
    | sed -e 's/|/\\|/g' -e 's/\\|$//')
# Get additional command and format results
ADDITIONAL_RESULTS=$($additional_cmd $query | grep -v "($ADDR)" )
# Display results
echo "$RESULTS"
echo "$ADDITIONAL_RESULTS"

