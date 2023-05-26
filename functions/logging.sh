#!/bin/bash

# Use a period(.) prefix for these functions, to avoid name collision with
# other commands.

# All these functions, except .fatal, emit a message level followed by all
# their arguments. The .fatal function uses the first argument as the exit
# code, and uses the remaining arguments as do other functions.
function .info()    { echo    "INFO: $@" >&1; }
function .notice()  { echo  "NOTICE: $@" >&1; }
function .warning() { echo "WARNING: $@" >&2; }
function .error()   { echo   "ERROR: $@" >&2; }
function .fatalmsg(){ echo   "FATAL: $@" >&2; }
function .fatal()
{
    exitCode="$1";
    shift;
    .fatalmsg "$@";
    exit "$exitCode";
}

# Code from https://stackoverflow.com/a/62757929/382700
function stacktrace()
{
    echo >&2 Call stack:
    local i=1 line file func
    while read -r line func file < <(caller $i); do
        echo >&2 "[$i] $file:$line $func(): $(sed -n ${line}p $file)"
        ((i++))
    done
}

