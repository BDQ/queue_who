require "bundler/capistrano"
#load 'deploy/assets'

set :application, "queue_who"
set :user, 'spree'
set :group, 'www-data'
set :rails_env, 'production'

role :web, '198.61.167.137'
role :app, '198.61.167.137'
role :db,  '198.61.167.137', :primary => true

set :scm, :git
set :repository,  "git@github.com:BDQ/queue_who.git"
set :branch,      "master"
set :deploy_to,   "/data/#{application}"
set :deploy_via,  :remote_cache
set :use_sudo,    false

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }

namespace :foreman do
  desc "Export the Procfile to Bluepill's .pill script"
  task :export, :roles => :app do
    run "cd #{current_path} && bundle exec foreman export bluepill /data/#{application}/shared/config"
    sudo "bluepill load /data/#{application}/shared/config/#{application}.pill"
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "bluepill #{application} start"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "bluepill #{application} stop"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    sudo "bluepill #{application} restart"
  end
end

namespace :deploy do
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/Procfile #{release_path}/Procfile"
    run "ln -nfs #{shared_path}/config/.foreman #{release_path}/.foreman"
  end
end

# before 'deploy:assets:precompile', 'deploy:symlink_shared'
after 'deploy:update_code', 'deploy:symlink_shared'

before 'deploy:start', 'foreman:export'
after 'deploy:start', 'foreman:start'

before 'deploy:restart', 'foreman:export'
after 'deploy:restart', 'foreman:restart'
