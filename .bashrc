# .bashrc

# TODO: Change all paths with varables to be double-qupted.

# Mute stdout and stderr if we don't have an interactive terminal. This
# helps in situations where some utility, like scp, uses ssh but gets
# confused if it sees text on the wire that it did not expect.
if [ ! -t 0 ]; then
	exec 3>&1 4>&2
	exec > /tmp/bashrc.$$.log 2>&1
fi

function prepend_to_path_if_exists {
    if [ -d "$1" ]; then
        export PATH="$1:$PATH"
    fi
}

# Added to override MacOSX's ls with ls and other commands provided by coreutils
prepend_to_path_if_exists "/opt/local/libexec/gnubin"

prepend_to_path_if_exists "/usr/local/go/bin"
prepend_to_path_if_exists "$HOME/go/bin"
prepend_to_path_if_exists "$HOME/bin"

# Python 2.7 or 3.7 on macOS
prepend_to_path_if_exists "$HOME/Library/Python/2.7/bin"
prepend_to_path_if_exists "$HOME/Library/Python/3.7/bin/"

prepend_to_path_if_exists "$HOME/rvm/bin"
prepend_to_path_if_exists "$HOME/.rvm/bin" # Add RVM to PATH for scripting


# MacPorts Installer addition on 2014-07-29_at_14:04:40: adding an appropriate PATH variable for use with MacPorts.
prepend_to_path_if_exists "/opt/local/bin"
prepend_to_path_if_exists "/opt/local/sbin"

# For Ruby Gems installed in user-directory(*), add the Gems' bin directory to PATH
#
# (*): E.g: gem install --user-install bundler jekyll
if which ruby >/dev/null && which gem >/dev/null; then
    prepend_to_path_if_exists "$(ruby -r rubygems -e 'puts Gem.user_dir')/bin"
fi

function source_if_readable() {
  [ -r "$1" ] && source "$1"
}

# Source global definitions
source_if_readable /etc/bashrc

# User specific aliases and functions

# Set a shortcut for Git DVCS
alias g=git

# Set an alias for Docker
alias d=docker

# Source the helper functions
source_if_readable $HOME/functions/main.sh

# include PG development environment related functions
source_if_readable $HOME/pgd/pgd.sh

# TODO: Use --no-use flag to nvm.sh so that nvm is not in-use by default.
# See the relevant comment in README at https://github.com/nvm-sh/nvm
#
# TODO: Consider using the default location $HOME/.nvm

# Use NVM for managing node.js versions and packages
source_if_readable $HOME/dev/NVM/nvm.sh
source_if_readable $HOME/dev/NVM/bash_completion

if [ -e $HOME/dev/NVM/nvm.sh ] ; then
	# Add currenlty active NodeJS' bin/ to PATH
	prepend_to_path_if_exists "$(dirname $(nvm which ''))"
fi

source_if_readable /etc/bash_completion
# Add bash completion from homebrew, if available
which brew &> /dev/null && source_if_readable "$(brew --prefix)/etc/bash_completion"

# Use Git completion, if available
# MacPorts (for Mac OS)
source_if_readable /opt/local/etc/profile.d/bash_completion.sh
source_if_readable /opt/local/share/git/contrib/completion/git-completion.bash
source_if_readable /opt/local/share/git/contrib/completion/git-prompt.sh

# Linux distributions
source_if_readable /etc/bash_completion.d/git
source_if_readable /usr/share/bash-completion/completions/git
source_if_readable /usr/share/git-core/contrib/completion/git-prompt.sh

source_if_readable "$HOME/rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source_if_readable "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source_if_readable "$HOME/lib/azure-cli/az.completion"

source_if_readable "$HOME/.nix-profile/etc/profile.d/nix.sh"
source_if_readable "$HOME/.nix-profile/etc/profile.d/bash_completion.sh"
source_if_readable "$HOME/.nix-profile/share/git/contrib/completion/git-completion.bash"
source_if_readable "$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh"

# If the function _git is defined, alias it to our 'g' alias for completion
type _git > /dev/null 2>&1
if [ $? == "0" ] ; then
	# Associate our alias ('g') with Git's completion function.
	complete -o bashdefault -o default -o nospace -F _git g 2>/dev/null \
    || complete -o default -o nospace -F _git g
fi

# If the function __git_ps1 is NOT defined, create a dummy
type __git_ps1 > /dev/null 2>&1
if [ $? != "0" ] ; then
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
# TODO: Take inputs from [1] and bash.it to incorporate 'tput' and 'precmd'.
# [1] http://stackoverflow.com/questions/6592077/bash-prompt-and-echoing-colors-inside-a-function
COLOR_CODE_DEFAULT="\033[0;39m"
    COLOR_CODE_RED="\033[0;31m"
 COLOR_CODE_RED_BG="\033[7;31m"
  COLOR_CODE_GREEN="\033[0;32m"
   COLOR_CODE_BLUE="\033[0;34m"
   COLOR_CODE_CYAN="\033[0;36m"
  COLOR_CODE_BCYAN="\033[1;36m"
   COLOR_CODE_GRAY="\033[0;37m"
 COLOR_CODE_DKGRAY="\033[1;30m"
  COLOR_CODE_WHITE="\033[1;37m"
 COLOR_CODE_YELLOW="\033[1;33m"

PS1_COLOR_DEFAULT="\[${COLOR_CODE_DEFAULT}\]"
    PS1_COLOR_RED="\[${COLOR_CODE_RED}\]"
  PS1_COLOR_GREEN="\[${COLOR_CODE_GREEN}\]"
   PS1_COLOR_BLUE="\[${COLOR_CODE_BLUE}\]"
   PS1_COLOR_CYAN="\[${COLOR_CODE_CYAN}\]"
  PS1_COLOR_BCYAN="\[${COLOR_CODE_BCYAN}\]"
   PS1_COLOR_GRAY="\[${COLOR_CODE_GRAY}\]"
 PS1_COLOR_DKGRAY="\[${COLOR_CODE_DKGRAY}\]"
  PS1_COLOR_WHITE="\[${COLOR_CODE_WHITE}\]"
 PS1_COLOR_YELLOW="\[${COLOR_CODE_YELLOW}\]"

# Try this little experiment to have some fun. Set PS1 with various colored strings.
#PS1="${PS1_COLOR_GREEN}green${PS1_COLOR_CYAN}cyan${PS1_COLOR_RED}red${PS1_COLOR_BCYAN}bcyan${PS1_COLOR_BLUE}blue${PS1_COLOR_GRAY}gray${PS1_COLOR_DKGRAY}dkgray${PS1_COLOR_WHITE}white${PS1_COLOR_DEFAULT}default $ "

# Record the wall-time taken by each command executed on the prompt.
#
# Caveat: This cannot track the time spent by a subshell, most likely because
# the DEBUG trap is fired _after_ the sub-shell is executed.
#
# If the time tracking needs to have a sub-second resolution, use this instead:
# trap '[[ -z $var ]] && var=$(date +%s%N)' DEBUG;PS1='$delta\$ ';PROMPT_COMMAND='delta=$((($(date +%s%N)-var)/1000000));unset var'
#
# This time and exit-code tracking came after a lot of help from pgas on '#bash
# IRC channel, and others like greycat and Riviera on the same channel.
#
# Be nice and _append_ our commands to PROMPT_COMMAND, instead of overwriting it.
trap '[[ -z $g_time_start ]] && g_time_start=$SECONDS' DEBUG;
PROMPT_COMMAND="${PROMPT_COMMAND:-:;}"	# If empty, substitute a no-op
# If it doesn't end with a semi-colon, append one.
PROMPT_COMMAND="${PROMPT_COMMAND}$( [[ $(echo -n ${PROMPT_COMMAND} | tail -c 1) == ';' ]] && echo '' || echo ';' )"
PROMPT_COMMAND="${PROMPT_COMMAND}"'g_time_delta=$(($SECONDS - $g_time_start));unset g_time_start;'

# Use a hard-coded prompt, since some sites have their own default that are
# different in subtle ways.

# Make the default prompt look cyan
PS1=${PS1_COLOR_CYAN}'[\u@\h:\l \w]'

# Show if we're connected over SSH
PS1="${PS1}$( [[ -n "$SSH_CLIENT" ]] && echo " ${COLOR_CODE_YELLOW}SSH")"

# Record and display the exit-code of the last command. The exit code is still
# available if the user wants to see it via `echo $?`.
PS1=${PS1}${PS1_COLOR_CYAN}'$(var=$?; echo " time:$g_time_delta $([[ $var != 0 ]] && echo -n "'$COLOR_CODE_RED_BG'")exit:$var")'

# Show time in HHMMSS format.
PS1=${PS1}${PS1_COLOR_BLUE}' T\D{%H%M%S}'

# Add Git-generated prompt.
PS1=${PS1}${PS1_COLOR_GREEN}' $(__git_ps1 "(%s) ")'

# End the prompt with the $ sign on a new line by itself.
PS1=${PS1}${PS1_COLOR_DEFAULT}'\n$ '

# Add a newline at the beginning of the prompt. # Commented out after some experience.
#PS1=${PS1/#/\\n}

# After the above three transformation to the PS1, two consecutive prompts now
# look like this:
#
#[gurjeet@work:4 ~] time:0 exit:0 T125121 (master)
#$ 
#[gurjeet@work:4 ~] time:0 exit:0 T125121 (master)
#$ 

# A nice way to check performance of a script.
# Adapted from http://stackoverflow.com/a/4338046/382700
#PS4='$(date "+%s.%N ($LINENO) $ ")' bash -x scriptname

#Set the default pager; programs use 'more' by default, which IMHO is paralysed
export PAGER=less

# Set the default editor
export EDITOR=vim

# Set the command line options to be used by 'less'
#	F = Quit if one screen
#	i = ignore case when searching, iff search pattern doesn't have uppercase letters
#	R = Use Raw Control Characters; useful for color output
#	X = disable termcap initialization and deinitialization;
#			not using this causes screen to be cleared when using F option above
#	x4 = Use tab size of 4 characters.
export LESS=FiRXx4

# Function to open items with preferred/associated applications
function open() {
    case $OSTYPE in
    darwin*)
        # Use macOS's built-in open command. We're using Bash's command builtin
        # to override function look-up by the same name and avoid recursion.
        command open "$@"
        ;;
    *)
        # Presume everything else is Linux; that is, ignore Windows for now.
        alias open=xdg-open
        ;;
    esac
}

# ls options that are most useful
#	l = Long listing
#	A = Show almost all files (show all files except . and ..)
#	rt = Sort the list by file-modified-time, in reverse order
#	h = Show file sizes in human readable format, kB/MB/Gb/...
#
# The --color option is supported by GNU ls, but not by some others, like SUS
# compliant MacOS' ls command. But if we have MacPorts installed, we use the
# --color option.

function ll() {
    local cmd=ls
    local options="-lArth"

    case $OSTYPE in
    darwin*)
        # If MacPorts is installed, assume GNU options are available
        if [ -x /opt/local/bin/port ]; then
            opions="$options --color=auto"
        fi
        ;;
    *)
        opions="$options --color=auto"
        ;;
    esac

    $cmd $options "$@"
}

function llt() {
    ll "$@" | tail
}

export PGCONNECT_TIMEOUT=5

# Erase duplicates in bash history, so that bash can remember less-used commands
# for longer.
HISTCONTROL=erasedups

# Setup $CDPATH so that we can easily switch to directories under the
# development directory.
CDPATH=${CDPATH:-}:"${HOME}"/dev:"${GOPATH:-$HOME/go}"/src

# My favourite options for top
#	c = Show command-line for the processes
#	-d1 = Sleep for 1 second between every update
case $OSTYPE in
darwin*)
	alias top="top -s1 -o cpu -R -F"
	;;
*)
	alias top="top -c -d 1"
	;;
esac


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
	while sleep 1; do { timeout 4 ping -c 2 -i 1 $1 > /tmp/ping.$1.$$ 2>&1 && echo -n . ; } || { echo -n X ; } ; done
}

alias ping_google="ping_host google.com"
alias ping_router="ping_host 192.168.1.1"

# On Linux, Ubuntu 12.04 at least, this is the command to reset wifi
alias reset_wifi="nmcli nm wifi off && nmcli nm wifi on"

# Launch a command in background, while preserving the parameters.
#
# This function assumes the first parameter is the command to launch, and rest
# of the parameters are the parameter to that command, so it passes them on as
# is.
#
# It is assumed that the first parameter is in $PATH.
#
# I have symlinks in $HOME/bin/ that point to binaries I'm interested in, and $HOME/bin/
# is in my $PATH
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

# Function to pass the jq color output through the pager
function jq_pager() {  launch_in_fg jq -C "$@" | $PAGER; }

# Set Vi-style line editing
set -o vi

# Command to fetch all Git repos under $HOME/dev/ every 5 minutes.
alias git_fetch_all="while true; do time -p ls -d $HOME/dev/*/.git | while read line; do echo \$line; (cd \$line/..; time -p git fetch --all) ; done; date; echo ==== done ====; sleep 300; done"


# Command to restart network-manager when ping times-out
alias check_internet_connectivity="while true; do echo Checking internet reachability at \$(date); curl -# --max-time 5 -o /dev/null -I www.google.com || echo failed ; sleep 5; done 2>&1 | tee -a $HOME/internet_connectivity_tests.log"

# Launch a gnome-terminal with multiple tabs, each running a monitoring command.
#
# I invoke this alias in Ubuntu's 'Startup Applications' as
# 'bash -i -c monitor_all' and voila, it opens up a maximized terminal window
# with multiple tabs, running all my monitoring commands listed above.
alias monitor_all="gnome-terminal --maximize --tab -e 'bash -i -c ping_google' --tab -e 'bash -i -c git_fetch_all' --tab -e 'bash -i -c top' --tab -e 'bash -i -c \"iostat -x 1\"' --tab -e 'bash -i -c \"dstat\"' --tab -e 'bash -i -c check_internet_connectivity'"

# If in an X environment,  remap CAPS-lock key to ESCAPE key
# Try this iff $DISPLAY is not empty, and iff the utility is installed
[[ ! -z "$DISPLAY" ]] && which setxkbmap && setxkbmap -option caps:escape

# Reuse ssh-agent if already running, else start a new one
if [ ! -S $HOME/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "$SSH_AUTH_SOCK" $HOME/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=$HOME/.ssh/ssh_auth_sock
ssh-add -l | grep -q "The agent has no identities" && ssh-add

# This should be the last thing we enable, per recommendation in direnv docs
if which direnv >/dev/null 2>&1; then eval "$(direnv hook bash)"; fi

# Unmute the stdout and stderr, if we muted them at the beginning, and
# close the temporary FDs used for the purpose.
if [ ! -t 0 ]; then
	exec 1>&3 2>&4 3>&- 4>&-
fi

