require_relative 'lib.rb'

VERSIONS = {
  'ruby' => '2.5.1',
  'go' => '1.11.1',
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
  CMD
  puts "you'll need to run 'chsh -s $(which zsh)' to make zsh as your default shell"
end

desc 'Installed tracked files'
task :scripts do
  [
    '.zshrc',
    '.brew_profile',
    '.workrc',
    '.global_gitignore',
    '.gnu_profile',
  ].each do |file|
    sh <<~CMD
      rm -f ~/#{file} && cp ./files/#{file} ~/
    CMD
  end
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
    'python',
    'tree',
  ]
  pkgs.each do |pkg|
    sh "brew install #{pkg}"
  end

  # casks
  ['java8', 'visual-studio-code', 'dbeaver-community', 'sublime-text', 'google-chrome', 'google-backup-and-sync', 'spectacle'].each do |cask|
    sh "brew cask install --appdir=\"~/Applications\" #{cask}"
  end

  pips = [
    'chkcrontab'
  ]
  pips.each do |pip|
    sh "pip install --user #{pip}"
  end

  # configure go and ruby
  sh <<~CMD
    goenv install --keep --skip-existing --verbose #{VERSIONS['go']}
    rbenv install --keep --skip-existing --verbose #{VERSIONS['ruby']}
  CMD
end

desc 'Setup work stuff'
task :work do
  ["postgresql@#{VERSIONS['postgres']}", 'redis'].each do |pkg|
    sh "brew install #{pkg}"
  end
  sh 'brew services list'

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
  sh "brew services restart postgresql@#{VERSIONS['postgres']}"
end