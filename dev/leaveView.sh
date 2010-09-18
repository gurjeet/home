#!/bin/sh

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of GNU General Public License
# (www.gnu.org/copyleft/gpl.html)

if [ X$V == X ]; then

  echo not in a view...
  return 1

else
  source $DEV/unsetPGAliases.sh
  echo out of the view...
fi

