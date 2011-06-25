#! /bin/bash

# Author:  singh.gurjeet@gmail.com
# This script may be distributed under the terms of GNU General Public License
# (www.gnu.org/copyleft/gpl.html)

# This script accepts 2 optional parameters. First parameter is used to set the
# sources directory (called view, $V), and the second is used to set the build
# directory ($B).

if [ -n "$1" ]; then
	if [ ! -d "$1" ]; then
		echo "ERROR: $1 is not a directory"
		return 1
	fi
fi

if [ -n "$2" ]; then
	if [ ! -d "$2" ]; then
		echo "ERROR: $2 is not a directory"
		return 1
	fi
fi

if [ -n "$V" ] ; then
	echo already in a view... leaveView first. [`basename $V`]
	return 1
fi

# Set the View directory
echo -n Setting VIEW directory...

# We've established above that, if defined, $1 is a directory.
if [ "x$1" != "x" ]; then
	V=`cd $1; pwd`
else
	V=`pwd`
fi

echo $V

if [ -d $V/.git ] ; then
	GIT_DIR=$V/.git
fi

# Set build directory
echo -n Setting BUILD directory...

# We've established above that, if defined, $2 is a directory.
if [ "x$2" != "x" ] ; then
	B=`cd $2; pwd`

# If $2 was not used, then try to setup a build directory under $DEV/$BLD/
# using the current Git branch name
elif [ "x$GIT_DIR" != "x" ] ; then

	BRANCH=`git branch | grep \* | grep -v "\(no branch\)" | cut -d ' ' -f 2`

	if [ "x$BRANCH" = "x" ] ; then
		echo NOTICE: Could not get a Git branch.
	else
		B=$BLD/$BRANCH

		# Make the directory if it doen't exist already
		mkdir -p $B
	fi
else
	B=`pwd`
fi

echo $B

PGDATA=$B/db/data

# Save $PATH for when we want to leave the view
V_SAVED_PATH=$PATH

# Override $PATH and make it work for Postgres sources and binaries.

# slony needs pthreads library, hence we need [/MinGW]/lib
export PATH=$B/db/lib:$B/db/bin:/mingw/lib:$PATH

source $DEV/setPGAliases.sh

echo inside a view now... [`basename $V`]
