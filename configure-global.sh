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
brew upgrade --cask

echo
echo '==> Install common tools'
brew install coreutils findutils diffutils wget gzip grep bash less jq make cmake tree rsync ifstat gnu-sed gettext zsh ifstat direnv openssl nvim vim the_silver_searcher libsodium
brew install rbenv nodenv python@3 salt

echo
echo '==> Install work tools'
brew install packer shellcheck terraform tflint plantuml postgresql@9.6 postgresql redis

echo
echo '==> Install brew HEAD packages'
brew install --fetch-HEAD --HEAD goenv

echo
echo '==> Install brew cask packages'
brew install --cask java visual-studio-code sublime-text google-backup-and-sync spectacle iterm2 docker tunnelblick sourcetree google-cloud-sdk vagrant spotify bitbar smcfancontrol slack bitbar bitwarden virtualbox virtualbox-extension-pack macs-fan-control mtmr

echo
echo '==> Tweak sysctl stuff'
sudo rm -f /Library/LaunchDaemons/limit.maxfiles.plist && sudo cp ./files/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load /Library/LaunchDaemons/limit.maxfiles.plist
sudo rm -f /Library/LaunchDaemons/limit.maxproc.plist && sudo cp ./files/limit.maxproc.plist /Library/LaunchDaemons/limit.maxproc.plist
sudo launchctl load /Library/LaunchDaemons/limit.maxproc.plist
