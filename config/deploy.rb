# frozen_string_literal: true

lock '~> 3.18'

require 'capistrano/bundler'
require 'rvm1/capistrano3'

set :application, 'RVA'
set :repo_url, 'git@github.com:Re-Volt-America/RVA.git'
set :branch, 'production'
set :user, 'deploy'
set :stages, %w(production)
set :deploy_to, '/home/deploy/RVA'
set :linked_dirs, %w(.bundle log tmp/pids tmp/cache tmp/sockets vendor/bundle .bundle public/system public/uploads)
set :pty, true
set :rvm1_ruby_version, '3.2.2'

namespace :app do
  task :update_rvm_key do
    execute :gpg, '--keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3'
  end

  task :restart do
    on roles(:app) do
      execute :sudo, '/bin/systemctl restart rva.service'
    end
  end
end

before 'rvm1:install:rvm', 'app:update_rvm_key'
after 'deploy', 'app:restart'

set :rails_env, 'production'
set :migration_role, :app
set :migration_servers, -> { primary(fetch(:migration_role)) }
set :migration_command, 'db:migrate'
set :conditionally_migrate, true
set :assets_roles, [:web, :app]
set :assets_manifests, ['app/assets/config/manifest.js']
set :rails_assets_groups, :assets
set :normalize_asset_timestamps, %w(public/images public/javascripts public/stylesheets)
set :keep_assets, 2
