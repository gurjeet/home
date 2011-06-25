#!/bin/sh

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of GNU General Public License
# (www.gnu.org/copyleft/gpl.html)

unset START

export PATH=$V_SAVED_PATH
unset V_SAVED_PATH

unset V
unset GIT_DIR
unset BRANCH
unset B
unset PGDATA
unset PGUSER

unset -f pgsql
unset -f checkDATADir
unset -f getGitBranch
unset -f checkGitBranchBuildMatch

unset flavour
unset PGSUNAME
unset LAUNCH_PSQL
unset PGUSER

unalias pginitdb
unalias pgstart
unalias pgstatus
unalias pgreload
unalias pgstop
unalias pgcscope
unalias pgconfigure

