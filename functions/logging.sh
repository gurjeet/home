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
