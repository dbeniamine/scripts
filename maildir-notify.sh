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

# This script requires the MIME::Words perl library
# On debian: apt-get install libmime-tools-perl
# This script should be called after an IMAP sync (for instance with the
# postsync-hook on offlineimaprc
# It does 2 things:
#   1. Send an unified notification with all new mail for one account
#   2. Update the email search index (by default with mu index

if [ -z "$1" ]
then
    echo "usage $0 account"
    exit 1
fi

# My mails are in $PREFIX/Account/Folder/...
PREFIX="$HOME/Documents/mail/$1"
# Command used to update email index (for searches)
INDEXCMD="mu index --maildir=$PREFIX --muhome=${PREFIX/mail/mu}"

name=$(basename $0 .sh)

if [ -z "$TMPDIR" ]
then
    TMPDIR=$(dirname $(mktemp -t -u XXX))
fi
# Create temporary directory
get_temp_dir(){
    dir=$(find $TMPDIR -type d -name "$name*" 2> /dev/null)
    [ -z "$dir" ] && dir=$(mktemp -p $TMPDIR -d $name-XXX)
    echo $dir
}

# Decode headers
decode(){
    /usr/bin/perl -pe 'use MIME::Words(decode_mimewords);$_=decode_mimewords($_);'
}
get_headers(){
    grep -e "\(^From\|^Subject\)" $1 | sort | while read line
    do
        res=$(echo $line | decode | cut -d ' ' -f 2- | sed 's/\(.*\)<.*>/\1/')
        echo "${res:0:25}\n"
    done
}

ring_bell(){
    echo -e "\a" > $1 &
    pid=$!
    sleep 1
    kill -9 $pid
    if [ $? -eq 0 ]
    then
        # The kill doesn't failed => the fifo is unbounded, we need to remove
        # it
        rm $1
    fi
}


basedir=$(get_temp_dir)
tmpdir=$basedir/$1
mkdir -p $tmpdir
touch $tmpdir/seen

# Prepare notification
msg="New mail(s) for $1:\n"
count=0
# Count mails per directory
for dir in $PREFIX/*
do
    # Check if mail already known
    for f in $(find $dir/new -type f)
    do
        if [ -z "$(grep $f $tmpdir/seen)" ]
        then
            # Mark seen
            echo $f >> $tmpdir/seen
            # Update message
            count=$((count +1))
            msg="$msg\n$(get_headers $f)"
        fi
    done
done

# Do send the notification
if [[ $count -gt 0 ]]
then
    export DISPLAY=:0; export XAUTHORITY=~/.Xauthority;
    notify-send -a "OfflineImap" -i "mail-unread" \
        "$(echo -e $msg)"
    # Ring terminal bell if fifo available
    for fifo in $(find $TMPDIR -type p -name "$name*" 2>/dev/null)
    do
        ring_bell $fifo
    done
fi
# Update e-mail index
$INDEXCMD
