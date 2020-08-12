#!/usr/bin/env bash

echo '==> Configure global gitconfig'
cat <<EOF > ~/.gitconfig
[user]
    name = Arba Sasmoyo
    email = arba@toggl.com
[core]
    excludesfile = $USER/.global_gitignore
[push]
    default = current
[feature]
    manyFiles = true

# needed by go module to fetch private repositories
[url "ssh://git@github.com/"]
    insteadOf = https://github.com/
EOF

echo '==> Configure environment variable'
cat <<EOF > ~/.dotfiles/work.sh
export BOFT_LOGIN=arba
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
unset LC_TERMINAL
unset LC_TERMINAL_VERSION
EOF

echo '==> Install some tools'
pip3 freeze | grep chkcrontab || pip3 install chkcrontab
