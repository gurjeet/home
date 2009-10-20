# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias g=git
alias gk='gitk&'
alias gka='gitk --all&'

export DEV=~/dev/

if [[ X$V != X ]] ; then
  . $DEV/setPGAliases.sh
fi

export PAGER=less
export LESS=iRx4


