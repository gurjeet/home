# .bashrc

# TODO: Change all paths with varables to be double-quoted.

# Mute stdout and stderr if we don't have an interactive terminal. This
# helps in situations where some utility, like scp, uses ssh but gets
# confused if it sees text on the wire that it did not expect.
if [ ! -t 0 ]; then
	exec 3>&1 4>&2

    # Redirect stdout and stderr to a log file.
    exec > /tmp/bashrc.$$.log 2>&1
fi

function prepend_to_path_if_exists {
    if [ -d "$1" ]; then
        export PATH="$1:$PATH"
    fi
}

function source_if_readable() {
  [ -r "$1" ] && source "$1"
}

# If there's a bash in $PATH that's different version than bash being used in
# $SHELL environment variable, use that. This is to honor the user's desire to
# use a different version of bash than provided by the system.
#
# This is useful for me since I wish to use ~/.nix-profile/bin/bash (a symlink
# that points to a path somewhere under /nix). Also, it is not recommended to
# change the default shell to a path that is not a system path. Fr example, I
# have noticed on macOS Catalina that sometimes the /nix mountpoint is not
# mounted after a reboot, at least not by the time I launch my shell.
function exec_non_default_shell_if_any() {

    # We're going to use `exec -l` to launch our shell. Since I can't find a
    # definitive way, using environment variables, to differentiate between the
    # 'before' and 'after' states of this exec, I am going to rely on the Bash
    # version to detect if we're before or after the `exec`. This method may
    # lead to a false-negative; the versions of default and non-default Bash
    # binaries may be exactly the same, making us assume that we're in the
    # 'after' state when we may be actually in the 'before' state. But this
    # false-negative is harmless for our uses, since we're simply trying to
    # allow the user to use a specific/preferred version of Bash.

    local non_default_bash_version=$(bash --norc -c 'echo $BASH_VERSION')

    if [[ $? =  0
             && ! -z "$non_default_bash_version"
             && "$non_default_bash_version" != "$BASH_VERSION" ]]; then

             echo "Default Bash version is $BASH_VERSION; switching to Bash version $non_default_bash_version"
             exec -l bash
    fi
}

# This switching to non-default Bash should happen after all changes to $PATH
# have been performed by the user, or at least those changes that may introduce
# the non-default Bash in $PATH. Hence we source nix.sh and then try to switch
# to bash from the Nix installation.
#
# Ideally, we should be sourcing "$HOME/.nix-profile/etc/profile.d/nix.sh", but
# for some reason that does not exist on one of my systems, so the
# nix-daemon.sh seems to be a good replacement for it. Even the 'nix.sh' file
# in the same directory as nix-daemon.sh does not change the environment
# variables suitably to provide the various nix commands.
source_if_readable "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
# Source Homebrew's recommended environment variable configuration
[[ -x /opt/homebrew/bin/brew ]] \
    && eval "$(/opt/homebrew/bin/brew shellenv)"

# Export these variables for RustRover (a derivative of IntelliJ). These
# variables are wrapped in this conditional to prevent my ususal shell
# environment from being dirtied unnecessarily.
# Set this value to a ridiculously high value so that the Rust/Cargo builds and
# tests don't fail. The default (usually 256), is very low for this purpose.
ulimit -n 81960

export_veeva_platform_env_vars()
{
    export POSTGRES_USER=postgres
    export POSTGRES_PASSWORD=postgres
    export POSTGRES_DB=postgres
    export POSTGRES_HOSTNAME=instancedb
    export POSTGRES_PORT=5432
    export AWS_ACCESS_KEY_ID=minioadmin
    export AWS_SECRET_ACCESS_KEY=minioadmin
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_ENDPOINT_URL_S3=https://minio.veevaxlocal.com:9000
    export SERVER_NAME=local-dev-server
    export POD_NAME=local-pod
    export IS_PRERELEASE=false
    export BUILD_INFO=minimal

    export SERVER_PATH="/Users/gurjeet.singh/Workspace/x-platform/app/server"
    export HOST_PROJECT_PATH="/Users/gurjeet.singh/Workspace/x-platform/app/"

    export DEPLOYMENT_ENV=ci
}

# Do not try to load the newer version of Bash if this file is being read by
# RustRover (or any of the other IDEs that use the INTELLIJ_ENVIRONMENT_READER
# environment variable.)
#
# Or, if we don't have an interactive terminal
if [ ! -z "$INTELLIJ_ENVIRONMENT_READER" ] || [ ! -t 0 ]; then
  export_veeva_platform_env_vars
else
    exec_non_default_shell_if_any
fi

# Added to override MacOSX's ls with ls and other commands provided by coreutils
prepend_to_path_if_exists "/opt/local/libexec/gnubin"
prepend_to_path_if_exists "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"

prepend_to_path_if_exists "/usr/local/go/bin"
prepend_to_path_if_exists "$HOME/go/bin"
prepend_to_path_if_exists "$HOME/bin"

# Add Rust development related binaries to PATH
source_if_readable "$HOME/.cargo/env"

# Rust-specific environment variables.
llvm_path="/opt/homebrew/opt/llvm"
if [[ -d "$llvm_path" ]]; then
  export PATH="$llvm_path/bin:$PATH"

  # Linker and header files for LLVM
  export LDFLAGS="-L$llvm_path/lib:$LDFLAGS"
  export CPPFLAGS="-I$llvm_path/include:$CPPFLAGS"
fi

# Python 2.7 or 3.7 on macOS
prepend_to_path_if_exists "$HOME/Library/Python/2.7/bin"
prepend_to_path_if_exists "$HOME/Library/Python/3.7/bin/"
prepend_to_path_if_exists "$HOME/Library/Python/3.8/bin"

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

# User-specific aliases and functions

# Set a shortcut for Git DVCS
alias g=git

# Set an alias for Docker
alias d=docker

alias nixinfo='nix-shell -p nix-info --run "nix-info -m"'


# Based on the following advice, override `rm` in our interactive sessions.
#
# https://apple.stackexchange.com/a/17637/133968
alias trash="rmtrash"
function rm()
{
    echo Use 'trash' command, or the full path i.e. '/bin/rm' >&2
    return 1
}

function ,rm()
{
    /bin/rm "$@"
}

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
	prepend_to_path_if_exists "$(dirname $(nvm which current))"
fi

# Homebrew's (and possibly others') binaries are placed here.
#
# Note that on macOS, /etc/profile (sourced by Bash before reading this .bashrc
# file) uses `/usr/libexec/path_helper` to populate PATH variable, so these and
# many other directories may already be in $PATH.
prepend_to_path_if_exists "/usr/local/bin"

prepend_to_path_if_exists "/usr/local/sbin"

# Prepend Nix bin directory last, so that executables installed by Nix are picked first
prepend_to_path_if_exists "$HOME/.nix-profile/bin"

source_if_readable /etc/bash_completion
# Add bash completion from homebrew, if available
which brew &> /dev/null && source_if_readable "$(brew --prefix)/etc/bash_completion"
export HOMEBREW_GITHUB_API_TOKEN=$( [[ -e ~/.github_token_w_public_repo ]] \
                                    && cat ~/.github_token_w_public_repo)

# Add findutils binaries, with their original names, to PATH. Because of
# conflict with Host's binaries' names, Homebrew adds to default PATH these
# binaries with a 'g' prefix.
prepend_to_path_if_exists "$(brew --prefix findutils)/libexec/gnubin"

# Use Git completion, if available
# MacPorts (for Mac OS)
source_if_readable /opt/local/etc/profile.d/bash_completion.sh
source_if_readable /opt/local/share/git/contrib/completion/git-completion.bash
source_if_readable /opt/local/share/git/contrib/completion/git-prompt.sh

# Linux distributions
source_if_readable /etc/bash_completion.d/git
source_if_readable /usr/share/bash-completion/completions/git
source_if_readable /usr/share/git-core/contrib/completion/git-prompt.sh


# If fzf is installed
which fzf &> /dev/null \
&& source_if_readable ~/.fzf.bash \
&& {

  # Enable a key-binding (^g^b) to pop up list of local Git branches to choose
  # from.
  #
  # Shortened and slightly modified version of the accepted answer here:
  # https://stackoverflow.com/a/37007733/382700

  g__is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
  }

  g__gb() {
    g__is_in_git_repo &&
      git branch -vv --color=always | grep -v '/HEAD\s' |
      fzf --height 40% --ansi --multi --tac | sed 's/^..//' | awk '{print $1}' |
      sed 's#^remotes/[^/]*/##'
  }

  g__get_brach_selection() {
    local selected;
    selected="$(g__gb)";
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}";
    READLINE_POINT=$(( READLINE_POINT + ${#selected} ));
  }

  # Set key-bindings only if in an interactive shell
  if [[ $- = *i* ]]; then
      #bind '"\C-g\C-b": "$(g__gb)\r\b\b"'

      # This invocation works only in Bash versions 4 and later. For Bash versions 3
      # and below, see the relevant code in key-bindings.bash in fzf source code.
      bind -m emacs-standard -x '"\C-g\C-b": g__get_brach_selection'
      bind -m vi-command     -x '"\C-g\C-b": g__get_brach_selection'
      bind -m vi-insert      -x '"\C-g\C-b": g__get_brach_selection'
  fi

  # This is an example of how any regular key-sequence (and not just
  # control/alt keys) can be used to trigger function calling. But this is
  # dangerous, since this will be triggered even if this sequence exists in the
  # middle of some command or commnet we're typing. What would be ideal is that
  # if we could somehow signify that we want this binding to trigger only when
  # the sequence is the first thing being typed on the command-line.
  #bind -m vi-insert      -x '"g ": g__get_brach_selection'
}

source_if_readable "$HOME/rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source_if_readable "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
source_if_readable "$HOME/lib/azure-cli/az.completion"

source_if_readable "$HOME/.nix-profile/etc/profile.d/bash_completion.sh"
source_if_readable "$HOME/.nix-profile/share/git/contrib/completion/git-completion.bash"
source_if_readable "$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh"

# Use the same auto-complete rules for our alias `g` as are defined for `git`.
#
# In newer versions of git-completion scripts, the functions __git_omplete and
# __git_main combined do this for us.  In older versions, the function _git
# used to do the needful.
if (type __git_complete && type __git_main) >/dev/null 2>&1 ; then
    __git_complete g __git_main
elif type _git > /dev/null 2>&1 ; then
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

# Allow Git commands to walk up directory tree even if parent is on a different
# filesystem. Avoid the following error when one of the parents leading up to
# .git/ directory is on a different filesystem.
#
#     fatal: not a git repository (or any parent up to mount point /Users/gurjeetsingh)
#     Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
export GIT_DISCOVERY_ACROSS_FILESYSTEM=true

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
#	x4 = Use tab size of 4 columns.
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

function l1()  {
    ls -1 "$@"
}

function l() {
    ls -l
}

function llh() {
    ll "$@" | head
}

export PGCONNECT_TIMEOUT=5

# Erase duplicates in bash history, so that bash can remember less-used commands
# for longer.
HISTCONTROL="erasedups:ignoredups"


# Remove limits on how much Bash command history to save
#
# https://stackoverflow.com/a/19533853/382700
HISTSIZE=
HISTFILESIZE=

# Setup $CDPATH so that we can easily switch to directories under the
# development directory.
CDPATH=${CDPATH:-}:".:${HOME}"/dev:"${GOPATH:-$HOME/go}"/src

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
    # Tell Bash to restore `set` options at function return. Note that this
    # feature was introduced in Bash 4.4.
    local -

    # disable noclobber option, so that we can write to the temp file
    set +o noclobber

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

function nv() {  launch_in_fg nvim -R "$@" ; }

# Function to see the various dates of interest for a domain name registration
function whois-dates() {
  whois "$@" | \
    grep -iE 'Creat.*Date|Updat.*Date|Expir.*Date'; }


# Prevent command-redirection from accidentally overwriting existing files
set +o noclobber

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

# Start the ssh-agent, unless either we already have one running, or if we are
# using credentials forwarded by another agent.
if [[ -e "$HOME/.ssh/ssh_auth_sock" ]]; then
  export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"
else
  eval "$(ssh-agent)"
  ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
fi
ssh-add -l | grep -q "The agent has no identities" && ssh-add

xcollapse_import_use_statements() (
    cargo fmt -- --config imports_granularity="Module"
)

x_pre_ci_checks() (
     ( :                                            \
       && echo "==== Cargo fmt ===="                \
       && cargo fmt --all --check                   \
       && echo "==== Cargo Check ===="              \
       && cargo check                               \
       && echo "==== Cargo Clippy ===="             \
       && cargo clippy --all-targets -- -D warnings \
       && echo "==== Cargo Build All Targets ===="  \
       && cargo build --all-targets --profile dev   \
       && echo "==== All Passed ===="               \
     )                                              \
     || (echo "==== Something Failed ===" >&2 && exit 1)
)

x_get_current_release_number() (
  git fetch origin &>/dev/null && git show origin/main:app/server/Cargo.toml 2>/dev/null | grep ^version
)

export RIPGREP_CONFIG_PATH=~/.config/ripgreprc

# Compile only those packages that are affected by the current branch, in the
# hopes that doing so will take less time than compiling all packages in the
# Workspace.
#
# The search_up() function's code adapted from an SO answer
# https://stackoverflow.com/a/19011599/382700
function ,xcompile_only_affected_packages() {
  git diff --name-only --merge-base origin/main --relative . | grep '/' | xargs -IXXXX bash -c 'search_up(){ local look=${2%/}; while [[ -n "$look" ]]; do [[ -e "$look/$1" ]] && { printf '%s\\\\n' "$look"; return; }; look=${look%/*}; done; [[ -e /$1 ]] && echo /; }; search_up Cargo.toml XXXX' | uniq | while read line; do echo ==== $line ====; cargo build --manifest-path "$line/Cargo.toml"; done
}

# This should be the last thing we enable, per recommendation in direnv docs
if which direnv >/dev/null 2>&1; then eval "$(direnv hook bash)"; fi

export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/libpq/include"

export PKG_CONFIG_PATH="$(brew --prefix libpq)/lib/pkgconfig:${PKG_CONFIG_PATH}"
export CPPFLAGS="-I$(brew --prefix libpq)/include ${CPPFLAGS}"
export LDFLAGS="-L$(brew --prefix libpq)/lib ${LDFLAGS}"

# Unmute the stdout and stderr, if we muted them at the beginning, and
# close the temporary FDs used for the purpose.
if [ ! -t 0 ]; then
	exec 1>&3 2>&4 3>&- 4>&-
fi

