require_relative 'lib.rb'

desc 'Install configuration files'
task :configfiles do
  [
    '.zshrc',
    '.global_gitignore',
    '.terraformrc',
  ].each do |file|
    sh "rm -f ~/#{file} && cp ./files/#{file} ~/"
  end

  sh 'mkdir -p ~/.more'
  render_tpl 'files/profiles/pg_profile.erb', "#{ENV['HOME']}/.more/pg_profile"
  render_tpl 'files/profiles/gnu_profile.erb', "#{ENV['HOME']}/.more/gnu_profile"
  render_tpl 'files/profiles/python_profile.erb', "#{ENV['HOME']}/.more/python_profile"
  render_tpl 'files/profiles/libraries.erb', "#{ENV['HOME']}/.more/libraries_profile"

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
  go_version = '1.13.4'
  ruby_version = '2.7.0'
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
  'packer',
  'shellcheck',
  'terraform',
  'tflint',
  'rbenv',
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
  'postgresql', # latest version for cli
  'redis',
  'homebrew/cask-drivers/logitech-options',
  'the_silver_searcher',
  'tmux',
  's3cmd',
  'plantuml',
  'direnv',
  'php',
  'ifstat',
  'gnu-sed',
]

# packages to be installed on HEAD
head_packages = [
  'goenv'
]

cask_packages = [
  'java',
  'visual-studio-code',
  'sublime-text',
  'google-backup-and-sync',
  'spectacle',
  'iterm2',
  'docker',
  'tunnelblick',
  'sourcetree',
  'google-cloud-sdk',
  'vagrant',
  'spotify',
  'bitbar',
  'smcfancontrol', # needed for bitbar
]

ruby_tools = ['rubocop', 'rufo', 'rcodetools', 'solargraph']

# these packages do not have pinned version so they are always asking to be updated
cask_packages_to_update = cask_packages - ['google-backup-and-sync', 'google-cloud-sdk', 'visual-studio-code', 'spotify']

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
  sh "brew install --HEAD #{head_packages.join(' ')}"
  sh "brew cask install #{cask_packages.join(' ')}"

  # latest virtualbox doesn't work with vagrant
  sh 'brew cask install https://raw.githubusercontent.com/Homebrew/homebrew-cask/e7426e2dbc67958d8b68920464ec1c8507d30a2f/Casks/virtualbox.rb'

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute

  sh "gem install --bindir ~/.bin #{ruby_tools.join(' ')}"

  puts "Now you'll need to restart your shell"
end

desc 'Upgrade packages'
task :upgrade do
  sh "brew upgrade"
  sh "brew upgrade --fetch-HEAD #{head_packages.join(' ')}"
  sh "brew cask upgrade --greedy #{cask_packages_to_update.join(' ')}"
  sh 'brew cask upgrade'

  sh "gem update --bindir ~/.bin #{ruby_tools.join(' ')}"
end

desc 'Install personal related dotfiles only'
task :me do
  render_tpl 'files/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"
end

desc 'Install work related dotfiles only'
task :work do
  sh 'rm -f ~/.more/work_profile && cp ./files/work/work_profile ~/.more/'
  render_tpl 'files/work/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute
  puts "Now you'll need to restart your shell"
end

desc 'Setup bitbar plugins'
task :bitbar do
  sh <<~EOF
    mkdir -p ~/.bitbar
    cd ~/.bitbar
    rm -f *

    wget https://raw.githubusercontent.com/matryer/bitbar-plugins/master/System/mtop.5s.sh
    wget https://raw.githubusercontent.com/matryer/bitbar-plugins/master/Network/bandwidth_primary.1s.sh
    wget https://raw.githubusercontent.com/matryer/bitbar-plugins/master/System/fan-speed.5s.sh

    chmod +x *
  EOF
end

desc 'Sysctl tweak'
task :sysctl do
  sh <<~EOF
    sudo rm -f /Library/LaunchDaemons/limit.maxfiles.plist && sudo cp ./files/limit.maxfiles.plist /Library/LaunchDaemons/limit.maxfiles.plist
    sudo launchctl load /Library/LaunchDaemons/limit.maxfiles.plist

    sudo rm -f /Library/LaunchDaemons/limit.maxproc.plist && sudo cp ./files/limit.maxproc.plist /Library/LaunchDaemons/limit.maxproc.plist
    sudo launchctl load /Library/LaunchDaemons/limit.maxproc.plist
  EOF
end
