# frozen_string_literal: true

lock '~> 3.18'

set :application, 'RVA'
set :repo_url, 'git@github.com:Re-Volt-America/RVA.git'
set :branch, 'production'
set :user, 'rva'
set :stages, %w(production)
set :deploy_to, '/home/rva/RVA'
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle .bundle public/system public/uploads)
set :linked_files, %w(.env)
set :pty, true

namespace :app do
  task :set_permissions do
    on roles(:app) do
      execute :sudo, "chmod -R 777 #{shared_path}"
    end
  end

  task :restart do
    on roles(:app) do
      execute :sudo, '/bin/systemctl restart rva.service'
    end
  end
end

after 'deploy', 'app:restart'
