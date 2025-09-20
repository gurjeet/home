

_sshfs_url="fm2343@fm2343.rsync.net";
_sshfs_mount_point="/Volumes/rsync.net"

function sshfs_mount_rsync_net()
{
    if mount | grep -q "$_sshfs_mount_point"; then
        .warning "$_sshfs_mount_point" seems to be already mounted
    else
        sshfs "$_sshfs_url": "$_sshfs_mount_point"
        if [[ $? -eq 0 ]]; then
            .info Successfully mounted "$_sshfs_url" at "$_sshfs_mount_point"
        else
            .error Successfully mounted "$_sshfs_url" at "$_sshfs_mount_point"
        fi
    fi
}

function sshfs_unmount_rsync_net()
{
    if ! (mount | grep -q "$_sshfs_mount_point"); then
        .warning "$_sshfs_mount_point" does not seem to be mounted
    else
        umount "$_sshfs_mount_point"
        if [[ $? -eq 0 ]]; then
            .info Successfully unmounted "$_sshfs_mount_point"
        else
            .error Could not unmount "$_sshfs_mount_point"
        fi
    fi
}

