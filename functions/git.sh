
function ,listDirtyGitRepos()
(
    # Find all directories under $HOME and $HOME/dev/ that are Git repositories.
    # For each Git repository, check if it has any uncommitted changes.
    #
    # We use some uncommon options to prevent tripping over directory names that may contain uncommon characters.
    #   find's -print0 option terminates each result with a NULL byte
    #   xarg's --null option pairs with find's -print0 option to identify each input individually
    #   xarg's -l option ensures that we pass only one input parameter at a time to the Bash script
    #   git-status' --porcelain command produces output suitable for usage in scripts
    #   We ask grep to succeed if it sees __any__ input, by using empty string '' as a parameter'
    #
    # TODO: Instead of a plain echo at the end of this chain, we should emit
    # each directory name with a null terminator, just like find's -print0
    # option does. That will allow us to write reliable scripts that can
    # consume the output of this function.

    find "$HOME"/ "$HOME"/dev -maxdepth 1 -type d -print0   \
        | xargs --null --no-run-if-empty --max-args=1       \
            bash -c 'D="$0";
                # Note that the .git may be a file or a directory, so we use -e
                # for "exists" check rather than the -d for a "directory" check
                if [[ -e "$D/.git" ]]; then
                    (cd "$D";
                        git status --porcelain      \
                        | grep '\'\'' >/dev/null    \
                          && echo "$D";
                     # End the command chain with a successful command, to
                     # prevent errors from propagating further.
                     true);
                fi'

    # Irrespective of the exit status of the above chain of commands, we return
    # with a code of 0, to indicate that we have performed our job successfully.
    # return 0
)

