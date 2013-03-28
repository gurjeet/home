#!/bin/bash
# This script is licensed under GPL 2.0 license.

# This script uses some special features (look for 'wait' command)
# provided by Bash shell.

# get my pid
mypid=$$;

# determine a dir/ where I will keep my running info
MYDIR=/tmp/parallel.$mypid;

# echo my pid for the logs
echo PARALLEL: pid: $mypid;

# remove the directory/file if it is left over from a previous run
if [ -e $MYDIR ] ; then
  rm -r $MYDIR
fi

# make my dir/
mkdir $MYDIR

# determine the degreee of parallelization
degree=$1;

# default degree of parallelism, if not specified on command line
if [ "X$degree" = "X" ] ; then
  degree=2;
fi

# echo for logs
echo PARALLEL: Degree of parallelism: $degree;

# read each line from stdin and process it

while read -r line ;
do

  while [ true ]; do

    # re-adjust degree of parallelization communicated through this file
    if [ -f $MYDIR/degree ] ; then
      new_degree=`cat $MYDIR/degree`
      rm $MYDIR/degree
        if [ $new_degree -gt 0  ] ; then
          degree=$new_degree;
        fi
    fi

    # Look for a free slot
    for (( i = 0 ; i < $degree ; ++i )) ; do
      if [ ! -e $MYDIR/parallel.$i ]; then
        break
      fi
    done

    if [ $i -lt $degree ]; then
      break
    fi

    # if can't find any free slot, repeat after a sleep of 1 sec
    sleep 1;

  done

  # occupy this slot
  ( # echo PARALLEL: touching $MYDIR/parallel.$i;
    touch $MYDIR/parallel.$i )

  # perform the task in background, and free the slot when done
  ( echo PARALLEL: $degree $mypid;
    sh -c "$line";
    # echo PARALLEL: removing $MYDIR/parallel.$i;
    rm $MYDIR/parallel.$i ) &
done

# Wait for all child processes to finish
wait;

# echo PARALLEL: removing base dir;
rm -r $MYDIR;

