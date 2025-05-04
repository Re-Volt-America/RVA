# frozen_string_literal: true

lock '~> 3.18'

require 'capistrano/bundler'
require 'rvm1/capistrano3'

set :application, 'RVA'
set :repo_url, 'git@github.com:Re-Volt-America/RVA.git'
set :branch, 'production'
set :user, 'rva'
set :stages, %w(production)
set :deploy_to, '/home/rva/RVA'
set :linked_files, %w(config/secrets.yml)
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
set :assets_roles, [:web, :app]
set :assets_manifests, ['app/assets/config/manifest.js']
set :rails_assets_groups, :assets
set :normalize_asset_timestamps, %w(public/images public/javascripts public/stylesheets)
set :keep_assets, 2

namespace :yarn do
  task :install do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, 'yarn:install'
        end
      end
    end
  end
end

after 'bundler:install', 'yarn:install'
