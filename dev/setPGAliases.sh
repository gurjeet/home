#Functions

. $DEV/checkDATADir.sh

  alias pginitdb="                 $V/db/bin/initdb -D $PGDATA"
  alias pgstart=" _checkDATADir && $V/db/bin/pg_ctl -D $PGDATA -l $PGDATA/server.log -w start && sleep 2 && pgstatus"
  alias pgstatus="_checkDATADir && $V/db/bin/pg_ctl -D $PGDATA status"
  alias pgreload="_checkDATADir && $V/db/bin/pg_ctl -D $PGDATA reload"

  alias pgstop="pgstatus && $V/db/bin/pg_ctl -D $PGDATA stop"

# On MinGW's rxvt, psql's prompt doesn't show up; hence we have to start a new
# console and assign it to psql

  MINGW32=MINGW32
 
  if [ X$MSYSTEM == X$MINGW32 ] ; then
    START=start
  else
    START=
  fi

  if [ ! -f configure.in ] ; then
    echo "WARNING: Are you sure that `pwd` is a source directory?"
  else
    grep -m 1 EnterpriseDB configure.in 2>&1 > /dev/null
    if [[ $? == "0" ]]; then
      alias pgsql="$START edb-psql"
    else
      alias pgsql="$START psql"
    fi;
  fi;

