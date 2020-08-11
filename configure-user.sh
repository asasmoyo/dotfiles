#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

mkdir -p ~/.dotfiles

# versions definition
GO_VERSION=1.14.6
RUBY_VERSION=2.7.1
NODE_VERSION=12.18.3

echo
echo '==> Install user dotfiles'
for f in .zshrc .global_gitignore .terraformrc; do
  rm -f "~/$f" && cp "files/$f" ~/
done
cat <<EOF > ~/.gitconfig
[user]
    name = Arba Sasmoyo
    email = arba.sasmoyo@gmail.com
[core]
    excludesfile = $HOME/.global_gitignore
[push]
    default = current
[feature]
    manyFiles = true
EOF

echo
echo '==> Configure ohmyzsh'
[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
if ! grep -i -q $(brew --prefix zsh)/bin/zsh /etc/shells; then
  echo $(brew --prefix zsh)/bin/zsh | sudo tee -a /etc/shells
  chsh -s $(which zsh) $USER
fi

echo
echo '==> Add cli tools into path'
cat <<BASH > ~/.dotfiles/tools.sh
# gnu stuff
temp=$(brew --prefix coreutils)/libexec/gnubin
temp=\$temp:$(brew --prefix findutils)/libexec/gnubin
temp=\$temp:$(brew --prefix diffutils)/bin
temp=\$temp:$(brew --prefix openssl)/bin
temp=\$temp:$(brew --prefix grep)/libexec/gnubin
temp=\$temp:$(brew --prefix make)/libexec/gnubin
temp=\$temp:$(brew --prefix cmake)/bin
temp=\$temp:$(brew --prefix gnu-tar)/libexec/gnubin
temp=\$temp:$(brew --prefix gnu-sed)/libexec/gnubin
temp=\$temp:$(brew --prefix gettext)/bin

# more stuff
temp=\$temp:$(brew --prefix php)/bin

# postgres
temp=\$temp:$(brew --prefix postgresql@12)/bin

export PATH=\$temp:\$PATH
export PKG_CONFIG_PATH=$(brew --prefix libxml2)/lib/pkgconfig
BASH

echo
echo '==> Configure goenv'
goenv install --keep --skip-existing --verbose ${GO_VERSION}
goenv global ${GO_VERSION}
goenv rehash
cat <<'BASH' > ~/.dotfiles/go.sh
export GOENV_DISABLE_GOPATH=1
eval "$(goenv init -)"

export GO111MODULE=on
export GOPATH=~/go
export PATH=$GOPATH/bin:$PATH
BASH

echo
echo '==> Configure rbenv'
rbenv install --keep --skip-existing --verbose ${RUBY_VERSION}
rbenv global ${RUBY_VERSION}
rbenv rehash
cat <<'BASH' > ~/.dotfiles/ruby.sh
eval "$(rbenv init -)"
BASH

echo
echo '==> Configure nodenv'
nodenv install --keep --skip-existing --verbose ${NODE_VERSION}
nodenv global ${NODE_VERSION}
nodenv rehash
~/.nodenv/shims/npm install -g yarn
cat <<'BASH' > ~/.dotfiles/node.sh
eval "$(nodenv init -)"
BASH

echo
echo '==> Configure python'
cat <<EOF > ~/.dotfiles/python.sh
export PATH=$(brew --prefix python@3)/bin:\$PATH
export PATH=$(readlink -f $(python3 -m site --user-site)/../../../bin):\$PATH

alias python=python3
alias pip=pip3
EOF

echo
echo '==> Configure direnv'
cat <<'EOF' > ~/.dotfiles/direnv.sh
eval "$(direnv hook zsh)"
EOF

echo
echo '==> Configure vscode'
mkdir -p ~/Library/Application\ Support/Code
mkdir -p ~/Library/Application\ Support/Code/User
[ -f ~/Library/Application\ Support/Code/User/settings.json ] || cp files/vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json

echo
echo '==> Configure google chrome'
# disable auto update
defaults write com.google.keystone.agent checkinterval 0

echo
echo '==> Configure bitbar'
mkdir -p ~/.dotfiles/bitbar
pushd ~/.dotfiles/bitbar
  rm -f *
  wget https://raw.githubusercontent.com/matryer/bitbar-plugins/master/System/mtop.5s.sh
  wget https://raw.githubusercontent.com/matryer/bitbar-plugins/master/Network/bandwidth_primary.1s.sh
  chmod +x *
popd

echo
echo 'Configure MTMR'
rm -f ~/Library/Application\ Support/MTMR/items.json && cp files/mtmr.json ~/Library/Application\ Support/MTMR/items.json
