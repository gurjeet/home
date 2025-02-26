
function mount_rsync.net_sshfs()
{
    sudo mkdir -p /Volumes/sshfs
    sudo sshfs fm2343@fm2343.rsync.net: /Volumes/sshfs -oauto_cache,reconnect,local,volname=rsync.net,allow_other,defer_permissions,noappledouble
}
