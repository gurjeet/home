#!/bin/bash

# Use a period(.) prefix for these functions, to avoid name collision with
# other commands.

function .info()
{
    echo "INFO: $@" >&1
}

function .notice()
{
    echo "NOTICE: $@" >&1
}

function .warning()
{
    echo "WARNING: $@" >&2
}

function .error()
{
    echo "ERROR: $@" >&2
}

function .fatal()
{
    exitCode="$1"
    shift
    echo "FATAL: $@" >&2
    exit "$exitCode"
}
