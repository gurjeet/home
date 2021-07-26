#!/bin/bash

source ~/functions/github.sh
source ~/functions/homebrew.sh
source ~/functions/chores.sh

# Utility function that prints its arguments, each on a new line, with a
# numeric prefix that represents the argument's position.
function print_args() {
    # store arguments in a special array
    args=("$@")

    # Get number of elements
    ELEMENTS=${#args[@]}

    echo Number of elements: $ELEMENTS

    # echo each element in array
    # for loop
    for (( i=0;i<$ELEMENTS;i++)); do
        echo "$i: ${args[${i}]}"
    done
}

function hibernate() {
    ~/dev/HibernateUsingDeepSleepApp.applescript
}

