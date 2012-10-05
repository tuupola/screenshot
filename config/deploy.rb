set :application, "screenshot2"
set :repository, "git@github.com:tuupola/#{application}.git"
set :user, "sinatra"
set :server, "#{application}.taevas.com"
set :domain, "#{user}@#{server}"
set :deploy_to, "/srv/www/#{server}"
set :remote_port, 4567
set :local_port, 9393

require "vlad"

namespace :vlad do
  desc "Deploy the code and restart the server"
  task :deploy => [:update, :start_app]  
end

namespace :dev do
  task :start_shotgun do
    system "shotgun --port=#{local_port} rackup.ru"
  end

  desc "Start ssh tunnel between #{server}:#{remote_port} and localhost:#{local_port}"
  task :start_tunnel do
    puts "Tunneling  #{server}:#{remote_port} to localhost:#{local_port}"
    system "autossh -M 48484 -nNT -g -R *:#{remote_port}:127.0.0.1:#{local_port} #{server}"
  end

  remote_task :symlink do
    puts "Symlinking shared/htaccess to current/public/.htaccess"
    run "ln -f -s #{shared_path}/htaccess #{current_release}/public/.htaccess"
  end

  desc "Switch to tunneled development mode."
  multitask :start => [ "dev:symlink", "dev:start_shotgun", "dev:start_tunnel" ]
end