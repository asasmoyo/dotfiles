require_relative 'lib.rb'

VERSIONS = {
  'ruby' => '2.5.3',
  'go' => '1.11.1',
  'node' => '8.2.0',
  'postgres' => '9.6',
}

desc 'Install XCode command line tools'
task :xcode do
  sh 'xcode-select -p || xcode-select --install'
end

desc 'Install and configure brew'
task :base do
  sh <<~CMD
    [ -d ~/.homebrew ] || git clone https://github.com/Homebrew/brew ~/.homebrew
    [ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    rm -f ~/.brew_profile && cp ./files/.brew_profile ~/
    source ~/.brew_profile
    brew update
    brew analytics off
    brew install zsh
    mkdir -p ~/more.d
    sudo mkdir -p /usr/local/lib
    sudo chown -R root:wheel /usr/local/lib
    sudo chmod -R 755 /usr/local/lib
  CMD
  puts "you'll need to run 'chsh -s $(which zsh)' to make zsh as your default shell"
end

desc 'Installed tracked files'
task :scripts do
  # ~/
  [
    '.zshrc',
    '.global_gitignore',
    '.brew_profile',
  ].each do |file|
    sh <<~CMD
      rm -f ~/#{file} && cp ./files/#{file} ~/
    CMD
  end

  # ~/more.d
  sh 'rm -f ~/more.d/work_profile && cp ./files/work_profile ~/more.d/'
  openssl_bin = %x( brew --prefix openssl ).strip
  grep_bin = %x( brew --prefix grep ).strip
  gnu_profile = <<~EOF
    export PATH=#{openssl_bin}/bin:#{grep_bin}/libexec/gnubin:$PATH
  EOF
  File.write("#{ENV['HOME']}/more.d/gnu_profile", gnu_profile)

  render_tpl 'files/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"
end

desc 'Install some packages'
task :packages do
  # install packages
  sh 'brew update'

  taps = [
    'caskroom/versions'
  ]
  taps.each do |tap|
    sh "brew tap #{tap}"
  end

  pkgs = [
    'rbenv',
    'goenv',
    'nodenv',
    'coreutils',
    'findutils',
    'binutils',
    'diffutils',
    'wget',
    'gzip',
    'grep',
    'bash',
    'less',
    'jq',
    'make',
    'zlib', # needed for python2
    'python2',
    'python',
    'tree',
    'libsodium',
  ]
  pkgs.each do |pkg|
    sh "brew install #{pkg}"
  end

  # link libsodium
  libsodium_dir = %x( brew --prefix libsodium ).strip
  sh <<~EOF
    sudo ln -sf #{libsodium_dir}/lib/libsodium.dylib /usr/local/lib/libsodium.dylib
  EOF

  # casks
  ['java8', 'visual-studio-code', 'dbeaver-community', 'sublime-text', 'google-chrome', 'google-backup-and-sync', 'spectacle', 'iterm2'].each do |cask|
    sh "brew cask install --appdir=\"~/Applications\" #{cask}"
  end
  sh <<~CMD
    if [ ! -d ~/Applications/Docker.app ]; then
      brew cask install docker
      sudo chown -R root ~/Applications/Docker.app
    fi
  CMD
  sh <<~CMD
    if [ ! -d /Applications/Tunnelblick.app ]; then
      brew cask install tunnelblick
      sudo chown -R root /Applications/Tunnelblick.app
    fi
  CMD
  # install scroll reverser from github release
  scroll_reverser_url = 'https://github.com/pilotmoon/Scroll-Reverser/releases/download/1.7.6/ScrollReverser-1.7.6.zip'
  Dir.chdir('/tmp') do
    sh <<~CMD
      if [ ! -d ~/Applications/Scroll\\ Reverser.app ]; then
        wget #{scroll_reverser_url} -O scroll-reverser.zip
        unzip scroll-reverser.zip
        mv Scroll\\ Reverser.app ~/Applications
      fi
    CMD
  end

  sh <<~CMD
    goenv install --keep --skip-existing --verbose #{VERSIONS['go']}
    goenv global #{VERSIONS['go']}
    rbenv install --keep --skip-existing --verbose #{VERSIONS['ruby']}
    rbenv global #{VERSIONS['ruby']}
    nodenv install --keep --skip-existing --verbose #{VERSIONS['node']}
    nodenv global #{VERSIONS['node']}
  CMD
end

desc 'Setup work stuff'
task :work do
  pips = [
    'chkcrontab'
  ]
  pips.each do |pip|
    sh "pip3 install --user #{pip}"
  end

  sh 'brew install packer'

  ["postgresql@#{VERSIONS['postgres']}", 'redis'].each do |pkg|
    sh "brew install #{pkg}"
    sh "brew services start #{pkg}"
  end

  # configure postgres
  pg_data = "#{ENV['HOME']}/.homebrew/var/postgresql@#{VERSIONS['postgres']}"
  pg_hba = <<~EOF
    local all all trust
    host all all 127.0.0.1/32 trust
    host all all ::1/128 trust
  EOF
  File.write("#{pg_data}/pg_hba.conf", pg_hba)
  pg_conf_file = "#{pg_data}/postgresql.conf"
  sh <<~EOF
    mkdir -p #{pg_data}/conf.d && chmod -R 700 #{pg_data}/conf.d
    grep -q "include_dir = 'conf.d'" #{pg_conf_file} || echo "include_dir = 'conf.d'" >> #{pg_conf_file}
  EOF
  work_conf = <<~EOF
    bytea_output = 'escape'
    datestyle = 'iso, mdy'
    default_text_search_config = 'pg_catalog.english'
    timezone = 'UTC'
    lc_messages = 'en_US.UTF-8'                     # locale for system error message
    lc_monetary = 'en_US.UTF-8'                     # locale for monetary formatting
    lc_numeric = 'en_US.UTF-8'                      # locale for number formatting
    lc_time = 'en_US.UTF-8'                         # locale for time formatting
  EOF
  File.write("#{pg_data}/conf.d/work.conf", work_conf)
  sh "brew services restart postgresql@#{VERSIONS['postgres']}"
  pg_bin_path = %x( brew --prefix postgresql@#{VERSIONS['postgres']} ).strip
  pg_path_env = <<~EOF
    export PATH=#{pg_bin_path}/bin:$PATH
  EOF
  File.write("#{ENV['HOME']}/more.d/postgres_profile", pg_path_env)
end
