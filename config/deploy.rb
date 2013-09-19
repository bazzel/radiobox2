# RVM bootstrap
set :rvm_ruby_string, 'ruby-2.0.0-p247@radiobox2'
require 'rvm/capistrano'                               # Load RVM's capistrano plugin.
require 'puma/capistrano'
set :puma_config_file, 'config/puma.rb'

# When using whenever gem:
# set :whenever_command, "bundle exec whenever"
# require 'whenever/capistrano'

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
#set :branch, 'master'
set :branch,                'feature-capistrano'
set :git_enable_submodules, 1

# tasks
namespace :deploy do
  task :start, :roles => :app do
    #run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    #run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Symlink shared resources on each release - not used"
  task :symlink_shared, :roles => :app do
    #run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:restart',     'deploy:cleanup'
after 'deploy:update_code', 'deploy:symlink_shared'

load 'deploy/assets'
