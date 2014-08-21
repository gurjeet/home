# How to restore home dierctory on a new machine
## Using wget
    cd /tmp
    wget --no-check-certificate https://github.com/gurjeet/home/archive/master.zip
    unzip master
    ls -A home-master | xargs -I ccc mv home-master/ccc ~/
    rm -rf master home-master
## Using Git

    cd ~
    git remote add origin https://github.com/gurjeet/home.git
    git fetch origin
    git checkout master
    # If the above fails, and the errors shown don't bother you, use the below command
    #git checkout -f master

