
function docker_set_host_to_podman_socket()
{
    local socket_path="$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
    local unix_domain_socket="unix://$socket_path"
    .info "Setting DOCKER_HOST=$unix_domain_socket"
    export DOCKER_HOST="$unix_domain_socket"
}
