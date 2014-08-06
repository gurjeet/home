# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$HOME/local/bin:$PATH

export PATH

##
# Your previous /Users/gurjeet/.bash_profile file was backed up as /Users/gurjeet/.bash_profile.macports-saved_2014-07-29_at_14:04:40
##

# MacPorts Installer addition on 2014-07-29_at_14:04:40: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# Added by Gurjeet to override MacOSX's ls with ls and other commands provided
# by coreutils
export PATH=/opt/local/libexec/gnubin/:$PATH

[[ -s /Users/gurjeet/.nvm/nvm.sh ]] && . /Users/gurjeet/.nvm/nvm.sh # This loads NVM

