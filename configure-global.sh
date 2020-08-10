#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

echo
echo '==> Install xcode'
xcode-select -p || xcode-select --install

echo
echo '==> Configure brew'
brew analytics off
brew upgrade
brew cask upgrade

echo
echo '==> Install common tools'
brew install coreutils findutils diffutils wget gzip grep bash less jq make cmake tree rsync ifstat gnu-sed gettext zsh ifstat direnv openssl stubby nvim vim the_silver_searcher libsodium
brew install rbenv nodenv python@3

echo
echo '==> Install work tools'
brew install packer shellcheck terraform tflint plantuml postgresql@9.6 postgresql redis

echo
echo '==> Install brew HEAD packages'
brew install --HEAD goenv

echo
echo '==> Install brew cask packages'
brew cask install java visual-studio-code sublime-text google-backup-and-sync spectacle iterm2 docker tunnelblick sourcetree google-cloud-sdk vagrant spotify bitbar smcfancontrol slack bitbar bitwarden virtualbox virtualbox-extension-pack homebrew/cask-drivers/logitech-options macs-fan-control

echo
echo '==> Tweak sysctl stuff'
sudo rm -f /Library/LaunchDaemons/limit.maxfiles.plist && sudo cp ./files/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load /Library/LaunchDaemons/limit.maxfiles.plist
sudo rm -f /Library/LaunchDaemons/limit.maxproc.plist && sudo cp ./files/limit.maxproc.plist /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load /Library/LaunchDaemons/limit.maxproc.plist

echo
echo '==> Configure stubby'
mkdir -p /usr/local/etc/stubby
cat <<EOF > /usr/local/etc/stubby/stubby.yml
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
idle_timeout: 300
listen_addresses:
  - 127.0.0.1
round_robin_upstreams: 1
tls_authentication: GETDNS_AUTHENTICATION_NONE
upstream_recursive_servers:
  - address_data: 1.1.1.1
    tls_port: 853
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 1.0.0.1
    tls_port: 853
    tls_auth_name: "cloudflare-dns.com"
EOF
sudo brew services restart stubby
sudo /usr/local/opt/stubby/sbin/stubby-setdns-macos.sh
