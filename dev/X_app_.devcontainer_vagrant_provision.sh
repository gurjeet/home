#!/usr/bin/env bash

function info() {
    echo "INFO: $@" >&1
}

function notice() {
    echo "NOTICE: $@" >&1
}

function warning() {
    echo "WARNING: $@" >&2
}

function error() {
    echo "ERROR: $@" >&2
}

function fatal() {
    exitCode="$1"
    shift
    echo "FATAL: $@" >&2
    exit "$exitCode"
}

set -eo pipefail
set -x

echo "Shell: $SHELL"
echo Running as:
whoami

info "Adding mount points to /etc/synthetic.conf"
printf "data2\t/Users/Shared/data2\n" | sudo tee -a /etc/synthetic.conf
printf "workspaces\t/Users/Shared/workspaces\n" | sudo tee -a /etc/synthetic.conf

info "Creating actual directories for /data2 and /workspaces"
mkdir /Users/Shared/data2
mkdir /Users/Shared/workspaces

#info "Checking if GitLab access works with SSH"
#ssh -T -o StrictHostKeyChecking=no git@gitlab.veevadev.com

info "Installing Homebrew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> /Users/admin/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/admin/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

info "Installing Rust toolchain"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo 'source "$HOME/.cargo/env"' >> ~/.zshrc
# `cargo build` and `cargo test` run massively parallel jobs, which may fail if
# the number of open files allowed is small (which is 256 by default)
echo '# Raise the number of open files' >> ~/.zshrc
echo 'ulimit -n 20480' >> ~/.zshrc
source "$HOME/.cargo/env"

info "Verifying that Rust toolchain is correctly installed"
rustc --version
cargo --version

brew install llvm lld
echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
llvm-config --version

# Install Docker, devcontainer, and related utilities. Apparently devcontainer scripts depend
# on jq and docker-compose.
brew install docker devcontainer jq docker-compose

mkdir ~/.docker/

cat > ~/.docker/config.json <<EOF
{
  "cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
  ]
}
EOF

echo 'export DOCKER_HOST=192.168.64.1:4243' >> ~/.zshrc
source ~/.zshrc

echo 'source "/Volumes/My Shared Files/Veeva/app/.devcontainer/.env"' >> ~/.zshrc
echo 'unset DEVCONTAINER' >> ~/.zshrc

echo 'export SERVER_PATH="/Volumes/My Shared Files/Veeva/app/server/"' >> ~/.zshrc

# This file is populated by the Vagrantfile.
_tmp="$(cat /tmp/host_vagrant_root)"

echo 'export HOST_PROJECT_PATH="'$_tmp'/app/"' >> ~/.zshrc

echo 'export CARGO_TARGET_DIR="$HOME/cargo_target/"' >> ~/.zshrc

brew install dnsmasq
mkdir -p "$(brew --prefix)/etc/"
cat "/Volumes/My Shared Files/Veeva/app/.devcontainer/dnsmasq.conf" >> "$(brew --prefix)/etc/dnsmasq.conf"

# This configuration tells dnsmasq to resolve all subdomains of veevaxlocal.com
# to 127.0.0.1. Changes will be applied
sed -i '' "s|172.28.0.20|127.0.0.1|g" "$(brew --prefix)/etc/dnsmasq.conf"

# Create a directory for resolver configuration
sudo mkdir -p /etc/resolver

# Create a resolver file for your domain
echo 'nameserver 127.0.0.1' | sudo tee -a /etc/resolver/veevaxlocal.com

sudo brew services start dnsmasq

# Can't use /data2 in the root directory yet, since it's not mounted until a
# reboot
mkdir -p /Users/Shared/data2/conf
ln -s "/Volumes/My Shared Files/Veeva/app/server/shared/veeva-config/src/conf/InstanceSettings.toml" /Users/Shared/data2/conf/
ln -s "/Volumes/My Shared Files/Veeva/app/server/shared/veeva-config/src/conf/DomainSettings.toml" /Users/Shared/data2/conf/

ln -s "/Volumes/My Shared Files/Veeva/app/server/shared/veeva-config/src/conf/InstanceSettings.ci.toml" /Users/Shared/data2/conf/
ln -s "/Volumes/My Shared Files/Veeva/app/server/shared/veeva-config/src/conf/DomainSettings.ci.toml" /Users/Shared/data2/conf/

# Override domaindb port to 5434
echo 'dbport = 5434' >> '/Users/Shared/data2/conf/DomainSettings.local.toml'

# Create symlink to cert/keys
ln -s "/Volumes/My Shared Files/Veeva/app" /Users/Shared/workspaces/app

ROUTER_IP="$(netstat -nr | grep default | head -n 1 | awk '{print $2}')"

# DNS override on localhost
cat  <<EOF | sudo tee -a /etc/hosts

# add test hostname entries (based on .devrc, check the latest .devrc for what DNS entries are needed)
127.0.0.1 localhost testing.veevaxlocal.com testing-instance.veevaxlocal.com testing-different.veevaxlocal.com aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-instance.veevaxlocal.com a-instance.veevaxlocal.com a.veevaxlocal.com aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.veevaxlocal.com base-test-domain.veevaxlocal.com
# Mapping container hostname to localhost
$ROUTER_IP instancedb domaindb app minio.veevaxlocal.com localstack.veevaxlocal.com otel-collector jaeger

EOF

info Testing that the dns setup works
ping -c 4 asdf.veevaxlocal.com

brew install libpq
echo 'export PATH="/opt/homebrew/opt/libpq/bin:$PATH"' >> ~/.zshrc
echo 'export CARGO_BUILD_JOBS="$(( $(sysctl -n hw.ncpu) * 2 / 3))"' >> ~/.zshrc

info "Copy the cert + key from https://drive.google.com/drive/folders/16cXF1PH-MOyeBbS68YWVuS12yv4u9bIX into ./app/.devcontainer"
info 'Reboot now with `sudo reboot` for some changes to take effect'


#### host side tools needed:
# Git - to clone the Git repository
# Homebrew - for package manamement
# Vagrant - brew install vagrant
# vagrant-tart - vagrant plugin install vagrant-tart
# Tart - brew install cirruslabs/cli/tart
# Docker - Ask IT team for a license
# socat - brew install socat
#    On host: socat TCP-LISTEN:4243,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock
#    On guest: DOCKER_HOST=192.168.64.1:4243 docker ps

# On Guest
# To install/run Docker Desktop on Guest: brew install --cask docker
#
# To get Host/router IP address
# netstat -nr | grep default | head -n 1 | awk '{print $2}'
#
# cargo test -- --skip ses::tests::send_email --skip s3_tests
# /Applications/Docker.app/Contents/MacOS/install --help
#
# brew install minio/stable/mc
# mc alias set myminio https://minio.veevaxlocal.com:9000 minioadmin minioadmin
# mc admin info myminio
# mc ping myminio --count 5
#
# time cargo test -- --skip domain_session_verify_tests::verify_domain_session_expired_session --skip codegen::llvm::tests:: --skip core::component_types::tests::test_component_embed_as_child_file
#
# Known good commit-id on origin/main branch:
# 7260adfba67836ac10841b09195621078fec90aa (except for the following tests)
# cargo test --no-fail-fast -- --skip codegen::llvm::tests:: --skip \
# domain_session_verify_tests::verify_domain_session_expired_session
#
# When trying to debug in macos over an ssh connection, use this command to enable debugging"
#   sudo DevToolsSecurity --enable
#
# Use this command to monitor Tailscale
#   while sleep 1; do if [[ "$(tailscale status --json | jq '.ExitNodeStatus != null')" == 'true' ]] then echo -n . ; else echo -n X; fi; done
#
#
#   tailscale set --exit-node= &&  g fa &&  tailscale set --exit-node=auto:any
