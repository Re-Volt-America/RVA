# frozen_string_literal: true

require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/scm/git'
require 'capistrano/rails'

require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'rvm1/capistrano3'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
