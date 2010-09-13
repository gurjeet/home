#!/bin/sh

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of GNU General Public License
# (www.gnu.org/copyleft/gpl.html)

if [ X$V == X ]; then

  echo not in a view...
  return 1

else

  unset START

  export PATH=$V_SAVED_PATH
  unset V_SAVED_PATH

  unset V
  unset GIT_DIR
  unset B
  unset PGDATA
  unset PGUSER

  unalias pginitdb
  unalias pgstart
  unalias pgstatus
  unalias pgreload
  unalias pgstop
  unalias pgcscope
  unalias pgconfigure

#  unalias pgpsqlo
  unalias pgsql

  echo out of the view...
  return 0

fi

