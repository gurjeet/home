# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# Set a shortcut for Git DVCS
alias g=git

# Set an alias for Docker
alias d=docker

# include PG development environment related functions
[ -r ~/pgd/pgd.sh ] && . ~/pgd/pgd.sh

# Use NVM for managing node.js versions and packages
[ -r ~/dev/NVM/nvm.sh ] && . ~/dev/NVM/nvm.sh
[ -r ~/dev/NVM/bash_completion ] && . ~/dev/NVM/bash_completion

[ -r /etc/bash_completion ] && . /etc/bash_completion

# Use Git completion, if available
if [ -r /etc/bash_completion.d/git ] ; then
	. /etc/bash_completion.d/git

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

# Define functions that emit escape sequnces for coloring the prompt
# Color codes copied from: http://brettterpstra.com/my-new-favorite-bash-prompt/
# TODO: Take inputs from [1] and bash.it to incorporate `tput` and `precmd`.
# [1] http://stackoverflow.com/questions/6592077/bash-prompt-and-echoing-colors-inside-a-function
COLOR_CODE_DEFAULT="\033[0;39m"
    COLOR_CODE_RED="\033[0;31m"
  COLOR_CODE_GREEN="\033[0;32m"
   COLOR_CODE_BLUE="\033[0;34m"
   COLOR_CODE_CYAN="\033[0;36m"
  COLOR_CODE_BCYAN="\033[1;36m"
   COLOR_CODE_GRAY="\033[0;37m"
 COLOR_CODE_DKGRAY="\033[1;30m"
  COLOR_CODE_WHITE="\033[1;37m"

PS1_COLOR_DEFAULT="\[${COLOR_CODE_DEFAULT}\]"
    PS1_COLOR_RED="\[${COLOR_CODE_RED}\]"
  PS1_COLOR_GREEN="\[${COLOR_CODE_GREEN}\]"
   PS1_COLOR_BLUE="\[${COLOR_CODE_BLUE}\]"
   PS1_COLOR_CYAN="\[${COLOR_CODE_CYAN}\]"
  PS1_COLOR_BCYAN="\[${COLOR_CODE_BCYAN}\]"
   PS1_COLOR_GRAY="\[${COLOR_CODE_GRAY}\]"
 PS1_COLOR_DKGRAY="\[${COLOR_CODE_DKGRAY}\]"
  PS1_COLOR_WHITE="\[${COLOR_CODE_WHITE}\]"

# Try this little experiment to have some fun. Set PS1 with various colored strings.
#PS1="${PS1}${PS1_COLOR_GREEN}green${PS1_COLOR_CYAN}cyan${PS1_COLOR_RED}red${PS1_COLOR_BCYAN}bcyan${PS1_COLOR_BLUE}blue${PS1_COLOR_GRAY}gray${PS1_COLOR_DKGRAY}dkgray${PS1_COLOR_WHITE}white${PS1_COLOR_DEFAULT}default $ "

# myDEBUG_CMD=" gTIME_SPENT=\$\(\(\$SECONDS-\$saved_SECONDS\)\) \$SECONDS; saved_SECONDS=\$SECONDS"
# gDEBUG_CMD=$(trap -p DEBUG | sed "s/trap -- '\(.*\)' DEBUG/\1/g")
# if [ ! -z "${gDEBUG_CMD}" ] ; then newDEBUG_CMD="${gDEBUG_CMD};${myDEBUG_CMD}" ; else newDEBUG_CMD="${myDEBUG_CMD}" ; fi
# trap "${newDEBUG_CMD}" DEBUG
# unset gDEBUG_CMD newDEBUG_CMD myDEBUG_CMD

# Use a hard-coded prompt, since some sites have their own default that are
# different in subtle ways.
PS1='[\u@\h:\l \w]\$ '

# make the default prompt look cyan
PS1=${PS1_COLOR_CYAN}${PS1}

# Replace the trailing '$' string in PS1 with Git-generated prompt, followed by $
# Also set it up to show time in HHMMSS format.
PS1=${PS1/%\\$ / ${PS1_COLOR_BLUE}T\\D\{%H%M%S\}${PS1_COLOR_GREEN} \$\(__git_ps1 \"(%s)\"\)${PS1_COLOR_DEFAULT}\\\$ }

# Add a newline just before the last $
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

# A nice way to check performance of a script.
# Adapted from http://stackoverflow.com/a/4338046/382700
#PS4='$(date "+%s.%N ($LINENO) $ ")' bash -x scriptname

#Set the default pager; programs use `more' by default, which IMHO is paralysed
export PAGER=less

# Set the default editor
export EDITOR=vim

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
alias llt="ll | tail"

export PGCONNECT_TIMEOUT=5

# Erase duplicates in bash history, so that bash can remember less-used commands
# for longer.
HISTCONTROL=erasedups

# Setup $CDPATH so that we can easily switch to directories under the
# development directory.
CDPATH=${CDPATH:-}:${HOME}/dev

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
#     while sleep 1; do echo A random number: $RANDOM; done | dateline
alias dateline='while read line; do echo $(date) "${line}"; done'

function ping_host()
{
	#while sleep 1; do { timeout 4 ping -w 3 -c 2 -i 1 $1 > /tmp/ping.$1.$$ 2>&1 && echo $1 Success ; } || { echo $1 FAILURE && cat /tmp/ping.$1.$$ ; } ; done | dateline
	while sleep 1; do { timeout 4 ping -w 3 -c 2 -i 1 $1 > /tmp/ping.$1.$$ 2>&1 && echo -n . ; } || { echo -n X ; } ; done
}

alias ping_google="ping_host google.com"
alias ping_local="ping_host 192.168.1.1"

# On Linux, Ubuntu 12.04 at least, this is the command to reset wifi
alias reset_wifi="nmcli nm wifi off && nmcli nm wifi on"

alias open=xdg-open

# Launch a command in background, while preserving the parameters.
#
# This function assumes the first parameter is the command to launch, and rest
# of the parameters are the parameter to that command, so it passes them on as
# is.
#
# It is assumed that the first parameter is in $PATH.
#
# I have symlinks in ~/bin/ that point to binaries I'm interested in, and ~/bin/
# is in my $PATH (done in ~/.bash_profile)
function launch_in_bg() { local cmd="$1"; shift; $cmd "$@" & }
function launch_in_fg() { local cmd="$1"; shift; $cmd "$@" ; }

# Shortcut function/alias to launch SublimeText in background, preserving the arguments.
function sl() {  launch_in_bg sublime_text "$@" ; }

# Shortcut function/alias to launch NetBeans in background, preserving the arguments.
function nb() {  launch_in_bg netbeans "$@" ; }

# Shortcut function/alias to launch GEdit (TeXt) in background, preserving the arguments.
function tx() {  launch_in_bg gedit "$@" ; }

# Shortcut function/alias to launch Vagrant in foreground, preserving the arguments.
function vg() {  launch_in_fg vagrant "$@" ; }

# Set Emacs style line editing
set -o emacs

# Command to fetch all Git repos under ~/dev/ every 5 minutes.
alias git_fetch_all="while true; do time -p ls -d ~/dev/*/.git | while read line; do echo \$line; (cd \$line/..; time -p git fetch --all) ; done; date; echo ==== done ====; sleep 300; done"


# Command to restart network-manager when ping times-out
alias check_internet_connectivity="while true; do echo Checking internet reachability at \$(date); curl -# --max-time 5 -o /dev/null -I www.google.com || echo failed ; sleep 5; done 2>&1 | tee -a ~/internet_connectivity_tests.log"

# Launch a gnome-terminal with multiple tabs, each running a monitoring command.
#
# I invoke this alias in Ubuntu's 'Startup Applications' as
# `bash -i -c monitor_all` and voila, it opens up a maximized terminal window
# with multiple tabs, running all my monitoring commands listed above.
alias monitor_all="gnome-terminal --maximize --tab -e 'bash -i -c ping_google' --tab -e 'bash -i -c git_fetch_all' --tab -e 'bash -i -c top' --tab -e 'bash -i -c \"iostat -x 1\"' --tab -e 'bash -i -c \"dstat\"' --tab -e 'bash -i -c check_internet_connectivity'"

# Make 'vi' a function to launch Vim such that the Ctr-S sequence isn't blocked by bash.
#
# No ttyctl, so we need to save and then restore terminal settings
# Source: http://vim.wikia.com/wiki/Map_Ctrl-S_to_save_current_or_new_files
vi()
{
	local STTYOPTS="$(stty --save)"
	stty stop '' -ixoff
	command vi "$@"
	stty "$STTYOPTS"
}

