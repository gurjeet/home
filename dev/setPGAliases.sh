# This file is separated out from enterView.sh to make it usable in ~/.bashrc
# All `export` commands are in enterView.sh and this file is mainly for setting
# aliases.

# Function declarations

# Check if $PGDATA directory exists
checkDATADir()
{
  if [ ! -d $PGDATA ] ; then
    echo VIEW: ERROR: $PGDATA, no such directory
    return 1;
  fi;

  return 0;
}

getGitBranch()
{
	BRANCH=`git branch | grep \* | grep -v "\(no branch\)" | cut -d ' ' -f 2`

	if [ "x$BRANCH" = "x" ] ; then
		echo WARNING: Looks like you have not checked out any branch.
		return 1
	fi

	return 0
}

checkGitBranchBuildMatch()
{
	if [ -n "$GIT_DIR" ] ; then

		getGitBranch

		TEMP_BUILD_DIR=`basename $B`

		if [ "$BRANCH" != "$TEMP_BUILD_DIR" ] ; then
			echo WARNING: Your build-dir and checked out branch are out of sync.
			echo 'DETAIL: You might want to `leaveView; enterView` again.'
			echo HELP: Branch: $BRANCH vs. Build: $TEMP_BUILD_DIR
			read -p "Press ENTER to continue..."
		fi

		unset TEMP_BUILD_DIR
	fi
}

# It is a known bug that on MinGW's rxvt, psql's prompt doesn't show up; psql
# works fine, its just that the prompt is always missing, hence we have to
# start a new console and assign it to psql
if [ X$MSYSTEM == "XMINGW32" ] ; then
	START=start
else
	START=
fi

if [ ! -f $V/configure.in ] ; then
	echo "WARNING: Are you sure that $V is a Postgres source directory?"
else
	# If the configure.in file contains the word EnterpriseDB, then we're
	# we're working with EnterpriseDB sources.
	grep -m 1 EnterpriseDB $V/configure.in 2>&1 > /dev/null
	if [[ $? == "0" ]]; then
		flavour="edb"
	else
		flavour=
	fi;
fi;

if [ X$flavour == "Xedb" ] ; then
	PGSUNAME=edb
	LAUNCH_PSQL="$START edb-psql"
else
	PGSUNAME=postgres
	LAUNCH_PSQL="$START psql"
fi

# By default, use the database's SU name for connections; this also allows us
# to address the limitation that `pg_ctl -w start` does not provide a -U
# option when trying to verify if the database has started.
#
# $PGSUNAME is initialized by setPGAliases.sh called above.
export PGUSER=$PGSUNAME

pgsql()
{
	$LAUNCH_PSQL "$@"

	# ~/.psqlrc changes the terminal title, so change it back to something sensible
	echo -en '\033]2;Termnal\007'
}

alias pginitdb="checkGitBranchBuildMatch && $B/db/bin/initdb -D $PGDATA -U $PGSUNAME"
alias pgstart="checkGitBranchBuildMatch && checkDATADir && $B/db/bin/pg_ctl -D $PGDATA -l $PGDATA/server.log -w start && pg_controldata $PGDATA | grep 'Database cluster state'"
alias pgstatus="checkGitBranchBuildMatch && checkDATADir && $B/db/bin/pg_ctl -D $PGDATA status"
alias pgreload="checkGitBranchBuildMatch && checkDATADir && $B/db/bin/pg_ctl -D $PGDATA reload"

alias pgstop="checkGitBranchBuildMatch && pgstatus && $B/db/bin/pg_ctl -D $PGDATA stop"

alias pgconfigure=" checkGitBranchBuildMatch && ( cd $B; $V/configure --prefix=$B/db --enable-debug --enable-cassert CFLAGS=-O0 --enable-depend --enable-thread-safety ) "
alias pgmake="checkGitBranchBuildMatch && make --no-print-directory -C $B"

# Emit a list of all source files, and make cscope consume that list from stdin
alias pgcscope="checkGitBranchBuildMatch &&  ( cd $V; find -L ./src/ ./contrib/ -iname *.[chyl] -or -iname *.[ch]pp | cscope -Rb -i - ) "
