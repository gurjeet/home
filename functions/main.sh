#!/bin/bash

source ~/functions/github.sh

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

