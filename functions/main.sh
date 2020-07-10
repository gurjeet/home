#!/bin/bash

source ~/functions/github.sh

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
        echo $i: ${args[${i}]}
    done
}

function morning_chores() {
    ~/dev/OpenBookmarkGroup.applescript Morning
}

function afternoon_chores() {
    ~/dev/OpenBookmarkGroup.applescript Afternoon
}

function evening_chores() {
    ~/dev/OpenBookmarkGroup.applescript Evening
}

function hibernate() {
    ~/dev/HibernateUsingDeepSleepApp.applescript
}

