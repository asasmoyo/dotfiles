require_relative 'lib.rb'

user = 'personal'

VERSIONS = {
  'ruby' => '2.6.0',
  'go' => '1.11.4',
  'node' => '10.15.0',
  'postgres' => '9.6',
  'postgres-cli' => '11',
}

task :config do
  [
    '.zshrc',
    '.global_gitignore',
  ].each do |file|
    sh <<~CMD
      rm -f ~/#{file} && cp ./files/#{file} ~/
    CMD
  end
  sh 'mkdir -p ~/.more'
  sh 'rm -f ~/.more/work_profile && cp ./files/work_profile ~/.more/'
  render_tpl 'files/.gitconfig.erb', "#{ENV['HOME']}/.gitconfig"
end

task :common do
  sh '[ -d ~/.oh-my-zsh ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"'
  puts "you'll need to run 'chsh -s $(which zsh)' to make zsh as your default shell"

  sh <<~CMD
    goenv install --keep --skip-existing --verbose #{VERSIONS['go']}
    goenv global #{VERSIONS['go']}
    rbenv install --keep --skip-existing --verbose #{VERSIONS['ruby']}
    rbenv global #{VERSIONS['ruby']}
    nodenv install --keep --skip-existing --verbose #{VERSIONS['node']}
    nodenv global #{VERSIONS['node']}
  CMD
end

task :run do
  sh 'xcode-select -p || xcode-select --install'

  sh <<~CMD
    [ -d /usr/local/Homebrew ] || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew update
    brew analytics off
    brew install zsh
  CMD

  # install packages
  sh 'brew update'
  taps = ['caskroom/versions']
  taps.each do |tap|
    sh "brew tap #{tap}"
  end

  pkgs = [
    'rbenv',
    'goenv',
    'nodenv',
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
    'postgresql@9.6',
    'postgresql@11',
    'php', # :(
  ]
  pkgs.each do |pkg|
    sh "brew install #{pkg}"
  end

  # casks
  [
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
  ].each do |cask|
    sh "brew cask install #{cask}"
  end

  # install scroll reverser from github release
  scroll_reverser_url = 'https://github.com/pilotmoon/Scroll-Reverser/releases/download/1.7.6/ScrollReverser-1.7.6.zip'
  Dir.chdir('/tmp') do
    sh <<~CMD
      if [ ! -d /Applications/Scroll\\ Reverser.app ]; then
        wget #{scroll_reverser_url} -O scroll-reverser.zip
        unzip scroll-reverser.zip
        mv Scroll\\ Reverser.app ~/Applications
      fi
    CMD
  end
end
