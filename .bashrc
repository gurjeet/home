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

alias enterView=". $DEV/enterView.sh"
alias leaveView=". $DEV/leaveView.sh"

# If inside a view, then setup aliases. This can happen when an application
# opens a shell (like opening shell from VI)
if [[ X$V != X ]] ; then
  . $DEV/setPGAliases.sh
fi

export PAGER=less
export LESS=FiRx4

alias ll="ls -lArth"
