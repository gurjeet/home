# How to restore home dierctory on a new machine

    cd /tmp
    git clone git://github.com/gurjeet/home.git
    ls -A home | xargs -I ccc mv home/ccc ~/
    rm -rf home

