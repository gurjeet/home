# How to restore home dierctory on a new machine

## Using Git

    cd ~
    git init ./
    git remote add origin https://github.com/gurjeet/home.git
    git fetch origin
    git checkout master
    # If the above fails, and the errors shown don't bother you, use the below command
    #git checkout -f master
    #
    # To get the Git-submodules as well, use the following commands
    git submodule init
    git submodule update

## Using `curl` (Not Recommended)
    cd /tmp
    curl --remote-name --location https://github.com/gurjeet/home/archive/master.zip
    unzip master.zip
    ls -A home-master | xargs -I XXX mv home-master/XXX ~/
    rm -rf master home-master

