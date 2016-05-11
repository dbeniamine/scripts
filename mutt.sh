#!/bin/bash
#default values
term_emulator="mate-terminal"
TRM="TERM=xterm-256color"
Title="Mutt mail reader"
args=""

usage()
{
    echo "Usage $0 [options]"
    echo "Launch mutt in a terminal"
    echo "Options:"
    echo "-t Title      Set the window title, default:  $Title"
    echo "-a Args       Pass args to mutt"
    echo "-R            Start mutt in readonly mode"
    echo "-e Emulator   Choose the terminal emulator default: $term_emulator"
    echo "-T TERM       Set the TERM env variable, default: $TERM"
}

while getopts "T:e:t:a:R" opt; do
    case $opt in
        t)
            Title="$OPTARG"
            ;;
        a)
            args="$OPTARG"
            ;;
        R)
            args="-R $args"
            ;;
        e)
            term_emulator="$OPTARG"
            ;;
        T)
            TRM="TERM=$OPTARG"
            ;;
        \?)
            echo "Invalid option : -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

$term_emulator -t "$Title" -e  "bash -c \"$TRM mutt $args\""
