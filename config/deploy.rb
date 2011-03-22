# deploy.rb
role :app, "sgtc-svr108.stanford.edu"
role :web, "sgtc-svr108.stanford.edu"
#role :db,  "hjdb.stanford.edu", :primary => true

set :user, "sgrimes"
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true

set :deploy_to, "/opt/rails/iscc_rnaseq"
set :deploy_via, :remote_cache
set :use_sudo, true

set :scm, "git"
set :repository, "git@github.com:suegrimes/ISCC_LIMS.git"
set :branch, "master"
set :git_shallow_clone, 1
set :deploy_via, :remote_cache

namespace :deploy do
#  desc "Tell Passenger to restart the app."
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "touch #{current_path}/tmp/restart.txt"
#    end
#  [:start, :stop].each do |t|
#    desc "#{t} task is a no-op with mod_rails"
#    task t, :roles => :app do ; end
#    end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
  end
  
#  desc "Sync the public/assets directory."
#  task :assets do
#    system "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{application}:#{shared_path}/"
#  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
