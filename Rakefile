require_relative 'lib.rb'

desc 'Install configuration files'
task :configfiles do
  [
    '.zshrc',
    '.global_gitignore',
  ].each do |file|
    sh "rm -f ~/#{file} && cp ./files/#{file} ~/"
  end

  sh 'mkdir -p ~/.more'
  render_tpl 'files/profiles/pg_profile.erb', "#{ENV['HOME']}/.more/pg_profile"
  render_tpl 'files/profiles/gnu_profile.erb', "#{ENV['HOME']}/.more/gnu_profile"
  render_tpl 'files/profiles/python_profile.erb', "#{ENV['HOME']}/.more/python_profile"
  render_tpl 'files/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"

  # nvim
  sh 'mkdir -p ~/.config/nvim'
  sh 'rm -f ~/.config/nvim/init.vim && cp ./files/vim/bootstrap.vim ~/.config/nvim/init.vim'
  sh 'rm -f ~/.config/nvim/local_init.vim && cp ./files/vim/local_init.vim ~/.config/nvim/local_init.vim'
  sh 'rm -f ~/.config/nvim/local_bundles.vim && cp ./files/vim/local_bundles.vim ~/.config/nvim/local_bundles.vim'
  sh '$(brew --prefix nvim)/bin/nvim +PlugInstall +qall'

  # tmux
  sh <<~EOF
    [ -d ~/.tmux/plugins/tpm ] && pushd ~/.tmux/plugins/tpm && git pull --rebase && popd
    [ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    rm -f ~/.tmux.conf && cp ./files/.tmux.conf ~/.tmux.conf
  EOF

  # vscode initial settings
  require 'json'
  vscode_settings_gist_id = '3248cc6252d7fdda40a46e29a7f11c86'
  vscode_settings_path = File.expand_path('~/Library/Application Support/Code/User/settings.json')
  if File.file?(vscode_settings_path)
    vscode_settings = JSON.parse(File.read(vscode_settings_path))
    current_gist_id = vscode_settings['sync.gist']
    if current_gist_id != vscode_settings_gist_id
      vscode_settings['sync.gist'] = vscode_settings_gist_id
      File.write(vscode_settings_path, JSON.pretty_generate(vscode_settings))
    end
  else
    File.write(vscode_settings_path, JSON.pretty_generate({'sync.gist':vscode_settings_gist_id}))
  end
end

desc 'Install and configures programming languages version'
task :langenv do
  go_version = '1.11.4'
  ruby_version = '2.6.2'
  node_version = '11.13.0'

  sh <<~CMD
    goenv install --keep --skip-existing --verbose #{go_version}
    goenv global #{go_version}
    goenv rehash

    rbenv install --keep --skip-existing --verbose #{ruby_version}
    rbenv global #{ruby_version}
    rbenv rehash

    nodenv install --keep --skip-existing --verbose #{node_version}
    nodenv global #{node_version}
    npm install -g yarn
    nodenv rehash
  CMD

  # python virtualenv
  sh '$(brew --prefix python3)/bin/pip3 install virtualenvwrapper'
end

packages = [
  'rbenv',
  'goenv',
  'nodenv',
  'python@2',
  'python3',
  'ctags',
  'coreutils',
  'findutils',
  'diffutils',
  'wget',
  'gzip',
  'grep',
  'bash',
  'less',
  'jq',
  'make',
  'cmake',
  'tree',
  'libsodium',
  'nvim',
  'rsync',
  'openssl',
  'postgresql@9.6',
  'postgresql@11', # latest version for cli
  'homebrew/cask-drivers/logitech-options',
  'elixir',
  'the_silver_searcher',
  'tmux',
  'stubby',
]

cask_packages = [
  'java8',
  'visual-studio-code',
  'dbeaver-community',
  'sublime-text',
  'google-chrome',
  'google-backup-and-sync',
  'spectacle',
  'iterm2',
  'docker',
  'tunnelblick',
  'sourcetree',
  'google-cloud-sdk',
  'vagrant',
]

# these packages do not have pinned version so they are always asking to be updated
cask_packages_to_update = cask_packages - ['google-backup-and-sync', 'google-cloud-sdk']

desc 'Install dotfiles'
task :install do
  # xcode
  sh 'xcode-select -p || xcode-select --install'

  # brew
  sh <<~CMD
    [ -d /usr/local/Homebrew ] || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew analytics off
    brew update
    brew upgrade
  CMD

  # zsh
  sh 'brew install zsh'
  sh '[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"'
  sh <<~CMD
  if ! grep -i -q $(brew --prefix zsh)/bin/zsh /etc/shells; then
    echo $(brew --prefix zsh)/bin/zsh | sudo tee -a /etc/shells
    chsh -s $(which zsh) $USER
  fi
  CMD

  sh "brew install #{packages.join(' ')}"
  sh "brew cask install #{cask_packages.join(' ')}"

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute

  puts "Now you'll need to restart your shell"
end

desc 'Upgrade packages'
task :upgrade do
  sh "brew upgrade"
  sh "brew cask upgrade --greedy #{cask_packages_to_update.join(' ')}"
end

desc 'Install work related dotfiles only'
task :work do
  sh 'rm -f ~/.more/work_profile && cp ./files/work/work_profile ~/.more/'

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute
  puts "Now you'll need to restart your shell"
end

desc 'Setup dns over tls'
task :dns do
  version = '1.4.0'
  dir = '/opt/coredns'
  binary = "#{dir}/coredns"
  config = "#{dir}/config"
  binary_url = "https://github.com/coredns/coredns/releases/download/v#{version}/coredns_#{version}_darwin_amd64.tgz"

  sh <<~EOF
    sudo mkdir -p #{dir}
    sudo chown root  #{dir}
    sudo chmod 755 #{dir}

    if [[ -f #{binary} ]]; then
      if [[ $(#{binary} -version | grep #{version}) ]]; then
        echo 'already installed'
        exit 0
      fi
    fi

    pushd /tmp
      if [[ ! -f coredns_#{version}_darwin_amd64.tgz ]]; then
        wget #{binary_url}
      fi
      if [[ ! -f coredns ]]; then
        tar -xzvf coredns_#{version}_darwin_amd64.tgz
      fi

      sudo rm -f #{binary}
      sudo mv coredns #{dir}
      sudo chown root #{binary}
      sudo chmod 755 #{binary}
    popd

    sudo rm -f #{config}
    sudo cp files/coredns/config #{config}
    sudo chown root #{config}
    sudo chmod 755 #{config}
    sudo cp files/coredns/io.coredns.coredns.plist /Library/LaunchDaemons

    sudo rm -f /etc/newsyslog.d/coredns.conf
    sudo cp files/coredns/coredns.conf /etc/newsyslog.d
  EOF

  puts "Now you need to set your dns to 127.0.0.1"
end
