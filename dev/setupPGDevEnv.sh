
vxzBLD=~/dev/builds/

#If return code is 0, $vxzBRANCH will contain branch name.
vxzGetGitBranchName()
{
	vxzBRANCH=`git branch | grep \* | grep -v "\(no branch\)" | cut -d ' ' -f 2`

	if [ "x$vxzBRANCH" = "x" ] ; then
		echo WARNING: Could not get a branch name
		return 1
	fi

	return 0
}

vxzInvalidateVariables()
{
	unset B
	unset PGDATA
	unset vxzFLAVOR
	unset vxzPSQL
	unset vxzPGSUNAME
	unset CSCOPE_DB

	if [ "x$vxzSaved_PATH" != "x" ] ; then
		export PATH=$vxzSaved_PATH
	fi

	unset vxzBRANCH
	unset vxzSaved_PATH
}

vxzSetVariables()
{
	vxzGetBuildDirectory
	vxzGetPGDATA
	vxzGetPGFlavor
	vxzGetPSQL
	vxzGetPGSUNAME

	# cscope_map.vim, a Vim plugin, uses this environment variable
	export CSCOPE_DB=$B/cscope.out

	vxzSaved_PATH=$PATH
	export PATH=$B/db/lib:$B/db/bin:/mingw/lib:$PATH

	mkdir -p $B
}

vxzDetectBranchChange()
{
	vxzGetPGFlavor >/dev/null 2>&1

	if [ $? -ne 0 ] ; then
		echo Not in Postgres sources 1>&2
		return 1
	fi

	local vxzSAVED_BRANCH_NAME=$vxzBRANCH

	vxzGetGitBranchName

	if [ $? -ne 0 ] ; then
		return 1
	fi

	if [ "x$vxzSAVED_BRANCH_NAME" != "x$vxzBRANCH" ] ; then
		vxzInvalidateVariables
		vxzSetVariables
	fi

	return 0
}

# set $B to the location where builds should happen
vxzGetBuildDirectory()
{
	vxzGetGitBranchName

	# $vxzBLD is set at the beginning of this file

	if [ $? -ne 0 ] ; then
		return 1
	fi

	B=$vxzBLD/$vxzBRANCH

	return 0
}

#Set $PGDATA
vxzGetPGDATA()
{
	if [ "x$B" = "x" ] ; then
		vxzGetBuildDirectory
	fi

	if [ $? = "0" ] ; then
		PGDATA=$B/db/data
		return 0
	fi

	return 1
}

# Check if $PGDATA directory exists
vxzCheckDATADirectoryExists()
{
  if [ ! -d $PGDATA ] ; then
    return 1;
  fi;

  return 0;
}

vxzGetSTARTShell()
{
	# It is a known bug that on MinGW's rxvt, psql's prompt doesn't show up; psql
	# works fine, its just that the prompt is always missing, hence we have to
	# start a new console and assign it to psql
	if [ X$MSYSTEM = "XMINGW32" ] ; then
		vxzSTART='start '
	else
		vxzSTART=' '
	fi

	return 0
}

vxzGetPGFlavor()
{
	local src_dir

	local git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 1

	src_dir=`cd $git_dir/../; pwd`

	if [ ! -f $src_dir/configure.in ] ; then
		echo "WARNING: Are you sure that $src_dir is a Postgres source directory?" 1>&2
		return 1
	fi

	# If the configure.in file contains the word EnterpriseDB, then we're
	# we're working with EnterpriseDB sources.
	grep -m 1 EnterpriseDB $src_dir/configure.in 2>&1 > /dev/null
	if [ $? -eq 0 ] ; then
		vxzFLAVOR="edb"
		return 0
	fi

	# If the configure.in file contains the word PostgreSQL, then we're
	# we're working with Postgres sources.
	grep -m 1 PostgreSQL $src_dir/configure.in 2>&1 > /dev/null
	if [ $? -eq 0 ] ; then
		vxzFLAVOR="postgres"
		return 0
	fi

	return 1
}

vxzGetPSQL()
{
	if [ "x$vxzFLAVOR" = "x" ] ; then
		vxzGetPGFlavor
	fi

	if [ "x$vxzFLAVOR" = "xpostgres" ] ; then
		vxzPSQL=psql
	elif [ "x$vxzFLAVOR" = "xedb" ] ; then
		vxzPSQL=edb-psql
	fi
}

vxzGetPGSUNAME()
{
	if [ "x$vxzFLAVOR" = "x" ] ; then
		vxzGetPGFlavor
	fi

	if [ "x$vxzFLAVOR" = "xpostgres" ] ; then
		vxzPGSUNAME=postgres
	elif [ "x$vxzFLAVOR" = "xedb" ] ; then
		vxzPGSUNAME=edb
	fi
}

##########
# The real commands supposed to be used by the user
#########

pgsql()
{
	vxzDetectBranchChange

	# This check is not part of vxzDetectBranchChange() because a change in
	# branch does not affect this variable
	if [ "x$vxzSTART" = "x" ] ; then
		vxzGetSTARTShell
	fi

	$vxzSTART$B/db/bin/$vxzPSQL "$@"

	local ret_code=$?

	# ~/.psqlrc changes the terminal title, so change it back to something sensible
	echo -en '\033]2;Terminal\007'

	return $ret_code
}

pginitdb()
{
	vxzDetectBranchChange

	$B/db/bin/initdb -D $PGDATA -U $vxzPGSUNAME
}

pgstart()
{
	vxzDetectBranchChange

	vxzCheckDATADirectoryExists

	if [ $? -ne 0 ] ; then
	    echo ERROR: \$PGDATA not set\; $PGDATA, no such directory
		return 1
	fi

	# Set $PGUSER to DB superuser's name so that `pg_ctl -w` can connect to
	# instance, to be able to check its status

	if [ "$PGUSER" ] ; then
		local save_PGUSER=$PGUSER
	fi

	export PGUSER=$vxzPGSUNAME

	# use pgstatus() to check if the server is already running
	pgstatus || $B/db/bin/pg_ctl -D $PGDATA -l $PGDATA/server.log -w start "$@"

	# Record pg_ctl's return code, so that it can be returned as return value
	# of this function.
	local ret_value=$?

	if [ "$save_PGUSER" ] ; then
		export PGUSER=$save_PGUSER
	fi

	$B/db/bin/pg_controldata $PGDATA | grep 'Database cluster state'

	return $ret_value
}

pgstatus()
{
	vxzDetectBranchChange

	vxzCheckDATADirectoryExists

	if [ $? -ne 0 ] ; then
	    echo ERROR: \$PGDATA not set\; $PGDATA, no such directory
		return 1
	fi

	$B/db/bin/pg_ctl -D $PGDATA status

	return $?
}

pgreload()
{
	vxzDetectBranchChange

	vxzCheckDATADirectoryExists

	if [ $? -ne 0 ] ; then
	    echo ERROR: \$PGDATA not set\; $PGDATA, no such directory
		return 1
	fi

	$B/db/bin/pg_ctl -D $PGDATA reload

	return $?
}

pgstop()
{
	vxzDetectBranchChange

	# Call pgstatus() to check if the server is running.
	pgstatus && $B/db/bin/pg_ctl -D $PGDATA stop "$@"
}

pgconfigure()
{
	vxzDetectBranchChange

	local src_dir

	if [ "x$GIT_DIR" != "x" ] ; then
		src_dir=$GIT_DIR/../
	else
		src_dir=`pwd`
	fi

	( cd $B; $src_dir/configure --prefix=$B/db --enable-debug --enable-cassert CFLAGS=-O0 --enable-depend --enable-thread-safety "$@" )

	return $?
}

pgmake()
{
	vxzDetectBranchChange

	# Append "$@" to the command so that we can do `pgmake -C src/backend/`, or
	# anything similar. `make` allows multiple -C options, and does the right thing
	make --no-print-directory -C "$B" "$@"

	return $?
}

pgcscope()
{
	vxzDetectBranchChange

	local src_dir

	if [ "x$GIT_DIR" != "x" ] ; then
		src_dir=$GIT_DIR/../
	else
		src_dir=`pwd`
	fi

	# Emit a list of all source files, and make cscope consume that list from stdin
	( cd $src_dir; find -L ./src/ ./contrib/ -iname "*.[chyl]" -or -iname "*.[ch]pp" | cscope -Rb -f $B/cscope.out -i - )
}

# unset $GIT_DIR
pgUnsetGitDir()
{
	unset GIT_DIR
}

# Set $GIT_DIR. If provided with a parameter, set the variable to that directory
# else set the variable to `pwd`
pgSetGitDir()
{
	if [ "x$1" != "x" ] ; then
		GIT_DIR=`cd "$1"; pwd`/.git/
	else
		GIT_DIR=`pwd`/.git/
	fi

	export GIT_DIR
}


# append branch detection code to $PASSWORD_COMMAND so that we can detect Git
# branch change ASAP.
if [ "x$PROMPT_COMMAND" != "x" ] ; then
	PROMPT_COMMAND=${PROMPT_COMMAND}\;
fi
PROMPT_COMMAND=${PROMPT_COMMAND}$(echo vxzDetectBranchChange \>/dev/null 2\>\&1)

