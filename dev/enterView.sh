#! /bin/sh

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of General Public License
# (www.gnu.org/copyleft/gpl.html)

# Functions
. $DEV/checkDATADir.sh

if [ -n "$1" ]; then
  if [ ! -d "$1" ]; then
    echo "ERROR: $1 is not a directory"
    return 1
  fi
fi

# On MinGW's rxvt, psql's prompt doesn't show up; hence we have to start a new
# console and assign it to psql

MINGW32=MINGW32
 
if [ X$MSYSTEM == X$MINGW32 ] ; then
  START=start
else
  START=
fi

if [ X$V != X ] ; then
  echo already in a view... leaveView first. [`basename $V`]
  return 1
else

  if [ -n "$1" ]; then
    cd $1
  fi

  export V_SAVED_PATH=$PATH

  export V=`pwd`

  export PGDATA=$V/db/data

  # slony needs pthreads library, hence we need [/MinGW]/lib
  export PATH=$V/db/lib:$V/db/bin:/mingw/lib:$PATH

  . $DEV/setPGAliases.sh

  # By default, use the database's SU name for connections; this also allows us
  # to address the limitation that pg_ctl does not provide a -U option when
  # trying to verify if the database has started.
  # $PGSUNAME is initialized by setPGAliases.sh
  export PGUSER=$PGSUNAME

  echo inside a view now... [`basename $V`]
  return 0

fi



#  alias pgsql="pgstatus | head -2 | tail -1 | grep edb-postgres 2>&1 > /dev/null;\
#                  if [[ \$? == "0" ]]; then $START edb-psql edb; else $START psql postgres; fi;"

#  $V/db/bin/pg_ctl -D $VDATA status | head -2 | tail -1 | grep edb-postgres 2>&1 > /dev/null
#  if [[ $? == "0" ]]; then
#    alias pgsql="$START edb-psql"
#  else
#    alias pgsql="$START psql"
#  fi;


