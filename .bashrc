# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

# Set a shortcut for Git DVCS
alias g=git

# include PG development environment related functions
. ~/dev/setupPGDevEnv.sh

#Set the default pager; programs use `more' by default, which is paralysed
export PAGER=less

#Set the command line options to be used by `less'
#	F = Quit if one screen
#	i = ignore case
#	R = Use Raw Control Characters; useful for color output
#	X = disable termcap initialization and deinitialization;
#			not using this causes screen to be cleared when using F option above
#	x4 = Use tab size of 4 characters.
export LESS=FiRXx4

#ls options that are most useful
alias ll="ls -lArth"

