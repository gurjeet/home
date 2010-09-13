#! /bin/sh

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of GNU General Public License
# (www.gnu.org/copyleft/gpl.html)

# Import functions
. $DEV/checkDATADir.sh

if [ -n "$1" ]; then
  if [ ! -d "$1" ]; then
    echo "ERROR: $1 is not a directory"
    return 1
  fi
fi

if [ X$V != X ] ; then
  echo already in a view... leaveView first. [`basename $V`]
  return 1
else

  export V_SAVED_PATH=$PATH

  # We've established above that if defined, $1 is a directory.
  if [ -n "$1" ]; then
    export V=`cd $1; pwd`
  else
    export V=`pwd`
  fi
  echo Setting VIEW directory: $V

  export GIT_DIR=$V/.git

  # Set the build location variable
  export B=`pwd`
  echo Setting BUILD directory: $B

  export PGDATA=$B/db/data

  # slony needs pthreads library, hence we need [/MinGW]/lib
  export PATH=$B/db/lib:$B/db/bin:/mingw/lib:$PATH

  . $DEV/setPGAliases.sh

  # By default, use the database's SU name for connections; this also allows us
  # to address the limitation that `pg_ctl -w start` does not provide a -U
  # option when trying to verify if the database has started.
  #
  # $PGSUNAME is initialized by setPGAliases.sh called above.
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


