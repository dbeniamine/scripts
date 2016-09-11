#!/bin/bash
#default values
term_emulator="x-terminal-emulator"
TRM="TERM=xterm-256color"
Title="Mutt mail reader"
use_fifo=true
args=""

usage()
{
    echo "Usage $0 [options]"
    echo "Launch mutt in a terminal"
    echo "Options:"
    echo "-h            Displays this help and exit"
    echo "-t Title      Set the window title, default:  $Title"
    echo "-a Args       Pass args to mutt"
    echo "-R            Start mutt in readonly mode"
    echo "-e Emulator   Choose the terminal emulator default: $term_emulator"
    echo "-T TERM       Set the TERM env variable, default: $TERM"
    echo "-B            Disable notifications via terminal bell"
}

while getopts "T:e:t:a:RBh" opt; do
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
        B)
            use_fifo=false
            ;;
        h)
            usage
            exit
            ;;
        \?)
            echo "Invalid option : -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done

# Prepare fifo for new mail notification
if $use_fifo
then
    fifo=$(mktemp -u -t maildir-notify-XXXXXX)
    mkfifo -m 600 $fifo
    watch_fifo="tail -f $fifo &"
fi

$term_emulator --title "$Title" -e  /bin/bash -c \
    "$watch_fifo $TRM mutt $args"
