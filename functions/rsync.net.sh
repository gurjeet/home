
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
    # Usage: rsyncnet --rsync-option1 --option2 ... file1 file2 ... destination-path--on-remote
    #
    # Example:
    #
    # rsyncnet -v "/Applications/Install macOS Ventura.app" /Applications/Install\ macOS\ Sonoma.app installers/macos/

    #rsync --archive --no-group --no-times --checksum "$@"
    #rsync --archive --no-group --no-times            "$@"
    #rsync --archive --no-group                       "$@"

    # Last parameter
    local last="${@:$#}"

    # other, non-last, parameters
    local others=("${@:1: $#-1}")

    #print_args
    rsync --archive --no-group "${others[@]}" fm2343@fm2343.rsync.net:"$last"
}

