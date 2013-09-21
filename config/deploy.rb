require 'rvm/capistrano'                               # Load RVM's capistrano plugin.
require 'puma/capistrano'
require 'delayed/recipes'
# Current version of delayed_job still expects script to be located in script folder
set :delayed_job_command, 'bundle exec bin/delayed_job'


# RVM bootstrap
set :rvm_ruby_string,  'ruby-2.0.0-p247@radiobox2'
set :puma_config_file, 'config/puma.rb'
set :rails_env,        'production' #added for delayed job

set :rvm_type, :system

# bundler bootstrap
require 'bundler/capistrano'

# main details
set :application, 'radiobox2'
role :web,        'patrickbaselier.nl'
role :app,        'patrickbaselier.nl'
role :db,         'patrickbaselier.nl', :primary => true

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to,   '/var/www/radiobox2'
set :deploy_via,  :remote_cache
set :user,        'passenger'
set :use_sudo,    false

# repo details
set :scm, :git
set :scm_username,          'passenger'
set :repository,            'git@github.com:bazzel/radiobox2.git'
set :branch,                'master'
set :git_enable_submodules, 1

# tasks
namespace :deploy do
  task :start, :roles => :app do
    #run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
  end

  desc "Initiate first delayed_job"
  task :restart, :roles => :app do
    run "cd #{current_path} && bundle exec rails r -e #{rails_env} 'Song.populate'"
  end

  desc "Symlink shared resources on each release - not used"
  task :symlink_shared, :roles => :app do
    #run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:restart',     'deploy:cleanup'
after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:stop',        'delayed_job:stop'
after 'deploy:start',       'delayed_job:start'
after 'deploy:restart',     'delayed_job:restart'

load 'deploy/assets'
