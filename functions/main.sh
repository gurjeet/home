#!/bin/bash

source ~/functions/github.sh
source ~/functions/homebrew.sh
source ~/functions/chores.sh
source ~/functions/git.sh
source ~/functions/docker.sh

# Include logging functions for use by other functions.
source ~/functions/logging.sh

# Utility function that prints its arguments, each on a new line, with a
# numeric prefix that represents the argument's position.
function print_args() {
    # store arguments in a special array
    args=("$@")

    # Get number of elements
    ELEMENTS=${#args[@]}

    .info Number of elements: $ELEMENTS

    # echo each element in array
    # for loop
    for (( i=0;i<$ELEMENTS;i++)); do
        .info "$i: ${args[${i}]}"
    done
}

function hibernate() {
    ~/dev/HibernateUsingDeepSleepApp.applescript
}

