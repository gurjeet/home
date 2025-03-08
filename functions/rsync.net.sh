
function rsync_net_sshfs_mount()
{
    sudo mkdir -p /Volumes/sshfs
    sudo sshfs fm2343@fm2343.rsync.net: /Volumes/sshfs -oauto_cache,reconnect,local,volname=rsync.net,allow_other,defer_permissions,noappledouble
}

function rsync_net_sshfs_unmount()
{
    sudo umount /Volumes/sshfs
}
