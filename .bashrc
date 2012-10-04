# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# Set a shortcut for Git DVCS
alias g=git

# include PG development environment related functions
[ -r ~/dev/setupPGDevEnv.sh ] && source ~/dev/setupPGDevEnv.sh

# Use NVM for managing node.js versions and packages
[ -r ~/dev/NVM/nvm.sh ] && source ~/dev/NVM/nvm.sh
[ -r ~/dev/NVM/bash_completion ] && source ~/dev/NVM/bash_completion

[ -r /etc/bash_completion ] && source /etc/bash_completion

# Use Git completion, if available
if [ -r /etc/bash_completion.d/git ] ; then
	source /etc/bash_completion.d/git

	# Associate our alias ('g') with Git's completion function.
	complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
    || complete -o default -o nospace -F _git g
else
	# define a dummy function so that it can be safely used in PS1 below.
	__git_ps1() { echo ; }
fi

# Choose what all info you want to see in Git-generated prompt.
# I choose not to show DIRTY state in prompt, because that information is very
# expensive; with dropped cahces (echo 3 > /proc/sys/vm/drop_cahces), using
# Postgres 9.1-stable branch, getting new prompt takes 10 seconds vs. 2 seconds
# when this variable is not set.
#
# GIT_PS1_SHOWUNTRACKEDFILES is even more expensive when run on a Git-managed
# home directory, which has a *lot* of unmanaged files at different hierarchy
# levels. It takes more than 60 seconds to generate the prompt after dropping
# caches; even with FS caches intact, it takes about 2 seconds.

#GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
#GIT_PS1_SHOWUNTRACKEDFILES=1

# myDEBUG_CMD=" gTIME_SPENT=\$\(\(\$SECONDS-\$saved_SECONDS\)\) \$SECONDS; saved_SECONDS=\$SECONDS"
# gDEBUG_CMD=$(trap -p DEBUG | sed "s/trap -- '\(.*\)' DEBUG/\1/g")
# if [ ! -z "${gDEBUG_CMD}" ] ; then newDEBUG_CMD="${gDEBUG_CMD};${myDEBUG_CMD}" ; else newDEBUG_CMD="${myDEBUG_CMD}" ; fi
# trap "${newDEBUG_CMD}" DEBUG
# unset gDEBUG_CMD newDEBUG_CMD myDEBUG_CMD

# Replace any trailing '$' string in PS1 with Git-generated prompt, followed by $
# Also set it up to show time in HHMMSS format.
PS1=${PS1/%\\$ / T\\D\{%H%M%S\} \$\(__git_ps1 \"(%s)\"\)\\\$ }

# Add a newline lust before the last $
PS1=${PS1/%\$ /\n\\$ }

# Add a newline at the beginning of the prompt. # Commented out after some experience.
#PS1=${PS1/#/\\n}

# After the above three transformation to the PS1, two consecutive prompts now
# look like this:
#
#gurjeet@work:~ T153031 (master)
#$ 
#gurjeet@work:~ T153031 (master)
#$ 

#Set the default pager; programs use `more' by default, which IMHO is paralysed
export PAGER=less

# Set the command line options to be used by `less'
#	F = Quit if one screen
#	i = ignore case when searching, iff search pattern doesn't have uppercase letters
#	R = Use Raw Control Characters; useful for color output
#	X = disable termcap initialization and deinitialization;
#			not using this causes screen to be cleared when using F option above
#	x4 = Use tab size of 4 characters.
export LESS=FiRXx4

# ls options that are most useful
#	l = Long listing
#	A = Show almost all files (show all files except . and ..)
#	rt = Sort the list by file-modified-time, in reverse order
#	h = Show file sizes in human readable format, kB/MB/Gb/...
alias ll="ls -lArth --color=auto"

export PGCONNECT_TIMEOUT=5

# Erase duplicates in bash history, so that bash can remember less-used commands
# for longer.
HISTCONTROL=erasedups

# Setup $CDPATH so that we can easily switch to directories under the
# development directory.
CDPATH=${CDPATH}:${HOME}/dev

# My favourite options for top
#	c = Show command-line for the processes
#	-d1 = Sleep for 1 second between every update
alias top="top -c -d 1"

# alias for tagging every line of input with a timestamp
#
# How to use it:
#   any_program_that_emits_output | dateline
#
# For eg.
#     (echo line1; echo line2; echo line3) | dateline
alias dateline='while read line; do echo `date` $line; done'

alias ping_google="ping -i 3 google.com | dateline"

# Make an alias to a command, to background the prcess while preserving the arguments
# It is assumed that the first parameter is in $PATH.
#
# I have symlinks in ~/bin/ that point to binaries I'm interested in, and ~/bin/
# is in my $PATH (done in ~/.bash_profile)
function mkalias() { local cmd="$1"; shift; $cmd "$@" & }

# Shortcut function/alias to launch SublimeText in background, preserving the arguments.
function sl() {  mkalias sublime_text "$@" ; }

# Shortcut function/alias to launch NetBeans in background, preserving the arguments.
function nb() {  mkalias netbeans "$@" ; }

# Shortcut function/alias to launch GEdit (TeXt) in background, preserving the arguments.
function tx() {  mkalias gedit "$@" ; }

# Command to fetch all Git repos under ~/dev/ every 5 minutes.
alias git_fetch_all="while true; do time -p ls -d ~/dev/*/.git | while read line; do echo \$line; (cd \$line/..; time -p git fetch --all) ; done; date; echo ==== done ====; sleep 300; done"

# Launch a gnome-terminal with multiple tabs, each running a monitoring command.
#
# I invoke this alias in Ubuntu's 'Startup Applications' as
# `bash -i -c monitor_all` and voila, it opens up a maximized terminal window
# with multiple tabs, running all my monitoring commands listed above.
alias monitor_all="gnome-terminal --maximize --tab -e 'bash -i -c ping_google' --tab -e 'bash -i -c git_fetch_all' --tab -e 'bash -i -c top' --tab -e 'bash -i -c \"iostat -x 1\"' --tab -e 'bash -i -c \"dstat\"'"

