#!/bin/bash

#
# Function to clone a public GitHub repo to personal account
#
# This is necessary since GitHub deletes the forks under some common situations:
# https://help.github.com/articles/what-happens-to-forks-when-a-repository-is-deleted-or-changes-visibility/
#
function github_clone_to_personal_account() {
    local PERSONAL_ACCOUNT=gurjeet
    local PUBLIC_REPO_URL=$1

    # If the URL contains : (colon), replace it with slash
    # The URLs using Git protocol do this
    local PUBLIC_REPO_W_SLASHES=$(echo $PUBLIC_REPO_URL | tr : /)
    # Repo name is the first field counting from the end
    local REPO_NAME=$(echo $PUBLIC_REPO_W_SLASHES | rev | cut -d / -f 1 | rev)
    # Repo owner's name is the second field counting from the end
    local REPO_OWNER=$(echo $PUBLIC_REPO_W_SLASHES | rev | cut -d / -f 2 | rev)

    local TMP_DIR=$(mktemp -d /tmp/github_clone_XXXXX)

    local GH_TOKEN=$(cat ~/.github_token_w_public_repo)

    pushd $TMP_DIR
    git clone --mirror $PUBLIC_REPO_URL $TMP_DIR
    curl --header "Authorization: token $GH_TOKEN" --request POST --data '{"name":"'$REPO_NAME'","description":"Clone of '${REPO_OWNER}/${REPO_NAME}'"}' https://api.github.com/user/repos
    git lfs fetch --all
    git push --mirror https://github.com/$PERSONAL_ACCOUNT/$REPO_NAME
    git lfs push --all https://github.com/$PERSONAL_ACCOUNT/$REPO_NAME
    popd

    rm -rf $TMP_DIR
}
