# scripts

Several scripts that I use quite often

Many of them are used by my [configuration files](https://github.com/dbeniamine/conf)

## Description

+   DisplaySet.sh

    One of the script I use the most often: it is a very quick and efficient
    way to configure external monitor. It uses the next script to prompt the
    user (used in my .i3/config file).

+   prompt_user.sh
 
    This one is used by several other scripts including DisplaySet.sh, it
    queries the user using dmenu if available else it uses a simple temrinal
    read.

+   healthReport.sh

    This script is designed to be run once or twice a day on a server, it
    send a health report of the server including, uptime, IP, upgradable
    packages, services issues, memory and disk usage ...
    The mail is sent as a multipart alternative text plain / html with a
    tar.xz attachement containing usefull log files.
    If some important services are down the report switch it's level to alert
    and includes more detailed logs

+   dirdiff.sh

    Do a diff between the content of two directories, does not do a diff
    between the files content

+   dmenu_run.sh

    Replace demnu, include my path (source bashrc) and set nice colors (used in
    my .i3/config file).

+   gvim.sh

    Start vim in a temrinal, usefull for X-applications which want to start
    vim (firefox's it's all text plugin for instance).

+   i3_exit_menu.sh

    A nice exit menu for i3, using either systemctl if available or dbus to
    run the commands (used in my .i3/config file).

+   maildir_size.sh

    A pretty display of a maildir size for Mutt or other CLI mail clients
    (used in my muttrc).

+   mutt_bgrun

    Run stuff in background for mutt, this one is not from me but from Gary A.
    Johnson (used in my muttrc).

+   nextWorskpaceNumber.sh

    Helper for i3 to find the next available workspace number (used in my
    .i3/config file).

+   publish.sh

    Used to exctract and publish the public files from my private script repo.

+   xbacklight.sh

    Set backlight using xbackligh (used in my .i3/config file).

+   xinput_mouse_settings.sh

    Set my usual mouse settings (used by a udev rule when a mouse is added).

+   dbus_pow.sh

    Old script for powering off using dbus, used to be used by DisplaySet.sh ...
