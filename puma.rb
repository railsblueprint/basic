#!/usr/bin/env puma

environment "production"

app_dir = "/home/deploy/blueprint/production/basic/current"

directory app_dir
rackup "#{app_dir}/config.ru"

pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"
stdout_redirect "#{app_dir}/log/puma_access.log", "#{app_dir}/log/puma_error.log", true
bind "unix://#{app_dir}/tmp/sockets/puma.sock"

threads 0,16

#workers 0




restart_command "bundle exec puma"


prune_bundler


on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end

