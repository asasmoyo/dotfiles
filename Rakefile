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
  render_tpl 'files/pg_profile.erb', "#{ENV['HOME']}/.more/pg_profile"
  render_tpl 'files/gnu_profile.erb', "#{ENV['HOME']}/.more/gnu_profile"
  render_tpl 'files/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"
end

desc 'Install and configures programming languages version'
task :langenv do
  go_version = '1.11.4'
  ruby_version = '2.6.0'
  node_version = '10.15.0'

  sh <<~CMD
    goenv install --keep --skip-existing --verbose #{go_version}
    goenv global #{go_version}

    rbenv install --keep --skip-existing --verbose #{ruby_version}
    rbenv global #{ruby_version}

    nodenv install --keep --skip-existing --verbose #{node_version}
    nodenv global #{node_version}
  CMD

  # python virtualenv
  sh '$(brew --prefix python3)/bin/pip3 install virtualenvwrapper'
end

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

  # some packages
  pkgs = [
    'rbenv',
    'goenv',
    'nodenv',
    'python3',
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
    'tree',
    'libsodium',
    'nvim',
    'openssl',
    'postgresql@9.6',
    'postgresql@11', # latest version for cli
    'homebrew/cask-drivers/logitech-options',
  ]
  sh "brew install #{pkgs.join(' ')}"

  # more packages
  pkgs = [
    'java8',
    'visual-studio-code-insiders',
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
  sh "brew cask install #{pkgs.join(' ')}"

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute

  puts "Now you'll need to restart your shell"
end

desc 'Install work related dotfiles only'
task :work do
  sh 'rm -f ~/.more/work_profile && cp ./files/work_profile ~/.more/'

  Rake::Task['langenv'].execute
  Rake::Task['configfiles'].execute
  puts "Now you'll need to restart your shell"
end
