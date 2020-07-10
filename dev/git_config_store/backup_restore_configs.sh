#!/bin/bash

set -e

source ~/functions/logging.sh

# Absolute path of the directory where Git projects are hosted
project_store=~/dev

# Absolute path of the directory where to backup the config files
config_store=~/dev/git_config_store

# Backup/update files in config_store. Look for config files in .git/ directoreis.
info "Backing up config files"
cd "$project_store"
for cand_git_dir in */.git; do

    # Strip .git suffix from 'project/.git'
    project_name=$(dirname "$cand_git_dir")
    src_config="$cand_git_dir/config"

    info "Processing project $project_name"

    # Sanity checks
    if [[ -f "$cand_git_dir" ]]; then
        error "$cand_git_dir is a file; not yet supported." && continue;
    fi
    if [[ ! -e "$src_config" ]]; then
        error "$src_config does not exist." && continue;
    fi
    if [[ ! -f "$src_config" ]]; then
        error "$src_config is not a file." && continue;
    fi

    dest_dir="$config_store/$project_name"
    dest_config="$dest_dir/config"

    # Copy the file if it doesn't exist
    if [[ ! -e "$dest_config" ]]; then
        mkdir -p "$dest_dir"
        cp "$src_config" "$dest_config"
        continue
    fi

    # Backup the file if it's changed since last run
    if diff --brief "$src_config" "$dest_config" > /dev/null; then
        cp "$src_config" "$dest_config"
        continue
    fi
done

# Restore any files that are missing in the project_store
info "Restoring config files, if necessary"
cd "$config_store"
for config_file in */config; do

    project_name="$(dirname "$config_file")"
    project_dir="$project_store/$project_name"
    project_config="$project_dir/.git/config"

    info "Processing project $project_name"

    # Restore only if the destination directory does not exist. If the directory
    # already exists, we do not overwrite its contents.
    if [[ ! -e  "$project_dir" ]]; then
        mkdir -p "$project_dir"
        git init "$project_dir" > /dev/null
        cp "$config_file" "$project_config"
    fi

    pushd "$project_dir" > /dev/null
        for remote in $(git remote); do

            # Capture diff between local and remote repositories. Ignore error
            # exit-code from `diff`, else the `set -e` above would end the script.
                                        # Exclude local stash entries \
                                        # TODO Exclude remotes that don't match $remote; then remove the `uniq` from the below pipeline \
                                        # Ignore remotes tracked by our remote \
            local_vs_remote_diff=$(diff --ignore-space-change \
                                      <(git show-ref | grep -v 'refs/stash' | sed 's|refs/remotes/.*/\(.*\)|refs/heads/\1|' | sort | uniq) \
                                      <(git ls-remote 2> /dev/null | sed 's|.*refs/remotes/.*||' | sort) || true)

            remote_has_new_tags=$(echo "$local_vs_remote_diff" | grep -E '^>.*tags.*' || true)
            local_has_new_tags=$(echo "$local_vs_remote_diff" | grep -E '^<.*tags.*' || true)
            # TODO There are many more things we can detect from the captured
            # diff. For example, local branches not pushed to remote, new
            # branches in remote, etc.

            if [[ "$remote_has_new_tags" != "" ]]; then
                notice "Remote has new tags; cosider running "'`git fetch --all`'
            fi

            if [[ "$local_has_new_tags" != "" ]]; then
                notice "Local has new tags; cosider running "'`git push`'
            fi

            needs_update=$(git remote show "$remote" | grep -E 'out of date|new \(' || true)

            if [[ "$needs_update" != "" ]]; then
                notice "$project_name needs update; consider running "'`git fetch --all`'
            fi

            # Fetch the remote's updated contents. Do it in background so that
            # neither does it blocks the main loop, not does its exit code
            # affect this script's execution. Assumption here is that the
            # previous Git commands prompted for password, if necessary, and
            # cached the credentials.
            git fetch "$remote" &
        done
    popd > /dev/null
done

