# How to restore home dierctory on a new machine
## Using wget
    cd /tmp
    wget --no-check-certificate https://github.com/gurjeet/home/archive/master.zip
    unzip master
    ls -A home-master | xargs -I ccc mv home-master/ccc ~/
    rm -rf master home-master
## Using Git

    cd /tmp
    git clone git://github.com/gurjeet/home.git
    ls -A home | xargs -I ccc mv home/ccc ~/
    rm -rf home

