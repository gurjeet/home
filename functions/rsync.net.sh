
function rsyncnet_ssh()
{
    ssh fm2343@fm2343.rsync.net "$@"
}

function rsyncnet_sshfs_mount()
{
    sudo mkdir -p /Volumes/sshfs
    sudo sshfs fm2343@fm2343.rsync.net: /Volumes/sshfs -oauto_cache,reconnect,local,volname=rsync.net,allow_other,defer_permissions,noappledouble
}

function rsyncnet_sshfs_unmount()
{
    sudo umount /Volumes/sshfs
}

function rsyncnet
{
    rsync -a --no-group --no-times "$@"
}

