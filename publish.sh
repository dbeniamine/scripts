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

# Script to publish some of my scripts
usage()
{
    echo "Usage $0 [options]"
    echo "Publish every files listed as public"
    echo "Options:"
    echo "-h            Display this help and exit"
    echo "-f file       Set the file containning the list of public files"
}
message=""
public_file=public
repo="git@github.com:dbeniamine/scripts.git"
while getopts "hf:" opt
do
    case $opt in
        h)
            usage
            exit 0
            ;;
        f)
            public_file="$OPTARG"
            ;;
        *)
            echo "Invalid option $opt $OPTARG"
            usage
            exit 1
            ;;
    esac
done
# Get the public repo
if [ ! -d "pub" ]
then
    git clone $repo pub
else
    cd pub
    git pull
    cd ..
fi
# Copy files
while read f
do
    if [ -d "./$f" ]
    then
        cp -rv $f pub/$(dirname $f)
    else
        cp -v $f pub/$f
    fi
done < $public_file
cd pub
git status
