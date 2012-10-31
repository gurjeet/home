#!/bin/sh

# This maps right-alt keyboaard key to right-click of mouse
# and right-command key to middle-click of mouse.
#
# This script is supposed to be launched as a 'Startup Application' in Ubuntu
# and other distros whose Desktop shells have such facilities.
#
# Source : http://ubuntuforums.org/showpost.php?p=5801976
xmodmap -e "keycode 108 = Pointer_Button3"
xmodmap -e "keycode 134 = Pointer_Button2"
xkbset m
