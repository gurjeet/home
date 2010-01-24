#Functions

# On MinGW's rxvt, psql's prompt doesn't show up; hence we have to start a new
# console and assign it to psql

  if [ X$MSYSTEM == "XMINGW32" ] ; then
    START=start
  else
    START=
  fi

  if [ ! -f configure.in ] ; then
    echo "WARNING: Are you sure that `pwd` is a source directory?"
  else
    grep -m 1 EnterpriseDB configure.in 2>&1 > /dev/null
    if [[ $? == "0" ]]; then
      flavour="edb"
    else
      flavour=
    fi;
  fi;

. $DEV/checkDATADir.sh

  if [ X$flavour == "Xedb" ] ; then
	PGSUNAME=edb
    alias pgsql="$START edb-psql"
  else
	PGSUNAME=postgres
    alias pgsql="$START psql"
  fi

  alias pginitdb="                 $V/db/bin/initdb -D $PGDATA -U $PGSUNAME"
  alias pgstart=" _checkDATADir && $V/db/bin/pg_ctl -D $PGDATA -l $PGDATA/server.log -w start && pg_controldata | grep 'Database cluster state'"
  alias pgstatus="_checkDATADir && $V/db/bin/pg_ctl -D $PGDATA status"
  alias pgreload="_checkDATADir && $V/db/bin/pg_ctl -D $PGDATA reload"

  alias pgstop="pgstatus && $V/db/bin/pg_ctl -D $PGDATA stop"

  alias pgconfigure="$V/configure --prefix=$V/db --enable-debug --enable-cassert CFLAGS=-O0 --enable-depend"
  alias pgcscope="find ./src/ ./contrib/ -name *.[chyl] | xargs cscope -Rb"


